# RUN: fish --no-config %s

set fish_function_path (path resolve (status dirname)/../functions) $fish_function_path
set -g tmp (path resolve (mktemp -d))
set -gx HOME $tmp/home
mkdir -p $HOME $tmp/root/{app,lib,--help}/.git $tmp/empty

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

# After --, an option is a keyword.
pjo -- --help
# CHECK: opener: [--new-window] [$tmp/root/--help]

# An empty PATH and no editor variables, so the editors installed on this machine aren't found.
set -e pj_open_cmd
PATH=$tmp/empty VISUAL= EDITOR= pjo app
echo $status
# CHECKERR: pjo: No editor found (set pj_open_cmd to your preferred editor)
# CHECK: 1

# Every lookup starts with the query, so a mark it leaves shows whether one was started.
# It can't report on stderr, since __pj_query drops that.
function query
    set -g queried
end

pjo --help
echo $status
# CHECK: Usage: pjo <keywords>...  Open the best match for the keywords in your editor
# CHECK:        pjo                Pick from every project
# CHECK: Options:
# CHECK:        -h, --help  Print this help message
# CHECK:        --          Take what follows as keywords, even if it starts with -
# CHECK: Variables:
# CHECK:        pj_root       Directories to scan for projects
# CHECK:        pj_query_cmd  Command that ranks the directories you've visited
# CHECK:        pj_find_cmd   Command that picks a project from a list
# CHECK:        pj_open_cmd   Command that pjo opens a project with
# CHECK: 0

pjo -h | string match 'Usage:*'
echo $pipestatus[1]
# CHECK: Usage: pjo <keywords>...  Open the best match for the keywords in your editor
# CHECK: 0

# Only the prefix is ours. argparse writes the rest of the message.
pjo --nope
echo $status
# CHECKERR: pjo: {{.*--nope.*}}
# CHECK: 2

set -q queried; or echo not queried
# CHECK: not queried

# query only leaves its mark now, so an empty root leaves nothing to list.
set pj_root $tmp/empty
pjo
echo $status
# CHECKERR: pjo: No repositories found (set pj_root to your projects directory)
# CHECK: 1

# An empty PATH, so the finders installed on this machine aren't found.
set pj_root $tmp/root
set -e pj_find_cmd
PATH=$tmp/empty pjo
echo $status
# CHECKERR: pjo: No fuzzy finder found (set pj_find_cmd to your preferred finder)
# CHECK: 1

rm -rf $tmp
