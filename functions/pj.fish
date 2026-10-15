function pj --description 'Jump to a git repository'
    # Declared first, so a global _flag_help isn't read when the flag isn't given.
    set -l _flag_help
    argparse h/help -- $argv
    or return

    if set -q _flag_help[1]
        __pj_help pj
        return
    end

    # Excludes where you are, so jumping again moves on to the next match like zoxide does.
    set -l dir (__pj_resolve --exclude=$PWD -- $argv); or return
    cd $dir
end
