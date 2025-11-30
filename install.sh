#!/usr/bin/env bash
# WP Staging CLI Installer
# This script installs wpstaging on Linux, macOS, and WSL
#
# Usage:
#   Install latest stable version (default):
#     curl -fsSL https://wp-staging.com/install.sh | bash
#
#   Install specific version:
#     curl -fsSL https://wp-staging.com/install.sh | bash -s -- -v 1.4.0-beta.1
#
#   Install with license key (for immediate use without prompts):
#     curl -fsSL https://wp-staging.com/install.sh | bash -s -- -l YOUR_LICENSE_KEY
#
#   Install specific version with license:
#     curl -fsSL https://wp-staging.com/install.sh | bash -s -- -v 1.4.0 -l YOUR_LICENSE_KEY
#
# Options:
#   -v, --version VERSION    Install specific version (e.g., 1.4.0, 1.4.0-beta.1)
#   -l, --license KEY        Register license key after installation
#
# Examples:
#   bash -s -- -v 1.4.0-beta.1              # Install version 1.4.0-beta.1
#   bash -s -- -v 1.3.5                     # Install version 1.3.5
#   bash                                    # Install latest stable (no beta/alpha/rc)
#   bash -s -- -l abc123                    # Install latest with license
#   bash -s -- -v 1.4.0 -l abc123           # Install 1.4.0 with license

set -e

# Configuration
GITHUB_API_URL="https://api.github.com/repos/wp-staging/wp-staging-cli-release"
GITHUB_RAW_URL="https://raw.githubusercontent.com/wp-staging/wp-staging-cli-release"
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
    echo -e "${BLUE}$1${NC}" >&2
}

success() {
    echo -e "${GREEN}$1${NC}" >&2
}

warning() {
    echo -e "${YELLOW}$1${NC}" >&2
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Pick the appropriate RC file based on user's login shell
# Only edit one file to avoid noise and user distrust
pick_rc_file() {
    local s
    s=$(basename "${SHELL:-/bin/bash}")

    case "$s" in
        zsh)
            echo "$HOME/.zshrc"
            ;;
        bash)
            # Prefer .bash_profile on login shells (macOS), fallback to .bashrc
            if [ -f "$HOME/.bash_profile" ]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi
            ;;
        fish)
            echo "$HOME/.config/fish/config.fish"
            ;;
        *)
            echo "$HOME/.profile"
            ;;
    esac
}

# Get shell-specific source command based on user's login shell
get_source_command() {
    local rc
    rc=$(pick_rc_file)
    echo "source $rc"
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

# Install aliases (symlinks)
install_aliases() {
    local install_dir="$1"
    local use_sudo="$2"

    local binary_path="${install_dir}/${BINARY_NAME}"
    local wpstg_alias="${install_dir}/wpstg"
    local wp_staging_alias="${install_dir}/wp-staging"

    if [ "$use_sudo" = "true" ] && command_exists sudo; then
        sudo ln -sf "$BINARY_NAME" "$wpstg_alias" || warning "Failed to create wpstg alias"
        sudo ln -sf "$BINARY_NAME" "$wp_staging_alias" || warning "Failed to create wp-staging alias"
    else
        ln -sf "$BINARY_NAME" "$wpstg_alias" || warning "Failed to create wpstg alias"
        ln -sf "$BINARY_NAME" "$wp_staging_alias" || warning "Failed to create wp-staging alias"
    fi

    success "✓ Created aliases: wpstg, wp-staging"
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

# Prompt user for sudo permission
# Returns 0 if user accepts, 1 if user declines
# NOTE: All output goes to stderr to avoid polluting stdout (used for return values)
prompt_sudo() {
    local system_dir="$1"

    echo "" >&2
    info "sudo permission requested"
    echo "" >&2
    info "Why: Installing to $system_dir allows wpstaging to work immediately"
    info "     without modifying your shell configuration or restarting your terminal."
    echo "" >&2
    info "What happens: sudo will copy the wpstaging binary to $system_dir"
    info "              This is a standard location for user-installed programs."
    echo "" >&2

    # Read from /dev/tty to work in piped scripts (curl | bash)
    # Prompt also goes to stderr to keep stdout clean
    printf "%b" "${BLUE}Allow sudo installation to $system_dir? [Y/n] ${NC}" >&2
    read -r response < /dev/tty 2>/dev/null || response="y"

    case "$response" in
        [nN]|[nN][oO])
            return 1
            ;;
        *)
            return 0
            ;;
    esac
}

