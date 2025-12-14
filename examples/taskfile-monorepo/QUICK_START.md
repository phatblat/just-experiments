# Quick Start Guide

## Install Task

```bash
# macOS
brew install go-task/tap/go-task

# Linux
sh -c "$(curl -L https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

# Using Go
go install github.com/go-task/task/v3/cmd/task@latest
```

## Basic Commands

```bash
# Show all available tasks
task --list

# Show help with examples
task help

# List available SDKs
task list-sdks
```

## Build, Test, Run

```bash
# Build a specific SDK
task build SDK=sdk/go
task build SDK=sdk/rust
task build SDK=sdk/cpp

# Run tests
task test SDK=sdk/go

# Run application
task run SDK=sdk/rust CLI_ARGS="hello world"

# Build all SDKs
task build-all

# Run full CI pipeline
task ci
```

## Alternative Syntax (using includes)

```bash
# Direct SDK invocation
task go:build
task rust:test
task cpp:run CLI_ARGS="test"
```

## Common Options

```bash
# Dry run - see what would execute
task --dry build SDK=sdk/go

# Verbose output
task --verbose build SDK=sdk/rust

# Silent mode
task --silent test SDK=sdk/cpp

# Force execution (ignore cache)
task --force build-all

# Parallel execution
task --parallel build-all

# Watch mode (rebuild on changes)
task --watch build SDK=sdk/go
```

## Development Workflow

```bash
# 1. Install dependencies
task install SDK=sdk/go

# 2. Format code
task format SDK=sdk/go

# 3. Lint code
task lint SDK=sdk/go

# 4. Run tests
task test SDK=sdk/go

# 5. Build
task build SDK=sdk/go

# 6. Run
task run SDK=sdk/go CLI_ARGS="--help"

# 7. Clean up
task clean SDK=sdk/go
```

## Working with All SDKs

```bash
# Install all dependencies
task install-all

# Format all code
task format-all

# Lint all code
task lint-all

# Build all SDKs
task build-all

# Test all SDKs
task test-all

# Clean all SDKs
task clean-all
```

## Tips

- Use tab completion: `task <TAB>`
- Check task description: `task --summary <task-name>`
- See task details: `task --list-all`
- Get help: `task help`
