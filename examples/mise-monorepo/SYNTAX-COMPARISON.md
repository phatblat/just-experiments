# Side-by-Side Syntax Comparison: Mise vs Just

This document provides a direct comparison of how common patterns are expressed in mise vs Just.

## Basic Command Invocation

### Building the Go SDK

**Just (Clean & Natural)**
```bash
just build sdk/go
```

**Mise (Multiple Options)**
```bash
# Option 1: Namespaced (verbose config, but clean invocation)
mise run go:build

# Option 2: Environment variable (awkward)
PRODUCT=sdk/go mise run build-env

# Option 3: Wrapper script (extra setup)
./mise-wrapper.sh build sdk/go

# Option 4: Navigate to directory (natural, but slower)
cd sdk/go && mise run build
```

**Winner: Just** - Natural positional arguments without workarounds

---

## Path Validation

### Validating a directory exists before running a task

**Just**
```just
build path:
    #!/usr/bin/env bash
    if [ ! -d "{{path}}" ]; then
        echo "Error: {{path}} not found"
        exit 1
    fi
    cd "{{path}}" && just build
```

**Mise**
```toml
[tasks."build-env"]
run = """
#!/usr/bin/env bash
if [ -z "${PRODUCT:-}" ]; then
    echo "Error: PRODUCT required"
    exit 1
fi
if [ ! -d "$PRODUCT" ]; then
    echo "Error: $PRODUCT not found"
    exit 1
fi
cd "$PRODUCT" && mise run build
"""
```

**Winner: Just** - Same complexity, but Just has better argument handling

---

## Task with Optional Arguments

### Running with optional arguments

**Just**
```just
run path *args:
    cd "{{path}}" && just run {{args}}
```

**Usage:**
```bash
just run sdk/go arg1 arg2 arg3
```

**Mise**
```toml
[tasks."run-env"]
run = """
cd "$PRODUCT" && mise run run
"""
```

**Usage:**
```bash
PRODUCT=sdk/go mise run run-env
# Note: Passing additional args is difficult
```

**Winner: Just** - Native variadic arguments with `*args`

---

## Multiple Positional Arguments

### Task that takes multiple parameters

**Just**
```just
deploy environment service version:
    echo "Deploying {{service}} v{{version}} to {{environment}}"
    # deployment commands here
```

**Usage:**
```bash
just deploy production api-gateway v1.2.3
```

**Mise**
```toml
[tasks.deploy]
run = """
echo "Deploying $SERVICE v$VERSION to $ENV"
# deployment commands here
"""
```

**Usage:**
```bash
ENV=production SERVICE=api-gateway VERSION=v1.2.3 mise run deploy
```

**Winner: Just** - Much cleaner syntax for multiple parameters

---

## Task with Default Values

### Task with optional parameters that have defaults

**Just**
```just
build path="sdk/go" mode="debug":
    echo "Building {{path}} in {{mode}} mode"
    cd "{{path}}" && just build-{{mode}}
```

**Usage:**
```bash
just build                    # Uses defaults
just build sdk/rust           # Override path
just build sdk/go release     # Override both
```

**Mise**
```toml
[tasks.build]
run = """
PRODUCT=${PRODUCT:-sdk/go}
MODE=${MODE:-debug}
echo "Building $PRODUCT in $MODE mode"
cd "$PRODUCT" && mise run build-$MODE
"""
```

**Usage:**
```bash
mise run build                              # Uses defaults
PRODUCT=sdk/rust mise run build             # Override product
PRODUCT=sdk/go MODE=release mise run build  # Override both
```

**Winner: Just** - Native default values, much cleaner syntax

---

## Listing Available Tasks

**Just**
```bash
$ just --list
Available recipes:
    build path          # Build a specific product
    test path           # Test a specific product
    lint path           # Lint a specific product
    run path *args      # Run a specific product
    build-all           # Build all products
    test-all            # Test all products
```

