function pj --description 'Jump to a git repository'
    set -l dir (__pj_resolve $argv); or return
    cd $dir
end
