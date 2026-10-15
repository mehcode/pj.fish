# RUN: fish --no-config %s

set fish_function_path (path resolve (status dirname)/../functions) $fish_function_path
set -g tmp (path resolve (mktemp -d))
set -gx HOME $tmp/home
mkdir -p $HOME

# --no-config doesn't stop these coming in from the environment.
set -e pj_find_cmd pj_root

# Reports its name, its arguments and the labels it read, then picks the last label.
printf '%s\n' '#!/bin/sh' 'printf %s "${0##*/}" >&2; printf " [%s]" "$@" >&2; echo >&2' \
    'labels=; while IFS= read -r label; do labels="$labels [$label]"; choice=$label; done' \
    'echo "labels:$labels" >&2; echo "$choice"' >$tmp/finder
# Prints no roots, so with pj_root unset the preview has none to name.
printf '%s\n' '#!/bin/sh' >$tmp/ghq
chmod +x $tmp/finder $tmp/ghq

# Each directory is used as the whole PATH, so the finders installed on this machine aren't found.
# Each holds one finder and the ones it's tried ahead of, so its case also shows that it wins.
set -l finders gum tv sk fzf
for i in 1 2 3 4
    set -l dir $tmp/$finders[$i]
    mkdir $dir
    for finder in $finders[1..$i]
        ln -s $tmp/finder $dir/$finder
    end
    ln -s $tmp/ghq $dir/ghq
end

function labels
    printf '%s\n' app 'my lib' /elsewhere/tool
end

# The root and the query are still passed when they're empty.
for finder in $finders
    labels | PATH=$tmp/$finder __pj_find
end
# CHECKERR: gum [filter] [--no-fuzzy-sort] [--value] [] [--select-if-one]
# CHECKERR: labels: [app] [my lib] [/elsewhere/tool]
# CHECKERR: tv [--no-sort] [--input] [] [--select-1] [--preview-command] [git -C '' -C '{}' log --oneline --color -15]
# CHECKERR: labels: [app] [my lib] [/elsewhere/tool]
# CHECKERR: sk [--no-sort] [--scheme] [path] [--query] [] [--select-1] [--preview] [git -C '' -C {} log --oneline --color -15]
# CHECKERR: labels: [app] [my lib] [/elsewhere/tool]
# CHECKERR: fzf [--no-sort] [--scheme=path] [--query] [] [--select-1] [--exit-0] [--preview] [git -C '' -C {} log --oneline --color -15]
# CHECKERR: labels: [app] [my lib] [/elsewhere/tool]
# CHECK: /elsewhere/tool
# CHECK: /elsewhere/tool
# CHECK: /elsewhere/tool
# CHECK: /elsewhere/tool

# The preview is only handed to the finder, so the roots don't have to exist.
set -g pj_root '/projects/my root' /projects/other
for finder in $finders
    labels | PATH=$tmp/$finder __pj_find foo bar
end
# CHECKERR: gum [filter] [--no-fuzzy-sort] [--value] [foo bar] [--select-if-one]
# CHECKERR: labels: [app] [my lib] [/elsewhere/tool]
# CHECKERR: tv [--no-sort] [--input] [foo bar] [--select-1] [--preview-command] [git -C '/projects/my root' -C '{}' log --oneline --color -15]
# CHECKERR: labels: [app] [my lib] [/elsewhere/tool]
# CHECKERR: sk [--no-sort] [--scheme] [path] [--query] [foo bar] [--select-1] [--preview] [git -C '/projects/my root' -C {} log --oneline --color -15]
# CHECKERR: labels: [app] [my lib] [/elsewhere/tool]
# CHECKERR: fzf [--no-sort] [--scheme=path] [--query] [foo bar] [--select-1] [--exit-0] [--preview] [git -C '/projects/my root' -C {} log --oneline --color -15]
# CHECKERR: labels: [app] [my lib] [/elsewhere/tool]
# CHECK: /elsewhere/tool
# CHECK: /elsewhere/tool
# CHECK: /elsewhere/tool
# CHECK: /elsewhere/tool

rm -rf $tmp
