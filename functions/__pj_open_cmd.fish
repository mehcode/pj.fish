function __pj_open_cmd
    if set -q pj_open_cmd[1]
        printf "%s\n" $pj_open_cmd
        return
    end

    # Try several editors first.
    for cmd in zeditor zed code idea
        if command -q $cmd
            echo $cmd
            return
        end
    end

    # Fallback to $VISUAL, $EDITOR.
    for var in VISUAL EDITOR
        if set -q $var
            echo $$var | read -at cmd
            printf "%s\n" $cmd
            return
        end
    end

    echo 'pjo: No editor found (set pj_open_cmd to your preferred editor)' >&2
    return 1
end