# Pick best installation directory
# Prefers directories already on PATH to avoid needing shell reload
# Returns: "directory|use_sudo" (e.g., "/usr/local/bin|true")
pick_install_dir() {
    # Trusted candidates only, do not install into arbitrary PATH entries
    local candidates=(
        "/usr/local/bin"
        "/opt/homebrew/bin"
        "${HOME}/.local/bin"
        "${HOME}/bin"
    )

    # 1) If candidate is in PATH and writable, use it (no sudo, no reload needed)
    for d in "${candidates[@]}"; do
        if in_path "$d" && [ -d "$d" ] && [ -w "$d" ]; then
            echo "$d|false"
            return 0
        fi
    done

    # 2) If /usr/local/bin is in PATH and sudo is available, ask user
    if in_path "/usr/local/bin" && command_exists sudo; then
        if prompt_sudo "/usr/local/bin"; then
            echo "/usr/local/bin|true"
            return 0
        fi
        # User declined sudo, fall through to user directory
        echo "${HOME}/.local/bin|false|declined"
        return 0
    fi

    # 3) If /opt/homebrew/bin is in PATH (Apple Silicon) and sudo is available, ask user
    if in_path "/opt/homebrew/bin" && command_exists sudo; then
        if prompt_sudo "/opt/homebrew/bin"; then
            echo "/opt/homebrew/bin|true"
            return 0
        fi
        # User declined sudo, fall through to user directory
        echo "${HOME}/.local/bin|false|declined"
        return 0
    fi

    # 4) Fallback to user dir (will need PATH update and shell reload)
    echo "${HOME}/.local/bin|false"
}

# Add directory to shell RC file (single file based on user's shell)
# Uses idempotent guarded block to avoid duplicates
add_to_path() {
    local dir="$1"
    local rc
    rc=$(pick_rc_file)

    # Fish shell uses different syntax
    case "$rc" in
        *"fish/config.fish")
            # Ensure fish config directory exists
            mkdir -p "$(dirname "$rc")"
            [ -f "$rc" ] || touch "$rc"

            # Check if already configured (idempotent)
            if grep -q "WP Staging CLI installer" "$rc" 2>/dev/null; then
                info "PATH already configured in $rc"
                return 0
            fi

            # Add Fish-style path export
            {
                echo ""
                echo "# Added by WP Staging CLI installer"
                echo "set -gx PATH \$PATH \"$dir\""
            } >> "$rc"

            success "✓ Added $dir to PATH in $rc"
            info "  Run '$(get_source_command)' or restart your shell to apply changes"
            return 0
            ;;
    esac

    # Create file if it doesn't exist (for bash/zsh/POSIX shells)
    [ -f "$rc" ] || touch "$rc"

    # Check if already configured (idempotent)
    if grep -q "WP Staging CLI installer" "$rc" 2>/dev/null; then
        info "PATH already configured in $rc"
        return 0
    fi

    # Add guarded PATH export (only adds if not already in PATH)
    {
        echo ""
        echo "# Added by WP Staging CLI installer"
        echo "case \":\$PATH:\" in"
        echo "  *\":$dir:\"*) ;;"
        echo "  *) export PATH=\"\$PATH:$dir\" ;;"
        echo "esac"
    } >> "$rc"

    success "✓ Added $dir to PATH in $rc"
    info "  Run '$(get_source_command)' or restart your shell to apply changes"
}

# Fetch latest stable version from GitHub (excludes beta/alpha/rc)
fetch_latest_stable_version() {
    info "Fetching latest stable version..."

    local tags_json
    local version=""

    # Try to fetch tags from GitHub API
    if command_exists curl; then
        tags_json=$(curl -fsSL "${GITHUB_API_URL}/tags" 2>/dev/null) || {
            warning "Failed to fetch tags from GitHub API, falling back to 'main'"
            echo "main"
            return 0
        }
    elif command_exists wget; then
        tags_json=$(wget -qO- "${GITHUB_API_URL}/tags" 2>/dev/null) || {
            warning "Failed to fetch tags from GitHub API, falling back to 'main'"
            echo "main"
            return 0
        }
    else
        warning "Neither curl nor wget available, falling back to 'main'"
        echo "main"
        return 0
    fi

    # Parse tags and filter out pre-release versions (beta, alpha, rc)
    # Extract tag names and filter
    version=$(echo "$tags_json" | grep '"name"' | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | grep -v -E 'beta|alpha|rc|Alpha|Beta|RC' | head -1)

    if [ -z "$version" ]; then
        warning "No stable version found, falling back to 'main'"
        echo "main"
        return 0
    fi

    echo "$version"
}

