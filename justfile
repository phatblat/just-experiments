#!/usr/bin/env -S just --justfile
# ^ A shebang isn't required, but allows a justfile to be executed
#   like a script, with `./justfile test`, for example.

all-projects := `ls -d */`

# lists recipes (default)
list:
    @just --list

# lint
lint:
    @just --unstable --fmt --check

# format justfile
format:
    @just --unstable --fmt

# just ${project}/build

# build one or more projects (default: all)
build projects=all-projects:
    #!/usr/bin/env bash
    for project in {{ projects }}; do
        echo Building $project
        just ${project}/build
    done
# shows var values
vars:
    @just --evaluate

