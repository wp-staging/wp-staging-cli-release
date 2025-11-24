#!/usr/bin/env bash
# WP Staging CLI Installer
# This script installs wpstaging on Linux, macOS, and WSL
# Usage: curl -fsSL https://wp-staging.com/install.sh | bash

set -e

# Configuration
REPO_URL="https://raw.githubusercontent.com/wp-staging/wp-staging-cli-release/main"
MANIFEST_URL="${REPO_URL}/manifest.json"
INSTALL_DIR_USER="${HOME}/.local/bin"
INSTALL_DIR_SYSTEM="/usr/local/bin"
COMPLETION_DIR_USER="${HOME}/.local/share/bash-completion/completions"
COMPLETION_DIR_SYSTEM="/etc/bash_completion.d"
BINARY_NAME="wpstaging"
COMPLETION_NAME="wpstaging"

# Colors for output
RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;36m'
NC='\033[0m' # No Color

# Temporary directory for downloads
TMP_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'wpstaging')
trap "rm -rf '$TMP_DIR'" EXIT

# Helper functions
error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

info() {
    echo -e "${BLUE}$1${NC}"
}

success() {
    echo -e "${GREEN}$1${NC}"
}

warning() {
    echo -e "${YELLOW}$1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect OS
detect_os() {
    local os
    os=$(uname -s | tr '[:upper:]' '[:lower:]')

    case "$os" in
        linux*)
            # Check for WSL
            if grep -qi microsoft /proc/version 2>/dev/null || grep -qi wsl /proc/version 2>/dev/null; then
                echo "linux"  # WSL is treated as Linux
            else
                echo "linux"
            fi
            ;;
        darwin*)
            echo "darwin"
            ;;
        mingw* | msys* | cygwin*)
            error "Windows detected. Please use PowerShell installer instead:\n\n    irm https://wp-staging.com/install.ps1 | iex\n\nOr download manually from:\n    https://github.com/wp-staging/wp-staging-cli-release"
            ;;
        *)
            error "Unsupported operating system: $os"
            ;;
    esac
}

# Detect architecture
detect_arch() {
    local arch
    arch=$(uname -m)

    case "$arch" in
        x86_64 | amd64)
            echo "amd64"
            ;;
        aarch64 | arm64)
            echo "arm64"
            ;;
        i386 | i686)
            echo "386"
            ;;
        *)
            error "Unsupported architecture: $arch"
            ;;
    esac
}

# Detect if system is using musl (Alpine Linux, etc.)
is_musl() {
    if [ -f /lib/libc.musl-x86_64.so.1 ] || [ -f /lib/libc.musl-aarch64.so.1 ]; then
        return 0
    fi

    if command_exists ldd; then
        if ldd --version 2>&1 | grep -qi musl; then
            return 0
        fi
    fi

    return 1
}

# Download file using curl or wget
download() {
    local url="$1"
    local output="$2"

    if command_exists curl; then
        curl -fsSL "$url" -o "$output" || error "Failed to download: $url"
    elif command_exists wget; then
        wget -q "$url" -O "$output" || error "Failed to download: $url"
    else
        error "Neither curl nor wget is available. Please install one of them."
    fi
}

# Parse JSON value (works without jq)
parse_json() {
    local json="$1"
    local key="$2"
    echo "$json" | grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | sed 's/.*"\([^"]*\)".*/\1/'
}

# Get platform string
get_platform() {
    local os="$1"
    local arch="$2"

    # Map to platform strings used in binary names
    case "$os" in
        darwin)
            # Use universal binary for macOS (works on both Intel and ARM)
            echo "macos_universal"
            ;;
        linux)
            echo "linux_${arch}"
            ;;
        *)
            error "Unknown OS: $os"
            ;;
    esac
}

# Verify checksum
verify_checksum() {
    local file="$1"
    local expected="$2"

    # Validate checksum format (SHA256 is 64 hex characters)
    if ! echo "$expected" | grep -qE '^[a-f0-9]{64}$'; then
        error "Invalid checksum format: $expected"
    fi

    local actual
    if command_exists sha256sum; then
        actual=$(sha256sum "$file" | awk '{print $1}')
    elif command_exists shasum; then
        actual=$(shasum -a 256 "$file" | awk '{print $1}')
    else
        warning "Neither sha256sum nor shasum found. Skipping checksum verification."
        return 0
    fi

    if [ "$actual" != "$expected" ]; then
        error "Checksum verification failed!\n  Expected: $expected\n  Got:      $actual"
    fi

    success "✓ Checksum verified"
}

