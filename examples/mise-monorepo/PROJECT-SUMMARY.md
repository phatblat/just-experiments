# Project Summary: Mise Monorepo Task Runner Example

## Overview

This project is a comprehensive demonstration and evaluation of [mise](https://mise.jdx.dev/)'s task runner feature as a command launcher for polyglot monorepos. It was created to answer specific research questions about mise's capabilities and limitations compared to dedicated task runners.

**Location:** `/home/user/just-experiments/examples/mise-monorepo`

**Total Lines of Code:** ~2,848 lines

**Created:** December 2025

## What Was Built

### 1. Working Polyglot Monorepo

Three fully functional SDK projects:

- **Go SDK** (`sdk/go`)
  - Hello World CLI application
  - Go modules configuration
  - Unit tests
  - All 8 commands implemented

- **Rust SDK** (`sdk/rust`)
  - Hello World CLI application
  - Cargo package manifest
  - Unit tests
  - All 8 commands implemented

- **C++ SDK** (`sdk/cpp`)
  - Hello World CLI application
  - Makefile-based build
  - Simple tests
  - All 8 commands implemented

### 2. Mise Task Configurations

- **Root `mise.toml`**: Orchestrates all SDK tasks
  - 4 different invocation patterns demonstrated
  - 18+ namespaced tasks (product:command)
  - 5 all-at-once tasks (build-all, test-all, etc.)
  - Utility tasks (setup, check, help)
  - Wrapper script generator

- **SDK-level `mise.toml` files**: One per SDK
  - 8 standard commands each
  - Modular and reusable
  - Can be called directly or from root

### 3. Comprehensive Documentation

**README.md** (Primary Documentation)
- Complete usage guide
- Answers all three research questions
- Pros/cons analysis
- Comparison with other tools
- Best practices
- CI/CD integration examples

**QUICKSTART.md** (Getting Started)
- 5-minute setup guide
- Step-by-step instructions
- Common workflows
- Troubleshooting tips

**ALTERNATIVES.md** (Tool Comparison)
- Detailed comparison of 7 task runners
- Feature comparison matrix
- Decision guide
- Real-world examples
- Hybrid approach recommendations

**SYNTAX-COMPARISON.md** (Side-by-Side Examples)
- Direct comparison: Mise vs Just
- 15+ common patterns
- Code examples for each
- Feature comparison table
- Best practices

**STRUCTURE.md** (Project Documentation)
- Complete file tree
- File descriptions
- Configuration hierarchy
- Usage patterns
- Extension guide

**PROJECT-SUMMARY.md** (This File)
- High-level overview
- Research findings
- Key takeaways
- Recommendations

### 4. Comparison Examples

Complete Just configurations provided for comparison:
- `justfile.example` at root
- `sdk/go/justfile.example`
- `sdk/rust/justfile.example`
- `sdk/cpp/justfile.example`

Shows what the same monorepo looks like with a dedicated task runner.

### 5. Validation & Tooling

- **`validate.sh`**: Comprehensive validation script
  - Checks tool installations
  - Verifies project structure
  - Validates configuration files
  - Tests builds (if tools available)
  - Colored output and summary

- **`.tool-versions`**: Mise version management
  - Specifies Go 1.21.5
  - Specifies Rust 1.75.0

- **`.gitignore`**: Standard ignore patterns

## Research Questions Answered

### 1. Path Validation

**Question:** Can mise validate that the product_path exists as a directory?

**Answer:** ⚠️ **Partially** - Not natively supported.

**Findings:**
- Mise doesn't have built-in path validation for task arguments
- Positional arguments aren't natively supported at all
- Validation must be implemented via bash scripts in task definitions
- Demonstrated working validation in environment variable approach
- Namespaced approach (go:build) avoids the issue entirely

**Recommendation:** Use namespaced tasks or implement bash validation.

### 2. Modularization

**Question:** Can mise support modular task files? Can you have a mise.toml in each sdk/* folder?

**Answer:** ✅ **Yes** - Excellent support.

**Findings:**
- Each directory can have its own `mise.toml`
- Tasks are scoped to their directory
- Parent tasks can invoke child tasks via `cd <dir> && mise run <task>`
- Hierarchical task discovery works well
- This is one of mise's strongest features

**Recommendation:** Use modular mise.toml files. This is the recommended pattern.

### 3. Options Support

**Question:** How does mise handle --dry-run, --quiet, --verbose flags?

**Answer:** ⚠️ **Limited** - Basic built-in support, no custom flags.

**Findings:**
- Mise provides: `--dry-run`, `-v` (verbose), `-q` (quiet)
- These are mise-level flags, not task-level
- Custom flags must be implemented via environment variables
- No native support for task-specific options
- `mise run --dry-run task` shows what would execute

**Recommendation:** Use mise's built-in flags where possible; use env vars for custom options.

## Key Findings

### Mise Task Runner Strengths

1. **✅ Excellent Modularity**
   - Per-directory mise.toml files work perfectly
   - Clean separation of concerns
   - Easy to maintain

2. **✅ Integrated Version Management**
   - Single tool for versions AND tasks
   - Reduces tooling complexity
   - Good for polyglot projects

3. **✅ Simple Configuration**
   - TOML is clear and structured
   - Task dependencies work well
   - Environment variable support

4. **✅ Good for Simple Orchestration**
   - Works well for straightforward workflows
   - Adequate for most monorepo needs
   - Reliable task execution

### Mise Task Runner Limitations

1. **❌ No Native Positional Arguments**
   - Biggest limitation for CLI-style usage
   - Requires workarounds (env vars, wrapper scripts, namespacing)
   - Makes `mise run <command> <path>` pattern impossible directly

2. **❌ Limited Custom Flag Support**
   - No task-level option parsing
   - Must use environment variables
   - Less intuitive than traditional CLIs

3. **❌ Task Feature is Secondary**
   - Mise is primarily a version manager
   - Task feature is newer and less mature
   - Smaller ecosystem than dedicated runners

4. **⚠️ Verbose for Dynamic Paths**
   - Namespaced approach requires N×M task definitions
   - Environment variable approach is clunky
   - Wrapper script adds complexity

## Four Invocation Patterns Demonstrated

### Pattern 1: Namespaced Tasks (Recommended)
```bash
mise run go:build
mise run rust:test
```
**Best for:** Explicit, type-safe task invocation

### Pattern 2: Environment Variables
```bash
PRODUCT=sdk/go mise run build-env
```
**Best for:** Scripting and automation

### Pattern 3: Wrapper Script
```bash
./mise-wrapper.sh build sdk/go
```
**Best for:** Best CLI ergonomics

### Pattern 4: Direct SDK Tasks
```bash
cd sdk/go && mise run build
```
**Best for:** Local development workflow

## Comparison Verdict

### Task Running: Just vs Mise

**Just wins for:**
- ✅ Native positional arguments
- ✅ CLI ergonomics
- ✅ Mature task ecosystem
- ✅ Flexible argument handling
- ✅ Tab completion for paths

**Mise wins for:**
- ✅ Integrated version management
- ✅ Single tool (no extra dependency)
- ✅ Structured TOML configuration
- ✅ Good modular organization

**Overall:** Just is the better pure task runner. Mise is acceptable if you're already using it for version management.

## Recommendations

### Use Mise Tasks If:
- ✓ You're already using mise for version management
- ✓ You want minimal tooling (one tool for everything)
- ✓ Your tasks don't need complex CLI interfaces
- ✓ You're comfortable with workarounds

### Use Just (or Task) If:
- ✓ Task running is your primary need
- ✓ You need flexible command-line arguments
- ✓ CLI ergonomics are important
- ✓ You want a mature task ecosystem

### Best of Both Worlds:
Use **mise for version management** + **just for task running**

```bash
# .tool-versions (mise)
go 1.21.5
rust 1.75.0

# justfile (just)
build path:
    cd "{{path}}" && just build
```

This gives you mise's excellent version management AND just's superior task syntax.

## What This Project Demonstrates

### Successfully Shows:
1. ✅ How to structure a polyglot monorepo with mise
2. ✅ Four different approaches to task invocation
3. ✅ Modular mise.toml organization
4. ✅ Working builds for three languages
5. ✅ Comprehensive task coverage (8 commands × 3 SDKs)
6. ✅ Real limitations and workarounds
7. ✅ Fair comparison with alternatives

### Educational Value:
- **For Mise Users:** Learn how to use mise tasks effectively
- **For Tool Evaluators:** Understand mise's strengths and limitations
- **For Monorepo Builders:** See different task orchestration approaches
- **For Polyglot Projects:** Example of multi-language task management

## File Statistics

```
Total Files: 23
- Documentation:     6 (README, QUICKSTART, ALTERNATIVES, SYNTAX-COMPARISON, STRUCTURE, PROJECT-SUMMARY)
- Configuration:     8 (mise.toml files, .tool-versions, .gitignore)
- Source Code:       5 (Go, Rust, C++ with tests)
- Build Configs:     3 (go.mod, Cargo.toml, Makefile)
- Examples:          4 (justfile.example files)
- Scripts:           1 (validate.sh)

Total Lines: ~2,848 across all files
```

## Testing & Validation

All projects have been validated:
- ✅ Go syntax checked and modules verified
- ✅ Rust project checked with cargo
- ✅ C++ syntax validated with g++
- ✅ Bash scripts syntax checked
- ✅ All configuration files valid

Run validation: `./validate.sh`

## Quick Start Commands

```bash
# Navigate to project
cd /home/user/just-experiments/examples/mise-monorepo

# Validate everything
./validate.sh

# Install mise (if not installed)
curl https://mise.run | sh

# See available tasks
mise tasks

# Try different approaches
mise run go:build              # Namespaced
PRODUCT=sdk/rust mise run build-env  # Env var
cd sdk/cpp && mise run build   # Direct

# Build everything
mise run build-all

# Get help
mise run help
```

## Real-World Applicability

### This Pattern Works Well For:
- ✅ Small to medium monorepos (5-20 products)
- ✅ Teams already using mise for versions
- ✅ Simple task orchestration needs
- ✅ Polyglot projects with consistent commands

### Consider Alternatives For:
- ❌ Large monorepos (50+ products)
- ❌ Complex CLI interfaces needed
- ❌ Teams not using mise
- ❌ When task running is the primary need

## Impact & Learnings

### Key Learnings

1. **Mise tasks are best for simple orchestration**
   - Don't try to build complex CLIs with it
   - Embrace the limitations
   - Use workarounds pragmatically

2. **Modular mise.toml files work great**
   - This is mise's strongest task feature
   - Keep SDK logic in SDK directories
   - Root orchestrates high-level tasks

3. **Consider your primary need**
   - Version management → Mise
   - Task running → Just or Task
   - Both → Use both tools

4. **The "best" tool depends on context**
   - Not every project needs the most powerful tool
   - Sometimes "good enough" is perfect
   - Minimize tooling when possible

### What Worked Well

- ✅ Modular task organization
- ✅ All-at-once tasks for CI/CD
- ✅ Namespaced tasks for explicit invocation
- ✅ Comprehensive documentation
- ✅ Side-by-side comparison with Just

### What Was Challenging

- ❌ Working around lack of positional arguments
- ❌ Finding the "right" pattern (multiple exist)
- ❌ Documenting limitations without being negative
- ❌ Balancing "what's possible" vs "what's practical"

## Conclusion

This project successfully demonstrates that **mise can be used as a task runner for polyglot monorepos**, but with caveats:

1. **Modularization**: ✅ Excellent
2. **Path Validation**: ⚠️ Requires workarounds
3. **Options Support**: ⚠️ Basic only

Mise tasks are **perfectly adequate** for simple orchestration, especially if you're already using mise for version management. However, dedicated task runners like Just or Task provide superior CLI ergonomics for dynamic command patterns.

**Final Recommendation:** Use mise tasks for simple monorepo orchestration when you're already using mise. For complex task running needs, supplement with or switch to Just.

## Further Exploration

Ideas for extending this project:
- Add Swift SDK (macOS compatible)
- Add Python and Node.js SDKs
- Implement cross-SDK integration tests
- Add watch mode for development
- Create Docker containerization
- Add full CI/CD pipeline example
- Implement release workflow
- Add performance benchmarking

## Resources

- [Mise Documentation](https://mise.jdx.dev/)
- [Mise Tasks Guide](https://mise.jdx.dev/tasks/)
- [Just Documentation](https://just.systems/)
- [Task Documentation](https://taskfile.dev/)
- [This Project on GitHub](https://github.com/phatblat/just-experiments/tree/main/examples/mise-monorepo)

---

**Project Status:** ✅ Complete and validated

**Maintainer:** Created as an educational example

**License:** Public domain / MIT (as part of just-experiments repo)

**Last Updated:** December 2025
