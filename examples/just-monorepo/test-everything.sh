#!/usr/bin/env bash
# Comprehensive test script for the just monorepo launcher
# This script tests all key functionality

set -e  # Exit on error

echo "======================================"
echo "Just Monorepo Launcher Test Suite"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

test_section() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

test_pass() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Check just is installed
test_section "Checking Prerequisites"
if ! command -v just &> /dev/null; then
    echo "Error: just is not installed"
    echo "Install with: cargo install just"
    exit 1
fi
test_pass "just is installed ($(just --version))"
echo ""

# Test 1: List commands
test_section "Test 1: Listing Available Commands"
just --list > /dev/null
test_pass "just --list works"
echo ""

# Test 2: Check SDK configuration
test_section "Test 2: SDK Configuration"
just check
test_pass "All SDKs configured"
echo ""

# Test 3: Path validation
test_section "Test 3: Path Validation"
if just build nonexistent/path 2>&1 | grep -q "does not exist"; then
    test_pass "Path validation works"
else
    echo "Error: Path validation failed"
    exit 1
fi
echo ""

# Test 4: Build each SDK
test_section "Test 4: Building Individual SDKs"
for sdk in sdk/go sdk/rust sdk/cpp; do
    just build "$sdk"
    test_pass "Built $sdk"
done
echo ""

# Test 5: Test each SDK
test_section "Test 5: Testing Individual SDKs"
for sdk in sdk/go sdk/rust sdk/cpp; do
    just test "$sdk" > /dev/null
    test_pass "Tested $sdk"
done
echo ""

# Test 6: Run each SDK
test_section "Test 6: Running Individual SDKs"
output=$(just run sdk/go "test")
if [[ "$output" == *"Hello from Go SDK"* ]]; then
    test_pass "Go SDK runs correctly"
fi

output=$(just run sdk/rust "test")
if [[ "$output" == *"Hello from Rust SDK"* ]]; then
    test_pass "Rust SDK runs correctly"
fi

output=$(just run sdk/cpp "test")
if [[ "$output" == *"Hello from C++ SDK"* ]]; then
    test_pass "C++ SDK runs correctly"
fi
echo ""

# Test 7: Dry-run mode
test_section "Test 7: Dry-Run Mode"
output=$(just --dry-run build sdk/go)
if [[ "$output" == *"validate-path"* ]]; then
    test_pass "Dry-run mode works"
fi
echo ""

# Test 8: Build all SDKs
test_section "Test 8: Building All SDKs"
just build-all > /dev/null
test_pass "Built all SDKs successfully"
echo ""

# Test 9: Test all SDKs
test_section "Test 9: Testing All SDKs"
just test-all > /dev/null
test_pass "All SDK tests passed"
echo ""

# Test 10: Clean
test_section "Test 10: Cleaning Build Artifacts"
just clean-all > /dev/null
test_pass "Cleaned all SDKs"
echo ""

# Final summary
echo "======================================"
echo -e "${GREEN}All tests passed!${NC}"
echo "======================================"
echo ""
echo "The just monorepo launcher is working correctly."
echo "See README.md for detailed documentation."
