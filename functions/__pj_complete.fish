function __pj_complete
    set -l dirs (__pj_list)

    # fish reads a token ending in a lone backslash without it, while string unescape refuses it.
    set -l token (commandline -ct)
    set -l word (string unescape -- "$token"; or string unescape -- (string sub -e -1 -- "$token"))

    # A path is read the way pj reads one, so ./src is from where you are and foo/ is a keyword.
    set -l expanded (commandline --input=$token --tokens-expanded)
    if string match -qr -- '^(/|\.\.?/)' $expanded
        set -l word_dir (string replace -r -- '[^/]*$' '' $expanded)
        string match -q -- '/*' $word_dir; or set word_dir $PWD/$word_dir
        set word_dir (path normalize -- $word_dir)

        if __pj_is_inside_any $word_dir $dirs
            # fish offers ../ after a . or .., which from the project's own folder leads out of it.
            if __pj_is_inside_any (path dirname -- $word_dir) $dirs
                __fish_complete_directories $token ''
            else
                __fish_complete_directories $token '' | string match -vr -- '/\.\./\t'
            end
            return
        end

        # fish drops candidates that don't match the token as typed, so projects start the way it
        # does, through its last . or .. folder or else its first, like ~ or $HOME. fish matches
        # the rest itself, so ~/m/f offers ~/mehcode/foo.
        set -l start (string match -r -- '^(?:.*/)?\.\.?(?=/)|^[^/]*' $token)
        set -l start_dir (commandline --input=$start/ --tokens-expanded)
        string match -q -- '/*' $start_dir; or set start_dir $PWD/$start_dir
        set -l prefix (string escape --style=regex -- (string trim -r -c / -- (path normalize -- $start_dir))/)

        # string replace reads $ and \ in a replacement, so they're doubled in the start.
        set start (string unescape -- $start | string replace -ra -- '[\\\\$]' '$0$0')
        string replace -rf -- "^$prefix" $start/ $dirs
        return
    end

    # fish matches the word anywhere in the path, parent folders included, so match it on the name
    # unless it holds a /. Like fish, names starting with the word hide names containing it, which
    # hide names holding its letters in order.
    if not string match -q -- '*/*' $word
        set -l subsequence (string split -- '' $word | string escape --style=regex | string join -- '[^/]*')
        set -l pattern (string escape --style=regex -- $word)
        set -l found (string match -eir -- "/$pattern"'[^/]*$' $dirs)
        or set found (string match -eir -- '/[^/]*'"$pattern"'[^/]*$' $dirs)
        or set found (string match -eir -- '/[^/]*'"$subsequence"'[^/]*$' $dirs)
        set dirs $found
    end

    set -l home (string escape --style=regex -- $HOME)
    string replace -r -- "^$home/" '~/' $dirs
end
