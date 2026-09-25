function __pj_complete
    for dir in (__pj_list)
        printf '%s\t%s\n' (path basename $dir) (string replace $HOME '~' (path dirname $dir))
    end
end
