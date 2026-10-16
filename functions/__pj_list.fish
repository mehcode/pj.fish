function __pj_list
    set -l found (
        __pj_query

        # Stop 4 levels down, since a directory that isn't a repository can take seconds to walk.
        # Globs keep the trailing slash, so $dir.git is the directory's own .git.
        set -l dirs (__pj_root)/
        for depth in (seq 4)
            set -l next
            for dir in $dirs*/
                if test -d $dir.git
                    string trim -r -c / -- $dir
                else
                    set -a next $dir
                end
            end
            set dirs $next
        end
    )

    # A main worktree has a .git directory. A linked worktree has a .git file.
    for dir in (path filter -d -- $found/.git | string replace -r -- '/\.git$' '')
        # A variable named after each project marks it seen, since set -q finds one without walking
        # a list. It's set -f because a set -l in the loop is gone by the next pass.
        set -l key __pj_seen_(string escape --style=var -- $dir)
        set -q $key; and continue
        set -f $key
        echo $dir
    end
end
