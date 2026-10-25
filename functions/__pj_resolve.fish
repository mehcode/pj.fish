function __pj_resolve
    # Declared first, so a global _flag_exclude isn't read when the flag isn't given.
    set -l _flag_exclude
    argparse name= exclude= -- $argv
    or return

    # A lone ., .. or argument starting with /, ./ or ../ is a path. Any other word is a keyword,
    # even beside a folder of that name. It's where you asked to go, so --exclude doesn't apply.
    if test (count $argv) -eq 1; and string match -qr -- '^(/|\.\.?(/|$))' $argv[1]
        # Normalized rather than resolved, so a symlink stays in the path the way cd keeps it.
        set -l dir $argv[1]
        string match -q -- '/*' $dir; or set dir $PWD/$dir
        set dir (path normalize -- $dir)

        if not test -d $dir
            echo "$_flag_name: No such directory: $argv[1]" >&2
            return 1
        end
        echo $dir
        return
    end

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
        echo "$_flag_name: No repositories found (set pj_root to your projects directory)" >&2
        return 1
    end

    set -l labels $dirs
    set -l root (__pj_root)[1]
    if set -q root[1]
        set -l prefix (string escape --style=regex -- $root/)
        set labels (string replace -r -- "^$prefix" '' $dirs)
    end

    # Finders disagree on how they report a cancel, so anything but a label counts as one.
    set -l label (printf '%s\n' $labels | __pj_find --name=$_flag_name -- $argv)
    set -l i (contains -i -- "$label" $labels); or return 1
    echo $dirs[$i]
end
