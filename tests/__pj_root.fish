# RUN: fish --no-config %s

set fish_function_path (path resolve (status dirname)/../functions) $fish_function_path
set -g tmp (path resolve (mktemp -d))
set -gx HOME $tmp/home
mkdir -p $HOME/.config $tmp/xdg $tmp/none

# --no-config doesn't stop these coming in from the environment.
set -e pj_root PROJECT_PATHS XDG_CONFIG_HOME XDG_PROJECTS_DIR

# Each directory is used as the whole PATH, so the tools installed on this machine aren't found.
# The function of the same name is never run, so what it prints never shows up below.
for tool in ghq ghr gogh
    mkdir $tmp/$tool
    printf '%s\n' '#!/bin/sh' 'echo "${0##*/} $*"' >$tmp/$tool/$tool
    chmod +x $tmp/$tool/$tool
    function $tool
        echo function (status current-function) $argv
    end
end

function roots
    __pj_root | string replace $tmp '$tmp'
end

set -g pj_root $tmp/src/ $tmp/work/../code
roots
# CHECK: $tmp/src
# CHECK: $tmp/code

mkdir -p $tmp/workspace $tmp/code
set -gx PROJECT_PATHS $tmp/workspace/ $tmp/missing $tmp/src/../code
PATH=$tmp/ghq roots
# CHECK: $tmp/src
# CHECK: $tmp/code
set -e pj_root

# Ahead of every tool and of XDG_PROJECTS_DIR, and a directory that isn't there is left out.
PATH=$tmp/ghq:$tmp/ghr:$tmp/gogh XDG_PROJECTS_DIR=/srv/env roots
# CHECK: $tmp/workspace
# CHECK: $tmp/code

set PROJECT_PATHS
PATH=$tmp/ghq roots
# CHECK: ghq root --all
set -e PROJECT_PATHS

PATH=$tmp/ghq roots
# CHECK: ghq root --all
PATH=$tmp/ghr roots
# CHECK: ghr path
PATH=$tmp/gogh roots
# CHECK: gogh roots list

printf '%s\n' 'XDG_DESKTOP_DIR="$HOME/Desktop"' 'XDG_PROJECTS_DIR="$HOME/Code"' >$HOME/.config/user-dirs.dirs
PATH=$tmp/none roots
# CHECK: $tmp/home/Code

# xdg-user-dirs-update writes this, trailing slash and all, once the directory is gone.
printf '%s\n' 'XDG_PROJECTS_DIR="$HOME/"' >$HOME/.config/user-dirs.dirs
PATH=$tmp/none roots
# CHECK: $tmp/home/Projects

printf '%s\n' 'XDG_PROJECTS_DIR="/srv/projects"' >$tmp/xdg/user-dirs.dirs
PATH=$tmp/none XDG_CONFIG_HOME=$tmp/xdg roots
# CHECK: /srv/projects

PATH=$tmp/none XDG_CONFIG_HOME=$tmp/xdg XDG_PROJECTS_DIR=/srv/env roots
# CHECK: /srv/env

rm $HOME/.config/user-dirs.dirs
PATH=$tmp/none roots
# CHECK: $tmp/home/Projects

rm -rf $tmp
