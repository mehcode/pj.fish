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

    # Otherwise pick from every repository, labelled by its path relative to the first root.
    # Given no strings, string replace reads stdin, and gum filter lists the current directory.
    set -l dirs (__pj_list)
    if not set -q dirs[1]
        echo 'pj: No repositories found (set pj_root to your projects directory)' >&2
        return 1
    end

    set -l labels $dirs
    set -l root (__pj_root)[1]
    set -q root[1]; and set labels (string replace -- $root/ '' $dirs)

    # Finders disagree on how they report a cancel, so anything but a label counts as one.
    set -l label (printf '%s\n' $labels | __pj_find $argv)
    set -l i (contains -i -- "$label" $labels); or return 1
    echo $dirs[$i]
end
