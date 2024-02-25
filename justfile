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

# build
build project=all-projects:
    @echo Building {{ project }}
