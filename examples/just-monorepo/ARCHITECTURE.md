# Project Architecture

## Directory Structure

```
just-monorepo/
├── justfile                    # Root justfile (command router)
├── README.md                   # Complete documentation with research findings
├── QUICKSTART.md              # Quick start guide
├── ARCHITECTURE.md            # This file
├── test-everything.sh         # Comprehensive test suite
├── .gitignore                 # Git ignore rules
│
├── sdk/
│   ├── cpp/                   # C++ SDK
│   │   ├── justfile          # C++ specific commands
│   │   ├── Makefile          # Build configuration
│   │   └── src/
│   │       └── main.cpp      # Hello world CLI
│   │
│   ├── go/                    # Go SDK
│   │   ├── justfile          # Go specific commands
│   │   ├── go.mod            # Go module definition
│   │   ├── main.go           # Hello world CLI
│   │   └── main_test.go      # Tests
│   │
│   ├── rust/                  # Rust SDK
│   │   ├── justfile          # Rust specific commands
│   │   ├── Cargo.toml        # Cargo configuration
│   │   └── src/
│   │       └── main.rs       # Hello world CLI with tests
│   │
│   └── swift/                 # Swift SDK (placeholder)
│       └── README.md         # Implementation guide
```

## Command Flow

### Single SDK Command
```
User runs: just build sdk/go
    ↓
Root justfile receives command
    ↓
Validates path exists (validate-path recipe)
    ↓
Changes to sdk/go directory
    ↓
Invokes: just build (in sdk/go/justfile)
    ↓
Executes: go build -o bin/sdk-go main.go
```

### All SDKs Command
```
User runs: just build-all
    ↓
Root justfile receives command
    ↓
Invokes: all-sdks build
    ↓
Iterates over sdk/*/ directories
    ↓
For each SDK with justfile:
    - Changes to SDK directory
    - Invokes: just build
    - Continues even if one fails
```

## Justfile Architecture

### Root Justfile (`./justfile`)

**Purpose:** Command router and orchestrator

**Key Recipes:**
- `validate-path` - Ensures SDK path exists and has justfile
- `build`, `test`, `run`, etc. - Route to SDK-specific justfiles
- `build-all`, `test-all`, etc. - Execute commands across all SDKs
- `check` - Verify monorepo configuration
- `info` - Display monorepo information

**Pattern:**
```justfile
command path *FLAGS:
    @just validate-path {{path}}
    cd {{path}} && just {{FLAGS}} command
```

### SDK Justfiles (`sdk/*/justfile`)

**Purpose:** SDK-specific command implementations

**Standard Recipes:**
- `install` - Install dependencies
- `update` - Update dependencies
- `lint` - Lint code
- `format` - Format code
- `build` - Build binary
- `test` - Run tests
- `run` - Run the application
- `clean` - Clean build artifacts

**Pattern:**
```justfile
command:
    @echo "Running command..."
    <language-specific-tool> <args>
```

## Design Decisions

### 1. Directory-Based Execution vs. Imports

**Chosen:** Directory-based execution (`cd {{path}} && just command`)

**Alternatives Considered:**
- Import directive: `import 'sdk/go/justfile'`
- Module system: `mod go 'sdk/go/justfile'`

**Rationale:**
- Recipes run in correct context (SDK directory)
- No name collision issues
- Each SDK justfile is independently runnable
- Simpler mental model

### 2. Path Validation

**Implementation:** Private recipe that exits with error code

**Rationale:**
- Fails fast with clear error messages
- Prevents confusing errors from underlying tools
- Uses `[private]` to hide implementation detail

### 3. Variadic Arguments

**Pattern:** `command path *FLAGS` or `run path *ARGS`

**Rationale:**
- Allows passing through flags like `--verbose`
- Supports arbitrary arguments to `run` commands
- Flexible without being prescriptive

### 4. Error Handling

**Pattern:** `command || echo "Failed for $sdk"`

**Rationale:**
- Allows `-all` commands to continue on failure
- Still reports which SDK failed
- Prevents one failure from blocking others

## Extension Points

### Adding a New SDK

1. Create SDK directory: `mkdir -p sdk/newsdk/src`
2. Create SDK justfile: `sdk/newsdk/justfile`
3. Implement standard recipes (install, build, test, run, clean)
4. Test: `just build sdk/newsdk`

No changes needed to root justfile!

### Adding a New Command

1. Add recipe to each SDK justfile
2. Add routing recipe to root justfile:
   ```justfile
   newcommand path *FLAGS:
       @just validate-path {{path}}
       cd {{path}} && just {{FLAGS}} newcommand
   ```
3. Optionally add `-all` variant

### Adding Cross-SDK Dependencies

Current limitation: No built-in support

**Workaround:** Create custom recipes
```justfile
build-with-deps path:
    @just build sdk/common
    @just build {{path}}
```

## Testing Strategy

### Unit Testing (per SDK)
```bash
just test sdk/go
```

### Integration Testing (all SDKs)
```bash
just test-all
```

### Validation Testing
```bash
just check
```

### End-to-End Testing
```bash
./test-everything.sh
```

## Performance Considerations

### Minimal Overhead
- `just` itself is very fast (Rust binary)
- Only overhead is subprocess spawning for `cd && just`
- No caching, so every command runs fresh

### Parallelization
- Not supported out of the box
- Could be added with shell parallelization:
  ```justfile
  build-all-parallel:
      for sdk in sdk/*/; do (cd $sdk && just build) & done; wait
  ```

## Comparison to Alternatives

| Aspect | This Implementation | Alternative |
|--------|-------------------|-------------|
| Modularization | Directory-based | Import-based |
| Recipe sharing | Duplicate in each SDK | Shared via import |
| Context | Always correct (via cd) | May be incorrect |
| Complexity | Low | Medium |
| Maintainability | High (independent) | Medium (coupled) |

## Known Limitations

1. **No dependency graph** - Cannot express "build B if A changes"
2. **No caching** - Every command runs from scratch
3. **No parallelization** - Commands run sequentially
4. **Manual iteration** - Must manually loop over SDKs
5. **No built-in workspace concept** - Monorepo structure is convention, not enforced

## Future Enhancements

### Potential Improvements
1. Add parallel execution for `-all` commands
2. Create shared recipe library for common patterns
3. Add dependency graph support between SDKs
4. Integrate with CI/CD (GitHub Actions example)
5. Add more sophisticated error handling
6. Create SDK templates for quick scaffolding

### When to Graduate to Another Tool
Consider migrating when:
- Need sophisticated caching (→ nx, turborepo)
- Have complex inter-SDK dependencies (→ bazel)
- Need automatic change detection (→ nx, lerna)
- Want optimized CI/CD execution (→ nx, turborepo)
- Require fine-grained build orchestration (→ bazel, pants)

## Conclusion

This architecture demonstrates that `just` can effectively serve as a command launcher for polyglot monorepos through:
- Clear separation of concerns (root vs. SDK justfiles)
- Consistent command interface across languages
- Path validation and error handling
- Support for both single-SDK and monorepo-wide operations

The simplicity of this approach makes it easy to understand, extend, and maintain, while the limitations make it most suitable for small to medium-sized monorepos without complex inter-project dependencies.
