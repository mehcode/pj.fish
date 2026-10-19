# RUN: fish --no-config %s

set fish_function_path (path resolve (status dirname)/../functions) $fish_function_path
set -g tmp (path resolve (mktemp -d))
set -gx HOME $tmp/home
mkdir -p $HOME $tmp/root/app/.git $tmp/root/1/2/3/deep/.git $tmp/root/1/2/3/4/deeper/.git $tmp/else/tool/.git

mkdir $tmp/root/app.feature
echo "gitdir: $tmp/root/app/.git/worktrees/app.feature" >$tmp/root/app.feature/.git

function projects
    __pj_list | string replace $tmp '$tmp'
end

set -g pj_root $tmp/root

# The scan doesn't call seq, so a function of that name can't change how deep it goes.
function seq
    echo 1
end

set -g pj_query_cmd true
projects
# CHECK: $tmp/root/app
# CHECK: $tmp/root/1/2/3/deep

# The query prints deep twice and the scan finds it again, so it'd be printed three times if
# duplicates weren't dropped.
function query
    printf '%s\n' $tmp/root/app.feature $tmp/else/tool $tmp/root/1/2/3/deep $tmp/gone $tmp/root/1/2/3/deep
end

set pj_query_cmd query
projects
# CHECK: $tmp/else/tool
# CHECK: $tmp/root/1/2/3/deep
# CHECK: $tmp/root/app

rm -rf $tmp
