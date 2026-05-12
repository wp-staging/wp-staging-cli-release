#!/bin/sh
# WP Staging CLI Installer
# This script installs wpstaging on Linux, macOS, and WSL
#
# Usage:
#   Install latest stable version (default):
#     curl -fsSL https://wp-staging.com/install.sh | sh
#
#   Install specific version:
#     curl -fsSL https://wp-staging.com/install.sh | sh -s -- -v 1.4.0-beta.1
#
#   Install with license key (for immediate use without prompts):
#     curl -fsSL https://wp-staging.com/install.sh | sh -s -- -l YOUR_LICENSE_KEY
#
#   Install specific version with license:
#     curl -fsSL https://wp-staging.com/install.sh | sh -s -- -v 1.4.0 -l YOUR_LICENSE_KEY
#
#   Print installer build and latest release, then exit:
#     curl -fsSL https://wp-staging.com/install.sh | sh -s -- --print-version
#
# Options:
#   -v, --version VERSION    Install specific version (e.g., 1.4.0, 1.4.0-beta.1)
#   -l, --license KEY        Register license key after installation
#   -d, --bin-dir DIR        Install binary to custom directory
#   -e, --extract DIR        Extract all files to directory (no installation)
#   -a, --cli-args ARGS      Extra arguments passed to every wpstaging binary call
#   -V, --print-version      Print installer build and latest release version, then exit
#
# Environment variables (for testing only — do not set in production):
#   GITHUB_API_URL    Override GitHub API base URL
#   GITHUB_RAW_URL    Override GitHub raw content base URL
#
# Examples:
#   sh -s -- -v 1.4.0-beta.1              # Install version 1.4.0-beta.1
#   sh -s -- -v 1.3.5                     # Install version 1.3.5
#   sh                                    # Install latest stable (no beta/alpha/rc)
#   sh -s -- -l abc123                    # Install latest with license
#   sh -s -- -v 1.4.0 -l abc123           # Install 1.4.0 with license
#   sh -s -- -d /opt/mytools              # Install binary to /opt/mytools
#   sh -s -- -e /tmp/wpstaging-files      # Extract all files without installing
#   sh -s -- -a "--debug"                 # Install and pass --debug to binary calls

set -e

# Configuration
GITHUB_API_URL="${GITHUB_API_URL:-https://api.github.com/repos/wp-staging/wp-staging-cli-release}"
GITHUB_RAW_URL="${GITHUB_RAW_URL:-https://raw.githubusercontent.com/wp-staging/wp-staging-cli-release}"
INSTALL_DIR_USER="${HOME}/.local/bin"
INSTALL_DIR_SYSTEM="/usr/local/bin"
COMPLETION_DIR_USER="${HOME}/.local/share/bash-completion/completions"
COMPLETION_DIR_SYSTEM="/etc/bash_completion.d"
ZSH_COMPLETION_DIR_USER="${HOME}/.local/share/zsh/completions"
ZSH_COMPLETION_DIR_SYSTEM="/usr/local/share/zsh/completions"
BINARY_NAME="wpstaging"
COMPLETION_NAME="wpstaging"
SCRIPT_VERSION="20260430-090000"

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
    printf '%b\n' "${RED}Error: $1${NC}" >&2
    exit 1
}

info() {
    printf '%b\n' "${BLUE}$1${NC}" >&2
}

success() {
    printf '%b\n' "${GREEN}$1${NC}" >&2
}

