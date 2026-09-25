function __pj_resolve --description 'Resolve keywords to a main git checkout, falling back to fzf'
    if set -q argv[1]
        # Top zoxide match wins, using zoxide's own keyword rules.
        set -l dir (zoxide query --list --all -- $argv 2>/dev/null | while read -l d
            test -d "$d/.git"; and echo $d
        end)[1]
        if test -n "$dir"
            echo $dir
            return
        end
    end

    # No keywords, or nothing zoxide knows: pick from everything, ghq included.
    set -l root (ghq root)/
    set -l dir (__pj_list | string replace $root '' \
        | fzf --no-sort --scheme=path --query "$argv" --select-1 --exit-0 \
            --preview "cd $root && git -C {} log --oneline --color -15")
    or return 1
    string match -q '/*' -- $dir; or set dir $root$dir
    echo $dir
end
