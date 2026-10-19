function __pj_query
    if set -q pj_query_cmd[1]
        $pj_query_cmd $argv
    else if command -q zoxide
        # command -q only looks at PATH, so a function named zoxide would run here without command.
        command zoxide query --list --all -- $argv
    else if functions -q __z
        # z prints "score path", best first.
        __z --list $argv | string replace -r '^\S+\s+' ''
    else if functions -q _zlua
        # z.lua prints "score path", best last.
        set -l dirs (_zlua -l $argv | string replace -r '^\S+\s+' '')
        for dir in $dirs[-1..1]
            echo $dir
        end
    end 2>/dev/null
end
