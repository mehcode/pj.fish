function pjo --description 'Open a git repository in your editor'
    # Declared first, so a global _flag_help isn't read when the flag isn't given.
    set -l _flag_help
    argparse h/help -- $argv
    or return

    if set -q _flag_help[1]
        __pj_help pjo
        return
    end

    set -l dir (__pj_resolve --name=pjo -- $argv); or return
    __pj_open --name=pjo -- $dir
end
