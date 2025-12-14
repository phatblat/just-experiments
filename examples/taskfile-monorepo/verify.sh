#!/usr/bin/env bash
# Verification script to test the Taskfile monorepo example

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================"
echo "Taskfile Monorepo Verification Script"
echo "========================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check functions
check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 is installed"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is not installed"
        return 1
    fi
}

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} Found: $1"
        return 0
    else
        echo -e "${RED}✗${NC} Missing: $1"
        return 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} Found directory: $1"
        return 0
    else
        echo -e "${RED}✗${NC} Missing directory: $1"
        return 1
    fi
}

ERRORS=0

# 1. Check dependencies
echo "1. Checking dependencies..."
check_command "task" || ERRORS=$((ERRORS + 1))
check_command "go" || ERRORS=$((ERRORS + 1))
check_command "rustc" || ERRORS=$((ERRORS + 1))
check_command "g++" || ERRORS=$((ERRORS + 1))
check_command "cmake" || ERRORS=$((ERRORS + 1))
echo ""

# 2. Check project structure
echo "2. Checking project structure..."
check_file "Taskfile.yml" || ERRORS=$((ERRORS + 1))
check_file "README.md" || ERRORS=$((ERRORS + 1))
check_dir "sdk" || ERRORS=$((ERRORS + 1))
check_dir "sdk/go" || ERRORS=$((ERRORS + 1))
check_dir "sdk/rust" || ERRORS=$((ERRORS + 1))
check_dir "sdk/cpp" || ERRORS=$((ERRORS + 1))
check_file "sdk/go/Taskfile.yml" || ERRORS=$((ERRORS + 1))
check_file "sdk/rust/Taskfile.yml" || ERRORS=$((ERRORS + 1))
check_file "sdk/cpp/Taskfile.yml" || ERRORS=$((ERRORS + 1))
echo ""

# 3. Test Task commands (if task is installed)
if command -v task &> /dev/null; then
    echo "3. Testing Task commands..."

    # List tasks
    if task --list &> /dev/null; then
        echo -e "${GREEN}✓${NC} task --list works"
    else
        echo -e "${RED}✗${NC} task --list failed"
        ERRORS=$((ERRORS + 1))
    fi

    # Test build-all
    echo -e "${YELLOW}Building all SDKs...${NC}"
    if task build-all; then
        echo -e "${GREEN}✓${NC} task build-all succeeded"
    else
        echo -e "${RED}✗${NC} task build-all failed"
        ERRORS=$((ERRORS + 1))
    fi

    # Test individual builds
    for sdk in sdk/go sdk/rust sdk/cpp; do
        if task build SDK=$sdk &> /dev/null; then
            echo -e "${GREEN}✓${NC} task build SDK=$sdk succeeded"
        else
            echo -e "${RED}✗${NC} task build SDK=$sdk failed"
            ERRORS=$((ERRORS + 1))
        fi
    done

    # Test run commands
    echo -e "${YELLOW}Testing run commands...${NC}"
    for sdk in sdk/go sdk/rust sdk/cpp; do
        if task run SDK=$sdk CLI_ARGS="test" &> /dev/null; then
            echo -e "${GREEN}✓${NC} task run SDK=$sdk succeeded"
        else
            echo -e "${RED}✗${NC} task run SDK=$sdk failed"
            ERRORS=$((ERRORS + 1))
        fi
    done

    # Test tests
    echo -e "${YELLOW}Running tests...${NC}"
    if task test-all; then
        echo -e "${GREEN}✓${NC} task test-all succeeded"
    else
        echo -e "${RED}✗${NC} task test-all failed"
        ERRORS=$((ERRORS + 1))
    fi

    echo ""
else
    echo "3. Skipping Task command tests (task not installed)"
    echo ""
fi

# 4. Check binaries exist (if built)
echo "4. Checking built binaries..."
if [ -f "sdk/go/build/go-sdk" ]; then
    echo -e "${GREEN}✓${NC} Go binary exists"
    if ./sdk/go/build/go-sdk &> /dev/null; then
        echo -e "${GREEN}✓${NC} Go binary is executable"
    fi
else
    echo -e "${YELLOW}⚠${NC} Go binary not built yet"
fi

if [ -f "sdk/rust/target/release/rust-sdk" ]; then
    echo -e "${GREEN}✓${NC} Rust binary exists"
    if ./sdk/rust/target/release/rust-sdk &> /dev/null; then
        echo -e "${GREEN}✓${NC} Rust binary is executable"
    fi
else
    echo -e "${YELLOW}⚠${NC} Rust binary not built yet"
fi

if [ -f "sdk/cpp/build/cpp-sdk" ]; then
    echo -e "${GREEN}✓${NC} C++ binary exists"
    if ./sdk/cpp/build/cpp-sdk &> /dev/null; then
        echo -e "${GREEN}✓${NC} C++ binary is executable"
    fi
else
    echo -e "${YELLOW}⚠${NC} C++ binary not built yet"
fi

echo ""
echo "========================================"
echo "Verification Summary"
echo "========================================"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "Your Taskfile monorepo is properly set up."
    echo ""
    echo "Try these commands:"
    echo "  task --list"
    echo "  task help"
    echo "  task build-all"
    echo "  task test-all"
    echo "  task run SDK=sdk/go CLI_ARGS=\"hello\""
    exit 0
else
    echo -e "${RED}✗ $ERRORS check(s) failed${NC}"
    echo ""
    echo "Some issues were found. Please review the output above."
    echo ""
    if ! command -v task &> /dev/null; then
        echo "To install Task, run:"
        echo "  ./install-task.sh"
        echo ""
    fi
    exit 1
fi
