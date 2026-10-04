function __pj_resolve
    # Declared first, so a global _flag_exclude isn't read when the flag isn't given.
    set -l _flag_exclude
    argparse exclude= -- $argv
    or return

    # With keywords, the best repository the query finds wins.
    # The excluded one still wins when it's the only match, so that case never reaches the picker.
    if set -q argv[1]
        set -l best
        for dir in (__pj_query $argv)
            test -d "$dir/.git"; or continue
            set best $dir
            test "$dir" = "$_flag_exclude"; or break
        end
        if set -q best[1]
            echo $best
            return
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
    if set -q root[1]
        set -l prefix (string escape --style=regex -- $root/)
        set labels (string replace -r -- "^$prefix" '' $dirs)
    end

    # Finders disagree on how they report a cancel, so anything but a label counts as one.
    set -l label (printf '%s\n' $labels | __pj_find $argv)
    set -l i (contains -i -- "$label" $labels); or return 1
    echo $dirs[$i]
end
