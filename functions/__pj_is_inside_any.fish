function __pj_is_inside_any
    # Walked up as written, so a symlink inside a directory that leads out of it still counts.
    set -l ancestors
    set -l dir $argv[1]
    while test $dir != /
        set -a ancestors $dir
        set dir (path dirname -- $dir)
    end

    # Resolved, so a directory counts however a symlink spells its path.
    set -l dirs (path resolve -- $argv[2..])
    for ancestor in (path resolve -- $ancestors)
        contains -- $ancestor $dirs; and return
    end
    return 1
end
