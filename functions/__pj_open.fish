function __pj_open
    argparse name= -- $argv
    or return

    if set -q pj_open_cmd[1]
        $pj_open_cmd $argv
        return
    end

    # OpenZFS installs its event daemon as zed too, and only Zed's CLI prints "Zed <version>".
    # Ask with --version, since the daemon reads -v as verbose and tries to start.
    if command -q zed; and zed --version 2>/dev/null | string match -q 'Zed *'
        zed $argv
        return
    end

    # Try several editors first.
    for cmd in zeditor code idea
        if command -q $cmd
            $cmd $argv
            return
        end
    end

    # Fallback to $VISUAL, $EDITOR.
    # eval them the way git hands them to sh, so ~ and $HOME in them expand.
    for var in VISUAL EDITOR
        if test -n "$$var"
            eval $$var (string escape -- $argv)
            return
        end
    end

    echo "$_flag_name: No editor found (set pj_open_cmd to your preferred editor)" >&2
    return 1
end