**Mise**
```bash
$ mise tasks
build-env              Build a product (requires PRODUCT env var)
test-env               Test a product (requires PRODUCT env var)
go:build               Build Go SDK
go:test                Test Go SDK
rust:build             Build Rust SDK
rust:test              Test Rust SDK
cpp:build              Build C++ SDK
cpp:test               Test C++ SDK
build-all              Build all SDKs
test-all               Test all SDKs
```

**Winner: Just** - Cleaner output, shows parameter names

---

## Task Dependencies

### Task that depends on another task

**Just**
```just
test: build
    cargo test

deploy: test
    kubectl apply -f deployment.yaml
```

**Mise**
```toml
[tasks.test]
depends = ["build"]
run = "cargo test"

[tasks.deploy]
depends = ["test"]
run = "kubectl apply -f deployment.yaml"
```

**Winner: Tie** - Both support dependencies well

---

## Running Multiple Commands

### Task that runs multiple commands

**Just**
```just
check:
    go fmt ./...
    go vet ./...
    go test ./...
```

**Mise**
```toml
[tasks.check]
run = [
    "go fmt ./...",
    "go vet ./...",
    "go test ./..."
]
```

**Winner: Tie** - Both handle this cleanly

---

## Conditional Execution

### Task with conditional logic

**Just**
```just
build mode="debug":
    #!/usr/bin/env bash
    if [ "{{mode}}" = "release" ]; then
        cargo build --release
    else
        cargo build
    fi
```

**Mise**
```toml
[tasks.build]
run = """
if [ "${MODE:-debug}" = "release" ]; then
    cargo build --release
else
    cargo build
fi
"""
```

**Winner: Tie** - Both use shell scripts for conditionals

---

## Environment Variables

### Setting environment variables for a task

**Just**
```just
test:
    #!/usr/bin/env bash
    export RUST_BACKTRACE=1
    export CARGO_TERM_COLOR=always
    cargo test
```

**Mise**
```toml
[tasks.test]
env = { RUST_BACKTRACE = "1", CARGO_TERM_COLOR = "always" }
run = "cargo test"
```

**Winner: Mise** - Structured env vars in TOML vs shell exports

---

## Working Directory

### Running a task in a specific directory

**Just**
```just
build:
    cd sdk/go && go build .
```

**Mise**
```toml
[tasks.build]
dir = "{{cwd}}/sdk/go"
run = "go build ."
```

**Winner: Mise** - More explicit with `dir` parameter

---

## Task Documentation

### Adding help text to tasks

**Just**
```just
# Build a specific product
# Usage: just build sdk/go
build path:
    cd "{{path}}" && just build
```

**Mise**
```toml
[tasks.build]
description = "Build a specific product"
run = "cd $PRODUCT && mise run build"
```

**Winner: Mise** - Structured descriptions that appear in `mise tasks`

---

## Dry Run / Preview

**Just**
```bash
just --dry-run build sdk/go
# Shows what would be executed without running it
```

**Mise**
```bash
mise run --dry-run go:build
# Shows the task that would be executed
```

**Winner: Tie** - Both support dry-run mode

---

## Tab Completion

**Just**
```bash
just build sdk/<TAB>
# Completes to: sdk/go, sdk/rust, sdk/cpp
```

**Mise**
```bash
mise run go:<TAB>
# Completes to: go:build, go:test, go:lint, etc.
```

**Winner: Just** - Can complete file paths; mise completes task names only

---

## Configuration Syntax

**Just (justfile)**
```just
# Simple, make-like syntax
build path:
    cd "{{path}}" && just build

test path: (build path)
    cd "{{path}}" && just test
```

**Mise (mise.toml)**
```toml
# Structured TOML syntax
[tasks.build]
description = "Build a product"
run = "cd $PRODUCT && mise run build"

[tasks.test]
description = "Test a product"
depends = ["build"]
run = "cd $PRODUCT && mise run test"
```

**Winner: Personal preference**
- Just: More concise, make-like
- Mise: More structured, explicit

---

## Multi-line Shell Scripts

