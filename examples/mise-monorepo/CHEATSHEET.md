# Mise Monorepo Cheatsheet

Quick reference for using this example project.

## Installation

```bash
# Install mise
curl https://mise.run | sh

# Navigate to project
cd /home/user/just-experiments/examples/mise-monorepo

# Validate setup
./validate.sh
```

## Four Ways to Run Tasks

### 1. Namespaced (Recommended)
```bash
mise run go:build
mise run rust:test
mise run cpp:lint
```

### 2. Environment Variables
```bash
PRODUCT=sdk/go mise run build-env
PRODUCT=sdk/rust mise run test-env
```

### 3. Wrapper Script
```bash
mise run create-wrapper
./mise-wrapper.sh build sdk/go
./mise-wrapper.sh test sdk/rust
```

### 4. Direct in SDK
```bash
cd sdk/go && mise run build
cd sdk/rust && mise run test
```

## Common Commands

### Per SDK
```bash
# Pick one approach:
mise run go:build       # or rust:build or cpp:build
mise run go:test        # or rust:test or cpp:test
mise run go:lint        # or rust:lint or cpp:lint
mise run go:format      # or rust:format or cpp:format
mise run go:run         # or rust:run or cpp:run
mise run go:clean       # or rust:clean or cpp:clean
```

### All SDKs
```bash
mise run build-all
mise run test-all
mise run lint-all
mise run format-all
mise run clean-all
```

### Utility
```bash
mise tasks              # List all available tasks
mise run help           # Show help
mise run setup          # Setup all SDKs
mise run check          # Run all checks
```

## Available SDKs

- `sdk/go` - Go 1.21+ project
- `sdk/rust` - Rust 1.75+ project
- `sdk/cpp` - C++17 project

## File Locations

```
mise-monorepo/
├── mise.toml           # Root config (orchestration)
├── sdk/go/mise.toml    # Go-specific tasks
├── sdk/rust/mise.toml  # Rust-specific tasks
└── sdk/cpp/mise.toml   # C++-specific tasks
```

## Quick Tests

```bash
# Test one SDK
cd sdk/go
mise run build
mise run test
mise run run

# Test all SDKs
cd ../..
mise run build-all
mise run test-all
```

## Documentation

- **README.md** - Complete guide (start here)
- **QUICKSTART.md** - 5-minute setup
- **ALTERNATIVES.md** - Tool comparison
- **SYNTAX-COMPARISON.md** - Mise vs Just
- **STRUCTURE.md** - File organization
- **PROJECT-SUMMARY.md** - Overview

## Key Findings

✅ **Modularization**: Excellent (per-directory mise.toml)
⚠️ **Path Validation**: Manual (bash scripting required)
⚠️ **Options Support**: Limited (env vars only)

## Verdict

**Use Mise Tasks If:**
- Already using mise for versions
- Want single tool
- Simple orchestration needs

**Use Just If:**
- Need positional arguments
- Want better CLI ergonomics
- Task running is primary need

**Best Combo:**
mise (versions) + just (tasks)

## Version Management

```bash
# Specified in .tool-versions
go 1.21.5
rust 1.75.0

# Install these versions
mise install

# Check current versions
mise current
```

## Troubleshooting

```bash
# Mise not found?
eval "$(mise activate bash)"

# Tasks not found?
cd /home/user/just-experiments/examples/mise-monorepo

# Languages not installed?
mise install  # or install manually
```

## Examples

```bash
# Development workflow
cd sdk/rust
mise run build
mise run test
mise run lint
mise run run

# CI/CD workflow
mise run build-all
mise run lint-all
mise run test-all

# Scripted workflow
for sdk in sdk/*; do
    PRODUCT=$sdk mise run build-env
done
```

## Comparison: Syntax

```bash
# Mise (namespaced)
mise run go:build

# Mise (env var)
PRODUCT=sdk/go mise run build-env

# Just (for comparison)
just build sdk/go
```

Just has cleaner syntax for dynamic arguments.

## Resources

- Mise: https://mise.jdx.dev/
- Just: https://just.systems/
- Task: https://taskfile.dev/

## Quick Links

Within this project:
- Start: `cat QUICKSTART.md`
- Help: `mise run help`
- List: `mise tasks`
- Validate: `./validate.sh`
