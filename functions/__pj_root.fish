function __pj_root
    if set -q pj_root[1]
        path normalize -- $pj_root
    else if set -q PROJECT_PATHS[1]
        # A missing directory is dropped here, since the first root is what labels are relative to.
        path normalize -- $PROJECT_PATHS | path filter -d
    else if command -q ghq
        # command -q only looks at PATH, so a function named ghq would run here without command.
        command ghq root --all
    else if command -q ghr
        command ghr path
    else if command -q gogh
        command gogh roots list
    else
        set -l dir $XDG_PROJECTS_DIR
        if test -z "$dir"
            # xdg-user-dirs writes it to user-dirs.dirs, which shells don't usually source.
            set -l config ~/.config
            test -n "$XDG_CONFIG_HOME"; and set config $XDG_CONFIG_HOME
            test -r $config/user-dirs.dirs
            and set dir (string match -rg '^XDG_PROJECTS_DIR="(.*)"' <$config/user-dirs.dirs | string replace '$HOME' $HOME)
        end

        # xdg-user-dirs-update points a directory at $HOME once it's been removed.
        set dir (path normalize -- "$dir")
        if test -z "$dir"; or test "$dir" = $HOME
            set dir $HOME/Projects
        end
        echo $dir
    end 2>/dev/null
end