# Check if directory is writable
is_writable() {
    local dir="$1"
    [ -d "$dir" ] && [ -w "$dir" ]
}

# Ensure directory exists and is writable
ensure_dir() {
    local dir="$1"
    local use_sudo="$2"

    if [ ! -d "$dir" ]; then
        if [ "$use_sudo" = "true" ] && command_exists sudo; then
            sudo mkdir -p "$dir" || return 1
        else
            mkdir -p "$dir" || return 1
        fi
    fi

    if [ "$use_sudo" = "true" ]; then
        [ -d "$dir" ]
    else
        is_writable "$dir"
    fi
}

# Install binary
install_binary() {
    local binary="$1"
    local install_dir="$2"
    local use_sudo="$3"

    ensure_dir "$install_dir" "$use_sudo" || error "Cannot create directory: $install_dir"

    local target="${install_dir}/${BINARY_NAME}"

    if [ "$use_sudo" = "true" ] && command_exists sudo; then
        sudo cp "$binary" "$target" || error "Failed to install binary to $target"
        sudo chmod +x "$target" || error "Failed to set executable permission"
    else
        cp "$binary" "$target" || error "Failed to install binary to $target"
        chmod +x "$target" || error "Failed to set executable permission"
    fi

    success "✓ Installed binary to $target"
}

# Install bash completion
install_completion() {
    local completion_script="$1"
    local use_sudo="$2"

    # Skip if bash is not available
    if ! command_exists bash; then
        info "Bash not found, skipping completion installation"
        return 0
    fi

    local completion_dir
    local completion_target

    # Try user directory first
    if [ "$use_sudo" = "false" ]; then
        completion_dir="$COMPLETION_DIR_USER"
        ensure_dir "$completion_dir" "false" 2>/dev/null || true

        if [ -d "$completion_dir" ] && [ -w "$completion_dir" ]; then
            completion_target="${completion_dir}/${COMPLETION_NAME}"
            cp "$completion_script" "$completion_target" || warning "Failed to install bash completion"
            success "✓ Installed bash completion to $completion_target"
            return 0
        fi

        # Fallback to .bash_completion in home
        if [ -f "$HOME/.bashrc" ] || [ -f "$HOME/.bash_profile" ]; then
            # Check if completion already exists to avoid duplicates
            if [ -f "$HOME/.bash_completion" ] && grep -Fq "# wpstaging completion" "$HOME/.bash_completion" 2>/dev/null; then
                success "✓ Bash completion already installed in ~/.bash_completion"
                return 0
            fi

            cat "$completion_script" >> "$HOME/.bash_completion"
            success "✓ Installed bash completion to ~/.bash_completion"
            info "  Add 'source ~/.bash_completion' to your ~/.bashrc if not already present"
            return 0
        fi
    else
        # System-wide installation
        completion_dir="$COMPLETION_DIR_SYSTEM"
        ensure_dir "$completion_dir" "true" || return 1

        completion_target="${completion_dir}/${COMPLETION_NAME}"
        if command_exists sudo; then
            sudo cp "$completion_script" "$completion_target" || warning "Failed to install bash completion"
            success "✓ Installed bash completion to $completion_target"
        fi
    fi
}

# Check if directory is in PATH
in_path() {
    local dir="$1"
    echo "$PATH" | tr ':' '\n' | grep -q "^${dir}\$"
}

# Add directory to shell RC file
add_to_path() {
    local dir="$1"

    # Determine which RC file to use
    local rc_file=""
    if [ -n "$BASH_VERSION" ]; then
        rc_file="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        rc_file="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        rc_file="$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        rc_file="$HOME/.zshrc"
    elif [ -f "$HOME/.profile" ]; then
        rc_file="$HOME/.profile"
    fi

    if [ -z "$rc_file" ]; then
        warning "Could not determine shell RC file"
        info "Please manually add '$dir' to your PATH"
        return 1
    fi

    # Check if already in RC file
    if grep -q "export PATH=.*$dir" "$rc_file" 2>/dev/null; then
        info "PATH already configured in $rc_file"
        return 0
    fi

    # Add to RC file
    echo "" >> "$rc_file"
    echo "# Added by WP Staging CLI installer" >> "$rc_file"
    echo "export PATH=\"${dir}:\$PATH\"" >> "$rc_file"

    success "✓ Added $dir to PATH in $rc_file"
    info "  Run 'source $rc_file' or restart your shell to apply changes"
}

