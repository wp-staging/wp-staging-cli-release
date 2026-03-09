#!/usr/bin/env bash
# WP Staging CLI Uninstaller
# This script uninstalls wpstaging from Linux, macOS, and WSL
#
# Usage:
#   Uninstall wpstaging:
#     curl -fsSL https://wp-staging.com/uninstall.sh | bash
#
#   Or run locally:
#     bash uninstall.sh

set -e

# Configuration
# All candidate directories that the installer may use
INSTALL_CANDIDATES=(
    "/usr/local/bin"
    "/opt/homebrew/bin"
    "${HOME}/.local/bin"
    "${HOME}/bin"
)
COMPLETION_DIR_USER="${HOME}/.local/share/bash-completion/completions"
COMPLETION_DIR_SYSTEM="/etc/bash_completion.d"
ZSH_COMPLETION_DIR_USER="${HOME}/.local/share/zsh/completions"
ZSH_COMPLETION_DIR_SYSTEM="/usr/local/share/zsh/completions"
BINARY_NAME="wpstaging"
COMPLETION_NAME="wpstaging"

# Colors for output
RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;36m'
NC='\033[0m' # No Color

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

# Remove binary and aliases from a directory
remove_binaries() {
    local dir="$1"
    local use_sudo="$2"
    local removed=false

    local files=("$BINARY_NAME" "wpstg" "wp-staging")

    for file in "${files[@]}"; do
        local path="$dir/$file"
        if [ -f "$path" ] || [ -L "$path" ]; then
            if [ "$use_sudo" = "true" ] && command_exists sudo; then
                sudo rm -f "$path" && removed=true
            else
                rm -f "$path" && removed=true
            fi
        fi
    done

    if [ "$removed" = true ]; then
        success "✓ Removed binaries from $dir"
    fi
}

# Remove shell completions
remove_completion() {
    local removed=false

    # Bash: User completion directory
    if [ -f "$COMPLETION_DIR_USER/$COMPLETION_NAME" ]; then
        rm -f "$COMPLETION_DIR_USER/$COMPLETION_NAME"
        success "✓ Removed bash completion from $COMPLETION_DIR_USER"
        removed=true
    fi

    # Bash: System completion directory
    if [ -f "$COMPLETION_DIR_SYSTEM/$COMPLETION_NAME" ]; then
        if command_exists sudo; then
            sudo rm -f "$COMPLETION_DIR_SYSTEM/$COMPLETION_NAME"
            success "✓ Removed bash completion from $COMPLETION_DIR_SYSTEM"
            removed=true
        else
            warning "Cannot remove system bash completion (no sudo)"
        fi
    fi

    # Bash: ~/.bash_completion file
    if [ -f "$HOME/.bash_completion" ] && grep -q "wpstaging\|wp-staging-cli" "$HOME/.bash_completion" 2>/dev/null; then
        # Create backup and remove wpstaging completion
        cp "$HOME/.bash_completion" "$HOME/.bash_completion.bak"
        sed -i.tmp '/# wpstaging completion/,/^$/d' "$HOME/.bash_completion" 2>/dev/null || true
        sed -i.tmp '/wp-staging-cli/d' "$HOME/.bash_completion" 2>/dev/null || true
        rm -f "$HOME/.bash_completion.tmp"
        success "✓ Removed wpstaging entries from ~/.bash_completion"
        removed=true
    fi

    # Zsh: User completion directory
    if [ -f "$ZSH_COMPLETION_DIR_USER/_$COMPLETION_NAME" ]; then
        rm -f "$ZSH_COMPLETION_DIR_USER/_$COMPLETION_NAME"
        success "✓ Removed zsh completion from $ZSH_COMPLETION_DIR_USER"
        removed=true
    fi

    # Zsh: System completion directory
    if [ -f "$ZSH_COMPLETION_DIR_SYSTEM/_$COMPLETION_NAME" ]; then
        if command_exists sudo; then
            sudo rm -f "$ZSH_COMPLETION_DIR_SYSTEM/_$COMPLETION_NAME"
            success "✓ Removed zsh completion from $ZSH_COMPLETION_DIR_SYSTEM"
            removed=true
        else
            warning "Cannot remove system zsh completion (no sudo)"
        fi
    fi

    if [ "$removed" = false ]; then
        info "No shell completion files found"
    fi
}

