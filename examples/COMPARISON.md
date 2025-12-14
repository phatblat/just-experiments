# Task Runner Comparison: Just vs Taskfile vs Mise

This directory contains three example monorepo implementations demonstrating how each task runner handles polyglot project management.

## Quick Summary

| Feature | Just | Taskfile | Mise |
|---------|------|----------|------|
| **Command Syntax** | `just build sdk/go` | `task build SDK=sdk/go` | `mise run go:build` |
| **Path Validation** | ✅ Via shell scripts | ✅ Via preconditions | ⚠️ Manual implementation |
| **Modularization** | ✅ Directory-based | ✅ `includes` directive | ✅ Per-directory configs |
| **--dry-run** | ✅ Built-in | ✅ Built-in | ✅ Built-in |
| **--verbose** | ✅ Built-in | ✅ Built-in | ✅ Built-in |
| **--quiet** | ✅ Built-in | ✅ `--silent` | ✅ `-q` |
| **Positional args** | ✅ Native | ⚠️ Via variables | ❌ Not supported |
| **Config format** | Custom (make-like) | YAML | TOML |
| **Primary purpose** | Task runner | Task runner | Version manager + tasks |

## Detailed Findings

### 1. Just (`examples/just-monorepo/`)

**Strengths:**
- Most intuitive CLI syntax: `just build sdk/go`
- Native positional argument support
- Simple make-like syntax, easy to learn
- Fast (Rust binary)
- Excellent for your use case

**Limitations:**
- No built-in dependency graph or caching
- Manual "all" patterns implementation
- No built-in parallelization

**Best syntax achieved:**
```bash
just build sdk/go
just test sdk/rust --verbose
just build-all
```

### 2. Taskfile (`examples/taskfile-monorepo/`)

**Strengths:**
- Clean YAML configuration
- Excellent `includes` for modularization
- Built-in watch mode and parallelization
- Good incremental build support via `sources`/`generates`
- Strong cross-platform support

**Limitations:**
- Requires variable syntax: `SDK=sdk/go`
- Go template syntax can be verbose
- Manual path validation needed

**Best syntax achieved:**
```bash
task build SDK=sdk/go
task go:build          # Namespaced direct call
task build-all
```

### 3. Mise (`examples/mise-monorepo/`)

**Strengths:**
- Integrated version management (Go, Rust, Node, etc.)
- Per-directory config autodiscovery
- Single tool for versions + tasks
- Good modularization

**Limitations:**
- Task running is secondary feature
- No native positional arguments
- Requires environment variables or namespaced tasks
- Less mature task features

**Best syntax achieved:**
```bash
mise run go:build              # Namespaced
PRODUCT=sdk/go mise run build  # Env variable
mise run build-all
```

## Recommendation Matrix

| Use Case | Recommended Tool |
|----------|------------------|
| Simple monorepo, clean CLI | **Just** |
| Complex builds, need caching/watch | **Taskfile** |
| Already using mise for versions | **Mise** |
| Maximum flexibility | **Just** or **Taskfile** |
| CI/CD pipelines | **Taskfile** (YAML) |
| Migration from Make | **Just** |

## Your Requirements Assessment

Based on your specific requirements:

### Syntax: `<launcher> <command> <product_path> (<options>)`

| Tool | Achievable | How |
|------|------------|-----|
| **Just** | ✅ Perfect match | `just build sdk/go --verbose` |
| **Taskfile** | ⚠️ Close | `task build SDK=sdk/go -- --verbose` |
| **Mise** | ⚠️ Requires workaround | `mise run go:build` or wrapper script |

### Modularization (project-specific files in each sdk/)

All three tools support this well:
- **Just**: `sdk/go/justfile` invoked via `just --justfile`
- **Taskfile**: `sdk/go/Taskfile.yml` via `includes:`
- **Mise**: `sdk/go/mise.toml` autodiscovered

### Path Validation

- **Just**: Shell script checking `test -d "$path"`
- **Taskfile**: Preconditions with `sh: test -d {{.SDK}}`
- **Mise**: Manual validation in task scripts

## Other Tools to Consider

For large-scale monorepos, also evaluate:

| Tool | Best For | Trade-off |
|------|----------|-----------|
| **Make** | Universal availability | Dated syntax, tabs matter |
| **Bazel** | Huge monorepos, hermetic builds | Steep learning curve |
| **Nx** | JS/TS monorepos | Language-focused |
| **Turborepo** | JS/TS with caching | Language-focused |
| **Earthly** | Containerized builds | Requires Docker |
| **Gradle** | JVM projects | Heavy for simple needs |

## Getting Started

```bash
# Try Just
cd examples/just-monorepo
just --list
just build sdk/go
just run sdk/go "Hello"

# Try Taskfile
cd examples/taskfile-monorepo
task --list
task build SDK=sdk/go
task run SDK=sdk/go CLI_ARGS="Hello"

# Try Mise
cd examples/mise-monorepo
mise tasks
mise run go:build
mise run go:run
```

## Final Verdict

**For your use case (polyglot monorepo facade):**

🥇 **Just** - Best CLI ergonomics, perfect syntax match, simple and fast

🥈 **Taskfile** - Best if you need YAML, watch mode, or CI integration

🥉 **Mise** - Best if you're already using it for version management

The choice between Just and Taskfile often comes down to preference between make-like syntax vs YAML configuration.
