#!/bin/sh
# WP Staging CLI Uninstaller
# This script uninstalls wpstaging from Linux, macOS, and WSL
#
# Usage:
#   Uninstall wpstaging:
#     curl -fsSL https://wp-staging.com/uninstall.sh | sh
#
#   Or run locally:
#     sh uninstall.sh
#
#   Print uninstaller build, then exit:
#     sh uninstall.sh --print-version
#
# Options:
#   -V, --print-version      Print uninstaller build, then exit

set -e

# Configuration
COMPLETION_DIR_USER="${HOME}/.local/share/bash-completion/completions"
COMPLETION_DIR_SYSTEM="/etc/bash_completion.d"
ZSH_COMPLETION_DIR_USER="${HOME}/.local/share/zsh/completions"
ZSH_COMPLETION_DIR_SYSTEM="/usr/local/share/zsh/completions"
BINARY_NAME="wpstaging"
COMPLETION_NAME="wpstaging"
SCRIPT_VERSION="20260430-154943"

# Colors for output
RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;36m'
NC='\033[0m' # No Color

# Helper functions
error() {
    printf '%b\n' "${RED}Error: $1${NC}" >&2
    exit 1
}

info() {
    printf '%b\n' "${BLUE}$1${NC}"
}

success() {
    printf '%b\n' "${GREEN}$1${NC}"
}

warning() {
    printf '%b\n' "${YELLOW}$1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Print uninstaller build, then exit. Used as a smoke check that the
# downloaded uninstaller matches the just-released version.
print_version_and_exit() {
    echo "wpstaging uninstaller"
    echo "  build: $SCRIPT_VERSION"
    exit 0
}

# Verify that a binary is actually WP Staging CLI
# Returns 0 if verified, 1 if not
verify_binary() {
    _vb_binary_path="$1"

    # Use timeout to guard against a foreign binary that blocks on --version.
    # Prefer timeout (Linux coreutils), fall back to gtimeout (macOS Homebrew),
    # then direct execution as last resort.
    if command_exists timeout; then
        _vb_output=$(timeout 5 "$_vb_binary_path" --version 2>/dev/null) || return 1
    elif command_exists gtimeout; then
        _vb_output=$(gtimeout 5 "$_vb_binary_path" --version 2>/dev/null) || return 1
    else
        _vb_output=$("$_vb_binary_path" --version 2>/dev/null) || return 1
    fi

    echo "$_vb_output" | grep -Eqi "wpstaging|wp[-. ]staging"
}

# Remove binary and aliases from a directory
remove_binaries() {
    _rb_dir="$1"
    _rb_use_sudo="$2"
    _rb_removed=false

    # Always remove the main binary -- main() verified it before calling.
    _rb_main_path="$_rb_dir/$BINARY_NAME"
    if [ -f "$_rb_main_path" ] || [ -L "$_rb_main_path" ]; then
        if [ "$_rb_use_sudo" = "true" ] && command_exists sudo; then
            sudo rm -f "$_rb_main_path" && _rb_removed=true
        else
            rm -f "$_rb_main_path" && _rb_removed=true
        fi
    fi

    # Aliases: only remove if symlinked to the verified binary, or if they
    # themselves verify as WP Staging CLI. Avoids deleting unrelated user
    # binaries that happen to share these names (#296).
    for _rb_alias in "wpstg" "wp-staging"; do
        _rb_path="$_rb_dir/$_rb_alias"
        if [ ! -L "$_rb_path" ] && [ ! -f "$_rb_path" ]; then
            continue
        fi

        _rb_safe=false

        if [ -L "$_rb_path" ]; then
            # readlink is non-POSIX but ubiquitous on Linux/macOS. install.sh
            # creates these as relative links, target = "wpstaging". If
            # readlink is missing or fails, verify_binary below is the
            # fallback.
            _rb_target=$(readlink "$_rb_path" 2>/dev/null || echo "")
            case "$_rb_target" in
                "$BINARY_NAME" | "$_rb_dir/$BINARY_NAME")
                    _rb_safe=true
                    ;;
            esac
        fi

        if [ "$_rb_safe" = false ] && [ -x "$_rb_path" ] && verify_binary "$_rb_path"; then
            _rb_safe=true
        fi

        if [ "$_rb_safe" = false ]; then
            warning "Skipping $_rb_path: not recognised as a WP Staging CLI alias"
            continue
        fi

        if [ "$_rb_use_sudo" = "true" ] && command_exists sudo; then
            sudo rm -f "$_rb_path" && _rb_removed=true
        else
            rm -f "$_rb_path" && _rb_removed=true
        fi
    done

    if [ "$_rb_removed" = true ]; then
        success "✓ Removed binaries from $_rb_dir"
    fi
}

