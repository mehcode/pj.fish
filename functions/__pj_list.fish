function __pj_list
    # A main worktree has a .git directory. A linked worktree has a .git file.
    set -l found (path filter -d -- (__pj_query)/.git | string replace -r -- '/\.git$' '')

    # Stop 4 levels down, since a directory that isn't a repository can take seconds to walk.
    # Globs keep the trailing slash, so $subdirs.git is each directory's own .git.
    set -l dirs (__pj_root)/
    for depth in 1 2 3 4
        set -l subdirs $dirs*/
        set -a found (path filter -d -- $subdirs.git | string replace -r -- '/\.git$' '')
        test $depth = 4; and break

        # Any .git stops the walk, so it doesn't go into a linked worktree either.
        set dirs (path filter -v -- $subdirs.git | string replace -r -- '\.git$' '')
    end

    # A variable named after each project marks it seen, since set -q finds one without walking
    # a list. It's set -f because a set -l in the loop is gone by the next pass. The names are
    # escaped and unescaped in one call each, since a call per project adds up to milliseconds.
    for key in (string escape --style=var -- $found)
        set -q __pj_seen_$key; and continue
        set -f __pj_seen_$key
        echo $key
    end | string unescape --style=var
end
