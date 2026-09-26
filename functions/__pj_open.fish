function __pj_open
    if set -q pj_open_cmd[1]
        $pj_open_cmd $argv
        return
    end

    # Try several editors first.
    for cmd in zeditor zed code idea
        if command -q $cmd
            $cmd $argv
            return
        end
    end

    # Fallback to $VISUAL, $EDITOR.
    for var in VISUAL EDITOR
        if test -n "$$var"
            echo $$var | read -at cmd
            $cmd $argv
            return
        end
    end

    echo 'pjo: No editor found (set pj_open_cmd to your preferred editor)' >&2
    return 1
end
