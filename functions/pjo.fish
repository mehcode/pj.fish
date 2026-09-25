function pjo --description 'Open a git repository in your editor'
    set -l cmd (__pj_open_cmd); or return
    set -l dir (__pj_resolve $argv); or return
    $cmd $dir
end
