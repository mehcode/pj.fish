function pjo --description 'Open a git repository in your editor'
    set -l dir (__pj_resolve $argv); or return
    __pj_open $dir
end
