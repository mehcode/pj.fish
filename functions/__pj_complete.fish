function __pj_complete
    set -l dirs (__pj_list)

    # fish reads a token ending in a lone backslash without it, while string unescape refuses it.
    set -l token (commandline -ct)
    set -l word (string unescape -- "$token"; or string unescape -- (string sub -e -1 -- "$token"))

    # fish matches the word anywhere in the path, parent folders included, so match it on the name
    # unless it's a path. Like fish, names starting with the word hide names containing it, which
    # hide names holding its letters in order.
    if not string match -q -- '*/*' $word
        set -l subsequence (string split -- '' $word | string escape --style=regex | string join -- '[^/]*')
        set word (string escape --style=regex -- $word)
        set -l found (string match -eir -- "/$word"'[^/]*$' $dirs)
        or set found (string match -eir -- '/[^/]*'"$word"'[^/]*$' $dirs)
        or set found (string match -eir -- '/[^/]*'"$subsequence"'[^/]*$' $dirs)
        set dirs $found
    end

    set -l home (string escape --style=regex -- $HOME)
    string replace -r -- "^$home/" '~/' $dirs
end
