function __pj_complete --description 'Completion candidates for pj/pjo: repo name, parent dir as description'
    for dir in (__pj_list)
        printf '%s\t%s\n' (path basename $dir) (string replace $HOME '~' (path dirname $dir))
    end
end
