function pj --description 'Jump to a git repository'
    # Declared first, so a global _flag_ variable isn't read when its flag isn't given.
    set -l _flag_help
    set -l _flag_version
    set -l _flag_open

    # open is a subcommand only with a keyword after it, so a bare pj open still searches.
    # Checked before argparse drops --, so pj -- open foo searches for both keywords.
    if test "$argv[1]" = open; and set -q argv[2]
        set _flag_open open
        set -e argv[1]
    end

    argparse h/help v/version o/open -- $argv
    or return

    if set -q _flag_help[1]
        __pj_help pj
        return
    end

    if set -q _flag_version[1]
        __pj_version pj
        return
    end

    # No --exclude, so like pjo it opens the best match even from inside it.
    if set -q _flag_open[1]
        set -l dir (__pj_resolve --name=pj -- $argv); or return
        __pj_open --name=pj -- $dir
        return
    end

    # Excludes where you are, so jumping again moves on to the next match like zoxide does.
    set -l dir (__pj_resolve --name=pj --exclude=$PWD -- $argv); or return
    cd $dir
end
