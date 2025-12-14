#!/usr/bin/env bash
set -e

# Script to install Task (go-task/task)
# https://taskfile.dev/installation/

echo "Installing Task..."

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     OS_TYPE=linux;;
    Darwin*)    OS_TYPE=darwin;;
    *)          echo "Unsupported OS: ${OS}"; exit 1;;
esac

# Detect architecture
ARCH="$(uname -m)"
case "${ARCH}" in
    x86_64)     ARCH_TYPE=amd64;;
    arm64)      ARCH_TYPE=arm64;;
    aarch64)    ARCH_TYPE=arm64;;
    *)          echo "Unsupported architecture: ${ARCH}"; exit 1;;
esac

# Check if task is already installed
if command -v task &> /dev/null; then
    echo "Task is already installed:"
    task --version
    read -p "Do you want to reinstall? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Installation methods

# Method 1: Using Homebrew (macOS)
if [[ "$OS_TYPE" == "darwin" ]] && command -v brew &> /dev/null; then
    echo "Installing via Homebrew..."
    brew install go-task/tap/go-task
    echo "Task installed successfully!"
    task --version
    exit 0
fi

# Method 2: Using Go
if command -v go &> /dev/null; then
    echo "Installing via Go..."
    go install github.com/go-task/task/v3/cmd/task@latest
    echo "Task installed successfully!"

    # Check if GOPATH/bin is in PATH
    if ! command -v task &> /dev/null; then
        GOPATH="${GOPATH:-$(go env GOPATH)}"
        echo ""
        echo "⚠️  Note: task was installed to ${GOPATH}/bin"
        echo "Please add it to your PATH:"
        echo "  export PATH=\"\$PATH:${GOPATH}/bin\""
        echo ""
        echo "Or copy the binary to a directory in your PATH:"
        echo "  sudo cp ${GOPATH}/bin/task /usr/local/bin/"
    else
        task --version
    fi
    exit 0
fi

# Method 3: Download binary
echo "Installing via direct download..."
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
VERSION="${VERSION:-latest}"

if [[ "$VERSION" == "latest" ]]; then
    VERSION=$(curl -s https://api.github.com/repos/go-task/task/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    if [[ -z "$VERSION" ]]; then
        echo "Failed to determine latest version"
        exit 1
    fi
fi

echo "Downloading Task v${VERSION} for ${OS_TYPE}-${ARCH_TYPE}..."

DOWNLOAD_URL="https://github.com/go-task/task/releases/download/v${VERSION}/task_${OS_TYPE}_${ARCH_TYPE}.tar.gz"
TEMP_DIR=$(mktemp -d)

curl -L "${DOWNLOAD_URL}" -o "${TEMP_DIR}/task.tar.gz"
tar -xzf "${TEMP_DIR}/task.tar.gz" -C "${TEMP_DIR}"

# Install (may require sudo)
if [[ -w "$INSTALL_DIR" ]]; then
    mv "${TEMP_DIR}/task" "${INSTALL_DIR}/task"
    chmod +x "${INSTALL_DIR}/task"
else
    echo "Installing to ${INSTALL_DIR} (requires sudo)..."
    sudo mv "${TEMP_DIR}/task" "${INSTALL_DIR}/task"
    sudo chmod +x "${INSTALL_DIR}/task"
fi

rm -rf "${TEMP_DIR}"

echo "Task installed successfully!"
task --version
