# Makefile - Fallback for users without Task installed
# This demonstrates how to migrate from Make to Task

.PHONY: help install-task list build-all test-all clean-all

help:
	@echo "Taskfile Monorepo - Makefile Fallback"
	@echo "======================================"
	@echo ""
	@echo "This Makefile is a fallback for users without Task installed."
	@echo "For the full feature set, please install Task:"
	@echo ""
	@echo "  make install-task"
	@echo ""
	@echo "Or manually:"
	@echo "  ./install-task.sh"
	@echo ""
	@echo "Available commands (limited functionality):"
	@echo "  make build-all   - Build all SDKs"
	@echo "  make test-all    - Test all SDKs"
	@echo "  make clean-all   - Clean all SDKs"
	@echo ""
	@echo "With Task installed, you get:"
	@echo "  - Individual SDK commands: task build SDK=sdk/go"
	@echo "  - Better error handling"
	@echo "  - Path validation"
	@echo "  - Parallel execution"
	@echo "  - Watch mode"
	@echo "  - And much more!"

install-task:
	@echo "Installing Task..."
	@./install-task.sh

list:
	@if command -v task >/dev/null 2>&1; then \
		task --list; \
	else \
		echo "Task not installed. Run: make install-task"; \
		exit 1; \
	fi

# Build commands
build-go:
	cd sdk/go && go build -o build/go-sdk .

build-rust:
	cd sdk/rust && cargo build --release

build-cpp:
	cd sdk/cpp && mkdir -p build && cd build && cmake .. && make

build-all: build-go build-rust build-cpp

# Test commands
test-go:
	cd sdk/go && go test -v ./...

test-rust:
	cd sdk/rust && cargo test

test-cpp:
	cd sdk/cpp/build && ctest --verbose

test-all: test-go test-rust test-cpp

# Clean commands
clean-go:
	cd sdk/go && rm -rf build && go clean

clean-rust:
	cd sdk/rust && cargo clean

clean-cpp:
	cd sdk/cpp && rm -rf build

clean-all: clean-go clean-rust clean-cpp

# Run commands (limited - can't pass arguments easily)
run-go: build-go
	cd sdk/go && ./build/go-sdk

run-rust: build-rust
	cd sdk/rust && ./target/release/rust-sdk

run-cpp: build-cpp
	cd sdk/cpp && ./build/cpp-sdk
