# RUN: fish --no-config %s

set fish_function_path (path resolve (status dirname)/../functions) $fish_function_path
set -g tmp (path resolve (mktemp -d))
set -gx HOME $tmp/home
mkdir -p $HOME/bin $tmp/zed $tmp/zfs $tmp/none

# --no-config doesn't stop these coming in from the environment.
set -e pj_open_cmd VISUAL EDITOR

function stub -a file line
    printf '%s\n' '#!/bin/sh' $line >$file
    chmod +x $file
end

# Each directory is used as the whole PATH, so the editors installed on this machine aren't found.
# zfs has OpenZFS's event daemon, which is also installed as zed but isn't Zed's CLI.
stub $tmp/zed/zed 'test "$1" = --version && echo "Zed 0.204.1" || echo "zed $*"'
stub $tmp/zed/code 'echo "code $*"'
stub $tmp/zfs/zed 'test "$1" = --version && echo "zed-2.3.4-1" || echo "zed $*"'
stub $tmp/zfs/code 'echo "code $*"'
stub $HOME/bin/edit 'echo "edit $*"'

PATH=$tmp/zed __pj_open project
# CHECK: zed project

PATH=$tmp/zfs __pj_open project
# CHECK: code project

PATH=$tmp/none VISUAL='~/bin/edit --visual' EDITOR='~/bin/edit --editor' __pj_open project
# CHECK: edit --visual project

PATH=$tmp/none VISUAL= EDITOR='$HOME/bin/edit --editor' __pj_open project
# CHECK: edit --editor project

PATH=$tmp/none VISUAL= EDITOR= __pj_open --name=pjo project
echo $status
# CHECKERR: pjo: No editor found (set pj_open_cmd to your preferred editor)
# CHECK: 1

rm -rf $tmp
