alias fmt := format

[default]
list:
    @just --list

# Format fish files to fish_indent's style.
format:
    fish_indent --write functions/*.fish completions/*.fish

# Check syntax and formatting of every fish file.
check:
    for f in functions/*.fish completions/*.fish; do fish --no-execute "$f" || exit 1; done
    fish_indent --check functions/*.fish completions/*.fish
