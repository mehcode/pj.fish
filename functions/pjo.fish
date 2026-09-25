function pjo --description 'Open a main git checkout in Zed (fzf picker with no arguments)'
    set -l dir (__pj_resolve $argv); or return
    zeditor $dir
end
