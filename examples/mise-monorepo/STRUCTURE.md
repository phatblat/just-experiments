# Project Structure

This document provides a complete overview of the mise-monorepo example project structure.

## Directory Tree

```
mise-monorepo/
├── .gitignore                      # Git ignore rules
├── .tool-versions                  # Mise version specifications
├── mise.toml                       # Root mise task configuration
├── justfile.example                # Example justfile for comparison
├── validate.sh                     # Validation script
│
├── README.md                       # Main documentation
├── QUICKSTART.md                   # Quick start guide
├── ALTERNATIVES.md                 # Task runner comparison
├── STRUCTURE.md                    # This file
│
└── sdk/                            # SDK products
    ├── go/                         # Go SDK
    │   ├── mise.toml              # Go-specific tasks
    │   ├── justfile.example       # Go justfile (for comparison)
    │   ├── go.mod                 # Go module definition
    │   ├── main.go                # Go source code
    │   └── main_test.go           # Go tests
    │
    ├── rust/                       # Rust SDK
    │   ├── mise.toml              # Rust-specific tasks
    │   ├── justfile.example       # Rust justfile (for comparison)
    │   ├── Cargo.toml             # Rust package manifest
    │   └── src/
    │       └── main.rs            # Rust source code
    │
    └── cpp/                        # C++ SDK
        ├── mise.toml              # C++-specific tasks
        ├── justfile.example       # C++ justfile (for comparison)
        ├── Makefile               # Traditional C++ build
        └── main.cpp               # C++ source code
```

## File Descriptions

### Root Configuration Files

#### `.tool-versions`
Mise version management file specifying which versions of Go, Rust, etc. to use.
```toml
go 1.21.5
rust 1.75.0
```

#### `mise.toml`
Root task configuration demonstrating four different approaches to task invocation:
1. Environment variable based (PRODUCT=sdk/go mise run build-env)
2. Wrapper script (./mise-wrapper.sh build sdk/go)
3. Namespaced tasks (mise run go:build)
4. All-at-once tasks (mise run build-all)

#### `.gitignore`
Standard ignore patterns for build artifacts, dependencies, and IDE files.

### Documentation Files

#### `README.md` (Main Documentation)
- Comprehensive overview of the project
- Answers all three research questions
- Detailed usage examples for all approaches
- Pros/cons analysis of mise's task feature
- Comparison with other task runners
- Best practices and recommendations

#### `QUICKSTART.md`
- Step-by-step getting started guide
- Installation instructions
- Basic usage examples
- Troubleshooting tips
- Under 5 minutes to get running

#### `ALTERNATIVES.md`
- In-depth comparison of 7 different task runners
- Feature comparison matrix
- Decision guide for choosing a tool
- Real-world example comparisons
- Hybrid approach suggestions

#### `STRUCTURE.md`
This file - complete project structure documentation.

### Example and Comparison Files

#### `justfile.example`
Shows how the same monorepo would be structured with Just for comparison. Demonstrates:
- Natural positional argument syntax
- Cleaner path validation
- Better CLI ergonomics
- Side-by-side comparison with mise

#### `sdk/*/justfile.example`
SDK-specific justfiles showing how each language's tasks would be defined in Just.

### Utility Scripts

#### `validate.sh`
Comprehensive validation script that checks:
- Required tools installation (go, cargo, g++, mise)
- Project structure integrity
- Configuration file presence
- Source file existence
- Ability to build each SDK
- Provides colored output and summary

### SDK Projects

Each SDK contains:

1. **Task Configuration** (`mise.toml`)
   - SDK-specific task definitions
   - Can be called directly from SDK directory
   - Can be invoked from root

2. **Source Code**
   - Minimal "Hello World" CLI application
   - Accepts command-line arguments
   - Includes basic tests

3. **Build Configuration**
   - Go: `go.mod` module definition
   - Rust: `Cargo.toml` package manifest
   - C++: `Makefile` for compilation

4. **Comparison** (`justfile.example`)
   - Shows equivalent Just configuration
   - Demonstrates better CLI ergonomics

## File Count

```
Total files:     23
Configuration:    8 (.tool-versions, 4×mise.toml, .gitignore, Makefile, go.mod, Cargo.toml)
Documentation:    4 (README.md, QUICKSTART.md, ALTERNATIVES.md, STRUCTURE.md)
Source code:      5 (main.go, main_test.go, main.rs, main.cpp)
Examples:         4 (justfile.example ×4)
Scripts:          1 (validate.sh)
```

## Configuration Hierarchy

