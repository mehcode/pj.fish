function __pj_find
    set -l query "$argv"
    if set -q pj_find_cmd[1]
        $pj_find_cmd $query
        return
    end

    # Each line is a repository path, relative to the first root or absolute.
    # git resolves a relative -C against the one before it, so previews work for either.
    set -l root (__pj_root)[1]

    # With no root the quotes still escape to '', and git -C '' stays put.
    set root (string escape -- "$root")

    if command -q fzf
        fzf --no-sort --scheme=path --query $query --select-1 --exit-0 \
            --preview "git -C $root -C {} log --oneline --color -15"
    else if command -q sk
        # sk ignores --select-1 when --exit-0 is also given.
        sk --no-sort --scheme path --query $query --select-1 \
            --preview "git -C $root -C {} log --oneline --color -15"
    else if command -q tv
        # tv doesn't quote placeholders.
        tv --no-sort --input $query --select-1 \
            --preview-command "git -C $root -C '{}' log --oneline --color -15"
    else if command -q gum
        gum filter --no-fuzzy-sort --value $query --select-if-one
    else
        echo 'pj: No fuzzy finder found (set pj_find_cmd to your preferred finder)' >&2
        return 1
    end
end