# Remove shell completions
remove_completion() {
    _rc_removed=false

    # Bash: User completion directory
    if [ -f "$COMPLETION_DIR_USER/$COMPLETION_NAME" ]; then
        rm -f "$COMPLETION_DIR_USER/$COMPLETION_NAME"
        success "✓ Removed bash completion from $COMPLETION_DIR_USER"
        _rc_removed=true
    fi

    # Bash: System completion directory
    if [ -f "$COMPLETION_DIR_SYSTEM/$COMPLETION_NAME" ]; then
        if command_exists sudo; then
            sudo rm -f "$COMPLETION_DIR_SYSTEM/$COMPLETION_NAME"
            success "✓ Removed bash completion from $COMPLETION_DIR_SYSTEM"
            _rc_removed=true
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
        _rc_removed=true
    fi

    # Zsh: User completion directory
    if [ -f "$ZSH_COMPLETION_DIR_USER/_$COMPLETION_NAME" ]; then
        rm -f "$ZSH_COMPLETION_DIR_USER/_$COMPLETION_NAME"
        success "✓ Removed zsh completion from $ZSH_COMPLETION_DIR_USER"
        _rc_removed=true
    fi

    # Zsh: System completion directory
    if [ -f "$ZSH_COMPLETION_DIR_SYSTEM/_$COMPLETION_NAME" ]; then
        if command_exists sudo; then
            sudo rm -f "$ZSH_COMPLETION_DIR_SYSTEM/_$COMPLETION_NAME"
            success "✓ Removed zsh completion from $ZSH_COMPLETION_DIR_SYSTEM"
            _rc_removed=true
        else
            warning "Cannot remove system zsh completion (no sudo)"
        fi
    fi

    if [ "$_rc_removed" = false ]; then
        info "No shell completion files found"
    fi
}

# Remove PATH entries from shell RC files
# Handles both old format (single export line) and new format (guarded case block)
remove_from_path() {
    _rfp_any_updated=false

    for rc_file in \
        "$HOME/.zshrc" \
        "$HOME/.bashrc" \
        "$HOME/.bash_profile" \
        "$HOME/.profile" \
        "$HOME/.kshrc" \
        "$HOME/.config/fish/config.fish"; do
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
                    ' "$rc_file" >"${rc_file}.tmp" && mv "${rc_file}.tmp" "$rc_file"
                    ;;
            esac
            rm -f "${rc_file}.tmp"

            # Clean up any leftover empty lines at the end of the file
            sed -i.tmp -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$rc_file" 2>/dev/null || true
            rm -f "${rc_file}.tmp"

            success "✓ Removed PATH entries from $rc_file"
            _rfp_any_updated=true
        fi
    done

    if [ "$_rfp_any_updated" = false ]; then
        info "No PATH entries found in shell RC files"
    fi
}

# Remove license key from shell RC files
remove_license_from_env() {
    _rl_any_updated=false

    for rc_file in \
        "$HOME/.zshrc" \
        "$HOME/.bashrc" \
        "$HOME/.bash_profile" \
        "$HOME/.profile" \
        "$HOME/.kshrc" \
        "$HOME/.config/fish/config.fish"; do
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
            _rl_any_updated=true
        fi
    done

    if [ "$_rl_any_updated" = false ]; then
        info "No license key entries found in shell RC files"
    fi
}

# Remove cache and working directories
remove_cache() {
    for cache_dir in \
        "$HOME/.cache/wpstaging" \
        "$HOME/.wpstaging" \
        "$HOME/.config/wpstaging" \
        "$HOME/Library/Application Support/wpstaging"; do
        if [ -d "$cache_dir" ]; then
            rm -rf "$cache_dir"
            success "✓ Removed directory: $cache_dir"
        fi
    done
}

# Check for existing dockerized sites and offer cleanup.
# Uses WPSTG_BINARY env var (set by caller) to avoid running a foreign binary.
check_and_cleanup_sites() {
    _ck_bin="${WPSTG_BINARY:-}"

    if [ -z "$_ck_bin" ] || [ ! -x "$_ck_bin" ]; then
        info "No verified wpstaging binary, skipping site check"
        return 0
    fi

    info "Checking for existing dockerized sites..."
    echo ""

    # Capture site list output
    _ck_site_output=$("$_ck_bin" list 2>/dev/null) || true

    # Check if there are any sites (look for "Host" followed by spaces and colon in output)
    if echo "$_ck_site_output" | grep -q "Host[[:space:]]*:"; then
        echo "$_ck_site_output"
        echo ""
        warning "The above sites will remain on disk unless you delete them."

        # WPSTG_UNINSTALL_ASSUME_YES (internal, undocumented): when "1", auto-answer "No"
        # here — conservative default that preserves user data. Used by CI only.
        if [ "${WPSTG_UNINSTALL_ASSUME_YES:-}" = "1" ]; then
            DELETE_SITES=""
            info "Sites will be preserved (WPSTG_UNINSTALL_ASSUME_YES set)"
        else
            printf "Do you want to delete all sites and their Docker data? [y/N] "

            # Read user input with proper fallback handling
            if [ -r /dev/tty ]; then
                # Prefer reading from /dev/tty when available (works in piped scripts)
                read -r DELETE_SITES </dev/tty 2>/dev/null || DELETE_SITES=""
            elif [ -t 0 ]; then
                # Fall back to stdin only if it is an interactive terminal
                read -r DELETE_SITES || DELETE_SITES=""
            else
                # Non-interactive environment without /dev/tty: default to "No"
                DELETE_SITES=""
            fi
        fi
        echo ""

        case "$DELETE_SITES" in
            [Yy])
                info "Stopping all containers first..."
                "$_ck_bin" stop 2>/dev/null || true

                info "Running wpstaging remove to remove all sites..."
                if "$_ck_bin" remove --yes 2>/dev/null; then
                    success "✓ Sites and Docker data removed"
                else
                    warning "Site cleanup may have encountered errors. Some files may remain."
                fi
                ;;
            *)
                info "Sites will be preserved on disk"
                ;;
        esac
    else
        info "No dockerized sites found"
    fi
    echo ""
}