# Validate that a version exists in the release repository
validate_version() {
    local version="$1"

    # Skip validation for 'main'
    if [ "$version" = "main" ]; then
        return 0
    fi

    info "Validating version $version..."

    local manifest_url="${GITHUB_RAW_URL}/${version}/manifest.json"
    local status_code

    # Check if manifest exists for this version
    if command_exists curl; then
        status_code=$(curl -o /dev/null -s -w "%{http_code}" "$manifest_url")
        if [ "$status_code" != "200" ]; then
            error "Version '$version' not found in release repository.\n\n  Please check available versions at:\n  https://github.com/wp-staging/wp-staging-cli-release/tags\n\n  Or install the latest stable version by omitting the version argument."
        fi
    elif command_exists wget; then
        if ! wget -q --spider "$manifest_url" 2>/dev/null; then
            error "Version '$version' not found in release repository.\n\n  Please check available versions at:\n  https://github.com/wp-staging/wp-staging-cli-release/tags\n\n  Or install the latest stable version by omitting the version argument."
        fi
    fi

    success "✓ Version $version exists"
}

# Main installation
main() {
    info "WP Staging CLI Installer"
    info "========================\n"

    # Parse arguments (version and license)
    local REQUESTED_VERSION=""
    local LICENSE_KEY=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --license=*)
                LICENSE_KEY="${1#*=}"
                shift
                ;;
            --license|-l)
                LICENSE_KEY="$2"
                shift 2
                ;;
            --version=*)
                REQUESTED_VERSION="${1#*=}"
                shift
                ;;
            --version|-v)
                REQUESTED_VERSION="$2"
                shift 2
                ;;
            -*)
                warning "Unknown option: $1"
                shift
                ;;
            *)
                warning "Unknown argument: $1"
                shift
                ;;
        esac
    done

    local VERSION_REF=""

    if [ -n "$REQUESTED_VERSION" ]; then
        # User specified a version
        info "Requested version: $REQUESTED_VERSION"
        VERSION_REF="$REQUESTED_VERSION"

        # Validate version exists
        validate_version "$VERSION_REF"
    else
        # No version specified, fetch latest stable (no beta/alpha/rc)
        VERSION_REF=$(fetch_latest_stable_version)

        if [ "$VERSION_REF" = "main" ]; then
            info "Using branch: main"
        else
            info "Selected latest stable version: $VERSION_REF"
        fi
    fi

    # Build URLs based on version
    REPO_URL="${GITHUB_RAW_URL}/${VERSION_REF}"
    MANIFEST_URL="${REPO_URL}/manifest.json"

    # Detect platform
    info "\nDetecting platform..."
    OS=$(detect_os)
    ARCH=$(detect_arch)
    PLATFORM=$(get_platform "$OS" "$ARCH")

    info "  OS: $OS"
    info "  Architecture: $ARCH"
    info "  Platform: $PLATFORM"

    # Download manifest
    info "\nDownloading manifest..."
    download "$MANIFEST_URL" "$TMP_DIR/manifest.json"

    MANIFEST=$(cat "$TMP_DIR/manifest.json")
    VERSION=$(parse_json "$MANIFEST" "version")

    if [ -z "$VERSION" ]; then
        error "Failed to parse version from manifest"
    fi

    success "✓ Version: $VERSION"

    # Get checksum and download URL from manifest
    info "\nDownloading wpstaging..."

    # Parse checksum and binary path for this platform
    # Prefer jq for reliable JSON parsing, fallback to grep/sed
    if command_exists jq; then
        CHECKSUM=$(echo "$MANIFEST" | jq -r ".platforms[\"${PLATFORM}\"].checksum // empty")
        BINARY_PATH=$(echo "$MANIFEST" | jq -r ".platforms[\"${PLATFORM}\"].binary // empty")
    else
        # Fallback: Using grep -A to handle formatted JSON with additional fields
        # This approach is fragile but works for our specific manifest format
        CHECKSUM=$(echo "$MANIFEST" | grep -A 10 "\"${PLATFORM}\"" | grep '"checksum"' | head -1 | sed 's/.*"checksum"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        BINARY_PATH=$(echo "$MANIFEST" | grep -A 10 "\"${PLATFORM}\"" | grep '"binary"' | head -1 | sed 's/.*"binary"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    fi

    if [ -z "$CHECKSUM" ]; then
        error "No checksum found for platform: $PLATFORM"
    fi

    if [ -z "$BINARY_PATH" ]; then
        error "No binary path found for platform: $PLATFORM"
    fi

    # Download binary using path from manifest
    BINARY_URL="${REPO_URL}/build/${BINARY_PATH}"
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
    # Prefer directories already on PATH to avoid needing shell reload
    info "\nInstalling wpstaging..."

    IFS='|' read -r INSTALL_DIR USE_SUDO SUDO_DECLINED < <(pick_install_dir)

    # Show message if user declined sudo
    if [ "$SUDO_DECLINED" = "declined" ]; then
        info "Installing to user directory instead (no sudo required)"
    fi

    if in_path "$INSTALL_DIR"; then
        info "Installing to $INSTALL_DIR (already in PATH - works immediately)"
    else
        info "Installing to $INSTALL_DIR (will add to PATH)"
    fi

    # Ensure directory exists
    ensure_dir "$INSTALL_DIR" "$USE_SUDO" || error "Cannot create directory: $INSTALL_DIR"

    # Install binary
    install_binary "$TMP_DIR/${BINARY_NAME}" "$INSTALL_DIR" "$USE_SUDO"

    # Install aliases
    info "\nInstalling aliases..."
    install_aliases "$INSTALL_DIR" "$USE_SUDO"

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

    # Register license key if provided
    if [ -n "$LICENSE_KEY" ]; then
        info "\nRegistering license key..."
        local register_binary="${INSTALL_DIR}/${BINARY_NAME}"

        # Check if binary exists and is executable
        if [ ! -x "$register_binary" ]; then
            warning "Binary not found or not executable. Cannot register license."
            warning "You can register later with: wpstaging register"
        else
            # Pass license via environment variable to avoid exposure in process list
            local output
            if output=$(WPSTGPRO_LICENSE="$LICENSE_KEY" "$register_binary" register 2>&1); then
                success "✓ License registered successfully"
            else
                warning "License registration failed: $output"
                warning "You can register later with: wpstaging register"
            fi
        fi
    fi

    # Verify installation
    info "\nVerifying installation..."
    if command_exists "$BINARY_NAME"; then
        VERSION_OUTPUT=$("$BINARY_NAME" --version 2>&1 || echo "")
        success "✓ Installation successful!"
        success "Installed: $VERSION_OUTPUT"
    else
        warning "⚠ Installation complete, but '$BINARY_NAME' is not in PATH"
        info "  Run '$(get_source_command)' or restart your shell to apply changes"
    fi

    # Show usage
    echo ""

    # Check if installed to a directory already in PATH (works immediately)
    if in_path "$INSTALL_DIR"; then
        # Works immediately - no reload needed
        info "Get started:"
        if [ -n "$LICENSE_KEY" ]; then
            info "  wpstaging add mysite.local --license $LICENSE_KEY"
            echo ""
            info "Note: The license key is only needed once to activate WP Staging CLI."
            info "      After activation, you can use wpstaging without the --license flag."
        else
            info "  wpstaging add mysite.local"
        fi
    else
        # Need to reload shell or use full path
        info "Run wpstaging immediately (copy & paste):"
        if [ -n "$LICENSE_KEY" ]; then
            info "  ${INSTALL_DIR}/${BINARY_NAME} add mysite.local --license $LICENSE_KEY"
            echo ""
            info "Note: The license key is only needed once to activate WP Staging CLI."
            info "      After activation, you can use wpstaging without the --license flag."
        else
            info "  ${INSTALL_DIR}/${BINARY_NAME} add mysite.local"
        fi
        echo ""
        info "Or reload your shell first:"
        info "  $(get_source_command)"
        echo ""
        if [ -n "$LICENSE_KEY" ]; then
            info "Then use:"
            info "  wpstaging add mysite.local"
        fi
    fi

    echo ""
    info "Get help:"
    info "  wpstaging --help"
    echo ""
    info "Documentation:"
    info "  https://github.com/wp-staging/wp-staging-cli-release"
    echo ""
}

# Run main function with version argument (if provided)
main "$@"
