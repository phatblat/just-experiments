#!/usr/bin/env -S just --justfile
# ^ A shebang isn't required, but allows a justfile to be executed
#   like a script, with `./justfile test`, for example.

# initial recipe
default:
    echo 'Hello, world!'

# lint
lint:
    just --unstable --fmt --check
