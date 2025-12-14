#!/usr/bin/env -S just --justfile
# ^ A shebang isn't required, but allows a justfile to be executed
#   like a script, with `./justfile test`, for example.
#
# export - Export all variables as environment variables.

set export := true

bash := "/usr/bin/env bash -euo pipefail"

# Command used to invoke recipes and evaluate backticks.
# bash `-c` argument must be last.

set shell := ["bash", "-euo", "pipefail", "-c"]

# unstable - Enable unstable features. Required for --fmt.

# set unstable := true

# project variables

all-projects := `ls -d */`

# Default recipe, lists available recipes
@_default:
    just --list

# show var values
@vars:
    just --evaluate

# Lists installed tools managed by mise
[group('info')]
list:
    mise list --local

# Installs tools using mise
[group('configuration')]
install:
    mise install

# Lists available upgrades
[group('info')]
outdated:
    mise outdated --bump

# Upgrades tools using mise
[group('configuration')]
upgrade:
    mise upgrade --bump

# -----[ Lint ]-----------------------------------------------------------------

# lint justfile
[no-exit-message]
@_lint-just:
    just --unstable --fmt --check

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
lint project='all':
    #!{{ bash }}
    if [[ {{ project }} == 'all' ]]; then
        just _lint-all
    elif [[ {{ project }} == 'just' ]]; then
        just _lint-just
    else
        just _lint-one {{ project }}
    fi

# -----[ Format ]---------------------------------------------------------------

# Formats mise config
_format-mise:
    mise fmt

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
format project='all':
    #!{{ bash }}
    if [[ {{ project }} == 'all' ]]; then
        just _format-all
    elif [[ {{ project }} == 'just' ]]; then
        just _format-just
    elif [[ {{ project }} == 'mise' ]]; then
        just _format-mise
    else
        just _format-one {{ project }}
    fi

# -----[ Build ]----------------------------------------------------------------
# build a single project
[no-exit-message]
_build-one project:
    @just {{ project }}/build

# build all projects
[no-exit-message]
_build-all:
    #!{{ bash }}
    for project in {{ all-projects }}; do
        echo building $project
        just ${project}/build
    done

# build one or all projects (default: all)
build project='all':
    #!{{ bash }}
    if [[ {{ project }} == 'all' ]]; then
        just _build-all
    else
        just _build-one {{ project }}
    fi

# [group('configuration')]
# clean:
