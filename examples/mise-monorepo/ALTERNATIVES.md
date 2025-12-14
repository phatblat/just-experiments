# Task Runner Alternatives Comparison

This document compares mise's task runner feature with other popular task runners for polyglot monorepos.

## Overview

For the same monorepo use case, here's how different tools would handle the command pattern:
```
<tool> <command> <product_path>
```

## 1. Mise (This Example)

### Syntax
```bash
# Approach 1: Namespaced (recommended)
mise run go:build

# Approach 2: Environment variable
PRODUCT=sdk/go mise run build-env

# Approach 3: Wrapper script
./mise-wrapper.sh build sdk/go
```

### Pros
- ✅ Integrated version management (primary feature)
- ✅ Excellent modular task organization (per-directory mise.toml)
- ✅ Simple TOML syntax
- ✅ Single tool for versions + tasks
- ✅ Built-in task dependencies

### Cons
- ❌ No native positional arguments
- ❌ Requires workarounds for dynamic product selection
- ❌ Task runner is secondary feature
- ❌ Less mature task ecosystem

### Best For
- Projects already using mise for version management
- Simple task orchestration needs
- Teams that value minimal tooling

## 2. Just (casey/just)

### Syntax
```bash
just build sdk/go
just test sdk/rust
```

### Implementation
```just
# justfile
build path:
    #!/usr/bin/env bash
    if [ ! -d "{{path}}" ]; then
        echo "Error: {{path}} not found"
        exit 1
    fi
    cd "{{path}}" && just build

# sdk/go/justfile
build:
    go build -o bin/sdk-go .
```

### Pros
- ✅ Native positional arguments
- ✅ Clean, makefile-like syntax
- ✅ Excellent string interpolation
- ✅ Mature and battle-tested
- ✅ Great CLI ergonomics
- ✅ Recipe parameters with defaults

### Cons
- ❌ No version management
- ❌ Requires separate justfiles (less DRY)
- ⚠️ Less structured than YAML/TOML (personal preference)

### Best For
- Projects that need flexible command arguments
- Teams comfortable with make-like syntax
- When CLI ergonomics are priority

## 3. Task (go-task/task)

### Syntax
```bash
task build -- sdk/go
task test -- sdk/rust
```

### Implementation
```yaml
# Taskfile.yml
version: '3'

tasks:
  build:
    desc: Build a product
    cmds:
      - |
        if [ ! -d "{{.CLI_ARGS}}" ]; then
          echo "Error: {{.CLI_ARGS}} not found"
          exit 1
        fi
        cd {{.CLI_ARGS}} && task build

# sdk/go/Taskfile.yml
version: '3'
tasks:
  build:
    cmds:
      - go build -o bin/sdk-go .
```

### Pros
- ✅ Arguments via `{{.CLI_ARGS}}`
- ✅ Clean YAML syntax
- ✅ Excellent task dependency management
- ✅ Built-in file watching
- ✅ Cross-platform (written in Go)
- ✅ Structured task definitions

### Cons
- ❌ No version management
- ⚠️ Requires `--` separator for arguments
- ⚠️ CLI_ARGS is string-based (limited parsing)

### Best For
- Projects that want structured task definitions
- Teams that prefer YAML
- Cross-platform requirements

## 4. Make (GNU Make)

### Syntax
```bash
make build PRODUCT=sdk/go
make test PRODUCT=sdk/rust
```

### Implementation
```makefile
# Makefile
build:
    @test -d "$(PRODUCT)" || (echo "Error: $(PRODUCT) not found" && exit 1)
    cd $(PRODUCT) && $(MAKE) build

# sdk/go/Makefile
build:
    go build -o bin/sdk-go .
```

### Pros
- ✅ Universally available
- ✅ Time-tested and stable
- ✅ Excellent file-based dependencies
- ✅ Powerful pattern rules
- ✅ No installation needed

### Cons
- ❌ No version management
- ❌ Arcane syntax and whitespace rules (tabs required)
- ❌ Limited to variable-based parameters
- ❌ Poor error messages
- ⚠️ Platform differences (GNU Make vs BSD Make)

### Best For
- Projects that need maximum compatibility
- Build systems focused on file dependencies
- When no additional tools can be installed

## 5. Bazel

### Syntax
```bash
bazel build //sdk/go:sdk-go
bazel test //sdk/rust:sdk-rust
```

### Implementation
```python
# BUILD.bazel files in each directory
go_binary(
    name = "sdk-go",
    srcs = ["main.go"],
)
```

### Pros
- ✅ Extremely powerful for large monorepos
- ✅ Hermetic builds
- ✅ Advanced caching and remote execution
- ✅ Multi-language by design
- ✅ Scales to Google-sized codebases

### Cons
- ❌ Steep learning curve
- ❌ Heavy-weight for small projects
- ❌ Requires BUILD files everywhere
- ❌ Different mental model
- ❌ Complex setup

### Best For
- Large companies with huge monorepos
- Teams with dedicated build engineers
- When build reproducibility is critical

## 6. Nx

### Syntax
```bash
nx build sdk-go
nx test sdk-rust
```

### Implementation
```json
// workspace.json or project.json
{
  "projects": {
    "sdk-go": {
      "targets": {
        "build": {
          "executor": "@nrwl/workspace:run-commands",
          "options": {
            "command": "go build ."
          }
        }
      }
    }
  }
}
```

### Pros
- ✅ Powerful dependency graph
- ✅ Intelligent caching
- ✅ Great for JavaScript/TypeScript ecosystems
- ✅ Visual project graph
- ✅ Affected command (test only changed)

