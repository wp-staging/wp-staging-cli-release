# WP Staging CLI

**Run your production WordPress site locally — with one command.**

Turn any WP Staging backup into a fully working local copy of your live site: same content, same plugins, same database. **WP Staging CLI** sets up everything automatically on **Windows, macOS, or Linux** — no Docker expertise needed. Just copy, paste, run.

Site down? No problem. Extract and restore `.wpstg` backups **without a running WordPress installation** — ideal for disaster recovery or rescuing broken sites.

Built for developers and agencies who value their time.

> **License Required:**
> A valid [WP Staging Agency or Developer license](https://wp-staging.com) is required.

---

## Highlights

- **Dockerized Development Environments** — Spin up isolated WordPress environments with Docker Compose, including PHP-FPM, Nginx, MariaDB, and Mailpit.
- **Offline Backup Restoration** — Restore WordPress sites and databases even when the original installation is broken or inaccessible.
- **Stream-Based Extraction** — Memory-efficient extraction of large `.wpstg` backup files using chunked processing.
- **Database Normalization** — Automatically process WP Staging placeholders (`{WPSTG_TMP_PREFIX}`, `{WPSTG_FINAL_PREFIX}`, etc.) for standard SQL import.
- **Backup Introspection** — Inspect backup headers, metadata, and file indexes without full extraction.
- **Cross-Platform Support** — Native binaries for Linux, Windows, and macOS with platform-specific optimizations.
---

## Benchmarks

**Speed:** Extracted a 20 GB backup file in just 36 seconds on a modern computer with SSD storage.

---

## Installation

### Quick Install (Recommended)

**Linux / macOS / WSL:**
```bash
curl -fsSL https://wp-staging.com/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://wp-staging.com/install.ps1 | iex
```

**Windows (CMD):**
```cmd
curl -fsSL https://wp-staging.com/install.cmd -o install.cmd && install.cmd && del install.cmd
```

The installer will:
- Download the latest version for your platform
- Verify checksums for security
- Install to `~/.local/bin` (Linux/macOS) or `%LOCALAPPDATA%\Programs\wpstaging` (Windows)
- Add to your PATH automatically
- Install shell completion (Bash and Zsh on Linux/macOS)

### Install a Specific Version (including Beta/RC)

By default, the installer downloads the latest stable release. To install a specific version (including beta, alpha, or release candidate versions):

**Linux / macOS / WSL:**
```bash
curl -fsSL https://wp-staging.com/install.sh | bash -s -- -v 1.4.3-beta.1
```

**Windows (PowerShell):**
```powershell
& ([scriptblock]::Create((irm https://wp-staging.com/install.ps1))) -v "1.4.3-beta.1"
```

**Windows (CMD):**
```cmd
curl -fsSL https://wp-staging.com/install.cmd -o install.cmd && install.cmd -v 1.4.3-beta.1 && del install.cmd
```

**Available versions**: See all releases at [GitHub Releases](https://github.com/wp-staging/wp-staging-cli-release/tags)

### Manual Installation

If you prefer to download and install manually:

1. Download the latest release archive from:
   [GitHub Releases (main.zip)](https://github.com/wp-staging/wp-staging-cli-release/archive/refs/heads/main.zip)
2. Extract the archive and locate the binary in the `build` folder for your platform:
   - **Linux**: `build/linux_amd64/wpstaging` (64-bit) or `build/linux_i386/wpstaging` (32-bit)
   - **macOS**: `build/macos_arm64/wpstaging` (Apple Silicon) or `build/macos_amd64/wpstaging` (Intel)
   - **Windows**: `build/windows_amd64/wpstaging.exe` (64-bit) or `build/windows_i386/wpstaging.exe` (32-bit)
3. Make it accessible from anywhere on your computer:

**Linux / macOS:**
```bash
# User installation (no sudo required)
mkdir -p ~/.local/bin
mv wpstaging ~/.local/bin/
chmod +x ~/.local/bin/wpstaging

# Or system-wide installation
sudo mv wpstaging /usr/local/bin/
sudo chmod +x /usr/local/bin/wpstaging
```

**Windows:**
1. Create a directory: `C:\Program Files\wpstaging\`
2. Move `wpstaging.exe` to that directory
3. Add `C:\Program Files\wpstaging\` to your PATH environment variable

### Uninstallation

**Remove Docker Environment (Optional):**

If you've used the dockerize features, first remove all Docker containers and data:

```bash
wpstaging remove
```

This will stop and remove all Docker containers, volumes, and configurations.

#### Quick Uninstall (Recommended)

**Linux / macOS / WSL:**
```bash
curl -fsSL https://wp-staging.com/uninstall.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://wp-staging.com/uninstall.ps1 | iex
```

**Windows (CMD):**
```cmd
curl -fsSL https://wp-staging.com/uninstall.cmd -o uninstall.cmd && uninstall.cmd && del uninstall.cmd
```

The uninstaller will:
- Deactivate your license on the WP Staging server (if registered)
- Remove the wpstaging binary and aliases
- Remove PATH entries from shell configuration
- Remove license key environment variable
- Remove cache and working directories

#### Manual Uninstallation

If you prefer to uninstall manually:

**Linux:**
```bash
# Deactivate license first
wpstaging deactivate --yes

# Remove binary
rm ~/.local/bin/wpstaging  # or: sudo rm /usr/local/bin/wpstaging

# Remove shell completions (if installed)
rm ~/.local/share/bash-completion/completions/wpstaging
rm ~/.local/share/zsh/completions/_wpstaging

# Remove license and cache data
rm -rf ~/.config/wpstaging
```

**macOS:**
```bash
# Deactivate license first
wpstaging deactivate --yes

# Remove binary
rm ~/.local/bin/wpstaging  # or: sudo rm /usr/local/bin/wpstaging

# Remove shell completions (if installed)
rm ~/.local/share/bash-completion/completions/wpstaging
rm ~/.local/share/zsh/completions/_wpstaging

# Remove license and cache data
rm -rf ~/Library/Application\ Support/wpstaging
```

**Windows (PowerShell):**
```powershell
# Deactivate license first
wpstaging deactivate --yes

# Remove binary
Remove-Item "$env:LOCALAPPDATA\Programs\wpstaging" -Recurse -Force

# Remove from PATH (manual step required)
# Go to System Properties > Environment Variables > User Variables > PATH
# Remove the wpstaging entry

# Remove license and cache data
Remove-Item "$env:APPDATA\wpstaging" -Recurse -Force
```

---

## Usage

```bash
wpstaging [command] [flags] <backupfile.wpstg>
```

- Commands must come first
- Flags and `<backupfile.wpstg>` can appear in any order

### Commands

Below are the available commands you can use. The tool is organized into groups to make it easy to work with backups, manage Docker environments, and handle WordPress sites.

**Site Commands:**

These commands help you manage multiple WordPress sites in your Docker environment.

| Command | Description |
|----------|-------------|
| `add` | Add a new WordPress site |
| `list` | List all sites or show details for a specific site |
| `del` | Delete a WordPress site |
| `enable` | Enable a WordPress site |
| `disable` | Disable a WordPress site |
| `reset` | Reset a WordPress site |

**Backup Commands:**

These commands help you work with WP Staging backup files to extract, restore, and inspect their contents.

| Command | Description |
|----------|-------------|
| `extract` | Extract files, database, or metadata from a WP STAGING backup |
| `restore` | Restore a WordPress site from a WP STAGING backup |
| `dump-header` | View backup header details |
| `dump-metadata` | View metadata from a backup file |
| `dump-index` | View backup index details |

**Docker Commands:**

These commands help you control Docker containers for your WordPress environment.

| Command | Description |
|----------|-------------|
| `start` | Start containers for a site or all sites |
| `stop` | Stop containers for a site or all sites |
| `restart` | Restart containers for a site or all sites |
| `status` | Display container status for a site or all sites |
| `shell` | Open an interactive shell in the PHP container |
| `remove` | Stop containers and remove all Docker data |
| `update-hosts-file` | Update the local hosts file with site entries |
| `generate-compose-file` | Generate a docker-compose.yml file |
| `generate-docker-file` | Generate Docker configuration files |

**Other Commands:**

These commands help you manage your license and cache.

| Command | Description |
|----------|-------------|
| `register` | Activate your WP Staging Pro license |
| `clean` | Clean up cached data, license info, and temporary files |
| `help` | Help about any command |

### Your Backup File
`backupfile.wpstg` — The backup file you want to work with. You'll need this for `extract` and `restore` commands.

### Flags
See [WP Staging CLI Command Reference](./docs/COMMANDS.md) for a full list of available flags.

---

## Examples

### Extract a Backup

Extract all files and database from your backup to the default output directory.

```bash
wpstaging extract backupfile.wpstg
```

### Extract from Remote URL

Extract a backup directly from a remote URL without downloading it manually first.

```bash
# Using --from flag
wpstaging extract --from=https://example.com/backups/backup.wpstg

# Or pass URL directly as argument
wpstaging extract https://example.com/backups/backup.wpstg
```

The CLI will:
1. Validate the remote file (size and format)
2. Display backup information
3. Ask for confirmation before downloading
4. Download with progress indicator (supports resume for interrupted downloads)

### Extract and Prepare Database for Import

Extract your backup and automatically clean up the database file so it's ready to import with standard database tools.

```bash
wpstaging extract --normalizedb backupfile.wpstg
```

### Extract and Replace URL & Prefix

Extract your backup while replacing the site URL and database prefix. Perfect for moving your site to a new domain or environment.

```bash
wpstaging extract --normalizedb \
  --siteurl=https://example.local --db-prefix=wpsite backupfile.wpstg
```

---

### Restore to a Specific Directory

Restore your entire WordPress site (files and database) to a specific directory on your server.

```bash
wpstaging restore --path=/var/www/site backupfile.wpstg
```

Or, if you're already inside the WordPress root directory:
```bash
cd /var/www/site
wpstaging restore backupfile.wpstg
```

### Restore from Remote URL

Restore a WordPress site directly from a remote backup URL.

```bash
wpstaging restore --path=/var/www/site --from=https://example.com/backups/backup.wpstg
```

### Restore to External Database

Restore your site while connecting to an external or remote database server. Useful when your database is hosted separately.

```bash
wpstaging restore --path=/var/www/site \
  --db-name=dbname --db-user=user --db-pass=pass --db-host=host backupfile.wpstg
```

### Restore to Dockerized Site

Restore directly to an existing dockerized site using its hostname. Database credentials are auto-detected from the site's `.env` file.

```bash
wpstaging restore mysite.local backup.wpstg
wpstaging restore mysite.local --from=backup.wpstg
wpstaging restore mysite.local --from=https://example.com/backup.wpstg
```

The site must already exist (created with `wpstaging add mysite.local`).

---

### Dump Backup Index

See what's inside your backup file before extracting it. This shows you all the files included in the backup.

**Basic:**
```bash
wpstaging dump-index backupfile.wpstg
```

**Detailed output:**
```bash
wpstaging dump-index --data backupfile.wpstg
```

---

### Dockerize WordPress

Create isolated Docker-based WordPress environments for testing and development.

**Add a new site:**

Create a new WordPress site with a custom local domain.

```bash
wpstaging add https://mysite.local
```

**Add a new site and restore from backup:**

Create a new site and restore from a WP STAGING backup file in one step.

```bash
wpstaging add https://mysite.local --from=backup.wpstg
wpstaging add https://mysite.local --from=https://example.com/backup.wpstg
```

**Start containers:**

Start your Docker environment after adding sites or after stopping it.

```bash
wpstaging start
wpstaging start mysite.local  # Start a specific site only
```

**Manage WordPress sites:**

Add, list, reset, or remove WordPress sites in your Docker environment.

```bash
wpstaging add https://newsite.local
wpstaging list
wpstaging list site1.local site2.local  # Show details for multiple sites
wpstaging reset mysite.local  # Reset site to fresh WordPress
wpstaging reset mysite.local --wp=6.5  # Reset with specific WordPress version
wpstaging reset mysite.local --from=backup.wpstg  # Reset and restore from backup
wpstaging del oldsite.local
wpstaging del site1.local site2.local  # Delete multiple sites
wpstaging del  # Delete all sites (with confirmation)
```

**Access the staging site:**

Once running, visit your site in a browser.

```text
https://mysite.local
```

**Important Notes:**

- **Linux/macOS:** Some operations may ask for your password (sudo) to update your hosts file. This is normal and only happens during initial setup.
- **macOS Users (Passwordless Sudo Recommended):** Automatic IP alias binding is enabled by default for seamless multi-site setups using loopback IP range **127.3.2.1 - 127.3.2.254**. This requires sudo and you'll be prompted for your password in each new terminal session (5-15 minute timeout per session). **Solution:** Set up passwordless sudo for wpstaging — see [FAQ Q76](./docs/FAQ.md#q76-how-do-i-set-up-passwordless-sudo-for-wpstaging-cli) for step-by-step instructions. Alternatively, use `--skip-macos-auto-ip` to disable automatic IP binding (requires manual `ifconfig lo0 alias` commands for each IP in the range).
- **External Service Conflicts:** If other services (Apache, nginx, MySQL) or other Docker containers are using ports on the wpstaging IP range, the CLI detects this and either auto-switches to the next available IP or port (for new sites) or shows clear error messages with diagnostic commands.
- **Skip hosts update:** If you prefer to manage your hosts file manually, use `--skip-update-hosts-file` when creating sites.

---

### Register Your License (Recommended)

Run the `register` command once to securely save your license:

```bash
# Interactive mode (prompts for license key)
wpstaging register

# Non-interactive mode (useful for scripts/automation)
wpstaging register --license=YOUR_LICENSE_KEY
```

Your license key is encrypted and validated. After registration, you can run any command without the `--license` flag.

**Alternative Methods for Automation:**

- **Environment variable** `WPSTGPRO_LICENSE`:
  - Unix/macOS: `export WPSTGPRO_LICENSE=YOUR_LICENSE_KEY`
  - Windows CMD: `set WPSTGPRO_LICENSE=YOUR_LICENSE_KEY`
  - Windows PowerShell: `$env:WPSTGPRO_LICENSE="YOUR_LICENSE_KEY"`

- **Per-command flag**: `--license=YOUR_LICENSE_KEY` (on extract/restore commands)

### Environment Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `WPSTGPRO_LICENSE` | License key | `export WPSTGPRO_LICENSE=abc123...` |
| `WPSTGCLI_DEBUG` | Enable debug output | `export WPSTGCLI_DEBUG=1` |
| `WPSTGCLI_QUIET` | Suppress informational output | `export WPSTGCLI_QUIET=1` |
| `WPSTGCLI_ALLOW_ROOT` | Allow running as root user | `export WPSTGCLI_ALLOW_ROOT=1` |

---

### Use a Config File

You can create a settings file to remember your preferences. This saves you from typing the same options repeatedly.

**Default path:** `~/.wpstaging/wpstaging.conf`

**Example settings:**
```ini
--path /var/www/site
--outputdir /var/www/backups
```

---

## System Requirements

**Minimum Requirements:**
- **Extract/Restore:** Any modern system with 512 MB RAM and sufficient disk space
- **Dockerize:** 2 CPU cores, 4 GB RAM, Docker 20.10.0+, Docker Compose 2.19.0+

**License:** WP Staging Pro (Agency or Developer plan required)

For detailed system requirements, see [System Requirements Documentation](./docs/SYSTEM-REQUIREMENTS.md).

---

## Release Notes

See [CHANGELOG.md](./CHANGELOG.md) for detailed release history and version changes.

---

## FAQ and Troubleshooting

For common issues and troubleshooting guidance, refer to [FAQ.md](./docs/FAQ.md).

---

## Contributing

We'd love to hear from you!
Have a problem or idea? Let us know through our issue tracker.

- Submit an issue: https://github.com/wp-staging/wp-staging-cli-release/issues
- Check for existing issues before submitting new ones.
- Prebuilt binaries only — source contributions are not yet open.

---

## Acknowledgements

- [WP Staging Pro](https://wp-staging.com/) — The best backup and migration plugin for WordPress.
- [Go Programming Language](https://go.dev/) — The core language behind this tool.
- [Cobra](https://github.com/spf13/cobra) — CLI framework for Go applications.
- [bashunit](https://github.com/TypedDevs/bashunit) — Used for end-to-end testing.
