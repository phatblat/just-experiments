#!/usr/bin/env bash
#
# Validation script for mise-monorepo example
# This checks that the project structure is correct and can be built

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Mise Monorepo Validation Script"
echo "================================"
echo ""

# Track results
ERRORS=0
WARNINGS=0

# Helper functions
check_command() {
    local cmd=$1
    local name=$2
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name installed: $(command -v $cmd)"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $name not installed (optional)"
        ((WARNINGS++))
        return 1
    fi
}

check_file() {
    local file=$1
    local name=$2
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $name exists: $file"
        return 0
    else
        echo -e "${RED}✗${NC} $name missing: $file"
        ((ERRORS++))
        return 1
    fi
}

check_directory() {
    local dir=$1
    local name=$2
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} $name exists: $dir"
        return 0
    else
        echo -e "${RED}✗${NC} $name missing: $dir"
        ((ERRORS++))
        return 1
    fi
}

# Check we're in the right directory
if [ ! -f "mise.toml" ]; then
    echo -e "${RED}Error: Not in mise-monorepo root directory${NC}"
    echo "Please run this script from: /home/user/just-experiments/examples/mise-monorepo"
    exit 1
fi

echo "Step 1: Checking required tools"
echo "--------------------------------"
check_command "go" "Go"
GO_INSTALLED=$?
check_command "cargo" "Rust/Cargo"
CARGO_INSTALLED=$?
check_command "g++" "C++ Compiler (g++)" || check_command "clang++" "C++ Compiler (clang++)"
CPP_INSTALLED=$?
check_command "mise" "Mise"
MISE_INSTALLED=$?
echo ""

echo "Step 2: Checking project structure"
echo "-----------------------------------"
check_directory "sdk" "SDK directory"
check_directory "sdk/go" "Go SDK directory"
check_directory "sdk/rust" "Rust SDK directory"
check_directory "sdk/cpp" "C++ SDK directory"
echo ""

echo "Step 3: Checking configuration files"
echo "-------------------------------------"
check_file "mise.toml" "Root mise.toml"
check_file "sdk/go/mise.toml" "Go SDK mise.toml"
check_file "sdk/rust/mise.toml" "Rust SDK mise.toml"
check_file "sdk/cpp/mise.toml" "C++ SDK mise.toml"
echo ""

echo "Step 4: Checking source files"
echo "------------------------------"
check_file "sdk/go/main.go" "Go source"
check_file "sdk/go/go.mod" "Go module"
check_file "sdk/rust/Cargo.toml" "Rust manifest"
check_file "sdk/rust/src/main.rs" "Rust source"
check_file "sdk/cpp/main.cpp" "C++ source"
check_file "sdk/cpp/Makefile" "C++ Makefile"
echo ""

echo "Step 5: Checking documentation"
echo "-------------------------------"
check_file "README.md" "Main README"
check_file "QUICKSTART.md" "Quick Start guide"
check_file "ALTERNATIVES.md" "Alternatives comparison"
echo ""

# Try to build if tools are available
echo "Step 6: Testing builds"
echo "----------------------"

if [ $MISE_INSTALLED -eq 0 ]; then
    echo "Testing with mise..."

    if mise tasks >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Mise tasks loaded successfully"

        # List available tasks
        echo ""
        echo "Available mise tasks:"
        mise tasks | head -20

        # Try building with mise if languages are available
        if [ $GO_INSTALLED -eq 0 ]; then
            echo ""
            echo "Testing Go build with mise..."
            if cd sdk/go && mise run build 2>&1 | grep -q "error"; then
                echo -e "${RED}✗${NC} Go build failed"
                ((ERRORS++))
            else
                echo -e "${GREEN}✓${NC} Go build successful"
                cd ../..
            fi
        fi

        if [ $CARGO_INSTALLED -eq 0 ]; then
            echo ""
            echo "Testing Rust build with mise..."
            if cd sdk/rust && mise run build 2>&1 | grep -q "error"; then
                echo -e "${RED}✗${NC} Rust build failed"
                ((ERRORS++))
            else
                echo -e "${GREEN}✓${NC} Rust build successful"
                cd ../..
            fi
        fi

        if [ $CPP_INSTALLED -eq 0 ]; then
            echo ""
            echo "Testing C++ build with mise..."
            if cd sdk/cpp && mise run build 2>&1 | grep -q "error"; then
                echo -e "${RED}✗${NC} C++ build failed"
                ((ERRORS++))
            else
                echo -e "${GREEN}✓${NC} C++ build successful"
                cd ../..
            fi
        fi
    else
        echo -e "${RED}✗${NC} Failed to load mise tasks"
        ((ERRORS++))
    fi
else
    echo -e "${YELLOW}⚠${NC} Skipping build tests (mise not installed)"
    ((WARNINGS++))
fi

echo ""
echo "Summary"
echo "======="
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}$WARNINGS warning(s)${NC}"
        echo ""
        echo "Note: Some tools are not installed but the project structure is valid."
        echo "Install missing tools to use all features."
    fi
    echo ""
    echo "Next steps:"
    echo "  1. Install mise if not already: curl https://mise.run | sh"
    echo "  2. Read QUICKSTART.md for usage instructions"
    echo "  3. Try: mise run help"
    exit 0
else
    echo -e "${RED}$ERRORS error(s) found!${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}$WARNINGS warning(s)${NC}"
    fi
    echo ""
    echo "Please fix the errors above before using this project."
    exit 1
fi