# Main installation
main() {
    info "WP Staging CLI Installer"
    info "========================\n"

    # Detect platform
    info "Detecting platform..."
    OS=$(detect_os)
    ARCH=$(detect_arch)
    PLATFORM=$(get_platform "$OS" "$ARCH")

    info "  OS: $OS"
    info "  Architecture: $ARCH"
    info "  Platform: $PLATFORM"

    # Download manifest
    info "\nFetching latest version..."
    download "$MANIFEST_URL" "$TMP_DIR/manifest.json"

    MANIFEST=$(cat "$TMP_DIR/manifest.json")
    VERSION=$(parse_json "$MANIFEST" "version")

    if [ -z "$VERSION" ]; then
        error "Failed to parse version from manifest"
    fi

    success "✓ Latest version: $VERSION"

    # Get checksum and download URL from manifest
    info "\nDownloading wpstaging..."

    # Parse checksum for this platform
    # Using -A 10 to handle formatted JSON with additional fields between platform and checksum
    CHECKSUM=$(echo "$MANIFEST" | grep -A 10 "\"${PLATFORM}\"" | grep '"checksum"' | head -1 | sed 's/.*"checksum"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')

    if [ -z "$CHECKSUM" ]; then
        error "No checksum found for platform: $PLATFORM"
    fi

    # Download binary
    BINARY_URL="${REPO_URL}/build/${PLATFORM}/${BINARY_NAME}"
    download "$BINARY_URL" "$TMP_DIR/${BINARY_NAME}"

    success "✓ Downloaded binary"

    # Verify checksum
    info "\nVerifying checksum..."
    verify_checksum "$TMP_DIR/${BINARY_NAME}" "$CHECKSUM"

    # Make binary executable
    chmod +x "$TMP_DIR/${BINARY_NAME}"

    # Download bash completion
    info "\nDownloading bash completion script..."
    COMPLETION_URL="${REPO_URL}/wp_staging_cli_bash_completion"
    download "$COMPLETION_URL" "$TMP_DIR/wp_staging_cli_bash_completion" || warning "Failed to download bash completion (continuing anyway)"

    # Determine installation directory
    info "\nInstalling wpstaging..."

    USE_SUDO="false"
    INSTALL_DIR="$INSTALL_DIR_USER"

    # Try user directory first
    if ! ensure_dir "$INSTALL_DIR_USER" "false" 2>/dev/null || ! is_writable "$INSTALL_DIR_USER"; then
        # User directory not available, ask about system installation
        if command_exists sudo; then
            warning "User directory $INSTALL_DIR_USER is not writable"
            info "Would you like to install system-wide to $INSTALL_DIR_SYSTEM? (requires sudo)"
            read -p "Install system-wide? [y/N] " -n 1 -r < /dev/tty
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                USE_SUDO="true"
                INSTALL_DIR="$INSTALL_DIR_SYSTEM"
            else
                error "Installation cancelled"
            fi
        else
            error "Cannot write to $INSTALL_DIR_USER and sudo is not available"
        fi
    fi

    # Install binary
    install_binary "$TMP_DIR/${BINARY_NAME}" "$INSTALL_DIR" "$USE_SUDO"

    # Install bash completion
    if [ -f "$TMP_DIR/wp_staging_cli_bash_completion" ]; then
        info "\nInstalling bash completion..."
        install_completion "$TMP_DIR/wp_staging_cli_bash_completion" "$USE_SUDO"
    fi

    # Check and update PATH if needed
    if ! in_path "$INSTALL_DIR"; then
        info "\nUpdating PATH..."
        if [ "$USE_SUDO" = "false" ]; then
            add_to_path "$INSTALL_DIR"
        else
            success "✓ $INSTALL_DIR is typically in PATH by default"
        fi
    else
        success "✓ $INSTALL_DIR is already in PATH"
    fi

    # Verify installation
    info "\nVerifying installation..."
    if command_exists "$BINARY_NAME"; then
        VERSION_OUTPUT=$("$BINARY_NAME" --version 2>&1 || echo "")
        success "✓ Installation successful!\n"
        success "Installed: $VERSION_OUTPUT"
    else
        warning "⚠ Installation complete, but '$BINARY_NAME' is not in PATH"
        info "  You may need to restart your shell or run: source ~/.bashrc"
    fi

    # Show usage
    echo ""
    info "Usage:"
    info "  $BINARY_NAME add <mysite.com>"
    info ""
    info "Get started:"
    info "  $BINARY_NAME --help"
    info ""
    info "Documentation:"
    info "  https://github.com/wp-staging/wp-staging-cli-release"
    echo ""
}

# Run main function
main
