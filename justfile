#!/usr/bin/env -S just --justfile
# ^ A shebang isn't required, but allows a justfile to be executed
#   like a script, with `./justfile test`, for example.

# lists recipes (default)
list:
    @just --list

# lint
lint:
    just --unstable --fmt --check
