# Quick Start Guide

Get started with the just monorepo in under 5 minutes!

## Prerequisites

- **just** - Install via `cargo install just` or `brew install just`
- **Go** - For sdk/go (optional)
- **Rust** - For sdk/rust (optional)
- **C++** - For sdk/cpp (optional)

## Quick Setup

```bash
# 1. Navigate to the monorepo
cd examples/just-monorepo

# 2. List all available commands
just --list

# 3. Check SDK configuration
just check
```

## Try It Out

### Test Individual SDKs

```bash
# Go SDK
just build sdk/go
just test sdk/go
just run sdk/go "Hello from Go"

# Rust SDK
just build sdk/rust
just test sdk/rust
just run sdk/rust "Hello from Rust"

# C++ SDK
just build sdk/cpp
just test sdk/cpp
just run sdk/cpp "Hello from C++"
```

### Test Monorepo-Wide Commands

```bash
# Run tests for all SDKs
just test-all

# Build all SDKs
just build-all

# Clean all build artifacts
just clean-all
```

## Common Workflows

### Developing a Single SDK

```bash
# Work on the Go SDK
cd sdk/go

# Use the local justfile directly
just build
just test
just run

# Or from the root
cd ../..
just build sdk/go
just test sdk/go
```

### CI Pipeline

```bash
# Run the full CI pipeline
just ci

# This will:
# 1. Lint all SDKs
# 2. Test all SDKs
# 3. Build all SDKs
```

### Debugging

```bash
# Preview commands without executing (dry-run)
just --dry-run build sdk/go

# See detailed output (verbose)
just --verbose build sdk/rust

# Quiet mode (only errors)
just --quiet test-all
```

## Next Steps

1. Read the [full README](README.md) for detailed research findings
2. Explore the [root justfile](justfile) to see how commands are routed
3. Check SDK-specific justfiles:
   - [sdk/go/justfile](sdk/go/justfile)
   - [sdk/rust/justfile](sdk/rust/justfile)
   - [sdk/cpp/justfile](sdk/cpp/justfile)
4. Try adding your own SDK!

## Tips

- Use `just --list` to see all available commands
- Use `just --dry-run <command>` to preview what will be executed
- Each SDK can be developed independently
- The root justfile provides a consistent interface across all SDKs

## Troubleshooting

**Command not found:**
```bash
# Make sure just is in your PATH
export PATH="$HOME/.cargo/bin:$PATH"
just --version
```

**Path does not exist:**
```bash
# Make sure you're using the correct path
just list-sdks  # See available SDKs
just check      # Verify configuration
```

**Build failures:**
```bash
# Check if the SDK's tools are installed
go version
cargo --version
g++ --version
```

## Learn More

- [just documentation](https://just.systems/)
- [just GitHub repository](https://github.com/casey/just)
- [Full research findings](README.md)
