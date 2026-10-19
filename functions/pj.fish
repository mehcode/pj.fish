function pj --description 'Jump to a git repository'
    # Declared first, so a global _flag_help or _flag_version isn't read when its flag isn't given.
    set -l _flag_help
    set -l _flag_version
    argparse h/help v/version -- $argv
    or return

    if set -q _flag_help[1]
        __pj_help pj
        return
    end

    if set -q _flag_version[1]
        __pj_version pj
        return
    end

    # Excludes where you are, so jumping again moves on to the next match like zoxide does.
    set -l dir (__pj_resolve --name=pj --exclude=$PWD -- $argv); or return
    cd $dir
end