# Main uninstallation
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

    info "WP Staging CLI Uninstaller"
    info "==========================\n"

    # Check if wpstaging is installed in any candidate directory.
    # Track verified directories so we only remove confirmed WP Staging CLI binaries.
    # Entries are newline-separated (not space-separated) so paths containing
    # spaces -- e.g. macOS HOME like /Users/Jane Doe/.local/bin -- stay intact
    # when the list is iterated.
    found=false
    verified_dirs=""
    verified_binary=""

    for dir in "/usr/local/bin" "/opt/homebrew/bin" "${HOME}/.local/bin" "${HOME}/bin"; do
        # Check for regular file OR symlink -- remove_binaries() handles both,
        # so candidate discovery must not narrow that.
        if [ -f "$dir/$BINARY_NAME" ] || [ -L "$dir/$BINARY_NAME" ]; then
            if verify_binary "$dir/$BINARY_NAME"; then
                found=true
                verified_dirs="${verified_dirs}${dir}
"
                verified_binary="$dir/$BINARY_NAME"
                info "Found installation in: $dir"
            else
                warning "Binary at $dir/$BINARY_NAME is not WP Staging CLI, skipping"
            fi
        fi
    done

    if [ "$found" = false ]; then
        if command_exists wpstaging; then
            wpstaging_path=$(command -v wpstaging)
            if verify_binary "$wpstaging_path"; then
                info "Found wpstaging at: $wpstaging_path"
                found=true
                verified_binary="$wpstaging_path"
                verified_dirs="${verified_dirs}$(dirname "$wpstaging_path")
"
            else
                warning "Binary at $wpstaging_path is not WP Staging CLI, skipping"
            fi
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

    # WPSTG_UNINSTALL_ASSUME_YES (internal, undocumented): when "1", skip this
    # confirmation. Used by CI to test the documented `curl | sh` form.
    if [ "${WPSTG_UNINSTALL_ASSUME_YES:-}" = "1" ]; then
        REPLY="y"
        info "Proceeding (WPSTG_UNINSTALL_ASSUME_YES set)"
    else
        # Read from /dev/tty to work in piped scripts (curl | sh)
        # Fall back to stdin if /dev/tty is not available (CI environments)
        printf "Are you sure you want to uninstall WP Staging CLI? [y/N] "
        { read -r REPLY </dev/tty; } 2>/dev/null || read -r REPLY || REPLY=""
    fi
    echo ""

    case "$REPLY" in
        [Yy]) ;;
        *)
            info "Uninstallation cancelled"
            exit 0
            ;;
    esac

    echo ""

    # Check for existing dockerized sites and offer cleanup
    # Use the verified binary path to avoid running commands on a foreign binary
    if [ -n "$verified_binary" ]; then
        WPSTG_BINARY="$verified_binary" check_and_cleanup_sites
    fi

    # Stop any running wpstaging containers (fallback for containers not in site list)
    info "Stopping any running wpstaging containers..."
    if [ -n "$verified_binary" ]; then
        "$verified_binary" stop 2>/dev/null || true
        success "✓ Stopped wpstaging containers (if any were running)"
    else
        info "No verified wpstaging binary, skipping container stop"
    fi

    echo ""

    # Deactivate license on server before removing binary
    if [ -n "$verified_binary" ]; then
        if "$verified_binary" deactivate --yes >/dev/null 2>&1; then
            success "✓ License deactivated"
        fi
    fi

    echo ""

    # Remove binaries only from verified directories.
    # Iterate with IFS=newline so paths containing spaces are preserved.
    info "Removing binaries..."
    OLD_IFS=$IFS
    IFS='
'
    for dir in $verified_dirs; do
        [ -z "$dir" ] && continue
        # Use sudo for system directories
        case "$dir" in
            /usr/local/bin | /opt/homebrew/bin)
                remove_binaries "$dir" "true"
                ;;
            *)
                remove_binaries "$dir" "false"
                ;;
        esac
    done
    IFS=$OLD_IFS

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
