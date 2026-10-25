# RUN: fish --no-config %s

set fish_function_path (path resolve (status dirname)/../functions) $fish_function_path
set fish_complete_path (path resolve (status dirname)/../completions) $fish_complete_path
set -g tmp (path resolve (mktemp -d))
set -gx HOME $tmp/home
mkdir -p $HOME/mehcode/{foo,foobar,zfoo}/.git $HOME/work/{foo,demo}/.git "$HOME/work/it's (x)/.git" \
    $tmp/home.bak/lib/.git $tmp/mirror$HOME/tool/.git $tmp/empty

# Not in alphabetical order, which is the order fish puts completions in without -k.
function query
    printf '%s\n' $tmp/mirror$HOME/tool $tmp/home.bak/lib $HOME/mehcode/zfoo $HOME/mehcode/foobar \
        $HOME/work/demo $HOME/work/foo "$HOME/work/it's (x)" $HOME/mehcode/foo
end

set -g pj_root $tmp/empty
set -g pj_query_cmd query

# mirror has $HOME in the middle of its path and home.bak only starts like it, so neither gets a ~.
# Only projects, so open isn't offered at the top of a list that's otherwise most-used first.
complete -C 'pj ' | string replace -a $tmp '$tmp'
# CHECK: $tmp/mirror$tmp/home/tool
# CHECK: $tmp/home.bak/lib
# CHECK: ~/mehcode/zfoo
# CHECK: ~/mehcode/foobar
# CHECK: ~/work/demo
# CHECK: ~/work/foo
# CHECK: ~/work/it's (x)
# CHECK: ~/mehcode/foo

# Names that start with the word, without zfoo, which only contains it.
complete -C 'pj fo'
# CHECK: ~/mehcode/foobar
# CHECK: ~/work/foo
# CHECK: ~/mehcode/foo

complete -C 'pj FO'
# CHECK: ~/mehcode/foobar
# CHECK: ~/work/foo
# CHECK: ~/mehcode/foo

complete -C 'pj foo'
# CHECK: ~/mehcode/foobar
# CHECK: ~/work/foo
# CHECK: ~/mehcode/foo

complete -C 'pj zf'
# CHECK: ~/mehcode/zfoo

# Names that contain the word, when none start with it.
complete -C 'pj oob'
# CHECK: ~/mehcode/foobar

# Names that hold the word's letters in order, when none contain it.
complete -C 'pj fbr'
# CHECK: ~/mehcode/foobar

# Not the projects under mehcode or mirror, whose own names have no m.
complete -C 'pj m'
# CHECK: ~/work/demo

# The word as fish reads it, rather than as typed or as a pattern.
complete -C "pj it\\'s\\ \\("
# CHECK: ~/work/it's (x)

# A trailing backslash is still being typed, so the word is m, as fish reads it.
complete -C 'pj m\\'
# CHECK: ~/work/demo

# A path is left to fish, which matches it against the whole of each project's path.
complete -C 'pj ~/meh'
# CHECK: ~/mehcode/zfoo
# CHECK: ~/mehcode/foobar
# CHECK: ~/mehcode/foo

complete -C 'pjo fo'
# CHECK: ~/mehcode/foobar
# CHECK: ~/work/foo
# CHECK: ~/mehcode/foo

complete -C 'pj open fo'
# CHECK: ~/mehcode/foobar
# CHECK: ~/work/foo
# CHECK: ~/mehcode/foo

complete -C 'pj --open fo'
# CHECK: ~/mehcode/foobar
# CHECK: ~/work/foo
# CHECK: ~/mehcode/foo

complete -C 'pj -o fo'
# CHECK: ~/mehcode/foobar
# CHECK: ~/work/foo
# CHECK: ~/mehcode/foo

complete -C 'pj --echo fo'
# CHECK: ~/mehcode/foobar
# CHECK: ~/work/foo
# CHECK: ~/mehcode/foo

complete -C 'pj -e fo'
# CHECK: ~/mehcode/foobar
# CHECK: ~/work/foo
# CHECK: ~/mehcode/foo

complete -C 'pj -'
# CHECK: -e{{\t}}Print the path
# CHECK: -h{{\t}}Print help
# CHECK: -o{{\t}}Open in your editor
# CHECK: -v{{\t}}Print version
# CHECK: --echo{{\t}}Print the path
# CHECK: --help{{\t}}Print help
# CHECK: --open{{\t}}Open in your editor
# CHECK: --version{{\t}}Print version

complete -C 'pjo -'
# CHECK: -h{{\t}}Print help
# CHECK: -v{{\t}}Print version
# CHECK: --help{{\t}}Print help
# CHECK: --version{{\t}}Print version

rm -rf $tmp
