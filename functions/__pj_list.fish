function __pj_list
    begin
        zoxide query --list --all
        ghq list --full-path
    end 2>/dev/null | awk '!seen[$0]++' | while read -l dir
        # A main worktree has a .git directory; linked worktrees have a .git file.
        test -d "$dir/.git"; and echo $dir
    end
end
