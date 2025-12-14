# Taskfile Monorepo Example

A comprehensive demonstration of using [Task](https://taskfile.dev) (go-task/task) as a command launcher for a polyglot monorepo with Go, Rust, and C++ SDKs.

## Overview

This project showcases how Task can be used as a unified command runner across multiple programming languages in a monorepo structure, with support for modular task files and common operations like build, test, lint, and run.

## Project Structure

```
taskfile-monorepo/
├── Taskfile.yml              # Root taskfile with unified commands
├── sdk/
│   ├── go/
│   │   ├── Taskfile.yml      # Go-specific tasks
│   │   ├── main.go
│   │   ├── main_test.go
│   │   ├── go.mod
│   │   └── .golangci.yml
│   ├── rust/
│   │   ├── Taskfile.yml      # Rust-specific tasks
│   │   ├── Cargo.toml
│   │   ├── rustfmt.toml
│   │   └── src/
│   │       └── main.rs
│   └── cpp/
│       ├── Taskfile.yml      # C++-specific tasks
│       ├── CMakeLists.txt
│       ├── main.cpp
│       └── .clang-format
└── README.md
```

## Installation

### Install Task

```bash
# macOS
brew install go-task/tap/go-task

# Linux (from official script)
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

# Using Go
go install github.com/go-task/task/v3/cmd/task@latest

# Using Snap
snap install task --classic
```

For more installation methods, see the [official documentation](https://taskfile.dev/installation/).

## Usage

### Command Syntax

Task supports multiple command syntax patterns:

#### 1. Variable-based SDK Selection (Recommended)

```bash
task <command> SDK=<sdk-path> [CLI_ARGS="args"]
```

Examples:
```bash
task build SDK=sdk/go
task run SDK=sdk/rust CLI_ARGS="hello world"
task test SDK=sdk/cpp
task lint SDK=sdk/go
```

#### 2. Batch Operations (All SDKs)

```bash
task <command>-all
```

Examples:
```bash
task build-all       # Build all SDKs
task test-all        # Test all SDKs
task lint-all        # Lint all SDKs
task clean-all       # Clean all SDKs
```

#### 3. Direct SDK Invocation (Using Includes)

```bash
task <sdk-name>:<command> [CLI_ARGS="args"]
```

Examples:
```bash
task go:build
task rust:test
task cpp:run CLI_ARGS="--help"
```

### Available Commands

| Command   | Description                    | Example                           |
|-----------|--------------------------------|-----------------------------------|
| `install` | Install dependencies           | `task install SDK=sdk/go`         |
| `update`  | Update dependencies            | `task update SDK=sdk/rust`        |
| `lint`    | Run linters                    | `task lint SDK=sdk/cpp`           |
| `format`  | Format code                    | `task format SDK=sdk/go`          |
| `build`   | Build project                  | `task build SDK=sdk/rust`         |
| `test`    | Run tests                      | `task test SDK=sdk/cpp`           |
| `run`     | Run application                | `task run SDK=sdk/go`             |
| `clean`   | Clean build artifacts          | `task clean SDK=sdk/rust`         |
| `ci`      | Run full CI pipeline           | `task ci`                         |

### Help Commands

```bash
task --list          # List all available tasks
task help            # Show usage examples
task list-sdks       # List all available SDKs
```

## Research Questions & Answers

### 1. Path Validation: Can Taskfile validate that the product_path exists as a directory?

**Answer: Yes, with custom validation tasks.**

Task doesn't have built-in path validation, but it's easily implemented using shell scripts in a validation task. This project demonstrates path validation in the `validate-sdk` task:

```yaml
validate-sdk:
  internal: true
  cmds:
    - |
      if [ -z "{{.SDK}}" ]; then
        echo "Error: SDK parameter is required"
        exit 1
      fi
      if [ ! -d "{{.SDK}}" ]; then
        echo "Error: SDK path '{{.SDK}}' does not exist"
        exit 1
      fi
      if [ ! -f "{{.SDK}}/Taskfile.yml" ]; then
        echo "Error: No Taskfile.yml found in '{{.SDK}}'"
        exit 1
      fi
```

**Key Features:**
- Validates SDK parameter is provided
- Checks if directory exists
- Verifies Taskfile.yml exists in the SDK directory
- Provides clear error messages with valid options
- Used as a dependency (`deps: [validate-sdk]`) for all SDK-specific commands

**Pros:**
- Flexible validation logic
- Clear error messages
- Prevents cryptic errors downstream
- Can validate multiple conditions

**Cons:**
- Requires manual implementation
- Shell-dependent (bash/sh)
- No built-in declarative validation

### 2. Modularization: Can Taskfile support modular task files?

**Answer: Yes, using the `includes` feature.**

Task has excellent support for modular task files through the `includes` directive. This project demonstrates three approaches:

#### Approach 1: Includes with Namespace (Recommended)

```yaml
includes:
  go:
    taskfile: ./sdk/go/Taskfile.yml
    dir: ./sdk/go
  rust:
    taskfile: ./sdk/rust/Taskfile.yml
    dir: ./sdk/rust
```

**Usage:** `task go:build`, `task rust:test`

**Benefits:**
- Each SDK maintains its own Taskfile.yml
- Tasks are namespaced to avoid collisions
- Each taskfile runs in its own directory context
- Clean separation of concerns

#### Approach 2: Dynamic Invocation

```yaml
build:
  deps: [validate-sdk]
  dir: '{{.SDK}}'
  cmds:
    - task -d {{.SDK}} build
```

**Usage:** `task build SDK=sdk/go`

**Benefits:**
- Single command for all SDKs
- Runtime SDK selection
- Path validation before execution
- Consistent interface

#### Approach 3: Direct Task Delegation

Each SDK's Taskfile.yml is self-contained and can be run independently:

```bash
cd sdk/go && task build
cd sdk/rust && task test
```

**Modularization Features:**
- ✅ Each SDK has its own Taskfile.yml
- ✅ Tasks can include other taskfiles
- ✅ Supports directory context switching
- ✅ Variables can be passed down
- ✅ Tasks can be namespaced
- ✅ Supports recursive task calls

**Pros:**
- Excellent modularization support
- Clean namespace separation
- Easy to maintain SDK-specific logic
- Can compose tasks across modules

**Cons:**
- Includes must be explicitly defined
- No dynamic include discovery
- Circular includes not supported

### 3. Options Support: How does Taskfile handle --dry-run, --quiet, --verbose flags?

**Answer: Built-in support at the CLI level, custom support for application flags.**

#### Built-in Task Flags

Task provides several built-in flags:

```bash
# Dry run - show what would be executed
task --dry build SDK=sdk/go

# Verbose - show detailed output
task --verbose build SDK=sdk/rust

# Silent - suppress output
task --silent build SDK=sdk/cpp

# List tasks
task --list
task --list-all

# Show task summary
task --summary build

# Show task help
task --help

# Watch mode - rerun on file changes
task --watch build SDK=sdk/go

# Force execution (ignore up-to-date checks)
task --force build SDK=sdk/rust

# Parallel execution
task --parallel build-all
```

#### Custom Application Flags

For passing flags to the application being run, use the `CLI_ARGS` variable:

```yaml
run:
  desc: Run application
  deps: [build]
  cmds:
    - ./build/binary {{.CLI_ARGS}}
```

**Usage:**
```bash
task run SDK=sdk/go CLI_ARGS="--verbose --config=dev.yaml"
task run SDK=sdk/rust CLI_ARGS="--help"
```

#### Implementation Patterns

**Pattern 1: Variable-based Flags**
```yaml
tasks:
  build:
    cmds:
      - go build {{.BUILD_FLAGS}} -o output .
```
Usage: `task build BUILD_FLAGS="-race -v"`

**Pattern 2: Conditional Execution**
```yaml
tasks:
  lint:
    cmds:
      - |
        if [ "{{.DRY_RUN}}" = "true" ]; then
          echo "Would run: golangci-lint run"
        else
          golangci-lint run
        fi
```
Usage: `task lint DRY_RUN=true`

**Pattern 3: Environment Variables**
```yaml
tasks:
  test:
    env:
      VERBOSE: '{{.VERBOSE | default "0"}}'
    cmds:
      - go test ./...
```
Usage: `task test VERBOSE=1`

**Options Support Summary:**

| Flag Type | Support | Implementation |
|-----------|---------|----------------|
| `--dry-run` | Built-in | Task CLI flag |
| `--verbose` | Built-in | Task CLI flag |
| `--silent` | Built-in | Task CLI flag |
| `--force` | Built-in | Task CLI flag |
| `--parallel` | Built-in | Task CLI flag |
| Custom app flags | Manual | Via `CLI_ARGS` variable |
| Custom task flags | Manual | Via variables |

**Pros:**
- Built-in support for common operations
- Easy to pass custom flags via variables
- Flexible implementation options
- Good command-line ergonomics

**Cons:**
- Custom flags require manual implementation
- No standard convention for custom flags
- Flag validation is manual
- No built-in flag parsing

## Key Features & Capabilities

### 1. Source/Generate Tracking

Task supports incremental builds via `sources` and `generates`:

```yaml
build:
  sources:
    - 'src/**/*.rs'
    - Cargo.toml
  generates:
    - 'target/release/binary'
  cmds:
    - cargo build --release
```

**Benefits:**
- Only rebuilds when source files change
- Speeds up development workflow
- Similar to Make's dependency tracking

### 2. Task Dependencies

Tasks can depend on other tasks:

```yaml
run:
  deps: [build]
  cmds:
    - ./build/binary
```

**Benefits:**
- Ensures prerequisites are met
- Can run dependencies in parallel
- Clear dependency graph

### 3. Variables and Templating

Task uses Go templates for variables:

```yaml
vars:
  BINARY_NAME: myapp
  BUILD_DIR: build

tasks:
  build:
    cmds:
      - mkdir -p {{.BUILD_DIR}}
      - go build -o {{.BUILD_DIR}}/{{.BINARY_NAME}}
```

**Features:**
- Default values: `{{.VAR | default "value"}}`
- Shell expansion: `{{.VAR | shellQuote}}`
- Conditional logic: `{{if .VAR}}...{{end}}`

### 4. Platform-Specific Tasks

Task supports platform-specific execution:

```yaml
build:
  platforms: [linux, darwin]
  cmds:
    - go build .

build:windows:
  platforms: [windows]
  cmds:
    - go build -o app.exe .
```

### 5. Watch Mode

Task can watch files and rerun commands:

```bash
task --watch build SDK=sdk/go
```

Automatically rebuilds when source files change.

### 6. Parallel Execution

Run tasks in parallel:

```bash
task --parallel build-all
```

Each SDK builds concurrently.

## Pros and Cons

### Pros

1. **Excellent Modularization**
   - Clean separation via includes
   - Each SDK maintains its own Taskfile
   - Good namespace support

2. **Cross-Platform**
   - Works on Linux, macOS, Windows
   - Written in Go (single binary)
   - No dependencies

3. **Developer Friendly**
   - Clean YAML syntax
   - Good documentation
   - Built-in help system
   - Intuitive commands

4. **Performance**
   - Fast execution
   - Incremental builds via source tracking
   - Parallel task execution

5. **Flexibility**
   - Go templating engine
   - Shell command support
   - Environment variable support
   - Variable passing

6. **Built-in Features**
   - Dry run mode
   - Verbose/silent modes
   - Watch mode
   - Force execution
   - Task listing

### Cons

1. **Path Validation**
   - No built-in declarative validation
   - Requires custom shell scripts
   - Error messages need manual implementation

2. **Flag Handling**
   - No standard convention for custom flags
   - Application flags require variable passing
   - No built-in flag parsing
   - Manual validation needed

3. **Dynamic Discovery**
   - Includes must be explicitly defined
   - Can't auto-discover SDKs
   - No dynamic task generation

4. **Learning Curve**
   - Go template syntax not obvious
   - Documentation could be more comprehensive
   - Some features are underdocumented

5. **Debugging**
   - Limited debugging capabilities
   - Error messages can be cryptic
   - No interactive mode

6. **Editor Support**
   - Limited IDE integration
   - No official VSCode extension
   - YAML validation is basic

## Comparison with Alternatives

### vs Make
- **Pro:** Better cross-platform support, cleaner syntax
- **Pro:** Built-in parallel execution
- **Con:** Less ubiquitous, newer tool

### vs Just
- **Pro:** Better modularization via includes
- **Pro:** Source tracking for incremental builds
- **Con:** More complex setup for simple tasks

### vs npm scripts / package.json
- **Pro:** Language-agnostic
- **Pro:** Better suited for monorepos
- **Con:** Requires additional tool installation

### vs Custom Scripts
- **Pro:** Standardized, documented approach
- **Pro:** Better maintainability
- **Pro:** Built-in help and listing
- **Con:** Additional dependency

## Best Practices

### 1. Use Includes for Modularization

```yaml
includes:
  service-a: ./services/a/Taskfile.yml
  service-b: ./services/b/Taskfile.yml
```

### 2. Validate Inputs Early

```yaml
validate:
  internal: true
  cmds:
    - test -n "{{.SDK}}" || (echo "SDK required" && exit 1)
```

### 3. Provide Clear Descriptions

```yaml
tasks:
  build:
    desc: Build the application (usage: task build SDK=sdk/go)
    cmds: [...]
```

### 4. Use Variables for Configuration

```yaml
vars:
  BUILD_DIR: build
  BINARY_NAME: app
```

### 5. Leverage Source Tracking

```yaml
build:
  sources: ['src/**/*.go']
  generates: ['build/app']
```

### 6. Create Helper Tasks

```yaml
default:
  desc: Show available tasks
  cmds:
    - task --list

help:
  desc: Show usage examples
  cmds:
    - cat USAGE.txt
```

## CI/CD Integration

Task works well in CI/CD pipelines:

```bash
# Install task in CI
sh -c "$(curl -L https://taskfile.dev/install.sh)" -- -d -b .

# Run CI pipeline
./task ci
```

Example GitHub Actions:
```yaml
- name: Install Task
  run: |
    sh -c "$(curl -L https://taskfile.dev/install.sh)" -- -d -b .

- name: Run CI
  run: ./task ci
```

## Conclusion

Task is an excellent choice for polyglot monorepos, offering:

- ✅ Strong modularization support via includes
- ✅ Clean, maintainable YAML syntax
- ✅ Good cross-platform support
- ✅ Built-in parallel execution
- ✅ Incremental builds via source tracking

The main limitations are:
- ⚠️ Manual path validation required
- ⚠️ Custom flag handling needs implementation
- ⚠️ No dynamic SDK discovery

Overall, Task provides a solid foundation for building a unified command launcher in a polyglot monorepo, with enough flexibility to adapt to various workflows and requirements.

## Getting Started

1. **Install Task** (see Installation section)

2. **Clone or create the example:**
   ```bash
   cd examples/taskfile-monorepo
   ```

3. **List available tasks:**
   ```bash
   task --list
   ```

4. **Build an SDK:**
   ```bash
   task build SDK=sdk/go
   ```

5. **Run tests:**
   ```bash
   task test-all
   ```

6. **Explore the taskfiles:**
   - Root: `Taskfile.yml`
   - Go SDK: `sdk/go/Taskfile.yml`
   - Rust SDK: `sdk/rust/Taskfile.yml`
   - C++ SDK: `sdk/cpp/Taskfile.yml`

## Resources

- [Task Official Documentation](https://taskfile.dev/)
- [Task GitHub Repository](https://github.com/go-task/task)
- [Task Installation Guide](https://taskfile.dev/installation/)
- [Task Usage Guide](https://taskfile.dev/usage/)

## License

This example is provided as-is for demonstration purposes.
