function __pj_resolve
    # With keywords, the best repository the query finds wins.
    if set -q argv[1]
        for dir in (__pj_query $argv)
            if test -d "$dir/.git"
                echo $dir
                return
            end
        end
    end

    # Otherwise pick from every repository.
    # Each line is "label<tab>dir", and fzf shows only the the path relative to the ghq root.
    set -l root (ghq root)/
    set -l line (
        for dir in (__pj_list)
            printf '%s\t%s\n' (string replace -- $root '' $dir) $dir
        end | fzf --delimiter \t --with-nth 1 --no-sort --scheme=path \
            --query "$argv" --select-1 --exit-0 \
            --preview 'git -C {2} log --oneline --color -15'
    )
    or return 1

    string split -f 2 \t -- $line
end
