function pj --description 'Jump to a git repository'
    # Excludes where you are, so jumping again moves on to the next match like zoxide does.
    set -l dir (__pj_resolve --exclude=$PWD -- $argv); or return
    cd $dir
end