warning() {
    printf '%b\n' "${YELLOW}$1${NC}" >&2
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Print installer build and latest release version, then exit.
# Used as a release smoke test instead of installing the script.
print_version_and_exit() {
    echo "wpstaging installer"
    echo "  build:          $SCRIPT_VERSION"

    _pv_latest=$(fetch_latest_stable_version 2>/dev/null)
    if [ -n "$_pv_latest" ] && [ "$_pv_latest" != "main" ]; then
        echo "  latest release: $_pv_latest"
    else
        echo "  latest release: unknown (could not fetch from GitHub)"
    fi

    exit 0
}

# Pick the appropriate RC file based on user's login shell
# Only edit one file to avoid noise and user distrust
pick_rc_file() {
    _prf_s=$(basename "${SHELL:-/bin/bash}")

    case "$_prf_s" in
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
    _gsc_rc=$(pick_rc_file)
    echo "source $_gsc_rc"
}

# Show Windows detected error and exit
# This helper function avoids duplicating the error message
error_windows_detected() {
    _ewd_context="${1:-}"
    _ewd_msg="Windows detected"
    [ -n "$_ewd_context" ] && _ewd_msg="Windows detected ($_ewd_context)"
    error "$_ewd_msg. Please use the Windows installer instead:\n\n    For PowerShell:\n        irm https://wp-staging.com/install.ps1 | iex\n\n    For CMD:\n        curl -fsSL https://wp-staging.com/install.cmd -o install.cmd && install.cmd\n\nOr download manually from:\n    https://github.com/wp-staging/wp-staging-cli-release"
}

# Detect OS
detect_os() {
    # Early detection for Windows environments
    # Check for Windows-specific environment variables (always set on Windows regardless of shell)
    # Note: Bash is case-sensitive, so check both common casings
    if [ -n "$WINDIR" ] || [ -n "$windir" ] || [ -n "$SYSTEMROOT" ] || [ -n "$SystemRoot" ]; then
        error_windows_detected
    fi

    # Check for Windows paths that indicate we're on Windows (Git Bash uses /c/Windows)
    # Note: /mnt/c/Windows exists in WSL but WSL is a legitimate Linux environment
    if [ -d "/c/Windows" ]; then
        error_windows_detected "Git Bash"
    fi

    # Check OS environment variable (Windows sets this to "Windows_NT")
    if [ "$OS" = "Windows_NT" ]; then
        error_windows_detected
    fi

    # Note: We don't check for stdin tty here because piped installation (curl | sh)
    # also results in stdin not being a tty, which is the normal installation method.
    # WSL users running from Windows CMD/PowerShell will see prompts fail at runtime,
    # but that's preferable to blocking the standard curl | sh installation.

    _do_os=$(uname -s | tr '[:upper:]' '[:lower:]')

    case "$_do_os" in
        linux*)
            # WSL is a legitimate Linux environment, so we treat it the same as native Linux.
            echo "linux"
            ;;
        darwin*)
            echo "darwin"
            ;;
        mingw* | msys* | cygwin* | msys_nt* | mingw64_nt* | mingw32_nt*)
            error_windows_detected "MinGW/MSYS/Cygwin"
            ;;
        *)
            error "Unsupported operating system: $_do_os"
            ;;
    esac
}

# Detect architecture
detect_arch() {
    _da_arch=$(uname -m)

    case "$_da_arch" in
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
            error "Unsupported architecture: $_da_arch"
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
    _dl_url="$1"
    _dl_output="$2"

    if command_exists curl; then
        curl -fsSL "$_dl_url" -o "$_dl_output" || error "Failed to download: $_dl_url"
    elif command_exists wget; then
        wget -q "$_dl_url" -O "$_dl_output" || error "Failed to download: $_dl_url"
    else
        error "Neither curl nor wget is available. Please install one of them."
    fi
}

# Parse JSON value (works without jq)
parse_json() {
    _pj_json="$1"
    _pj_key="$2"
    echo "$_pj_json" | grep -o "\"$_pj_key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | sed 's/.*"\([^"]*\)".*/\1/'
}

# Get platform string
get_platform() {
    _gp_os="$1"
    _gp_arch="$2"

    # Map to platform strings used in binary names
    case "$_gp_os" in
        darwin)
            # Use universal binary for macOS (works on both Intel and ARM)
            echo "macos_universal"
            ;;
        linux)
            echo "linux_${_gp_arch}"
            ;;
        *)
            error "Unknown OS: $_gp_os"
            ;;
    esac
}

