function pj --description 'Jump to a main git checkout (fzf picker with no arguments)'
    set -l dir (__pj_resolve $argv); or return
    cd $dir
end
