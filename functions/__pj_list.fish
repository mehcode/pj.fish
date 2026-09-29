function __pj_list
    begin
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
    end | awk '!seen[$0]++' | while read -l dir
        # A main worktree has a .git directory; linked worktrees have a .git file.
        test -d "$dir/.git"; and echo $dir
    end
end
