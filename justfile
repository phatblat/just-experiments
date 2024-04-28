#!/usr/bin/env -S just --justfile
# ^ A shebang isn't required, but allows a justfile to be executed
#   like a script, with `./justfile test`, for example.
# ---------------------------------------------------------------------------- #
# just settings
# https://just.systems/man/en/chapter_26.html#settings
#
# bash with options. Reuse in recipes with #!{{ bash }}

bash := "/usr/bin/env bash -euo pipefail"

# Command used to invoke recipes and evaluate backticks.
# bash `-c` argument must be last.

set shell := ["bash", "-euo", "pipefail", "-c"]

# ---------------------------------------------------------------------------- #
# project variables

all-projects := `ls -d */`

# ---------------------------------------------------------------------------- #

default:
  @just --choose

# lists recipes
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
    @just {{ project }}/lint

# lint justfile and one or more projects (default: all)
lint +projects=all-projects:
    #!{{ bash }}
    for project in {{ projects }}; do
        echo Linting $project
        just ${project}/lint
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
