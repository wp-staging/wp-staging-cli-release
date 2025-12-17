# System Requirements

This document outlines the system requirements for WP Staging CLI operations.

---

## Quick Reference

| Operation | MySQL/MariaDB | Docker | External Tools | Works Offline |
|-----------|---------------|--------|----------------|---------------|
| **extract** | No | No | No | Yes* |
| **restore** | Yes | No | No | Yes* |
| **dockerize** | Optional | Yes | Yes | No** |

*Requires database server connection  
**Requires internet for initial setup  

All operations require internet connection for license validation (cached for 4 hours).

---

## Extract Operation

Extract backup files without any external dependencies.

### Requirements

**Required:**
- WP Staging CLI binary
- Valid WP Staging Pro license (Agency or Developer)
- Sufficient disk space (at least 2x backup file size)

**Supported Platforms:**
- Linux (x86_64, ARM64, ARM, i386)
- macOS (ARM64, x86_64)
- Windows (x86_64, i386)

### No External Dependencies

The extract operation is completely self-contained:
- ✅ No database server needed
- ✅ No Docker required
- ✅ No PHP or web server needed
- ✅ No additional packages or libraries
- ⚠️ Requires internet connection for license validation (cached for 4 hours)

### What You Can Do

```bash
# Extract entire backup
wpstaging extract backup.wpstg

# Extract and normalize database
wpstaging extract --normalizedb backup.wpstg

# Extract with custom output directory
wpstaging extract --outputdir=/custom/path backup.wpstg
```

---

## Restore Operation

Restore WordPress sites from backups. Requires an existing WordPress installation and database server.

### Requirements

**Required:**
- WP Staging CLI binary
- Valid WP Staging Pro license
- **Existing WordPress installation** with wp-config.php file
- **MySQL or MariaDB server** (running and accessible)
- Write access to target WordPress directory

**Note:** By default, the restore operation reads database connection details from the existing wp-config.php file in the target directory. You can override these settings using command-line flags.

**Database Server:**

| Component | Requirement |
|-----------|-------------|
| Server Type | MySQL or MariaDB |
| Minimum Version | MySQL 4.1+ or MariaDB 5.5.5+ |
| Recommended | MySQL 5.6+ or MariaDB 10.0+ |
| Connection | TCP/IP or Unix socket |
| Features | utf8mb4 support recommended |

**Database Permissions Required:**
- CREATE DATABASE
- DROP TABLE
- INSERT, UPDATE, DELETE, SELECT
- ALTER TABLE

### No External Tools Required

The CLI connects directly to your database:
- ✅ No `mysql` command-line client needed
- ✅ No `mysqldump` utility needed
- ✅ Direct connection using MySQL protocol

### Connection Options

**Standard Connection:**
```bash
wpstaging restore --path=/var/www/site \
  --db-host=localhost \
  --db-name=wordpress \
  --db-user=dbuser \
  --db-pass=dbpass \
  backup.wpstg
```

**SSL/TLS Connection:**
```bash
wpstaging restore --path=/var/www/site \
  --db-ssl-ca-cert=/path/to/ca.pem \
  --db-ssl-client-cert=/path/to/client-cert.pem \
  --db-ssl-client-key=/path/to/client-key.pem \
  backup.wpstg
```

**Unix Socket:**
- Automatically used when connecting to localhost if TCP fails

---

## Dockerize Operation

Create isolated WordPress environments using Docker containers.

### Requirements

**Required Software:**

| Component | Minimum Version | How to Check |
|-----------|-----------------|--------------|
| Docker | 20.10.0 | `docker version` |
| Docker Compose | 2.19.0 | `docker compose version` or `docker-compose version` |
| mkcert | v1.4.4 | Auto-downloaded if missing |

**Docker Compose Compatibility:**
- Docker Compose V2 (plugin): `docker compose` ✅
- Docker Compose V1 (standalone): `docker-compose` ✅ (only if version >= 2.19.0)
- The CLI checks both commands and uses the one that meets minimum version requirement

### System Requirements

**Minimal Configuration:**
- CPU: 2 cores
- RAM: 4 GB total (2 GB available for Docker)
- Disk: 10 GB available space
- Network: Internet connection

