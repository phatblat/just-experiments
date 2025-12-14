# Mise Monorepo Task Runner Example

This project demonstrates using [mise](https://mise.jdx.dev/) (formerly rtx) as a task runner for a polyglot monorepo. Mise is primarily a version manager (like asdf) but includes a task runner feature that can be used for command orchestration.

## Project Structure

```
mise-monorepo/
├── mise.toml              # Root task configuration
├── sdk/
│   ├── go/
│   │   ├── mise.toml      # Go-specific tasks
│   │   ├── go.mod
│   │   ├── main.go
│   │   └── main_test.go
│   ├── rust/
│   │   ├── mise.toml      # Rust-specific tasks
│   │   ├── Cargo.toml
│   │   └── src/main.rs
│   └── cpp/
│       ├── mise.toml      # C++-specific tasks
│       ├── Makefile
│       └── main.cpp
└── README.md
```

## Prerequisites

### Installing Mise

```bash
# macOS/Linux
curl https://mise.run | sh

# Or with Homebrew
brew install mise

# Add to shell (bash example)
echo 'eval "$(mise activate bash)"' >> ~/.bashrc
```

### Required Tools

The SDKs require their respective language toolchains:

- **Go SDK**: Go 1.21+
- **Rust SDK**: Rust 1.70+ (with cargo)
- **C++ SDK**: g++ or clang with C++17 support

You can manage these versions with mise itself:

```bash
# Install language runtimes via mise
mise use go@1.21
mise use rust@latest
```

## Usage

### Quick Start

```bash
# Navigate to the monorepo root
cd /home/user/just-experiments/examples/mise-monorepo

# Show all available tasks
mise tasks

# Show help
mise run help

# Setup all SDKs
mise run setup

# Build and test everything
mise run build-all
mise run test-all
```

### Working with Individual SDKs

Mise doesn't have native support for custom positional arguments in tasks. This example demonstrates **four different approaches** to work around this limitation:

#### Approach 1: Environment Variables (Recommended by Mise)

```bash
# Set PRODUCT env var and run task
PRODUCT=sdk/go mise run build-env
PRODUCT=sdk/rust mise run test-env
PRODUCT=sdk/cpp mise run lint-env

# Can also export for multiple commands
export PRODUCT=sdk/go
mise run build-env
mise run test-env
```

**Pros:**
- Native mise support
- Works with all mise features
- Can be used in CI/CD

**Cons:**
- Verbose syntax
- Less intuitive than positional arguments
- Requires exporting or prefixing each command

#### Approach 2: Wrapper Script (Best UX)

```bash
# First, create the wrapper
mise run create-wrapper

# Then use it with natural syntax
./mise-wrapper.sh build sdk/go
./mise-wrapper.sh test sdk/rust
./mise-wrapper.sh lint sdk/cpp
```

**Pros:**
- Clean, intuitive syntax
- Validates paths automatically
- Acts like a traditional CLI tool

**Cons:**
- Requires an extra script
- Not pure mise
- Extra setup step

#### Approach 3: Namespaced Tasks (Most Explicit)

```bash
# Use product:command format
mise run go:build
mise run rust:test
mise run cpp:lint

# All commands per SDK
mise run go:install
mise run go:update
mise run go:format
mise run go:run
mise run go:clean
```

**Pros:**
- Explicit and type-safe
- Full tab completion
- Self-documenting via `mise tasks`

**Cons:**
- Must define each product×command combination
- Verbose configuration (N×M tasks)
- Doesn't scale well with many products

#### Approach 4: All-at-Once Tasks

```bash
# Run command for all SDKs
mise run build-all
mise run test-all
mise run lint-all
mise run format-all
mise run clean-all
```

**Pros:**
- Simple for monorepo-wide operations
- Good for CI/CD
- Parallel execution possible

**Cons:**
- All-or-nothing (can't target specific SDKs)
- May waste time building unchanged products

### Working Within Individual SDKs

You can also run tasks directly from within each SDK directory:

```bash
# Navigate to an SDK
cd sdk/go

# Run tasks directly (uses local mise.toml)
mise run build
mise run test
mise run lint
mise run format
mise run run
mise run clean
```

This is often the most natural way to work during development.

## Research Questions & Findings

### 1. Path Validation: Can mise validate that the product_path exists?

**Answer:** ⚠️ **Partially** - Mise doesn't have built-in path validation for task arguments.

**Findings:**
- Mise tasks don't natively support custom positional arguments
- Path validation must be implemented in bash within the task's `run` script
- The example demonstrates validation in the environment variable approach:

```toml
[tasks."build-env"]
run = """
if [ ! -d "$PRODUCT" ]; then
    echo "Error: Product directory '$PRODUCT' does not exist"
    exit 1
fi
"""
```

**Workarounds:**
- Use bash `[ -d "$path" ]` checks in task scripts
- Create a wrapper script that validates before invoking mise
- Use the namespaced approach (product:command) which is inherently valid

**Verdict:** Possible but requires manual implementation. Not a first-class feature.

### 2. Modularization: Can mise support modular task files?

**Answer:** ✅ **Yes** - Mise fully supports modular task files.

**Findings:**
- Each directory can have its own `mise.toml` with task definitions
- Tasks are scoped to their directory by default (via `dir = "{{cwd}}"`)
- Parent tasks can invoke child tasks using `cd <dir> && mise run <task>`
- Tasks are discovered hierarchically - mise looks up the directory tree

**Example:**
```toml
# sdk/go/mise.toml defines tasks
[tasks.build]
run = "go build ."

# Root mise.toml invokes them
[tasks."go:build"]
run = "cd sdk/go && mise run build"
```

**Best Practices:**
- Define SDK-specific tasks in SDK directories (`sdk/*/mise.toml`)
- Define orchestration tasks in root (`mise.toml`)
- Use `dir = "{{cwd}}"` to ensure tasks run in correct directory
- Keep task names consistent across SDKs (build, test, lint, etc.)

**Verdict:** Excellent modularization support. This is one of mise's strengths.

### 3. Options Support: How does mise handle flags like --dry-run, --quiet, --verbose?

**Answer:** ⚠️ **Limited** - Mise doesn't have native support for custom flags.

**Findings:**
- Mise tasks don't parse custom flags (like `--dry-run`)
- Available built-in mise options:
  - `mise run -n <task>` or `mise run --dry-run <task>` - Show what would run (mise built-in)
  - `mise run -v <task>` - Verbose output (mise built-in)
  - `mise -q run <task>` - Quiet mode (global mise flag)
- Custom flags must be implemented via environment variables:

```bash
# Custom flags via env vars
DRY_RUN=1 VERBOSE=1 mise run build-env

# Or in the task definition
[tasks.build]
run = """
if [ "${DRY_RUN:-0}" = "1" ]; then
    echo "Would run: go build"
    exit 0
fi
go build .
"""
```

**Available Built-in Options:**
```bash
mise run --dry-run task-name   # Show what would execute
mise run --verbose task-name   # Show verbose output
mise -q run task-name          # Quiet mode
mise tasks                     # List all tasks
mise run task1 task2 task3     # Run multiple tasks
```

**Verdict:** Basic dry-run support exists via mise's `--dry-run` flag, but custom option handling requires environment variables.

## Comparison: Mise vs. Other Task Runners

### Mise as a Task Runner

**Strengths:**
- ✅ Unified tool for version management AND task running
- ✅ Excellent modular task organization (per-directory mise.toml)
- ✅ Good for multi-language projects (already managing versions)
- ✅ Simple TOML syntax
- ✅ Task dependencies and conditional execution
- ✅ Built-in parallel execution support
- ✅ Environment variable management integrated

**Limitations:**
- ❌ No native support for custom positional arguments
- ❌ Limited custom flag/option support
- ❌ Task runner is a secondary feature (not the primary focus)
- ❌ Less mature than dedicated task runners
- ❌ Smaller ecosystem of plugins/extensions

### Comparison with Alternatives

| Feature | Mise | Just | Task (go-task) | Make |
|---------|------|------|----------------|------|
| Positional Args | ❌ (workarounds needed) | ✅ Native | ✅ Native | ✅ Via variables |
| Custom Flags | ⚠️ Via env vars | ✅ Native | ✅ Native | ❌ |
| Modular Files | ✅ Excellent | ✅ Via imports | ✅ Via includes | ⚠️ Via includes |
| Version Management | ✅ Built-in | ❌ | ❌ | ❌ |
| Multi-language | ✅ Designed for it | ✅ Good | ✅ Good | ✅ Good |
| Learning Curve | Medium | Low | Low | Low |
| Maturity (tasks) | ⚠️ New feature | ✅ Mature | ✅ Mature | ✅ Very mature |

## Recommendations

### When to Use Mise Tasks

**Good fit:**
- ✅ You're already using mise for version management
- ✅ You want a single tool for both versions and tasks
- ✅ Your tasks don't require complex argument parsing
- ✅ You're comfortable with environment variables or wrapper scripts
- ✅ You value modular task organization

**Not ideal:**
- ❌ You need complex CLI interfaces with many flags
- ❌ You need positional arguments as a primary interface
- ❌ You're building a user-facing CLI tool (use a proper language)
- ❌ You need advanced task runner features (use Task or Just)

### Recommended Approach for This Monorepo

For a polyglot monorepo like this, I recommend:

1. **Use the namespaced approach (product:command)** for explicit, self-documenting tasks
2. **Supplement with "*-all" tasks** for CI/CD and bulk operations
3. **Keep SDK-specific logic in SDK directories** (`sdk/*/mise.toml`)
4. **Use environment variables** when you need dynamic product selection

Example workflow:
```bash
# Development: Use namespaced tasks
mise run go:build
mise run rust:test

# CI/CD: Use all tasks
mise run build-all
mise run test-all

# Dynamic scripting: Use env vars
for product in sdk/*; do
    PRODUCT=$product mise run build-env
done
```

## Advanced Usage

### Task Dependencies

Tasks can depend on other tasks:

```toml
[tasks.test]
depends = ["build"]
run = "cargo test"
```

### Environment Variables

Tasks can set and use environment variables:

```toml
[tasks.build]
env = { RUST_BACKTRACE = "1", CARGO_TERM_COLOR = "always" }
run = "cargo build"
```

### Conditional Execution

Use shell conditionals within task scripts:

```toml
[tasks.build]
run = """
if [ "${CI:-}" = "true" ]; then
    go build -race .
else
    go build .
fi
"""
```

### Parallel Execution

Run multiple tasks in parallel:

```bash
# Mise will run these in parallel where possible
mise run go:build rust:build cpp:build
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install mise
        uses: jdx/mise-action@v2

      - name: Setup environment
        run: mise run setup

      - name: Run all tests
        run: mise run test-all

      - name: Run all lints
        run: mise run lint-all
```

## Conclusion

Mise's task runner feature is a **useful addition** to an already valuable version management tool, but it's not a replacement for dedicated task runners like Just, Task, or Make when complex argument handling is required.

**Best use case:** You're already using mise for version management in a polyglot project and want to add simple task orchestration without introducing another tool.

**Key takeaway:** Mise tasks excel at modular organization and integration with version management, but require creative workarounds for traditional CLI patterns like positional arguments and custom flags.

For this specific monorepo use case, mise works well when you:
- Accept its limitations around argument passing
- Use one of the workaround patterns (namespaced tasks, env vars, or wrapper scripts)
- Leverage its strength in modular task organization

If your primary need is a flexible task runner with great CLI ergonomics, consider [just](https://github.com/casey/just) or [Task](https://taskfile.dev/) instead. If you're already using mise for versions, the task feature is a convenient addition.

## Further Reading

- [Mise Documentation](https://mise.jdx.dev/)
- [Mise Tasks Documentation](https://mise.jdx.dev/tasks/)
- [Mise GitHub Repository](https://github.com/jdx/mise)
- [Comparison with other version managers](https://mise.jdx.dev/comparison-to-asdf.html)

## License

This example is provided as-is for educational purposes.