**Just**
```just
deploy:
    #!/usr/bin/env bash
    set -euxo pipefail

    echo "Building..."
    cargo build --release

    echo "Testing..."
    cargo test --release

    echo "Deploying..."
    kubectl apply -f deployment.yaml
```

**Mise**
```toml
[tasks.deploy]
run = """
#!/usr/bin/env bash
set -euxo pipefail

echo "Building..."
cargo build --release

echo "Testing..."
cargo test --release

echo "Deploying..."
kubectl apply -f deployment.yaml
"""
```

**Winner: Tie** - Both handle multi-line scripts well

---

## Including/Importing Other Files

**Just**
```just
# justfile
import 'ci/tasks.just'

# ci/tasks.just
test:
    cargo test
```

**Mise**
```toml
# Each directory has its own mise.toml
# Root invokes them via cd

# Root mise.toml
[tasks."go:test"]
run = "cd sdk/go && mise run test"

# sdk/go/mise.toml
[tasks.test]
run = "go test ./..."
```

**Winner: Both support modularity**
- Just: Explicit imports
- Mise: Hierarchical discovery

---

## Real-World Example: Full Workflow

### Running lint, format, build, and test for a product

**Just**
```bash
just lint sdk/go
just format sdk/go
just build sdk/go
just test sdk/go

# Or with a combined task:
just check sdk/go
```

**Mise (Namespaced)**
```bash
mise run go:lint
mise run go:format
mise run go:build
mise run go:test

# Or with a combined task:
mise run go:check
```

**Mise (Environment Variable)**
```bash
export PRODUCT=sdk/go
mise run lint-env
mise run format-env
mise run build-env
mise run test-env
```

**Winner: Just** - Cleaner invocation, especially for multiple commands

---

## Summary Table

| Feature | Just | Mise | Winner |
|---------|------|------|--------|
| Positional Arguments | ✅ Native | ❌ Workarounds | **Just** |
| Default Values | ✅ Native | ⚠️ Via shell | **Just** |
| Variadic Args | ✅ Native (`*args`) | ❌ Limited | **Just** |
| Path Validation | ✅ Simple | ✅ Simple | **Tie** |
| Task Dependencies | ✅ | ✅ | **Tie** |
| Environment Variables | ⚠️ Via shell | ✅ Structured | **Mise** |
| Working Directory | ⚠️ Via cd | ✅ `dir` param | **Mise** |
| Documentation | ⚠️ Comments | ✅ `description` | **Mise** |
| Modularity | ✅ Imports | ✅ Hierarchical | **Tie** |
| Tab Completion | ✅ Full | ⚠️ Tasks only | **Just** |
| Dry Run | ✅ | ✅ | **Tie** |
| Learning Curve | ✅ Low | ⚠️ Medium | **Just** |
| Configuration | Make-like | TOML | **Preference** |
| Version Management | ❌ | ✅ Built-in | **Mise** |
| Maturity (tasks) | ✅ | ⚠️ New | **Just** |

## Overall Verdict

**For Task Running Only:**
- **Just** is the clear winner for CLI ergonomics and argument handling
- Natural positional arguments make Just much more intuitive
- Less boilerplate and cleaner invocations

**For Integrated Tooling:**
- **Mise** wins if you're already using it for version management
- One tool instead of two (mise + just)
- Acceptable task running with workarounds

**Recommendation:**
- **Just** for pure task running
- **Mise + Just** for best of both worlds (mise for versions, just for tasks)
- **Mise alone** to minimize tooling (acceptable tradeoffs)

## Example: Best of Both Worlds

You can use mise for version management and just for task running:

```bash
# .tool-versions (mise)
go 1.21.5
rust 1.75.0

# justfile (just)
build path:
    cd "{{path}}" && just build

# Commands
mise install           # Install language runtimes
just build sdk/go      # Run tasks
```

This gives you:
- ✅ Mise's excellent version management
- ✅ Just's superior task syntax
- ✅ Minimal tooling (only 2 tools)
- ✅ Each tool doing what it does best
