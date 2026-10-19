# RUN: fish --no-config %s

set fish_function_path (path resolve (status dirname)/../functions) $fish_function_path
set -g tmp (path resolve (mktemp -d))
set -gx HOME $tmp/home
mkdir -p $HOME $tmp/none $tmp/zoxide

# --no-config doesn't stop this coming in from the environment.
set -e pj_query_cmd

# Each directory is used as the whole PATH, so the zoxide installed on this machine isn't found.
# zoxide prints one path per line, best first.
printf '%s\n' '#!/bin/sh' 'printf %s "${0##*/}"; printf " [%s]" "$@"; echo' \
    'echo /projects/best; echo "/projects/my app"; echo /projects/gone' >$tmp/zoxide/zoxide
chmod +x $tmp/zoxide/zoxide

# The query runs the executable, so what this prints never shows up below.
function zoxide
    echo /projects/function
end

# Each case adds a tool to the ones before it, so it also shows that tool wins over them.
# With none, nothing is printed on either stream.
PATH=$tmp/none __pj_query foo

# z.lua prints each match as its score padded to nine columns, two spaces and the path, best last.
# The query filters what it prints, so it reports its arguments through a global.
function _zlua
    set -g called _zlua $argv
    printf '%-9s  %s\n' 3 /projects/old 12.5 '/projects/my app' 40 /projects/best
end

PATH=$tmp/none __pj_query foo bar
echo "["$called"]"
# CHECK: /projects/best
# CHECK: /projects/my app
# CHECK: /projects/old
# CHECK: [_zlua] [-l] [foo] [bar]

# z prints each match as its score padded to ten columns, a space and the path, best first.
# The line it writes to stderr checks that the query hides it.
function __z
    set -g called __z $argv
    printf '%-10s %s\n' 40 /projects/best 12.5 '/projects/my app' 3 /projects/old
    echo 'common:    /projects' >&2
end

PATH=$tmp/none __pj_query foo bar
echo "["$called"]"
# CHECK: /projects/best
# CHECK: /projects/my app
# CHECK: /projects/old
# CHECK: [__z] [--list] [foo] [bar]

PATH=$tmp/zoxide __pj_query foo bar
# CHECK: zoxide [query] [--list] [--all] [--] [foo] [bar]
# CHECK: /projects/best
# CHECK: /projects/my app
# CHECK: /projects/gone

rm -rf $tmp
