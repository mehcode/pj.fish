function __pj_help
    switch $argv[1]
        case pj
            echo 'Usage: pj <keywords>...       Jump to the best match for the keywords'
            echo '       pj <path>              Jump to a project directory'
            echo '       pj                     Pick from every project'
            echo '       pj open <keywords>...  Open the best match in your editor'
        case pjo
            echo 'Usage: pjo <keywords>...  Open the best match for the keywords in your editor'
            echo '       pjo <path>         Open a project directory in your editor'
            echo '       pjo                Pick from every project'
    end
    echo 'Options:'
    echo '       -h, --help     Print this help message'
    echo '       -v, --version  Print the version'
    switch $argv[1]
        case pj
            echo '       -o, --open     Open in your editor'
            echo '       -e, --echo     Print the path'
            echo "       --             Take what follows as arguments, even 'open' or one starting with -"
        case pjo
            echo '       --             Take what follows as arguments, even if it starts with -'
    end
    echo 'Variables:'
    echo '       pj_root       Directories to scan for projects'
    echo "       pj_query_cmd  Command that ranks the directories you've visited"
    echo '       pj_find_cmd   Command that picks a project from a list'
    echo '       pj_open_cmd   Command that opens a project in your editor'
end
