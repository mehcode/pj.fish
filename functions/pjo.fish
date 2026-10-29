function pjo --description 'Open a project in your editor'
    # Declared first, so a global _flag_help or _flag_version isn't read when its flag isn't given.
    set -l _flag_help
    set -l _flag_version
    argparse h/help v/version -- $argv
    or return

    if set -q _flag_help[1]
        __pj_help pjo
        return
    end

    if set -q _flag_version[1]
        __pj_version pjo
        return
    end

    set -l dir (__pj_resolve --name=pjo -- $argv); or return
    __pj_open --name=pjo -- $dir
end
