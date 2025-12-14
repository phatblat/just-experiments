# Quick Start Guide

This guide will get you up and running with the mise monorepo example in under 5 minutes.

## Step 1: Install Mise

```bash
# macOS/Linux
curl https://mise.run | sh

# Or with Homebrew (macOS)
brew install mise

# Activate mise in your shell
echo 'eval "$(mise activate bash)"' >> ~/.bashrc
source ~/.bashrc
```

## Step 2: Navigate to the Project

```bash
cd /home/user/just-experiments/examples/mise-monorepo
```

## Step 3: Install Language Runtimes

Mise can manage your Go and Rust installations:

```bash
# Install the versions specified in .tool-versions
mise install

# Verify installations
mise list
go version
cargo --version
```

If you prefer to use system-installed versions, skip this step.

## Step 4: See Available Tasks

```bash
# List all tasks
mise tasks

# Show help
mise run help
```

## Step 5: Try It Out!

### Build Everything

```bash
mise run build-all
```

### Test Everything

```bash
mise run test-all
```

### Work with Individual SDKs

Choose your preferred approach:

**Option A: Namespaced (recommended)**
```bash
mise run go:build
mise run go:test
mise run go:run
```

**Option B: Environment Variables**
```bash
PRODUCT=sdk/rust mise run build-env
PRODUCT=sdk/rust mise run test-env
```

**Option C: Wrapper Script**
```bash
# Create the wrapper first
mise run create-wrapper

# Then use it
./mise-wrapper.sh build sdk/cpp
./mise-wrapper.sh test sdk/cpp
./mise-wrapper.sh run sdk/cpp
```

**Option D: Work in SDK Directory**
```bash
cd sdk/go
mise run build
mise run test
mise run run
cd ../..
```

## Step 6: Explore the Code

### Go SDK
```bash
cd sdk/go
cat main.go        # View the source
mise run build     # Build it
mise run test      # Test it
mise run run       # Run it
```

### Rust SDK
```bash
cd sdk/rust
cat src/main.rs    # View the source
mise run build     # Build it
mise run test      # Test it
mise run run       # Run it
```

### C++ SDK
```bash
cd sdk/cpp
cat main.cpp       # View the source
mise run build     # Build it
mise run test      # Test it
mise run run       # Run it
```

## Common Workflows

### Full CI Check
```bash
mise run check
```

This runs linting and testing for all SDKs.

### Clean Everything
```bash
mise run clean-all
```

### Format All Code
```bash
mise run format-all
```

## Troubleshooting

### "mise: command not found"

Make sure you've activated mise in your shell:
```bash
eval "$(mise activate bash)"
```

### "go: command not found" or "cargo: command not found"

Either:
1. Install via mise: `mise install`
2. Or install manually from [golang.org](https://go.dev) and [rust-lang.org](https://www.rust-lang.org/)

### "Task not found"

Make sure you're in the project root directory:
```bash
cd /home/user/just-experiments/examples/mise-monorepo
```

## Next Steps

- Read the full [README.md](README.md) for detailed information
- Explore different task invocation patterns
- Check out [mise.toml](mise.toml) to see how tasks are defined
- Look at individual SDK mise.toml files in `sdk/*/mise.toml`
- Experiment with creating your own tasks

## Useful Commands Reference

```bash
# Task management
mise tasks              # List all available tasks
mise run <task>         # Run a specific task
mise run help           # Show help information

# Version management
mise list              # List installed versions
mise install           # Install versions from .tool-versions
mise use go@1.22       # Switch to a different Go version
mise current           # Show currently active versions

# General
mise doctor            # Check mise installation
mise --help            # Show mise help
```

Happy hacking! 🚀
