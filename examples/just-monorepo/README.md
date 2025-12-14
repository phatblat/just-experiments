# Just Monorepo Command Launcher

This project demonstrates using [just](https://github.com/casey/just) as a command launcher for a polyglot monorepo with multiple SDK projects.

## Overview

This monorepo contains multiple SDK implementations:
- **sdk/cpp** - C++ hello world CLI
- **sdk/go** - Go hello world CLI
- **sdk/rust** - Rust hello world CLI
- **sdk/swift** - (placeholder, not implemented)

Each SDK can be built, tested, and run independently using a consistent command interface powered by `just`.

## Installation

First, ensure you have `just` installed:

```bash
# Via cargo
cargo install just

# Via homebrew (macOS)
brew install just

# Via mise
mise install just
```

## Usage

### Basic Command Syntax

```bash
just <command> <product_path> [options]
```

### Available Commands

#### Per-SDK Commands

```bash
# Install dependencies
just install sdk/go

# Update dependencies
just update sdk/rust

# Lint code
just lint sdk/cpp

# Format code
just format sdk/go

# Build
just build sdk/rust

# Test
just test sdk/go

# Run (with optional arguments)
just run sdk/rust "Hello World"

# Clean build artifacts
just clean sdk/cpp
```

#### Monorepo-Wide Commands

```bash
# Run command for ALL SDKs
just build-all
just test-all
just lint-all
just format-all
just clean-all

# Check SDK configuration
just check

# Show available SDKs
just list-sdks

# Run CI pipeline (lint, test, build all)
just ci
```

### Examples

```bash
# Build and run the Go SDK
just build sdk/go
just run sdk/go "from monorepo"

# Build and test the Rust SDK
just build sdk/rust
just test sdk/rust

# Run tests for all SDKs
just test-all

# Clean all build artifacts
just clean-all
```

## Research Findings

### 1. Path Validation

**Can `just` validate that the product_path exists as a directory?**

**Answer: YES** - `just` supports path validation through shell scripts in recipes.

**Implementation:**
```justfile
[private]
validate-path path:
    #!/usr/bin/env bash
    if [ ! -d "{{path}}" ]; then
        echo "Error: Path '{{path}}' does not exist or is not a directory"
        exit 1
    fi
    if [ ! -f "{{path}}/justfile" ]; then
        echo "Error: No justfile found in '{{path}}'"
        exit 1
    fi
```

**How it works:**
- The `[private]` attribute prevents the recipe from being listed in `just --list`
- Variables are interpolated with `{{variable}}` syntax
- Shell scripts can be embedded using shebang lines (`#!/usr/bin/env bash`)
- Exit codes propagate correctly, causing dependent recipes to fail

**Example:**
```bash
$ just build nonexistent/path
Error: Path 'nonexistent/path' does not exist or is not a directory
error: Recipe `validate-path` failed with exit code 1
```

### 2. Modularization

**Can `just` support modular justfiles? Can you have a justfile in each sdk/* folder?**

**Answer: YES** - `just` supports modular justfiles through directory-based recipe execution.

**Implementation Approaches:**

#### A. Directory-Based Execution (Used in this project)
Each SDK has its own `justfile` with SDK-specific recipes. The root `justfile` changes directory and invokes the SDK's `justfile`:

```justfile
# Root justfile
build path *FLAGS:
    @just validate-path {{path}}
    cd {{path}} && just {{FLAGS}} build

# SDK justfile (sdk/go/justfile)
build:
    @echo "Building Go binary..."
    go build -o bin/sdk-go main.go
```

**Pros:**
- Clean separation of concerns
- Each SDK maintains its own recipes
- Easy to understand and maintain
- SDK teams can work independently

**Cons:**
- Requires `cd` to change context
- Cannot directly import recipes from other justfiles

#### B. Import Directive (Alternative approach)
`just` supports importing other justfiles with the `import` directive (since v1.14.0):

```justfile
# Alternative approach using imports
import 'sdk/go/justfile'
import 'sdk/rust/justfile'

# Can now call recipes from imported files
# Note: This requires recipes to have unique names or use modules
```

However, this approach has limitations:
- Imported recipes run in the context of the importing justfile's directory
- Name collisions can occur if multiple justfiles have recipes with the same name
- Less suitable for our use case where we want SDK-specific context

#### C. Module System (since v1.19.0)
`just` introduced a module system that allows more sophisticated organization:

```justfile
# Using modules
mod go 'sdk/go/justfile'
mod rust 'sdk/rust/justfile'

# Call module recipes
build-go:
    @just go::build
```

**Recommendation:** For monorepo command launchers, the directory-based execution approach (used in this project) provides the best balance of simplicity and maintainability.

### 3. Options Support

**How does `just` handle --dry-run, --quiet, --verbose flags?**

**Answer:** `just` has built-in support for these flags at the command level.

#### Built-in Flags

| Flag | Description | Example |
|------|-------------|---------|
| `--dry-run` | Print recipes that would be executed without running them | `just --dry-run build sdk/go` |
| `--verbose` | Show more detailed output | `just --verbose build sdk/rust` |
| `--quiet` | Suppress output (only errors shown) | `just --quiet test-all` |
| `--yes` | Automatically answer yes to prompts | `just --yes clean-all` |

#### Examples

**Dry Run Mode:**
```bash
$ just --dry-run build sdk/go
just validate-path sdk/go
echo "Building sdk/go..."
cd sdk/go && just  build
```

**Verbose Mode:**
```bash
$ just --verbose build sdk/rust
===> Running recipe `build`...
just validate-path sdk/rust
echo "Building sdk/rust..."
Building sdk/rust...
cd sdk/rust && just  build
Building Rust binary...
cargo build --release
    Finished `release` profile [optimized] target(s) in 0.03s
```

#### Custom Flags

You can pass custom flags through to SDK justfiles using variadic arguments:

```justfile
build path *FLAGS:
    cd {{path}} && just {{FLAGS}} build
```

Then use like:
```bash
just build sdk/go --verbose
```

This passes `--verbose` to the SDK's justfile.

### 4. Pros and Cons

#### Pros

1. **Simple and Intuitive**
   - Easy to learn and use
   - Familiar make-like syntax
   - Clear, readable recipe definitions

2. **Cross-Platform**
   - Works on Linux, macOS, Windows
   - No complex dependencies
   - Single binary installation

3. **Powerful Features**
   - Variables and string interpolation
   - Dependencies between recipes
   - Conditional execution
   - Variadic arguments (`*ARGS`)
   - Shell script integration
   - Built-in command-line flags

4. **Good for Monorepos**
   - Supports modular justfiles
   - Easy to create SDK-specific recipes
   - Can run commands across multiple projects
   - Directory-based execution works well

5. **Developer Experience**
   - Fast execution
   - Helpful error messages
   - Auto-completion support
   - `just --list` shows all available recipes
   - `--dry-run` for previewing commands

6. **Flexible**
   - Can invoke any language's tools (cargo, go, make, etc.)
   - Supports polyglot codebases
   - Easy to integrate with CI/CD

#### Cons

1. **Limited Import System**
   - Cannot easily share recipes between justfiles
   - Imported recipes run in wrong directory context for our use case
   - Module system exists but adds complexity

2. **No Built-in Workspace Concept**
   - No native understanding of monorepo structure
   - Must manually implement "run for all SDKs" logic
   - Path management is manual

3. **Recipe Context**
   - Recipes run in the directory of the justfile by default
   - Requires explicit `cd` commands to change context
   - Can be confusing when working with nested justfiles

4. **Error Handling**
   - No built-in retry logic
   - Error handling requires shell scripting
   - Cannot easily continue on error (must use `|| true`)

5. **Documentation**
   - Comments in justfiles are not shown in `just --list`
   - No built-in help text beyond recipe names
   - Must maintain separate documentation

6. **Type Safety**
   - No type checking for arguments
   - Easy to pass wrong parameters
   - Runtime errors only

7. **Dependency Management**
   - No built-in dependency between different justfiles
   - Must manually ensure build order for dependent SDKs
   - Cannot easily express "build sdk/go if sdk/common changes"

#### Comparison to Alternatives

| Feature | just | make | task | nx |
|---------|------|------|------|-----|
| Learning curve | Low | Medium | Low | High |
| Polyglot support | ✅ | ✅ | ✅ | ✅ |
| Modular files | Partial | No | ✅ | ✅ |
| Workspace aware | ❌ | ❌ | Partial | ✅ |
| Caching | ❌ | ✅ | ✅ | ✅ |
| Dependency graph | ❌ | ✅ | ✅ | ✅ |
| Cross-platform | ✅ | Partial | ✅ | ✅ |
| Installation | Easy | Built-in | Easy | Requires Node |

## Key Capabilities Demonstrated

### 1. Path Validation ✅
- Validates that SDK path exists
- Checks for justfile presence
- Provides clear error messages

### 2. Modular Justfiles ✅
- Each SDK has its own justfile
- Root justfile coordinates SDK operations
- Clean separation of concerns

### 3. Command Routing ✅
- Consistent interface for all SDKs
- Commands route to appropriate SDK justfile
- Support for SDK-specific and monorepo-wide operations

### 4. Polyglot Support ✅
- Supports Go, Rust, C++, and other languages
- Each SDK uses its native tools
- Unified interface across languages

### 5. Options Handling ✅
- Built-in --dry-run, --verbose, --quiet support
- Custom flags can be passed through
- Flexible argument handling with *ARGS

## Best Practices

1. **Use Path Validation**
   - Always validate paths before operations
   - Provide clear error messages
   - Use `[private]` recipes for internal helpers

2. **Keep SDK Justfiles Independent**
   - Each SDK justfile should be runnable standalone
   - Don't rely on root justfile recipes
   - Use relative paths within SDK justfiles

3. **Provide Monorepo-Wide Commands**
   - Create `-all` variants for common operations
   - Use shell loops for iterating over SDKs
   - Handle errors gracefully with `|| echo "Failed"`

4. **Document Your Recipes**
   - Add comments above recipes (shown in `just --list`)
   - Maintain a README with examples
   - Use descriptive recipe names

5. **Use Variadic Arguments**
   - Support passing arguments with `*ARGS` or `*FLAGS`
   - Makes recipes more flexible
   - Enables dry-run and verbose modes

## Conclusion

`just` is a capable command launcher for polyglot monorepos with these key findings:

**Strengths:**
- Simple, intuitive syntax
- Good modularization through directory-based execution
- Built-in support for common flags (--dry-run, --verbose)
- Excellent for teams wanting a make-like tool that's easier to use
- Works well for medium-sized monorepos

**Limitations:**
- No native workspace/monorepo understanding
- Limited recipe sharing between justfiles
- No dependency graph or caching
- Requires manual implementation of monorepo patterns

**Recommendation:**
Use `just` when:
- You want a simple, make-like tool with better ergonomics
- Your monorepo has independent SDKs with minimal cross-dependencies
- You prefer explicit over implicit behavior
- You don't need advanced features like caching or dependency graphs

Consider alternatives (nx, turborepo, bazel) when:
- You need sophisticated caching
- You have complex inter-project dependencies
- You require build optimization at scale
- You want more monorepo-specific features

For this use case, `just` provides a clean, maintainable solution that's easy for developers to understand and extend.
