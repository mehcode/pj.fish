alias fmt := format

src := "functions/*.fish completions/*.fish tests/*.fish"
littlecheck := "third-party/littlecheck/littlecheck/littlecheck.py"

[default]
list:
    @just --list

# Format fish files to fish_indent's style.
format:
    fish_indent --write {{ src }}

# Check syntax and formatting of every fish file.
check:
    for f in {{ src }}; do fish --no-execute "$f" || exit 1; done
    fish_indent --check {{ src }}

# Run the tests.
test:
    @test -f {{ littlecheck }} || git submodule update --init third-party/littlecheck
    @python3 {{ littlecheck }} --progress tests/*.fish
