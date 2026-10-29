# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-10-28

### Added

- `pj open` and `pj --open` (`-o`) open a project in your editor, the way `pjo` does.

- `pj --echo` (`-e`) prints a project's path instead of jumping to it.

- `pj` and `pjo` take a path to a project or a directory inside one, like `pj ~/dotfiles/fish` or `pjo .`.

- After a project's path, <kbd>Tab</kbd> completes the directories inside it.

- `--help` (`-h`) and `--version` (`-v`) for `pj` and `pjo`.

### Changed

- **Breaking:** Requires fish 4.0 or later.

- **Breaking:** An argument starting with `-` is an option, and `pj open` followed by another argument opens a project.

- **Breaking:** A single argument that's `.` or `..`, or starts with `/`, `./` or `../`, is a path rather than a keyword.

- **Breaking:** With `$pj_root` unset, projects are found under `$PROJECT_PATHS`, before asking ghq, ghr or gogh.

- From inside the highest-ranked matching project, `pj <keywords>` moves on to the next one.

### Fixed

- <kbd>Tab</kbd> completes a project's path and goes to the project you completed even when another has the same name.

- `pjo` starts its error messages with `pjo:`, not `pj:`.

- `pj` runs zoxide, ghq, ghr and gogh directly, ignoring a function with the same name.

- The search for projects no longer looks inside linked worktrees.

## [1.0.0] - 2026-09-30

### Added

- `pj` jumps to the project matching your keywords that zoxide, z or z.lua ranks highest, or picks from every project with fzf, sk, tv or gum.

- `pjo` opens a project in Zed, VS Code, IntelliJ IDEA, `$VISUAL` or `$EDITOR`.

- Projects are found under `$pj_root`, the roots ghq, ghr or gogh report, or `$XDG_PROJECTS_DIR`, with linked worktrees left out.

- <kbd>Tab</kbd> completes a project's name.

[unreleased]: https://github.com/mehcode/pj.fish/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/mehcode/pj.fish/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/mehcode/pj.fish/releases/tag/v1.0.0