# Verify checksum
verify_checksum() {
    _vc_file="$1"
    _vc_expected="$2"

    # Validate checksum format (SHA256 is 64 hex characters)
    if ! echo "$_vc_expected" | grep -qE '^[a-f0-9]{64}$'; then
        error "Invalid checksum format: $_vc_expected"
    fi

    if command_exists sha256sum; then
        _vc_actual=$(sha256sum "$_vc_file" | awk '{print $1}')
    elif command_exists shasum; then
        _vc_actual=$(shasum -a 256 "$_vc_file" | awk '{print $1}')
    else
        warning "Neither sha256sum nor shasum found. Skipping checksum verification."
        return 0
    fi

    if [ "$_vc_actual" != "$_vc_expected" ]; then
        error "Checksum verification failed!\n  Expected: $_vc_expected\n  Got:      $_vc_actual"
    fi

    success "✓ Checksum verified"
}

# Check if directory is writable
is_writable() {
    _iw_dir="$1"
    [ -d "$_iw_dir" ] && [ -w "$_iw_dir" ]
}

# Ensure directory exists and is writable
ensure_dir() {
    _ed_dir="$1"
    _ed_use_sudo="$2"

    if [ ! -d "$_ed_dir" ]; then
        if [ "$_ed_use_sudo" = "true" ] && command_exists sudo; then
            sudo mkdir -p "$_ed_dir" || return 1
        else
            mkdir -p "$_ed_dir" || return 1
        fi
    fi

    if [ "$_ed_use_sudo" = "true" ]; then
        [ -d "$_ed_dir" ]
    else
        is_writable "$_ed_dir"
    fi
}

# Install binary
install_binary() {
    _ib_binary="$1"
    _ib_install_dir="$2"
    _ib_use_sudo="$3"

    ensure_dir "$_ib_install_dir" "$_ib_use_sudo" || error "Cannot create directory: $_ib_install_dir"

    _ib_target="${_ib_install_dir}/${BINARY_NAME}"

    if [ "$_ib_use_sudo" = "true" ] && command_exists sudo; then
        sudo cp "$_ib_binary" "$_ib_target" || error "Failed to install binary to $_ib_target"
        sudo chmod +x "$_ib_target" || error "Failed to set executable permission"
    else
        cp "$_ib_binary" "$_ib_target" || error "Failed to install binary to $_ib_target"
        chmod +x "$_ib_target" || error "Failed to set executable permission"
    fi

    success "✓ Installed binary to $_ib_target"
}

# Install aliases (symlinks)
install_aliases() {
    _ia_install_dir="$1"
    _ia_use_sudo="$2"

    _ia_binary_path="${_ia_install_dir}/${BINARY_NAME}"
    _ia_wpstg_alias="${_ia_install_dir}/wpstg"
    _ia_wp_staging_alias="${_ia_install_dir}/wp-staging"

    if [ "$_ia_use_sudo" = "true" ] && command_exists sudo; then
        sudo ln -sf "$BINARY_NAME" "$_ia_wpstg_alias" || warning "Failed to create wpstg alias"
        sudo ln -sf "$BINARY_NAME" "$_ia_wp_staging_alias" || warning "Failed to create wp-staging alias"
    else
        ln -sf "$BINARY_NAME" "$_ia_wpstg_alias" || warning "Failed to create wpstg alias"
        ln -sf "$BINARY_NAME" "$_ia_wp_staging_alias" || warning "Failed to create wp-staging alias"
    fi

    success "✓ Created aliases: wpstg, wp-staging"
}

