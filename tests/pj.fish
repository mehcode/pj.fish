# RUN: fish --no-config %s

set fish_function_path (path resolve (status dirname)/../functions) $fish_function_path
set -g tmp (path resolve (mktemp -d))
set -gx HOME $tmp/home
mkdir -p $HOME $tmp/root/{app,lib}/.git $tmp/root/app/src $tmp/root/notes/lib $tmp/other/tool/.git $tmp/mirror$tmp/root/app/.git $tmp/empty

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

# notes holds a lib folder. Beside another argument, ./lib is a keyword rather than that folder.
cd $tmp/root/notes
set visited $tmp/root/notes
set -g choice nothing
pj ./lib foo
report
# CHECKERR: finder: [--query] [./lib foo]
# CHECKERR: labels: app lib $tmp/other/tool
# CHECK: 1 $tmp/root/notes

# A bare word is never a folder where you are, so lib is still the project.
set visited $tmp/root/lib
pj lib
report
# CHECK: 0 $tmp/root/lib

# A word that only starts with a dot is a keyword too, like a project named .dotfiles.
pj .lib
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

# After --, an option is a keyword.
pj -- --help
report
# CHECKERR: finder: [--query] [--help]
# CHECKERR: labels: app lib $tmp/other/tool
# CHECK: 1 $tmp/root/lib

# open is only the subcommand with an argument after it, and never after --.
pj open
report
# CHECKERR: finder: [--query] [open]
# CHECKERR: labels: app lib $tmp/other/tool
# CHECK: 1 $tmp/root/lib

pj -- open foo
report
# CHECKERR: finder: [--query] [open foo]
# CHECKERR: labels: app lib $tmp/other/tool
# CHECK: 1 $tmp/root/lib

pj openssl
report
# CHECKERR: finder: [--query] [openssl]
# CHECKERR: labels: app lib $tmp/other/tool
# CHECK: 1 $tmp/root/lib

pj foo open
report
# CHECKERR: finder: [--query] [foo open]
# CHECKERR: labels: app lib $tmp/other/tool
# CHECK: 1 $tmp/root/lib

function opener
    echo opener: "["$argv"]" | string replace $tmp '$tmp'
end

set -g pj_open_cmd opener --new-window

# Each spelling opens what pjo app does, and stays in lib.
set visited $tmp/root/app $tmp/root/lib
pj open app
report
# CHECK: opener: [--new-window] [$tmp/root/app]
# CHECK: 0 $tmp/root/lib

pj --open app
report
# CHECK: opener: [--new-window] [$tmp/root/app]
# CHECK: 0 $tmp/root/lib

pj -o app
report
# CHECK: opener: [--new-window] [$tmp/root/app]
# CHECK: 0 $tmp/root/lib

# pj lib would move on to app from here. Opening takes the best match wherever it's run.
set visited $tmp/root/lib $tmp/root/app
pj --open lib
report
# CHECK: opener: [--new-window] [$tmp/root/lib]
# CHECK: 0 $tmp/root/lib

set choice app
pj --open
report
# CHECKERR: finder: [--query] []
# CHECKERR: labels: lib app $tmp/other/tool
# CHECK: opener: [--new-window] [$tmp/root/app]
# CHECK: 0 $tmp/root/lib

# Captures stdout the way cd (pj -e) does. A cd in a command substitution still moves the shell,
# so report shows one, and an editor that started would print among the paths.
function echoed
    set -g out (pj $argv)
    report
    for dir in $out
        echo out: (string replace $tmp '$tmp' -- $dir)
    end
end

set visited $tmp/root/notes
set choice $tmp/other/tool
echoed -e foo
# CHECKERR: finder: [--query] [foo]
# CHECKERR: labels: app lib $tmp/other/tool
# CHECK: 0 $tmp/root/lib
# CHECK: out: $tmp/other/tool

set choice nothing
echoed -e foo
# CHECKERR: finder: [--query] [foo]
# CHECKERR: labels: app lib $tmp/other/tool
# CHECK: 1 $tmp/root/lib

# pj lib would move on to app from here. Printing takes the best match wherever it's run.
set visited $tmp/root/lib $tmp/root/app
echoed --echo lib
# CHECK: 0 $tmp/root/lib
# CHECK: out: $tmp/root/lib

set choice app
echoed --echo
# CHECKERR: finder: [--query] []
# CHECKERR: labels: lib app $tmp/other/tool
# CHECK: 0 $tmp/root/lib
# CHECK: out: $tmp/root/app

set visited $tmp/root/app $tmp/root/lib
echoed -e app
# CHECK: 0 $tmp/root/lib
# CHECK: out: $tmp/root/app

# An empty PATH and no editor variables, so the editors installed on this machine aren't found.
set -e pj_open_cmd
PATH=$tmp/empty VISUAL= EDITOR= pj open app
report
# CHECKERR: pj: No editor found (set pj_open_cmd to your preferred editor)
# CHECK: 1 $tmp/root/lib

set visited $tmp/root/notes

# An empty PATH, so the finders installed on this machine aren't found.
set -e pj_find_cmd
PATH=$tmp/empty pj foo
report
# CHECKERR: pj: No fuzzy finder found (set pj_find_cmd to your preferred finder)
# CHECK: 1 $tmp/root/lib

