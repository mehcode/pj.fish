# RUN: fish --no-config %s

set fish_function_path (path resolve (status dirname)/../functions) $fish_function_path
set -g tmp (path resolve (mktemp -d))
set -gx HOME $tmp/home
mkdir -p $HOME $tmp/root/{app,lib}/.git $tmp/root/notes $tmp/other/tool/.git $tmp/mirror$tmp/root/app/.git $tmp/empty

mkdir $tmp/root/app.feature
echo "gitdir: $tmp/root/app/.git/worktrees/app.feature" >$tmp/root/app.feature/.git

function query
    printf '%s\n' $visited
end

function finder
    set -l labels
    while read -l label
        set -a labels $label
    end
    echo finder: "["$argv"]" >&2
    string replace -a $tmp '$tmp' "labels: $labels" >&2
    echo $choice
end

# Reads $status, so it has to come straight after pj.
function report
    set -l code $status
    echo $code (string replace $tmp '$tmp' $PWD)
end

set -g pj_root $tmp/root $tmp/other
set -g pj_query_cmd query
set -g pj_find_cmd finder --query

# notes isn't a project and app.feature is a linked worktree, so app is the best match.
set -g visited $tmp/root/notes $tmp/root/app.feature $tmp/root/app $tmp/root/lib
cd $tmp
pj app
report
# CHECK: 0 $tmp/root/app

# Already in app, so the same keywords move on to lib.
pj app
report
# CHECK: 0 $tmp/root/lib

# lib is the only match, so pj stays in it instead of opening the picker.
set visited $tmp/root/lib
pj lib
report
# CHECK: 0 $tmp/root/lib

set visited $tmp/root/notes
set -g choice $tmp/other/tool
pj foo bar
report
# CHECKERR: finder: [--query] [foo bar]
# CHECKERR: labels: app lib $tmp/other/tool
# CHECK: 0 $tmp/other/tool

# mirror has the root in the middle of its path, so its label stays absolute.
set visited $tmp/mirror$tmp/root/app
set choice lib
pj
report
# CHECKERR: finder: [--query] []
# CHECKERR: labels: $tmp/mirror$tmp/root/app app lib $tmp/other/tool
# CHECK: 0 $tmp/root/lib

set visited $tmp/root/notes
set choice nothing
pj foo
report
# CHECKERR: finder: [--query] [foo]
# CHECKERR: labels: app lib $tmp/other/tool
# CHECK: 1 $tmp/root/lib

set pj_root $tmp/empty
pj
report
# CHECKERR: pj: No repositories found (set pj_root to your projects directory)
# CHECK: 1 $tmp/root/lib

rm -rf $tmp