```
Root Level (mise.toml)
│
├─> Orchestration Tasks
│   ├── build-env (requires PRODUCT env var)
│   ├── test-env (requires PRODUCT env var)
│   ├── lint-env (requires PRODUCT env var)
│   ├── create-wrapper (creates wrapper script)
│   └── help (shows usage)
│
├─> Namespaced Tasks (per SDK)
│   ├── go:build, go:test, go:lint, go:format, go:run, go:clean
│   ├── rust:build, rust:test, rust:lint, rust:format, rust:run, rust:clean
│   └── cpp:build, cpp:test, cpp:lint, cpp:format, cpp:run, cpp:clean
│
├─> All-at-Once Tasks
│   ├── build-all
│   ├── test-all
│   ├── lint-all
│   ├── format-all
│   └── clean-all
│
└─> Utility Tasks
    ├── setup (setup all SDKs)
    ├── check (run all checks)
    └── list-products (list available SDKs)

SDK Level (sdk/*/mise.toml)
│
└─> Standard Tasks (per SDK)
    ├── install (install dependencies)
    ├── update (update dependencies)
    ├── lint (lint code)
    ├── format (format code)
    ├── build (build application)
    ├── test (run tests)
    ├── run (run application)
    └── clean (clean artifacts)
```

## Usage Patterns

### Pattern 1: Environment Variables
```bash
PRODUCT=sdk/go mise run build-env
```
- Works from root only
- Requires setting PRODUCT env var
- Native mise approach

### Pattern 2: Wrapper Script
```bash
./mise-wrapper.sh build sdk/go
```
- Best CLI ergonomics
- Requires one-time setup
- Most intuitive for users

### Pattern 3: Namespaced Tasks
```bash
mise run go:build
```
- Works from root only
- Explicit and type-safe
- Self-documenting

### Pattern 4: Direct SDK Tasks
```bash
cd sdk/go && mise run build
```
- Works from SDK directory
- Natural during development
- Uses local mise.toml

### Pattern 5: All-at-Once
```bash
mise run build-all
```
- Operates on all SDKs
- Good for CI/CD
- Monorepo-wide operations

## Commands Available per SDK

| Command  | Go | Rust | C++ | Description |
|----------|-----|------|-----|-------------|
| install  | ✅  | ✅   | ✅  | Install dependencies |
| update   | ✅  | ✅   | ✅  | Update dependencies |
| lint     | ✅  | ✅   | ✅  | Lint code (requires tools) |
| format   | ✅  | ✅   | ✅  | Format code |
| build    | ✅  | ✅   | ✅  | Build application |
| test     | ✅  | ✅   | ✅  | Run tests |
| run      | ✅  | ✅   | ✅  | Run application |
| clean    | ✅  | ✅   | ✅  | Clean build artifacts |

## Adding a New SDK

To add a new SDK (e.g., Python):

1. Create SDK directory:
   ```bash
   mkdir -p sdk/python
   ```

2. Add source files:
   ```bash
   # sdk/python/main.py
   print("Hello from Python SDK!")
   ```

3. Create `sdk/python/mise.toml`:
   ```toml
   [tasks.build]
   run = "python -m py_compile main.py"

   [tasks.test]
   run = "python -m pytest"

   [tasks.run]
   run = "python main.py"
   ```

4. Add to root `mise.toml`:
   ```toml
   [tasks."python:build"]
   run = "cd sdk/python && mise run build"

   # Add to build-all
   [tasks."build-all"]
   run = [
       "cd sdk/go && mise run build",
       "cd sdk/rust && mise run build",
       "cd sdk/cpp && mise run build",
       "cd sdk/python && mise run build"  # Add this line
   ]
   ```

5. Update documentation and validation script.

## Key Design Decisions

### Why Multiple Approaches?

The project demonstrates four different approaches because:
1. Mise doesn't have native positional argument support
2. Different approaches suit different use cases
3. Shows mise's limitations and workarounds
4. Helps users choose what works for them

### Why Include Just Examples?

Including justfile examples:
1. Provides a fair comparison
2. Shows what "good" CLI ergonomics look like
3. Helps users make informed tool decisions
4. Demonstrates hybrid approaches (mise + just)

### Why Keep It Simple?

The SDKs are intentionally minimal:
1. Focus is on task runner capabilities, not SDK complexity
2. Easy to understand and modify
3. Quick to build and test
4. Demonstrates patterns applicable to real projects

## Testing the Project

### Quick Test
```bash
cd /home/user/just-experiments/examples/mise-monorepo
./validate.sh
```

### Manual Testing
```bash
# Test Go SDK
cd sdk/go
mise run build
mise run test
mise run run

# Test Rust SDK
cd ../rust
mise run build
mise run test
mise run run

# Test C++ SDK
cd ../cpp
mise run build
mise run test
mise run run

# Test from root
cd ../..
mise run go:build
mise run rust:test
mise run build-all
```

## Extending the Project

Ideas for extensions:
- Add Swift SDK (macOS/Linux compatible)
- Add Python SDK
- Add Node.js/TypeScript SDK
- Implement watch mode for development
- Add Docker containerization
- Add CI/CD pipeline examples
- Implement cross-SDK integration tests
- Add benchmarking tasks
- Implement release workflow

## Related Files in Parent Repo

This project is part of the `just-experiments` repository:
```
just-experiments/
├── README.md
├── justfile
├── android/
└── examples/
    └── mise-monorepo/  ← This project
```

The parent repository uses Just, making this a nice comparison point.