**Recommended Configuration:**
- CPU: 4+ cores
- RAM: 8 GB total (4 GB available for Docker)
- Disk: 20 GB available space (SSD preferred)
- Network: Broadband connection

### Container Images

The following Docker images will be downloaded automatically:

| Service | Image | Default Version | Configurable |
|---------|-------|-----------------|--------------|
| PHP | wpstaging/dockerize | php-8.1 | Yes (`--php`) |
| Nginx | nginx | stable-alpine-slim | No |
| MariaDB | mariadb | 11.8 | No |
| Mailpit | axllent/mailpit | latest | No |

### Network Ports

| Service | Default Port | Purpose | Configurable |
|---------|--------------|---------|--------------|
| HTTP (Nginx) | 80 | Web access | `--http-port` |
| HTTPS (Nginx) | 443 | Secure web access | `--https-port` |
| MariaDB | 3306 | Database access | `--db-port` |
| Mailpit | 8025 | Mail testing UI | `--mailpit-http-port` |

**Port Conflict Handling:**
- Automatically detects port conflicts
- Uses 10 predefined fallback ports per service
- Assigns random ports (49152-65535) if all fallbacks occupied

### System Permissions

Some operations require elevated privileges:

| Operation | Privilege | Platforms | Can Skip |
|-----------|-----------|-----------|----------|
| Update /etc/hosts | Root/Admin | All | Yes (`--skip-update-hosts-file`) |
| Install mkcert CA | Root/Admin | Linux/macOS | Yes (browsers show warnings) |
| Bind IP aliases | Root (sudo) | **macOS only** | Yes (`--skip-macos-auto-ip`, use different ports) |
| Docker operations | docker group | Linux | No |

### Platform-Specific Notes

**Linux:**
- Automatic IP allocation (127.3.2.1-254)
- User must be in `docker` group for non-root access
- NSS database support for Chrome/Chromium SSL trust

**macOS (Passwordless Sudo Recommended):**
- Default IP: 127.3.2.1
- **Automatic IP alias binding enabled by default** for loopback range **127.3.2.1 - 127.3.2.254** (requires sudo, unlike Linux/Windows where loopback IPs are always available)
- Each site automatically gets next available IP from the range as needed
- Sudo password prompts occur per terminal session (5-15 minute timeout) — can become repetitive
- **Passwordless sudo highly recommended** for seamless multi-site operation (see FAQ Q76 for setup)
- Use `--skip-macos-auto-ip` flag to disable automatic IP binding (requires manual `ifconfig lo0 alias` commands for each IP)
- LaunchDaemon can make manual IP bindings persistent (when using `--skip-macos-auto-ip`)

**Windows:**
- Requires Docker Desktop in **Linux container mode** (not Windows containers)
- Docker Desktop defaults to Linux containers, but if switched to Windows containers, you must switch back
- **Automatic switch:** When detected, the CLI will prompt to switch automatically:
  ```
  The next action will switch to Linux containers automatically.
  Continue? [y/N]:
  ```
- Manual switch: Right-click Docker Desktop tray icon → "Switch to Linux containers..." or run:
  ```cmd
  "C:\Program Files\Docker\Docker\DockerCli.exe" -SwitchLinuxEngine
  ```
- Automatic IP allocation (127.3.2.1-254)
- Native hosts file handling

### Storage Requirements

| Directory | Purpose | Typical Size |
|-----------|---------|--------------|
| `~/wpstaging/sites/<hostname>/` | WordPress site files | ~500 MB per site |
| `~/wpstaging/stack/mariadb/` | Database data | Varies |
| `~/wpstaging/stack/mkcert/` | mkcert binary and CA | <10 MB |
| `~/wpstaging/stack/docker/` | Shared Docker scripts | <1 MB |

### What You Can Do

**Setup a new site:**
```bash
wpstaging add mysite.local
```

**Custom configuration:**
```bash
wpstaging add mysite.local \
  --php=8.2 \
  --http-port=8080 \
  --https-port=8443
```

**Use external database:**
```bash
wpstaging add mysite.local --external-db \
  --db-host=192.168.1.100:3306 \
  --db-name=wordpress \
  --db-user=dbuser \
  --db-pass=dbpass
```

**Manage sites:**
```bash
wpstaging list              # List all sites
wpstaging start             # Start all sites
wpstaging stop              # Stop all sites
wpstaging del mysite.local  # Delete a site
```