set pj_root $tmp/empty
pj
report
# CHECKERR: pj: No repositories found (set pj_root to your projects directory)
# CHECK: 1 $tmp/root/lib

echoed --echo
# CHECKERR: pj: No repositories found (set pj_root to your projects directory)
# CHECK: 1 $tmp/root/lib

# Keywords and the picker both start with the query, so a mark it leaves shows whether either ran.
# It can't report on stderr the way finder does, since __pj_query drops that.
function query
    set -g queried
end

pj --help
report
# CHECK: Usage: pj <keywords>...       Jump to the best match for the keywords
# CHECK:        pj <path>              Jump to a project directory
# CHECK:        pj                     Pick from every project
# CHECK:        pj open <keywords>...  Open the best match in your editor
# CHECK: Options:
# CHECK:        -h, --help     Print this help message
# CHECK:        -v, --version  Print the version
# CHECK:        -o, --open     Open in your editor
# CHECK:        -e, --echo     Print the path
# CHECK:        --             Take what follows as arguments, even 'open' or one starting with -
# CHECK: Variables:
# CHECK:        pj_root       Directories to scan for projects
# CHECK:        pj_query_cmd  Command that ranks the directories you've visited
# CHECK:        pj_find_cmd   Command that picks a project from a list
# CHECK:        pj_open_cmd   Command that opens a project in your editor
# CHECK: 0 $tmp/root/lib

pj -h | string match 'Usage:*'
echo $pipestatus[1]
# CHECK: Usage: pj <keywords>...       Jump to the best match for the keywords
# CHECK: 0

pj --version
report
# CHECK: pj, version {{\d+\.\d+\.\d+}}
# CHECK: 0 $tmp/root/lib

pj -v
report
# CHECK: pj, version {{\d+\.\d+\.\d+}}
# CHECK: 0 $tmp/root/lib

# Only the prefix is ours. argparse writes the rest of the message.
pj --nope
report
# CHECKERR: pj: {{.*--nope.*}}
# CHECK: 2 $tmp/root/lib

# Opening and printing are two things to do with the path, so pj won't do both.
pj --echo --open app
report
# CHECKERR: pj: e/echo o/open: options cannot be used together
# CHECK: 2 $tmp/root/lib

pj open -e app
report
# CHECKERR: pj: e/echo o/open: options cannot be used together
# CHECK: 2 $tmp/root/lib

set -q queried; or echo not queried
# CHECK: not queried

# A path is checked against every project, so the query runs, but never with the path as a keyword.
function query
    set -ga keywords $argv
end

set pj_root $tmp/root $tmp/other
set -g pj_find_cmd finder --query
set -g pj_open_cmd opener

# A path goes to a project or a folder inside one, without the picker.
cd $tmp/root
pj ./app/src
report
# CHECK: 0 $tmp/root/app/src

pj ..
report
# CHECK: 0 $tmp/root/app

pj ../../other/tool
report
# CHECK: 0 $tmp/other/tool

pj $tmp/root/app/src
report
# CHECK: 0 $tmp/root/app/src

# Already in src, pj stays rather than moving on.
pj .
report
# CHECK: 0 $tmp/root/app/src

echoed -e ../../..//other/./tool/
# CHECK: 0 $tmp/root/app/src
# CHECK: out: $tmp/other/tool

pj open .
report
# CHECK: opener: [$tmp/root/app/src]
# CHECK: 0 $tmp/root/app/src

pj --open ..
report
# CHECK: opener: [$tmp/root/app]
# CHECK: 0 $tmp/root/app/src

# A project counts however a symlink spells its path, and so does a symlink in it leading out.
ln -s $tmp/root $tmp/link
ln -s $tmp/empty $tmp/root/app/out
cd $tmp/link/app
pj ./out
report
# CHECK: 0 $tmp/link/app/out

pj ../src
report
# CHECK: 0 $tmp/link/app/src

set pj_root $tmp/link $tmp/other
cd $tmp/root/app
pj ./src
report
# CHECK: 0 $tmp/root/app/src

set pj_root $tmp/root $tmp/other

# notes only holds a folder, and app.feature is a linked worktree whose name starts with app.
cd $tmp/root
pj ./notes
report
# CHECKERR: pj: Not inside a project: ./notes
# CHECK: 1 $tmp/root

pj ./app.feature
report
# CHECKERR: pj: Not inside a project: ./app.feature
# CHECK: 1 $tmp/root

pj .
report
# CHECKERR: pj: Not inside a project: .
# CHECK: 1 $tmp/root

echoed -e ./notes/lib
# CHECKERR: pj: Not inside a project: ./notes/lib
# CHECK: 1 $tmp/root

pj open ..
report
# CHECKERR: pj: Not inside a project: ..
# CHECK: 1 $tmp/root

pj --open ./notes
report
# CHECKERR: pj: Not inside a project: ./notes
# CHECK: 1 $tmp/root

pj ./nope
report
# CHECKERR: pj: No such directory: ./nope
# CHECK: 1 $tmp/root

set -q keywords; and not set -q keywords[1]; and echo queried without keywords
# CHECK: queried without keywords

rm -rf $tmp