# Remove PATH entries from shell RC files
# Handles both old format (single export line) and new format (guarded case block)
remove_from_path() {
    local rc_files=(
        "$HOME/.zshrc"
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.profile"
        "$HOME/.kshrc"
        "$HOME/.config/fish/config.fish"
    )

    local any_updated=false

    for rc_file in "${rc_files[@]}"; do
        if [ ! -f "$rc_file" ]; then
            continue
        fi

        # Check if file contains WP Staging CLI installer entries
        if grep -q "# Added by WP Staging CLI installer" "$rc_file" 2>/dev/null; then
            # Create backup
            cp "$rc_file" "${rc_file}.wpstg-uninstall.bak"

            # Remove the entire block added by WP Staging CLI installer
            # This handles both old format (export PATH=...) and new format (case block)
            case "$rc_file" in
                *"fish/config.fish")
                    # Fish shell: remove comment and the following set -gx PATH line
                    sed -i.tmp '/# Added by WP Staging CLI installer/{N;d;}' "$rc_file" 2>/dev/null || true
                    ;;
                *)
                    # Bash/Zsh/POSIX: remove the entire guarded block or old export line
                    # Use awk for reliable multi-line block removal
                    awk '
                    /# Added by WP Staging CLI installer/ {
                        skip = 1
                        # Check if next line starts a case block or is an export
                        getline nextline
                        if (nextline ~ /^case/) {
                            # New format: skip until esac
                            while ((getline nextline) > 0 && nextline !~ /^esac/) {}
                        }
                        # Skip the line (old format export or we already consumed the block)
                        next
                    }
                    !skip { print }
                    { skip = 0 }
                    ' "$rc_file" > "${rc_file}.tmp" && mv "${rc_file}.tmp" "$rc_file"
                    ;;
            esac
            rm -f "${rc_file}.tmp"

            # Clean up any leftover empty lines at the end of the file
            sed -i.tmp -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$rc_file" 2>/dev/null || true
            rm -f "${rc_file}.tmp"

            success "✓ Removed PATH entries from $rc_file"
            any_updated=true
        fi
    done

    if [ "$any_updated" = false ]; then
        info "No PATH entries found in shell RC files"
    fi
}

# Remove license key from shell RC files
remove_license_from_env() {
    local rc_files=(
        "$HOME/.zshrc"
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.profile"
        "$HOME/.kshrc"
        "$HOME/.config/fish/config.fish"
    )

    local any_updated=false

    for rc_file in "${rc_files[@]}"; do
        if [ ! -f "$rc_file" ]; then
            continue
        fi

        # Check if file contains WPSTGPRO_LICENSE
        if grep -q "WPSTGPRO_LICENSE" "$rc_file" 2>/dev/null; then
            # Create backup if not already created
            if [ ! -f "${rc_file}.wpstg-uninstall.bak" ]; then
                cp "$rc_file" "${rc_file}.wpstg-uninstall.bak"
            fi

            # Remove license entries (comment + export/set line)
            case "$rc_file" in
                *"fish/config.fish")
                    sed -i.tmp '/# WP Staging CLI license key/{N;d;}' "$rc_file" 2>/dev/null || true
                    # Fallback: remove just the set line if comment wasn't present
                    sed -i.tmp '/set -gx WPSTGPRO_LICENSE/d' "$rc_file" 2>/dev/null || true
                    ;;
                *)
                    sed -i.tmp '/# WP Staging CLI license key/{N;d;}' "$rc_file" 2>/dev/null || true
                    # Fallback: remove just the export line if comment wasn't present
                    sed -i.tmp '/export WPSTGPRO_LICENSE/d' "$rc_file" 2>/dev/null || true
                    ;;
            esac
            rm -f "${rc_file}.tmp"

            success "✓ Removed license key from $rc_file"
            any_updated=true
        fi
    done

    if [ "$any_updated" = false ]; then
        info "No license key entries found in shell RC files"
    fi
}

# Remove cache and working directories
remove_cache() {
    local cache_dirs=(
        "$HOME/.cache/wpstaging"
        "$HOME/.wpstaging"
        "$HOME/.config/wpstaging"                         # Linux default working directory
        "$HOME/Library/Application Support/wpstaging"     # macOS default working directory
    )

    for cache_dir in "${cache_dirs[@]}"; do
        if [ -d "$cache_dir" ]; then
            rm -rf "$cache_dir"
            success "✓ Removed directory: $cache_dir"
        fi
    done
}