---

## License Requirements

All operations require a valid WP Staging Pro license.

### License Types

- WP Staging Agency license ✅
- WP Staging Developer license ✅

### How to Provide License

**Option 1: Register (Recommended)**
```bash
wpstaging register
```

**Option 2: Environment Variable**
```bash
# Linux/macOS
export WPSTGPRO_LICENSE=your-license-key

# Windows PowerShell
$env:WPSTGPRO_LICENSE="your-license-key"

# Windows CMD
set WPSTGPRO_LICENSE=your-license-key
```

**Option 3: Command Flag**
```bash
wpstaging extract --license=your-license-key backup.wpstg
```

### License Validation

- Online validation against WP Staging servers
- Cached for 4 hours to reduce API calls
- Encrypted storage in `~/.wpstaging/`

---

## Troubleshooting

### Extract Issues

**"Backup file does not exist"**
- Verify file path is correct
- Use absolute paths
- Check read permissions

**"Insufficient disk space"**
- Ensure 2x backup file size is available
- Use `--outputdir` to specify different location with more space

### Restore Issues

**"Failed to connect to database"**
- Verify MySQL/MariaDB is running: `systemctl status mysql`
- Check credentials are correct
- Test connection: `mysql -h host -P port -u user -p`
- Verify firewall allows connection

**"Access denied for user"**
- Grant database permissions to user
- Ensure user has CREATE/DROP privileges
- Try with root credentials for testing

### Dockerize Issues

**"Docker version too old"**
- Current: Check with `docker version`
- Required: 20.10.0 or later
- Update Docker to latest version

**"docker-compose: command not found"**
- Docker Compose 2.0.0+ required
- Modern Docker includes compose plugin: `docker compose`
- Verify: `docker compose version`

**"Port already in use"**
- CLI automatically detects and uses fallback ports
- Manually specify custom ports:
  ```bash
  wpstaging add mysite.local \
    --http-port=8080 \
    --https-port=8443
  ```

**"Failed to update hosts file"**
- Requires root/admin privileges
- Run with `sudo` (Linux/macOS) or as Administrator (Windows)
- Alternative: Use `--skip-update-hosts-file` and manually add entries

**"mkcert download failed"**
- Check internet connection
- Verify GitHub access
- Check firewall/proxy settings
- Install mkcert manually: https://github.com/FiloSottile/mkcert

**"Could not find an available IP address pool"**
- Too many Docker networks created
- Clean up: `docker network prune -f`

---

## Supported Platforms

| Platform | Architecture | Extract | Restore | Dockerize |
|----------|-------------|---------|---------|-----------|
| Linux | x86_64 | ✅ | ✅ | ✅ |
| Linux | ARM64 | ✅ | ✅ | ✅ |
| Linux | ARM | ✅ | ✅ | ✅ |
| Linux | i386 | ✅ | ✅ | ✅ |
| macOS | ARM64 (Apple Silicon) | ✅ | ✅ | ✅ |
| macOS | x86_64 (Intel) | ✅ | ✅ | ✅ |
| Windows | x86_64 | ✅ | ✅ | ✅ |
| Windows | i386 | ✅ | ✅ | ✅ |

---

## Recommended Specifications

### For Extract/Restore

**Minimal:**
- CPU: Any modern processor
- RAM: 512 MB available
- Disk: 2x backup file size
- OS: Any supported platform

**Recommended:**
- CPU: 2+ cores
- RAM: 2 GB available
- Disk: SSD with 3x backup file size
- OS: Latest stable version

### For Dockerize

**Minimal:**
- CPU: 2 cores (4+ for multiple sites)
- RAM: 4 GB total
- Disk: 10 GB available
- Network: Broadband (5 Mbps+)

**Recommended:**
- CPU: 4+ cores
- RAM: 8 GB total
- Disk: 20+ GB available (SSD)
- Network: Broadband (25 Mbps+)

---

## Additional Resources

For more information about WP Staging CLI and getting help:

- **[WP Staging Pro](https://wp-staging.com)** - Official website with product information, pricing, and documentation
- **[Support](https://wp-staging.com/support)** - Get technical support, report issues, and access knowledge base

---

**Last Updated:** 2025-11-27 19:04:15 UTC
