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

# -----[ Lint ]-----------------------------------------------------------------

# lint justfile
[no-exit-message]
_lint-just:
    @just --unstable --fmt --check

# lint a single project
[no-exit-message]
_lint-one project:
    @just {{ project }}/lint

# lints all projects
[no-exit-message]
_lint-all:
    #!{{ bash }}
    for project in {{ all-projects }}; do
        echo Linting $project
        just ${project}/lint
    done

# lint justfile and one or more projects (default: all)
[no-exit-message]
lint +project='all':
    #!{{ bash }}
    if [[ {{ project }} == 'all' ]]; then
        just _lint-all
    elif [[ {{ project }} == 'just' ]]; then
        just _lint-just
    else
        just _lint-one {{ project }}
    fi

# -----[ Format ]---------------------------------------------------------------

# format justfile
[no-exit-message]
_format-just:
    @just --unstable --fmt

# format a single project
[no-exit-message]
_format-one project:
    @just {{ project }}/format

# formats all projects
[no-exit-message]
_format-all:
    #!{{ bash }}
    for project in {{ all-projects }}; do
        echo formating $project
        just ${project}/format
    done

# formats justfile or one or all projects (default: all)
[no-exit-message]
format +project='all':
    #!{{ bash }}
    if [[ {{ project }} == 'all' ]]; then
        just _format-all
    elif [[ {{ project }} == 'just' ]]; then
        just _format-just
    else
        just _format-one {{ project }}
    fi

# just ${project}/build
# {{ bash }}

# build one or more projects (default: all)
build *projects=all-projects:
    #!{{ bash }}
    for project in {{ projects }}; do
        echo 🏗️ Building $project
        just ${project}/build
    done