# Check for existing dockerized sites and offer cleanup
check_and_cleanup_sites() {
    if ! command_exists wpstaging; then
        info "wpstaging binary not found, skipping site check"
        return 0
    fi

    info "Checking for existing dockerized sites..."
    echo ""

    # Capture site list output
    local site_output
    site_output=$(wpstaging list 2>/dev/null) || true

    # Check if there are any sites (look for "Host" followed by spaces and colon in output)
    if echo "$site_output" | grep -q "Host[[:space:]]*:"; then
        echo "$site_output"
        echo ""
        warning "The above sites will remain on disk unless you delete them."
        printf "Do you want to delete all sites and their Docker data? [y/N] "

        # Read user input with proper fallback handling
        if [ -r /dev/tty ]; then
            # Prefer reading from /dev/tty when available (works in piped scripts)
            read -r DELETE_SITES < /dev/tty 2>/dev/null || DELETE_SITES=""
        elif [ -t 0 ]; then
            # Fall back to stdin only if it is an interactive terminal
            read -r DELETE_SITES || DELETE_SITES=""
        else
            # Non-interactive environment without /dev/tty: default to "No"
            DELETE_SITES=""
        fi
        echo ""

        if [[ $DELETE_SITES =~ ^[Yy]$ ]]; then
            info "Stopping all containers first..."
            wpstaging stop 2>/dev/null || true

            info "Running wpstaging remove to remove all sites..."
            if wpstaging remove --yes 2>/dev/null; then
                success "✓ Sites and Docker data removed"
            else
                warning "Site cleanup may have encountered errors. Some files may remain."
            fi
        else
            info "Sites will be preserved on disk"
        fi
    else
        info "No dockerized sites found"
    fi
    echo ""
}

# Main uninstallation
main() {
    info "WP Staging CLI Uninstaller"
    info "==========================\n"

    # Check if wpstaging is installed in any candidate directory
    local found=false
    local found_dirs=()

    for dir in "${INSTALL_CANDIDATES[@]}"; do
        if [ -f "$dir/$BINARY_NAME" ]; then
            found=true
            found_dirs+=("$dir")
            info "Found installation in: $dir"
        fi
    done

    if [ "$found" = false ]; then
        if command_exists wpstaging; then
            local wpstaging_path
            wpstaging_path=$(command -v wpstaging)
            info "Found wpstaging at: $wpstaging_path"
            found=true
        fi
    fi

    if [ "$found" = false ]; then
        warning "WP Staging CLI does not appear to be installed"
        info "Checking for leftover configuration files..."
    fi

    echo ""

    # Confirm uninstallation
    info "This will remove:"
    info "  - wpstaging binary and aliases (wpstg, wp-staging)"
    info "  - Shell completion scripts (Bash, Zsh)"
    info "  - PATH entries from shell RC files"
    info "  - License key from environment"
    info "  - Cache and working directories"
    echo ""

    # Read from /dev/tty to work in piped scripts (curl | bash)
    # Fall back to stdin if /dev/tty is not available (CI environments)
    printf "Are you sure you want to uninstall WP Staging CLI? [y/N] "
    { read -r REPLY < /dev/tty; } 2>/dev/null || read -r REPLY || REPLY=""
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Uninstallation cancelled"
        exit 0
    fi

    echo ""

    # Check for existing dockerized sites and offer cleanup
    check_and_cleanup_sites

    # Stop any running wpstaging containers (fallback for containers not in site list)
    info "Stopping any running wpstaging containers..."
    if command_exists wpstaging; then
        wpstaging stop 2>/dev/null || true
        success "✓ Stopped wpstaging containers (if any were running)"
    else
        info "wpstaging binary not found, skipping container stop"
    fi

    echo ""

    # Deactivate license on server before removing binary
    if command_exists wpstaging; then
        if wpstaging deactivate --yes >/dev/null 2>&1; then
            success "✓ License deactivated"
        fi
    fi

    echo ""

    # Remove binaries from all candidate directories
    info "Removing binaries..."
    for dir in "${INSTALL_CANDIDATES[@]}"; do
        # Use sudo for system directories
        if [[ "$dir" == "/usr/local/bin" ]] || [[ "$dir" == "/opt/homebrew/bin" ]]; then
            remove_binaries "$dir" "true"
        else
            remove_binaries "$dir" "false"
        fi
    done

    echo ""

    # Remove shell completions
    info "Removing shell completions..."
    remove_completion

    echo ""

    # Remove PATH entries
    info "Removing PATH entries from shell RC files..."
    remove_from_path

    echo ""

    # Remove license key
    info "Removing license key from environment..."
    remove_license_from_env

    echo ""

    # Remove cache
    info "Removing cache and working directories..."
    remove_cache

    echo ""

    # Summary
    success "======================================"
    success "   Uninstallation Complete!"
    success "======================================"
    echo ""

    info "WP Staging CLI has been removed from your system."
    echo ""

    warning "Note: You may need to restart your shell or run 'source ~/.bashrc'"
    warning "(or your shell's equivalent) for changes to take effect."
    echo ""

    info "Backup files were created with .wpstg-uninstall.bak extension."
    info "You can remove them manually if everything works correctly."
    echo ""
}

# Run main function
main "$@"