# Install bash completion
install_completion() {
    _ic_completion_script="$1"
    _ic_use_sudo="$2"

    # Skip if bash is not available
    if ! command_exists bash; then
        info "Bash not found, skipping completion installation"
        return 0
    fi

    # Try user directory first
    if [ "$_ic_use_sudo" = "false" ]; then
        _ic_completion_dir="$COMPLETION_DIR_USER"
        ensure_dir "$_ic_completion_dir" "false" 2>/dev/null || true

        if [ -d "$_ic_completion_dir" ] && [ -w "$_ic_completion_dir" ]; then
            _ic_completion_target="${_ic_completion_dir}/${COMPLETION_NAME}"
            cp "$_ic_completion_script" "$_ic_completion_target" || warning "Failed to install bash completion"
            success "✓ Installed bash completion to $_ic_completion_target"
            return 0
        fi

        # Fallback to .bash_completion in home
        if [ -f "$HOME/.bashrc" ] || [ -f "$HOME/.bash_profile" ]; then
            # Check if completion already exists to avoid duplicates
            if [ -f "$HOME/.bash_completion" ] && grep -Fq "# wpstaging completion" "$HOME/.bash_completion" 2>/dev/null; then
                success "✓ Bash completion already installed in ~/.bash_completion"
                return 0
            fi

            cat "$_ic_completion_script" >>"$HOME/.bash_completion"
            success "✓ Installed bash completion to ~/.bash_completion"
            info "  Add 'source ~/.bash_completion' to your ~/.bashrc if not already present"
            return 0
        fi
    else
        # System-wide installation
        _ic_completion_dir="$COMPLETION_DIR_SYSTEM"
        ensure_dir "$_ic_completion_dir" "true" || return 1

        _ic_completion_target="${_ic_completion_dir}/${COMPLETION_NAME}"
        if command_exists sudo; then
            sudo cp "$_ic_completion_script" "$_ic_completion_target" || warning "Failed to install bash completion"
            success "✓ Installed bash completion to $_ic_completion_target"
        fi
    fi
}

# Install zsh completion
install_zsh_completion() {
    _iz_completion_script="$1"
    _iz_use_sudo="$2"

    # Skip if zsh is not available
    if ! command_exists zsh; then
        return 0
    fi

    # Try user directory first
    if [ "$_iz_use_sudo" = "false" ]; then
        _iz_completion_dir="$ZSH_COMPLETION_DIR_USER"
        ensure_dir "$_iz_completion_dir" "false" 2>/dev/null || true

        if [ -d "$_iz_completion_dir" ] && [ -w "$_iz_completion_dir" ]; then
            _iz_completion_target="${_iz_completion_dir}/_${COMPLETION_NAME}"
            cp "$_iz_completion_script" "$_iz_completion_target" || warning "Failed to install zsh completion"
            success "✓ Installed zsh completion to $_iz_completion_target"
            info "  Add 'fpath=(${_iz_completion_dir} \$fpath)' to ~/.zshrc and run 'autoload -Uz compinit && compinit'"
            return 0
        fi
    else
        # System-wide installation
        _iz_completion_dir="$ZSH_COMPLETION_DIR_SYSTEM"
        ensure_dir "$_iz_completion_dir" "true" || return 1

        _iz_completion_target="${_iz_completion_dir}/_${COMPLETION_NAME}"
        if command_exists sudo; then
            sudo cp "$_iz_completion_script" "$_iz_completion_target" || warning "Failed to install zsh completion"
            success "✓ Installed zsh completion to $_iz_completion_target"
        fi
    fi
}

# Check if directory is in PATH
in_path() {
    _ip_dir="$1"
    echo "$PATH" | tr ':' '\n' | grep -q "^${_ip_dir}\$"
}

# Prompt user for sudo permission
# Returns 0 if user accepts, 1 if user declines
# NOTE: All output goes to stderr to avoid polluting stdout (used for return values)
prompt_sudo() {
    _ps_system_dir="$1"

    echo "" >&2
    info "sudo permission requested"
    echo "" >&2
    info "Why: Installing to $_ps_system_dir allows wpstaging to work immediately"
    info "     without modifying your shell configuration or restarting your terminal."
    echo "" >&2
    info "What happens: sudo will copy the wpstaging binary to $_ps_system_dir"
    info "              This is a standard location for user-installed programs."
    echo "" >&2

    # Read from /dev/tty to work in piped scripts (curl | sh)
    # Prompt also goes to stderr to keep stdout clean
    printf "%b" "${BLUE}Allow sudo installation to $_ps_system_dir? [Y/n] ${NC}" >&2
    read -r response </dev/tty 2>/dev/null || response="y"

    case "$response" in
        [nN] | [nN][oO])
            return 1
            ;;
        *)
            return 0
            ;;
    esac
}