### Cons
- ❌ Node.js focused (though supports others)
- ❌ Heavy for non-JS projects
- ❌ Opinionated project structure
- ❌ Complex configuration

### Best For
- JavaScript/TypeScript monorepos
- Teams already using Node.js
- When intelligent caching is needed

## 7. Rush

### Syntax
```bash
rush build --to sdk-go
rush test --to sdk-rust
```

### Pros
- ✅ Designed for large JavaScript monorepos
- ✅ Powerful dependency management
- ✅ Parallel execution
- ✅ Lock file management

### Cons
- ❌ JavaScript/TypeScript only
- ❌ Complex setup
- ❌ Opinionated workflows

### Best For
- Large JavaScript monorepos
- Enterprise TypeScript projects

## Feature Comparison Matrix

| Feature | Mise | Just | Task | Make | Bazel | Nx |
|---------|------|------|------|------|-------|-----|
| **Positional Args** | ❌ | ✅ | ⚠️ | ❌ | ✅ | ✅ |
| **Version Mgmt** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Modular Tasks** | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ |
| **Learning Curve** | Medium | Low | Low | Low | High | High |
| **Installation** | Required | Required | Required | Built-in | Required | Required |
| **Config Format** | TOML | Just | YAML | Makefile | Starlark | JSON |
| **Maturity (tasks)** | New | Mature | Mature | Very Mature | Mature | Mature |
| **Caching** | ❌ | ❌ | ⚠️ | ⚠️ | ✅✅✅ | ✅✅ |
| **Parallel Exec** | ✅ | ⚠️ | ✅ | ⚠️ | ✅✅✅ | ✅✅ |
| **Multi-language** | ✅ | ✅ | ✅ | ✅ | ✅✅✅ | ⚠️ |
| **Watch Mode** | ❌ | ❌ | ✅ | ❌ | ✅ | ✅ |
| **Remote Exec** | ❌ | ❌ | ❌ | ❌ | ✅ | ⚠️ |

Legend: ✅ = Full support, ⚠️ = Partial/Limited, ❌ = Not supported

## Decision Matrix

### Choose Mise if:
- ✓ You're already using mise for version management
- ✓ You want one tool for versions + tasks
- ✓ Your tasks don't need complex arguments
- ✓ You value modular task organization
- ✓ You prefer TOML configuration

### Choose Just if:
- ✓ You need flexible command arguments
- ✓ You want simple, make-like syntax
- ✓ CLI ergonomics are important
- ✓ You're comfortable with recipes
- ✓ You don't need version management

### Choose Task if:
- ✓ You prefer YAML configuration
- ✓ You need structured task definitions
- ✓ Cross-platform support is critical
- ✓ You want built-in file watching
- ✓ Task dependencies are complex

### Choose Make if:
- ✓ You can't install additional tools
- ✓ File-based dependencies are key
- ✓ Maximum compatibility needed
- ✓ Your team already knows Make
- ✓ You're okay with arcane syntax

### Choose Bazel if:
- ✓ You have a very large monorepo (1000+ projects)
- ✓ Build reproducibility is critical
- ✓ You need hermetic builds
- ✓ You can invest in learning/maintenance
- ✓ Remote execution is needed

### Choose Nx if:
- ✓ JavaScript/TypeScript monorepo
- ✓ You need intelligent caching
- ✓ Affected-based testing is valuable
- ✓ You want a visual project graph
- ✓ Your team uses Node.js

## Real-World Example Comparison

For the command: "Build the Go SDK"

```bash
# Mise (namespaced approach)
mise run go:build

# Mise (env var approach)
PRODUCT=sdk/go mise run build-env

# Just
just build sdk/go

# Task
task build -- sdk/go

# Make
make build PRODUCT=sdk/go

# Bazel
bazel build //sdk/go:sdk-go

# Nx
nx build sdk-go
```

## Recommendation for This Monorepo

For a polyglot monorepo with Go, Rust, C++, etc.:

### 1st Choice: **Just**
- Best CLI ergonomics
- Native argument support
- Simple and powerful
- Great for polyglot projects

### 2nd Choice: **Task**
- Structured YAML
- Good cross-platform support
- Excellent task dependencies
- Watch mode built-in

### 3rd Choice: **Mise** (if already using it)
- Avoid adding another tool
- Good modular organization
- Use namespaced tasks pattern
- Acceptable for simpler workflows

### For Large Scale: **Bazel**
- Only if you have 100+ developers
- Requires dedicated build team
- Overkill for most projects
- Best-in-class at scale

## Hybrid Approach

You can also combine tools:

```bash
# Use mise for version management
# Use just for task running
# .tool-versions
go 1.21.5
rust 1.75.0

# justfile
build path:
    cd {{path}} && just build
```

This gives you:
- Mise's version management
- Just's superior task syntax
- Best of both worlds

## Conclusion

For this specific use case (polyglot monorepo with dynamic product paths):

1. **Just** is the best pure task runner
2. **Task** is the best structured option
3. **Mise** is acceptable if already using it for versions
4. **Make** works but is dated
5. **Bazel/Nx** are overkill unless you're at scale

Mise's task feature is useful for simple orchestration when you're already using mise for version management, but it's not competitive with dedicated task runners for complex CLI patterns.

## Resources

- [Just](https://github.com/casey/just)
- [Task](https://taskfile.dev/)
- [Mise](https://mise.jdx.dev/)
- [Make](https://www.gnu.org/software/make/)
- [Bazel](https://bazel.build/)
- [Nx](https://nx.dev/)
- [Rush](https://rushjs.io/)
