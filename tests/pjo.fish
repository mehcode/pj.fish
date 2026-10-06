# RUN: fish --no-config %s

set fish_function_path (path resolve (status dirname)/../functions) $fish_function_path
set -g tmp (path resolve (mktemp -d))
set -gx HOME $tmp/home
mkdir -p $HOME $tmp/root/{app,lib}/.git

# The best match is named after the keywords, so pjo opens lib when they don't reach the query.
function query
    printf '%s\n' $tmp/root/$argv $tmp/root/lib
end

function opener
    echo opener: "["$argv"]" | string replace $tmp '$tmp'
end

set -g pj_root $tmp/root
set -g pj_query_cmd query

# Nothing here reaches the picker. This keeps fzf from starting if that ever changes.
set -g pj_find_cmd false
set -g pj_open_cmd opener --new-window

pjo app
# CHECK: opener: [--new-window] [$tmp/root/app]

# pj would move on to lib from here. pjo opens the best match wherever it's run.
cd $tmp/root/app
pjo app
# CHECK: opener: [--new-window] [$tmp/root/app]

rm -rf $tmp