# Find existing wpstaging installation in PATH
# Returns the directory containing the existing binary, or empty if not found
find_existing_installation() {
    _fei_existing=$(command -v "$BINARY_NAME" 2>/dev/null) || true
    if [ -n "$_fei_existing" ] && [ -x "$_fei_existing" ]; then
        # Return the directory containing the existing binary
        dirname "$_fei_existing" 2>/dev/null || true
    fi
}

# Pick best installation directory
# Prefers existing installation, then directories already on PATH to avoid needing shell reload
# Returns: "directory|use_sudo" (e.g., "/usr/local/bin|true")
pick_install_dir() {
    # First, check if wpstaging is already installed somewhere
    _pid_existing_dir=$(find_existing_installation)

    if [ -n "$_pid_existing_dir" ]; then
        # Found existing installation - update it
        if [ -w "$_pid_existing_dir" ]; then
            info "Found existing installation at $_pid_existing_dir (will update)"
            echo "$_pid_existing_dir|false"
            return 0
        elif command_exists sudo; then
            info "Found existing installation at $_pid_existing_dir (requires sudo to update)"
            if prompt_sudo "$_pid_existing_dir"; then
                echo "$_pid_existing_dir|true"
                return 0
            fi
            # User declined sudo - warn about potential conflict
            warning "Cannot update existing installation at $_pid_existing_dir without sudo"
            warning "Installing to user directory instead - you may have multiple versions"
        fi
    fi

    # Trusted candidates only, do not install into arbitrary PATH entries
    # 1) If candidate is in PATH and writable, use it (no sudo, no reload needed)
    for d in "/usr/local/bin" "/opt/homebrew/bin" "${HOME}/.local/bin" "${HOME}/bin"; do
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
    _atp_dir="$1"
    _atp_rc=$(pick_rc_file)

    # Fish shell uses different syntax
    case "$_atp_rc" in
        *"fish/config.fish")
            # Ensure fish config directory exists
            mkdir -p "$(dirname "$_atp_rc")"
            [ -f "$_atp_rc" ] || touch "$_atp_rc"

            # Check if already configured (idempotent)
            if grep -q "WP Staging CLI installer" "$_atp_rc" 2>/dev/null; then
                info "PATH already configured in $_atp_rc"
                return 0
            fi

            # Add Fish-style path export
            {
                echo ""
                echo "# Added by WP Staging CLI installer"
                echo "set -gx PATH \$PATH \"$_atp_dir\""
            } >>"$_atp_rc"

            success "✓ Added $_atp_dir to PATH in $_atp_rc"
            info "  Run '$(get_source_command)' or restart your shell to apply changes"
            return 0
            ;;
    esac

    # Create file if it doesn't exist (for bash/zsh/POSIX shells)
    [ -f "$_atp_rc" ] || touch "$_atp_rc"

    # Check if already configured (idempotent)
    if grep -q "WP Staging CLI installer" "$_atp_rc" 2>/dev/null; then
        info "PATH already configured in $_atp_rc"
        return 0
    fi

    # Add guarded PATH export (only adds if not already in PATH)
    {
        echo ""
        echo "# Added by WP Staging CLI installer"
        echo "case \":\$PATH:\" in"
        echo "  *\":$_atp_dir:\"*) ;;"
        echo "  *) export PATH=\"\$PATH:$_atp_dir\" ;;"
        echo "esac"
    } >>"$_atp_rc"

    success "✓ Added $_atp_dir to PATH in $_atp_rc"
    info "  Run '$(get_source_command)' or restart your shell to apply changes"
}

