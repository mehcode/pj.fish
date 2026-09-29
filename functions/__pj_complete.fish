function __pj_complete
    set -l home (string escape --style=regex -- $HOME)
    for dir in (__pj_list)
        printf '%s\t%s\n' (path basename $dir) (string replace -r -- "^$home(\$|/)" '~$1' (path dirname $dir))
    end
end
