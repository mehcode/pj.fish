function __pj_help
    switch $argv[1]
        case pj
            echo 'Usage: pj <keywords>...  Jump to the best match for the keywords'
            echo '       pj                Pick from every project'
        case pjo
            echo 'Usage: pjo <keywords>...  Open the best match for the keywords in your editor'
            echo '       pjo                Pick from every project'
    end
    echo 'Options:'
    echo '       -h, --help     Print this help message'
    echo '       -v, --version  Print the version'
    echo '       --             Take what follows as keywords, even if it starts with -'
    echo 'Variables:'
    echo '       pj_root       Directories to scan for projects'
    echo "       pj_query_cmd  Command that ranks the directories you've visited"
    echo '       pj_find_cmd   Command that picks a project from a list'
    echo '       pj_open_cmd   Command that pjo opens a project with'
end
