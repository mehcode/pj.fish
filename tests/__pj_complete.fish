# RUN: fish --no-config %s

set fish_function_path (path resolve (status dirname)/../functions) $fish_function_path
set fish_complete_path (path resolve (status dirname)/../completions) $fish_complete_path
set -g tmp (path resolve (mktemp -d))
set -gx HOME $tmp/home
mkdir -p $HOME/src/app/.git $HOME/dots/.git $tmp/home.bak/lib/.git $tmp/mirror$HOME/tool/.git $tmp/empty

# Not in alphabetical order, which is the order fish puts completions in without -k.
function query
    printf '%s\n' $tmp/mirror$HOME/tool $tmp/home.bak/lib $HOME/dots $HOME/src/app
end

set -g pj_root $tmp/empty
set -g pj_query_cmd query

# mirror has $HOME in the middle of its path and home.bak only starts like it, so neither gets a ~.
complete -C 'pj ' | string replace -a $tmp '$tmp'
# CHECK: tool{{\t}}$tmp/mirror$tmp/home
# CHECK: lib{{\t}}$tmp/home.bak
# CHECK: dots{{\t}}~
# CHECK: app{{\t}}~/src

complete -C 'pjo ' | string replace -a $tmp '$tmp'
# CHECK: tool{{\t}}$tmp/mirror$tmp/home
# CHECK: lib{{\t}}$tmp/home.bak
# CHECK: dots{{\t}}~
# CHECK: app{{\t}}~/src

rm -rf $tmp
