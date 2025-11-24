# WP Staging CLI

**WP Staging CLI** is a high-performance, cross-platform command-line tool for processing **WP Staging** backup files (`.wpstg`).
It allows you to extract, normalize, inspect, and restore backups created by the [WP Staging Pro](https://wp-staging.com) plugin — even when your WordPress site is broken or inaccessible — and spin up isolated test environments using Docker containers.

This tool is designed for developers and system administrators who want to automate WordPress site cloning, migration, and environment setup.

> License Required:  
> You must have a valid [WP Staging Agency or Developer license key](https://wp-staging.com) to use this tool.

---

## Highlights

- **Recover broken sites** — Restore your WordPress site files and database instantly, even when your site won't load.
- **Extract backups anywhere** — Open and extract `.wpstg` backup files on any computer without needing WordPress installed.
- **Clean database files** — Automatically prepare your database files so they work with any database tool.
- **View backup details** — See what's inside your backup files before extracting them.
- **Create test environments** — Set up isolated WordPress sites for testing using Docker containers.

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
- Install bash completion (Linux/macOS)

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
wpstaging uninstall
```

This will stop and remove all Docker containers, volumes, and configurations.

**Linux / macOS:**
```bash
# Remove binary
rm ~/.local/bin/wpstaging  # or: sudo rm /usr/local/bin/wpstaging

# Remove bash completion (if installed)
rm ~/.local/share/bash-completion/completions/wpstaging

# Remove license and cache data
rm -rf ~/.wpstaging
```

**Windows (PowerShell):**
```powershell
# Remove binary
Remove-Item "$env:LOCALAPPDATA\Programs\wpstaging" -Recurse -Force

# Remove from PATH (manual step required)
# Go to System Properties > Environment Variables > User Variables > PATH
# Remove the wpstaging entry

# Remove license and cache data
Remove-Item "$env:USERPROFILE\.wpstaging" -Recurse -Force
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
| `list` | List all WordPress sites |
| `del` | Delete a WordPress site |
| `enable` | Enable a WordPress site |
| `disable` | Disable a WordPress site |

**Backup Commands:**

These commands help you work with WP Staging backup files to extract, restore, and inspect their contents.

| Command | Description |
|----------|-------------|
| `extract` | Extract items from a WP STAGING backup file |
| `restore` | Restore a WordPress site from a WP STAGING backup |
| `dump-header` | Display backup header information |
| `dump-metadata` | Display backup metadata information |
| `dump-index` | Display backup file index |

**Docker Commands:**

These commands help you control Docker containers for your WordPress environment.

| Command | Description |
|----------|-------------|
| `setup` | Setup Docker containers and install default WordPress site |
| `start` | Start all Docker containers |
| `stop` | Stop and remove all containers |
| `restart` | Restart all containers |
| `status` | Display current container status |
| `shell` | Open an interactive shell in the PHP container |
| `uninstall` | Stop containers and remove all Docker data |
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

### Restore to External Database

Restore your site while connecting to an external or remote database server. Useful when your database is hosted separately.

```bash
wpstaging restore --path=/var/www/site \
  --db-name=dbname --db-user=user --db-pass=pass --db-host=host backupfile.wpstg
```

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

**Run setup:**

Initialize your Docker environment with default settings.

```bash
wpstaging setup
```

**Setup with custom URL (optional):**

Set up Docker with a specific local domain for your site.

```bash
wpstaging setup https://mysite.local
```

**Start containers:**

Start your Docker environment after setup or after stopping it.

```bash
wpstaging start
```

**Manage WordPress sites:**

Add, list, or remove WordPress sites in your Docker environment.

```bash
wpstaging add https://newsite.local
wpstaging list
wpstaging del https://oldsite.local
```

**Access the staging site:**

Once running, visit your site in a browser.

```text
https://mysite.local
```

**Important Notes:**

- **Linux/macOS:** Some operations may ask for your password (sudo) to update your hosts file. This is normal and only happens during initial setup.
- **macOS Users (Passwordless Sudo Recommended):** Automatic IP alias binding is enabled by default for seamless multi-site setups using loopback IP range **127.3.2.1 - 127.3.2.254**. This requires sudo and you'll be prompted for your password in each new terminal session (5-15 minute timeout per session). **Solution:** Set up passwordless sudo for wpstaging — see [FAQ Q76](./docs/FAQ.md#q76-how-do-i-set-up-passwordless-sudo-for-wpstaging-cli) for step-by-step instructions. Alternatively, use `--skip-macos-auto-ip` to disable automatic IP binding (requires manual `ifconfig lo0 alias` commands for each IP in the range).
- **Skip hosts update:** If you prefer to manage your hosts file manually, use `--skip-update-hosts-file` when creating sites.

---

### Register Your License (Recommended)

Run the `register` command once to securely save your license:

```bash
wpstaging register
```

Your license key is encrypted and validated. After registration, you can run any command without the `--license` flag.

**For Automation (No Prompts):**

Use these methods for automated scripts or CI/CD pipelines:

- **Environment variable** `WPSTGPRO_LICENSE`:
  - Unix/macOS: `export WPSTGPRO_LICENSE=YOUR_LICENSE_KEY`
  - Windows CMD: `set WPSTGPRO_LICENSE=YOUR_LICENSE_KEY`
  - Windows PowerShell: `$env:WPSTGPRO_LICENSE="YOUR_LICENSE_KEY"`

- **Command flag**: `--license=YOUR_LICENSE_KEY`

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
- **Dockerize:** 2 CPU cores, 4 GB RAM, Docker 20.10.0+, Docker Compose 2.0.0+

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
