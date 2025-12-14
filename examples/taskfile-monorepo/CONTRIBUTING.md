# Contributing Guide

## Adding a New SDK

To add a new SDK to this monorepo:

### 1. Create SDK Directory

```bash
mkdir -p sdk/<language>
```

### 2. Create SDK-Specific Taskfile

Create `sdk/<language>/Taskfile.yml` with these standard tasks:

```yaml
version: '3'

vars:
  BINARY_NAME: <language>-sdk
  BUILD_DIR: build

tasks:
  install:
    desc: Install dependencies
    cmds:
      - # Add install commands

  update:
    desc: Update dependencies
    cmds:
      - # Add update commands

  lint:
    desc: Lint code
    cmds:
      - # Add linting commands

  format:
    desc: Format code
    cmds:
      - # Add formatting commands

  build:
    desc: Build application
    cmds:
      - # Add build commands
    sources:
      - 'src/**/*'
    generates:
      - '{{.BUILD_DIR}}/{{.BINARY_NAME}}'

  test:
    desc: Run tests
    cmds:
      - # Add test commands

  run:
    desc: Run application
    deps: [build]
    cmds:
      - ./{{.BUILD_DIR}}/{{.BINARY_NAME}} {{.CLI_ARGS}}

  clean:
    desc: Clean build artifacts
    cmds:
      - # Add clean commands
```

### 3. Update Root Taskfile

Add your SDK to the includes section in `Taskfile.yml`:

```yaml
includes:
  <language>:
    taskfile: ./sdk/<language>/Taskfile.yml
    dir: ./sdk/<language>
```

Add your SDK to the SDK_PATHS variable:

```yaml
vars:
  SDK_PATHS: "sdk/go sdk/rust sdk/cpp sdk/<language>"
```

### 4. Update Documentation

Add your SDK to:
- README.md (project structure section)
- README.md (list of SDKs)
- QUICK_START.md (examples)

### 5. Add to CI/CD

Update `.github/workflows/ci.yml` to include your SDK in the matrix:

```yaml
strategy:
  matrix:
    sdk: [sdk/go, sdk/rust, sdk/cpp, sdk/<language>]
```

### 6. Test Your SDK

```bash
# Test individual commands
task build SDK=sdk/<language>
task test SDK=sdk/<language>
task run SDK=sdk/<language>

# Test batch operations
task build-all
task test-all
```

## Development Workflow

### Before Committing

```bash
# Format all code
task format-all

# Lint all code
task lint-all

# Run all tests
task test-all

# Build all SDKs
task build-all
```

### Running CI Locally

```bash
task ci
```

## Code Style Guidelines

### Taskfile Style

1. **Always provide descriptions:**
   ```yaml
   tasks:
     build:
       desc: Build the application
   ```

2. **Use variables for repeated values:**
   ```yaml
   vars:
     BINARY_NAME: app
   ```

3. **Add source/generate tracking when applicable:**
   ```yaml
   sources: ['src/**/*.go']
   generates: ['build/app']
   ```

4. **Use internal tasks for helpers:**
   ```yaml
   validate:
     internal: true
   ```

5. **Provide clear error messages:**
   ```yaml
   cmds:
     - test -d {{.SDK}} || (echo "Error: SDK not found" && exit 1)
   ```

### SDK Code Style

Each SDK should follow its language's standard conventions:

- **Go:** Use `gofmt` and `golangci-lint`
- **Rust:** Use `rustfmt` and `cargo clippy`
- **C++:** Use `clang-format` and `clang-tidy`

## Testing

### Unit Tests

Each SDK should include unit tests:

```bash
task test SDK=sdk/<language>
```

### Integration Tests

Test the task commands work correctly:

```bash
# Build
task build SDK=sdk/<language>

# Verify binary exists
test -f sdk/<language>/build/<binary>

# Run
task run SDK=sdk/<language> CLI_ARGS="--version"
```

## Documentation

### Task Descriptions

Always include clear descriptions:

```yaml
tasks:
  build:
    desc: Build the application (usage: task build SDK=sdk/go)
```

### Code Comments

Add comments for complex logic:

```yaml
tasks:
  build:
    # Check if sources have changed before rebuilding
    sources: ['src/**/*']
    generates: ['build/app']
    cmds:
      - go build -o build/app
```

### README Updates

Update documentation when:
- Adding new SDKs
- Adding new features
- Changing command syntax
- Discovering new pros/cons

## Common Patterns

### Conditional Execution

```yaml
tasks:
  lint:
    cmds:
      - |
        if command -v golangci-lint >/dev/null 2>&1; then
          golangci-lint run
        else
          echo "golangci-lint not installed"
        fi
```

### Error Handling

```yaml
tasks:
  validate:
    cmds:
      - |
        if [ ! -d "{{.SDK}}" ]; then
          echo "Error: SDK not found: {{.SDK}}"
          exit 1
        fi
```

### Parallel Execution

```yaml
tasks:
  test-all:
    cmds:
      - task: test
        vars: { SDK: sdk/go }
      - task: test
        vars: { SDK: sdk/rust }
      - task: test
        vars: { SDK: sdk/cpp }
```

## Troubleshooting

### Task Not Found

```bash
task --list-all  # Show all tasks including internal ones
```

### Path Issues

```bash
# Verify SDK exists
task list-sdks

# Check Taskfile syntax
task --dry build SDK=sdk/go
```

### Build Failures

```bash
# Clean and rebuild
task clean SDK=sdk/go
task build SDK=sdk/go --verbose

# Force rebuild (ignore cache)
task build SDK=sdk/go --force
```

## Questions?

If you have questions about:
- Task features: See [Task Documentation](https://taskfile.dev/)
- SDK-specific issues: Check the SDK's own documentation
- This project: Open an issue or discussion

## Resources

- [Task Documentation](https://taskfile.dev/)
- [Task GitHub](https://github.com/go-task/task)
- [Go Documentation](https://go.dev/doc/)
- [Rust Documentation](https://doc.rust-lang.org/)
- [CMake Documentation](https://cmake.org/documentation/)
