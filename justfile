#!/usr/bin/env -S just --justfile
# ^ A shebang isn't required, but allows a justfile to be executed
#   like a script, with `./justfile test`, for example.
# ---------------------------------------------------------------------------- #
# just settings
# https://just.systems/man/en/chapter_26.html#settings
#
# bash with options. Reuse in recipes with #!{{ bash }}

bash := "/usr/bin/env bash -euxo pipefail"

# Command used to invoke recipes and evaluate backticks.
# bash `-c` argument must be last.

set shell := ["bash", "-euxo", "pipefail", "-c"]

# ---------------------------------------------------------------------------- #
# project variables

all-projects := `ls -d */`

# ---------------------------------------------------------------------------- #

# lists recipes (default)
list:
    @just --list

# show var values
vars:
    @just --evaluate

# lint justfile
lint-just:
    @just --unstable --fmt --check

# lint project
_lint project:
    @just {{ project }}/build

# lint justfile and one or more projects (default: all)
lint +projects=all-projects:
    #!{{ bash }}
    for project in {{ projects }}; do
        echo Linting $project
        just ${project}/build
    done

# format justfile
format:
    @just --unstable --fmt

# just ${project}/build
# {{ bash }}

# build one or more projects (default: all)
build *projects=all-projects:
    #!{{ bash }}
    for project in {{ projects }}; do
        echo 🏗️ Building $project
        just ${project}/build
    done
