# pj.fish

**Jump to a project** (git repository), or open one in your editor, from [Fish](https://fishshell.com).

- Finds projects from [`$PROJECT_PATHS`], [`ghq`], [`ghr`], [`gogh`] or [`$XDG_PROJECTS_DIR`].

- Skips linked [worktrees], each project shows up once, at its main [worktree].

- Picks with [`fzf`], [`sk`], [`tv`] or [`gum`] (required).

- Opens projects in [Zed], [VS Code], [IntelliJ IDEA], `$VISUAL` or `$EDITOR`.

- Uses [`zoxide`], [`z`] or [`z.lua`] to rank projects by frecency (optional).

- No setup needed.

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher):

```fish
fisher install mehcode/pj.fish
```

## Quickstart

Jump to the best match for a keyword among the directories you've visited.

> Uses `zoxide`, `z` or `z.lua`. If nothing you've visited is a project that matches,
> `pj` opens the picker with your keywords as the query.

```fish
pj dotfiles
pj ~/dotfiles # Jumps to a path too.
```

Pick from every project, with the ones you visit most at the top.

```fish
pj
```

Open a project in your editor. `pjo` takes the same keywords as `pj`,
and so do `pj open` and `pj --open` (`-o`).

```fish
pjo dotfiles
pj open dotfiles
pj --open dotfiles
pjo . # Opens the current directory.
```

Print a project's path instead of jumping to it, with `pj --echo` (`-e`).
With no keywords it opens the picker and prints the one you pick.

```fish
ls (pj --echo dotfiles)
```

Press <kbd>Tab</kbd> after `pj` or `pjo` to complete a project's name.

## Worktrees

`pj` will only jump to a project's main [worktree] (the one with a `.git` directory).

- The picker lists each project once, regardless of how many [worktrees] it has.

- `pj app` lands in `app` even if `app.feature` is ranked higher.

## Configuration

### `$pj_root`

The directories to scan for projects.

Defaults to asking the project root from [`$PROJECT_PATHS`], [`ghq`], [`ghr`] or [`gogh`];
falling back to [`$XDG_PROJECTS_DIR`].

```fish
set --global pj_root ~/src ~/work
```

### `$pj_query_cmd`

The command that ranks the directories you've visited.
It gets your keywords as arguments and prints matching directories one per line, best first.
With no keywords, it prints every directory it knows.

Defaults to [`zoxide`], [`z`] or [`z.lua`].

### `$pj_find_cmd`

Reads one project per line on stdin and prints the line you chose, unchanged.
Printing anything else counts as a cancel.
It gets your keywords as its last argument, empty when there are none,
so end it with your finder's query flag.

Defaults to [`fzf`], [`sk`], [`tv`] or [`gum`].

```fish
set --global pj_find_cmd fzf --height 40% --reverse --query
```

### `$pj_open_cmd`

The command `pjo`, `pj open` and `pj --open` open a project with.
It gets the project's directory as its last argument.

Defaults to the first of [Zed], [VS Code] or [IntelliJ IDEA] that's installed,
then `$VISUAL`, then `$EDITOR`.

```fish
set --global pj_open_cmd code --new-window
```

## License

Licensed under the [MIT License](LICENSE).

[`fzf`]: https://github.com/junegunn/fzf
[`sk`]: https://github.com/skim-rs/skim
[`tv`]: https://github.com/alexpasmantier/television
[`gum`]: https://github.com/charmbracelet/gum
[`zoxide`]: https://github.com/ajeetdsouza/zoxide
[`z`]: https://github.com/jethrokuan/z
[`z.lua`]: https://github.com/skywind3000/z.lua
[`$PROJECT_PATHS`]: https://github.com/oh-my-fish/plugin-pj#configuration
[`ghq`]: https://github.com/x-motemen/ghq
[`ghr`]: https://github.com/siketyan/ghr
[`gogh`]: https://github.com/kyoh86/gogh
[`$XDG_PROJECTS_DIR`]: https://wiki.archlinux.org/title/XDG_user_directories
[zed]: https://zed.dev
[vs code]: https://code.visualstudio.com
[intellij idea]: https://www.jetbrains.com/idea/
[worktrees]: https://git-scm.com/docs/git-worktree
[worktree]: https://git-scm.com/docs/git-worktree