# Fetch latest stable version from GitHub (excludes beta/alpha/rc)
fetch_latest_stable_version() {
    info "Fetching latest stable version..."

    _flsv_version=""

    # Try to fetch tags from GitHub API
    if command_exists curl; then
        _flsv_tags_json=$(curl -fsSL "${GITHUB_API_URL}/tags" 2>/dev/null) || {
            warning "Failed to fetch tags from GitHub API, falling back to 'main'"
            echo "main"
            return 0
        }
    elif command_exists wget; then
        _flsv_tags_json=$(wget -qO- "${GITHUB_API_URL}/tags" 2>/dev/null) || {
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
    # Filter out pre-release versions using case-insensitive matching
    _flsv_version=$(echo "$_flsv_tags_json" | grep '"name"' | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | grep -v -i -E 'beta|alpha|rc' | head -1)

    if [ -z "$_flsv_version" ]; then
        warning "No stable version found, falling back to 'main'"
        echo "main"
        return 0
    fi

    echo "$_flsv_version"
}

# Validate that a version exists in the release repository
validate_version() {
    _vv_version="$1"

    # Skip validation for 'main'
    if [ "$_vv_version" = "main" ]; then
        return 0
    fi

    info "Validating version $_vv_version..."

    _vv_manifest_url="${GITHUB_RAW_URL}/${_vv_version}/manifest.json"

    # Check if manifest exists for this version
    if command_exists curl; then
        _vv_status_code=$(curl -o /dev/null -s -w "%{http_code}" "$_vv_manifest_url")
        if [ "$_vv_status_code" != "200" ]; then
            error "Version '$_vv_version' not found in release repository.\n\n  Please check available versions at:\n  https://github.com/wp-staging/wp-staging-cli-release/tags\n\n  Or install the latest stable version by omitting the version argument."
        fi
    elif command_exists wget; then
        if ! wget -q --spider "$_vv_manifest_url" 2>/dev/null; then
            error "Version '$_vv_version' not found in release repository.\n\n  Please check available versions at:\n  https://github.com/wp-staging/wp-staging-cli-release/tags\n\n  Or install the latest stable version by omitting the version argument."
        fi
    fi

    success "✓ Version $_vv_version exists"
}

# Main installation
main() {
    # Early --print-version short-circuit: print and exit before the banner so
    # the smoke-test output stays clean for piping through grep / jq / etc.
    for _arg in "$@"; do
        case "$_arg" in
            --print-version | -V)
                print_version_and_exit
                ;;
        esac
    done

    info "WP Staging CLI Installer"
    info "========================\n"

    # Parse arguments (version, license, bin-dir, extract)
    REQUESTED_VERSION=""
    LICENSE_KEY=""
    CUSTOM_BIN_DIR=""
    EXTRACT_DIR=""
    CLI_ARGS=""

    while [ $# -gt 0 ]; do
        case "$1" in
            --print-version | -V)
                print_version_and_exit
                ;;
            --license=*)
                LICENSE_KEY="${1#*=}"
                shift
                ;;
            --license | -l)
                LICENSE_KEY="$2"
                shift 2
                ;;
            --version=*)
                REQUESTED_VERSION="${1#*=}"
                shift
                ;;
            --version | -v)
                REQUESTED_VERSION="$2"
                shift 2
                ;;
            --bin-dir=*)
                CUSTOM_BIN_DIR="${1#*=}"
                shift
                ;;
            --bin-dir | -d)
                CUSTOM_BIN_DIR="$2"
                shift 2
                ;;
            --extract=*)
                EXTRACT_DIR="${1#*=}"
                shift
                ;;
            --extract | -e)
                EXTRACT_DIR="$2"
                shift 2
                ;;
            --cli-args=*)
                CLI_ARGS="${1#*=}"
                shift
                ;;
            --cli-args | -a)
                CLI_ARGS="$2"
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

    # Validate mutually exclusive flags
    if [ -n "$CUSTOM_BIN_DIR" ] && [ -n "$EXTRACT_DIR" ]; then
        error "--bin-dir and --extract are mutually exclusive. Use one or the other."
    fi

    VERSION_REF=""

    if [ -n "$REQUESTED_VERSION" ]; then
        # User specified a version
        info "Requested version: $REQUESTED_VERSION"
        case "$REQUESTED_VERSION" in
            v*) VERSION_REF="$REQUESTED_VERSION" ;;
            *) VERSION_REF="v${REQUESTED_VERSION}" ;;
        esac

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

    # Download shell completion scripts
    info "\nDownloading shell completion scripts..."
    COMPLETION_URL="${REPO_URL}/wp_staging_cli_bash_completion"
    download "$COMPLETION_URL" "$TMP_DIR/wp_staging_cli_bash_completion" || warning "Failed to download bash completion (continuing anyway)"
    ZSH_COMPLETION_URL="${REPO_URL}/wp_staging_cli_zsh_completion"
    download "$ZSH_COMPLETION_URL" "$TMP_DIR/wp_staging_cli_zsh_completion" || warning "Failed to download zsh completion (continuing anyway)"

    # ── Extract mode ──────────────────────────────────────────────────────
    # Copy all downloaded files to the given directory and exit early.
    # No PATH update, no symlinks/aliases, no shell rc changes, no license.
    if [ -n "$EXTRACT_DIR" ]; then
        info "\nExtracting files to $EXTRACT_DIR..."

        mkdir -p "$EXTRACT_DIR" || error "Cannot create directory: $EXTRACT_DIR"

        cp "$TMP_DIR/${BINARY_NAME}" "$EXTRACT_DIR/" || error "Failed to copy binary"
        chmod +x "$EXTRACT_DIR/${BINARY_NAME}"

        if [ -f "$TMP_DIR/wp_staging_cli_bash_completion" ]; then
            cp "$TMP_DIR/wp_staging_cli_bash_completion" "$EXTRACT_DIR/" || warning "Failed to copy bash completion"
        fi
        if [ -f "$TMP_DIR/wp_staging_cli_zsh_completion" ]; then
            cp "$TMP_DIR/wp_staging_cli_zsh_completion" "$EXTRACT_DIR/" || warning "Failed to copy zsh completion"
        fi

        echo ""
        success "✓ Files extracted to $EXTRACT_DIR:"
        ls -1 "$EXTRACT_DIR" | while read -r f; do
            info "  $f"
        done
        echo ""
        info "To install manually, copy the binary to a directory in your PATH."
        return 0
    fi

    # ── Determine installation directory ──────────────────────────────────
    # Prefer directories already on PATH to avoid needing shell reload
    info "\nInstalling wpstaging..."

    USE_SUDO="false"
    SUDO_DECLINED=""

    if [ -n "$CUSTOM_BIN_DIR" ]; then
        # Custom bin-dir mode: use the user-specified directory
        INSTALL_DIR="$CUSTOM_BIN_DIR"

        if [ -d "$INSTALL_DIR" ] && [ -w "$INSTALL_DIR" ]; then
            USE_SUDO=false
        elif [ ! -d "$INSTALL_DIR" ]; then
            # Directory doesn't exist yet — try to create it
            if mkdir -p "$INSTALL_DIR" 2>/dev/null; then
                USE_SUDO=false
            elif command_exists sudo; then
                USE_SUDO=true
            else
                error "Cannot create directory: $INSTALL_DIR (permission denied and sudo not available)"
            fi
        elif command_exists sudo; then
            USE_SUDO=true
        else
            error "Directory $INSTALL_DIR is not writable and sudo is not available"
        fi
    else
        _pick_result=$(pick_install_dir)
        _old_ifs="$IFS"
        IFS='|'
        # shellcheck disable=SC2086 -- intentional word splitting on pipe delimiter
        set -- $_pick_result
        IFS="$_old_ifs"
        INSTALL_DIR="$1"
        USE_SUDO="$2"
        SUDO_DECLINED="$3"

        # Show message if user declined sudo
        if [ "$SUDO_DECLINED" = "declined" ]; then
            info "Installing to user directory instead (no sudo required)"
        fi
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

    # Install shell completions
    if [ -f "$TMP_DIR/wp_staging_cli_bash_completion" ]; then
        info "\nInstalling bash completion..."
        install_completion "$TMP_DIR/wp_staging_cli_bash_completion" "$USE_SUDO"
    fi
    if [ -f "$TMP_DIR/wp_staging_cli_zsh_completion" ]; then
        info "\nInstalling zsh completion..."
        install_zsh_completion "$TMP_DIR/wp_staging_cli_zsh_completion" "$USE_SUDO"
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
    license_registered=false
    if [ -n "$LICENSE_KEY" ]; then
        info "\nRegistering license key..."
        register_binary="${INSTALL_DIR}/${BINARY_NAME}"

        # Check if binary exists and is executable
        if [ ! -x "$register_binary" ]; then
            warning "Binary not found or not executable. Cannot register license."
            warning "You can register later with: wpstaging register"
        else
            # Pass license via environment variable to avoid exposure in process list
            # Disable globbing around $CLI_ARGS to prevent wildcard expansion
            set -f
            if register_output=$(WPSTGPRO_LICENSE="$LICENSE_KEY" "$register_binary" register $CLI_ARGS 2>&1); then
                set +f
                success "✓ License registered successfully"
                license_registered=true
            else
                set +f
                warning "License registration failed: $register_output"
                warning "You can register later with: wpstaging register"
            fi
        fi
    fi

    # Verify installation
    info "\nVerifying installation..."
    if [ -x "${INSTALL_DIR}/${BINARY_NAME}" ]; then
        set -f
        VERSION_OUTPUT=$("${INSTALL_DIR}/${BINARY_NAME}" --version $CLI_ARGS 2>&1 || echo "")
        set +f
        success "✓ Installation successful!"
        success "Installed: $VERSION_OUTPUT"

        # Check for other installations that might shadow this one
        other_installs=""
        IFS_BACKUP="$IFS"
        IFS=':'
        for dir in $PATH; do
            if [ "$dir" != "$INSTALL_DIR" ] && [ -x "$dir/$BINARY_NAME" ]; then
                other_installs="$other_installs  - $dir/$BINARY_NAME\n"
            fi
        done
        IFS="$IFS_BACKUP"

        if [ -n "$other_installs" ]; then
            echo ""
            warning "⚠ Other wpstaging installations found:"
            printf "%b" "$other_installs"
            warning "These may take precedence over the newly installed version."
            info "Consider removing old installations or adjusting your PATH order."
        fi
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
        if [ -n "$LICENSE_KEY" ] && [ "$license_registered" = false ]; then
            # License registration failed, include it so user can try again
            info "  wpstaging add mysite.local --license $LICENSE_KEY"
            echo ""
            info "Note: The license key is only needed once to activate WP Staging CLI."
            info "      After activation, you can use wpstaging without the --license flag."
        else
            # No license provided, or license was already registered
            info "  wpstaging add mysite.local"
        fi
    else
        # Need to reload shell or use full path
        info "Run wpstaging immediately (copy & paste):"
        if [ -n "$LICENSE_KEY" ] && [ "$license_registered" = false ]; then
            # License registration failed, include it so user can try again
            info "  ${INSTALL_DIR}/${BINARY_NAME} add mysite.local --license $LICENSE_KEY"
            echo ""
            info "Note: The license key is only needed once to activate WP Staging CLI."
            info "      After activation, you can use wpstaging without the --license flag."
        else
            # No license provided, or license was already registered
            info "  ${INSTALL_DIR}/${BINARY_NAME} add mysite.local"
        fi
        echo ""
        info "Or reload your shell first:"
        info "  $(get_source_command)"
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
