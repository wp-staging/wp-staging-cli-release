# WP Staging CLI FAQ

## General Questions

<a name="q1"></a>
**Q1: What is `wpstaging`?**  
**A1:** `wpstaging` is a high-performance command-line tool to process WP Staging backup files (`.wpstg`). It allows you to extract, normalize, inspect, and restore backups without using WordPress itself.

<a name="q2"></a>
**Q2: Which operating systems are supported?**  
**A2:**
Windows, Linux, and macOS. Pre-built binaries are available for all major OSes. On Windows, the `wpstaging` binary requires Windows 10 or Server 2016 or later. The CMD installer one-liner (`install.cmd`) uses curl and additionally requires Windows 10 1803 (April 2018) or Server 2019 or later. The PowerShell one-liner (`irm https://wp-staging.com/install.ps1 | iex`) uses the built-in `System.Net.WebClient` and works on Windows 10 / Server 2016 without curl. Users on earlier builds can also download the binary manually.

<a name="q3"></a>
**Q3: Do I need a license to use this tool?**  
**A3:**
Yes. You need a valid WP Staging Agency or Developer license key to access backup files.

<a name="q4"></a>
**Q4: How fast is it?**  
**A4:**
Benchmarks show it can extract a 20GB backup in under 36 seconds on an AMD Ryzen 7 PRO 7840U with a fast SSD running Ubuntu 20.04.

## Installation Questions

<a name="q5"></a>
**Q5: How do I install `wpstaging`?**  
**A5:**
Use the quick install script (recommended):

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

**Manual Installation:**
1. Download the latest release: [GitHub Releases (main.zip)](https://github.com/wp-staging/wp-staging-cli-release/archive/refs/heads/main.zip)
2. Extract and locate the binary in the `build` folder for your platform
3. Make it accessible:
   ```bash
   # Linux/macOS (user installation)
   mkdir -p ~/.local/bin
   mv wpstaging ~/.local/bin/
   chmod +x ~/.local/bin/wpstaging

   # Or system-wide
   sudo mv wpstaging /usr/local/bin/
   sudo chmod +x /usr/local/bin/wpstaging
   ```

For complete installation details, see the [Installation section in README](../README.md#installation).

<a name="q6"></a>
**Q6: Can I install to a custom directory?**  
**A6:**
Yes. Use the `--bin-dir` (`-d`) flag to install the binary to a specific directory:
```bash
curl -fsSL https://wp-staging.com/install.sh | bash -s -- --bin-dir /opt/tools
```
The installer still configures PATH, shell aliases, and completion scripts. On Windows (PowerShell): `-d "C:\Tools"`. On Windows (CMD): `--bin-dir C:\Tools`.

<a name="q6a"></a>
**Q6a: Can I download files without installing?**  
**A6a:**
Yes. Use the `--extract` (`-e`) flag to download all installable files to a directory without running the full installation:
```bash
curl -fsSL https://wp-staging.com/install.sh | bash -s -- --extract /tmp/wpstaging-files
```
No PATH changes, aliases, or completion scripts are configured. The binary and completion files are copied to the specified directory.

**Note:** `--bin-dir` and `--extract` cannot be used together.

<a name="q6a1"></a>
**Q6a1: Can I pass extra arguments to the binary during installation?**  
**A6a1:**
Yes. Use the `--cli-args` (`-a`) flag to pass extra arguments to every wpstaging binary call the installer makes (version check and license registration):
```bash
curl -fsSL https://wp-staging.com/install.sh | bash -s -- -a "--debug"
```
On Windows (PowerShell): `-a "--debug"`. On Windows (CMD): `-a "--debug"`.

**Note:** Only simple space-separated flags are supported. Arguments with embedded spaces are not supported.

<a name="q6b"></a>
**Q6b: Can I use it without installing?**  
**A6b:**
Yes, you can run the binary directly from the extracted folder.

<a name="q6c"></a>
**Q6c: How do I uninstall wpstaging?**  
**A6c:**
Use the built-in `uninstall` command (recommended):

**Default uninstall** (deactivates license, removes binary, shell completions, and PATH entries):
```bash
wpstaging uninstall
```

**Full uninstall** (additionally removes cache, Docker sites, etc.):
```bash
wpstaging uninstall --full
```

Alternatively, download and run the uninstall script directly:

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

The default `uninstall` command:
- Deactivates your license on the WP Staging server and deletes the local key
- Removes the wpstaging binary
- Removes shell completion scripts for Bash and Zsh (Linux/macOS)
- Removes PATH entries from shell RC files (Linux/macOS) or user PATH (Windows)

The `--full` flag additionally removes:
- Cache and working directories:
  - Linux: `~/.config/wpstaging/`
  - macOS: `~/Library/Application Support/wpstaging/`
  - Windows: `%APPDATA%\wpstaging\`
- Docker sites and data

**Note:** If you've used Docker features, run `wpstaging remove` first to remove Docker containers and data before uninstalling the CLI.

For complete uninstallation details, see the [Uninstallation section in README](../README.md#uninstallation).

## Usage Questions

<a name="q7"></a>
**Q7: How do I run `wpstaging`?**  
**A7:**
Use the following command:
```bash
wpstaging [commands] [flags] <backupfile.wpstg>
```
Commands must come first. Flags and the backup file can appear in any order.

<a name="q8"></a>
**Q8: What are the main commands?**  
**A8:**
WP Staging CLI has four main command groups:

**Site Commands:**
- `add` – Add a new WordPress site
- `list [hostname...]` – List all sites or show details for specific sites
- `del [hostname...]` – Delete one or more sites, or all sites
- `enable` – Enable a WordPress site
- `disable` – Disable a WordPress site
- `reset` – Reset a WordPress site

**Backup Commands:**
- `extract` – Extract files, database, or metadata from a WP STAGING backup
- `restore` – Restore a WordPress site from a WP STAGING backup
- `dump-header` – View backup header details
- `dump-index` – View backup index details
- `dump-metadata` – View metadata from a backup file

**Docker Commands:**
- `start [hostname]` – Start Docker containers (all sites or specific site)
- `stop [hostname]` – Stop and remove containers (all sites or specific site)
- `restart [hostname]` – Restart containers (all sites or specific site)
- `status [hostname...]` – Display container status (all sites or specific sites)
- `shell <hostname> [root]` – Open an interactive shell in the PHP container
- `remove` – Stop containers and remove all Docker data
- `update-hosts-file` – Update the local hosts file with site entries
- `generate-compose-file [hostname]` – Generate docker-compose.yml (one site or all sites)
- `generate-docker-file [hostname]` – Generate Docker config files (one site or all sites)

**Other Commands:**
- `register` – Activate your WP Staging Pro license
- `update` – Update WP Staging CLI to the latest version
- `clean` – Clean up cached data, license info, and temporary files
- `help` – Help about any command

Use `wpstaging [command] --help` for detailed information about each command.

<a name="q9"></a>
**Q9: How do I register my license?**  
**A9:**
You can provide your license in three ways:

**Option 1: Register Your License (Recommended)**
```bash
# Interactive mode (prompts for license key)
wpstaging register

# Non-interactive mode (useful for scripts/automation)
wpstaging register -l=YOUR_LICENSE_KEY
wpstaging register --license=YOUR_LICENSE_KEY
```
This will validate your license with WP STAGING servers and store it encrypted locally for future use.

**Option 2: Environment Variable**
```bash
# Unix/Linux/macOS
export WPSTGPRO_LICENSE=YOUR_LICENSE_KEY

# Windows CMD
set WPSTGPRO_LICENSE=YOUR_LICENSE_KEY

# Windows PowerShell
$env:WPSTGPRO_LICENSE="YOUR_LICENSE_KEY"
```

**Option 3: Command-Line Flag**
```bash
wpstaging extract --license=YOUR_LICENSE_KEY backup.wpstg
```

Using license registration (Option 1) is recommended as it keeps sensitive data out of command history and works seamlessly across all commands.

<a name="q9a"></a>
**Q9a: How do I check my current license status?**  
**A9a:**
Run:
```bash
wpstaging register --status
```
This shows your registered license details from local storage: license holder, email, plan name, and expiration date. No network call is made. If no license is registered, the command tells you and prints the registration command.

<a name="q10"></a>
**Q10: How do I deactivate my license?**  
**A10:**
To deactivate and remove your license from this machine:

```bash
wpstaging deactivate
```

This command will:
1. Display your current license information
2. Prompt for confirmation
3. Deactivate the license on WP STAGING servers
4. Remove the encrypted license file from local storage

You can also use the `clean license` command for the same purpose:
```bash
wpstaging clean license
```

After deactivating, you'll need to re-enter your license key the next time you run a command.

<a name="q11"></a>
**Q11: How can I extract and normalize the database file?**  
**A11:**
```bash
wpstaging extract --normalizedb backupfile.wpstg
```

<a name="q12"></a>
**Q12: How can I restore to a different WordPress path?**  
**A12:**
Use the `--path` flag:
```bash
wpstaging restore --path=/var/www/site backupfile.wpstg
```
If running from the WP root, `--path` is optional.

## Filter Flags Questions

<a name="q13"></a>
**Q13: Can I extract only specific parts of the backup?**  
**A13:**
Yes, using “Only-Filters”:
- `--only-wpcontent` – Only extract `wp-content`.
- `--only-plugins` – Only extract plugins.
- `--only-file=<string>` – Extract only matching files.

<a name="q14"></a>
**Q14: Can I skip certain parts?**  
**A14:**
Yes, using "Skip-Filters":
- `--skip-wpcontent` – Skip `wp-content`.
- `--skip-uploads` – Skip uploads.
- `--skip-file=<string>` – Skip files matching a string.

<a name="q15"></a>
**Q15: How do --skip-file and --only-file work? Do they support regex or wildcards?**  
**A15:**
These flags use **simple substring matching**, not regex or wildcards. The string you provide is matched anywhere in the file path.

**How it works:**
- `--only-file=<string>` – Extract **only** files whose full path contains the string
- `--skip-file=<string>` – Skip files whose full path contains the string

**Examples:**

```bash
# Extract only SQL files (matches any path containing ".sql")
wpstaging extract --only-file=.sql backup.wpstg

# Extract only files from uploads directory
wpstaging extract --only-file=/uploads/ backup.wpstg

# Extract only images (matches .jpg, .jpeg, .png, .gif)
wpstaging extract --only-file=.jpg backup.wpstg

# Skip all log files
wpstaging extract --skip-file=.log backup.wpstg

# Skip cache directory
wpstaging extract --skip-file=/cache/ backup.wpstg

# Skip specific plugin
wpstaging extract --skip-file=/wp-content/plugins/problematic-plugin/ backup.wpstg
```

**Important notes:**
- ❌ Does **not** support wildcards like `*.sql` or `file?.txt`
- ❌ Does **not** support regex patterns like `^backup.*\.sql$`
- ✅ Uses simple substring search: `"uploads"` matches `/wp-content/uploads/image.jpg`
- ✅ Case-sensitive matching: `".SQL"` will not match `".sql"`
- ✅ Matches anywhere in the full file path

**Combining filters:**
```bash
# Extract only images from uploads, but skip thumbnails
wpstaging extract --only-file=/uploads/ --skip-file=-150x150 backup.wpstg
```

## Restore Flags Questions

<a name="q16"></a>
**Q16: How do I restore to an external database?**  
**A16:**
Use DB-related flags:
```bash
wpstaging restore --path=/var/www/site \
  --db-name=dbname --db-user=user --db-pass=pass --db-host=host backupfile.wpstg
```

<a name="q17"></a>
**Q17: Can I overwrite existing files or DB tables?**  
**A17:**
Yes, use:
- `--overwrite=<yes|no>` – Overwrite target directory.
- `--overwrite-db=<yes|no>` – Remove DB tables not in backup.
- `--overwrite-wproot=<yes|no>` – Remove WP root files not in backup or core.

## Config File Questions

<a name="q18"></a>
**Q18: What is the default configuration file used for?**  
**A18:**
The config file is used to store **flags only**, not commands. It allows you to avoid repeatedly typing commonly used flags, such as paths, database credentials, filters, or Docker flags.

**Default config file location (OS-specific):**
- **Linux/Unix:** `~/.config/wpstaging/wpstaging.conf`
- **macOS:** `~/Library/Application Support/wpstaging/wpstaging.conf`
- **Windows:** `%APPDATA%\wpstaging\wpstaging.conf`

<a name="q19"></a>
**Q19: Can I skip reading the config file?**  
**A19:**
Yes, use the `--skip-config` flag when running any command. This ensures the CLI ignores the config file entirely and only uses flags provided on the command line.

<a name="q20"></a>
**Q20: Do CLI flags override the config file?**  
**A20:**
Yes. Any flag provided directly in the CLI command will override the corresponding value in the config file.

<a name="q21"></a>
**Q21: What kind of flags can I define in the config file?**  
**A21:**
You can define most CLI flags in the config file to avoid repeatedly typing them on the command line. Each flag should be on its own line with its value (e.g., `--path=/var/www` or `--debug`).

However, the following flags are **ignored** and cannot be defined in the config file:
`-h`, `--help`, `-v`, `--version`, `--about`, `--yes`, `--options`

You can define flags such as:
- **WordPress Path:** `--path`
- **Database Credentials:** `--db-name`, `--db-user`, `--db-pass`, `--db-host`
- **File Overwrite Settings:** `--overwrite`, `--overwrite-db`, `--overwrite-wproot`
- **Filters:** `--only-wpcontent`, `--skip-uploads`, `--only-plugins`, etc.
- **Docker Defaults:** `--php`, `--http-port`, `--https-port`, `--db-port`, `--env-path`, etc.
- **General Flags:** `--debug`, `--quiet`, `--verify`

<a name="q22"></a>
**Q22: Can I use multiple config files?**  
**A22:**
WP-Staging-CLI only reads one config file at a time. By default, it uses the OS-specific config location (see [Q18](#q18)), but you can override it with a custom file using `--config=file.conf`. You can also temporarily bypass it using `--skip-config` and pass all flags directly on the CLI.

## Docker Questions

<a name="q23"></a>
**Q23: Where is the Docker environment setup?**  
**A23:**
By default, Docker-related files are stored in `~/wpstaging/`. Each WordPress site has its own isolated directory in `~/wpstaging/sites/<sitename>/`. You can change the parent location with the `--env-path=<path>` flag.

**Note:** The `--env-path` specifies a parent path. The CLI automatically appends `wpstaging/` to it. For example:
- `--env-path=/tmp/test` → actual path: `/tmp/test/wpstaging/`
- Site directory: `/tmp/test/wpstaging/sites/<hostname>/`

<a name="q24"></a>
**Q24: How do I create a new WordPress site with Docker?**  
**A24:**
Use the `add` command to create a new WordPress site with its own isolated Docker environment. Here's what happens step by step:

1. **Creates site-specific directory structure:**
   - `~/wpstaging/sites/<sitename>/` (site directory)
   - `config/` (PHP, Nginx, MariaDB configurations for this site)
   - `data/` (persistent data for MariaDB, PHP, Mailpit for this site)
   - `.env` (site configuration and credentials)

2. **Generates configuration files:**
   - `docker-compose.yml` with site-specific containers
   - PHP configuration (php.ini, PHP-FPM pool settings)
   - Nginx configuration (server block, SSL certificates)
   - MariaDB configuration
   - WP-CLI installation

3. **Pulls required Docker images** (if not already cached):
   - PHP-FPM (version specified with `--php`, default: 8.1)
   - Nginx (stable-alpine-slim)
   - MariaDB (latest, unless `--external-db`)
   - Mailpit (latest, unless `--disable-mailpit`)

4. **Starts site-specific Docker containers:**
   - Creates isolated containers with names like `wpstg-sitename-php`, `wpstg-sitename-nginx`, etc.
   - Automatically assigns unique IP and ports
   - Configures container communication

5. **Installs WordPress:**
   - Downloads WordPress core
   - Creates database and user (uses default credentials: admin/123456, or secure random passwords with `--secure-credentials`)
   - Installs WordPress with admin credentials
   - Updates `/etc/hosts` file for local access

**Example usage:**
```bash
# Create a new WordPress site (basic)
wpstaging add mysite.local

# Create with custom configuration
wpstaging add mysite.local \
  --php=8.3 \
  --http-port=8080 \
  --https-port=8443 \
  --db-port=3307

# Create with specific WordPress version
wpstaging add mysite.local --wp=6.4
```

After creating a site, use `wpstaging list` to see all your sites and their ports.

<a name="q25"></a>
**Q25: How can I assign a specific IP to my Docker site?**  
**A25:**
Use `--container-ip=<ipv4>` when creating a site. If you don't specify an IP, the CLI automatically assigns the next available IP from the range **127.3.2.1 - 127.3.2.254**:

- **Linux/Windows:** Automatic IP allocation — loopback IPs are always available, no sudo required
- **macOS:** Automatic IP alias binding enabled by default — requires sudo (passwordless sudo recommended, see [Q87](#q87)). Use `--skip-macos-auto-ip` to disable and bind IPs manually with `ifconfig lo0 alias`

**Important:** When you explicitly specify `--container-ip` with an IP that's already used by another site, the CLI will show an error and suggest the next available IP:
```
Error: The IP address 127.3.2.1 is already in use by 'existingsite.local'.

You can either:
  - Use the next available IP: --container-ip=127.3.2.2
  - Remove the --container-ip flag to auto-assign an available IP
```

Without `--container-ip`, the CLI automatically finds the next available IP without errors.

**Q26: How many sites can I create? What's the maximum limit?**  
**A26:**
The limit depends on how you allocate IPs:

**With unique IPs per site (default behavior):**
- Maximum **254 sites** — limited by our loopback IP range 127.3.2.1 - 127.3.2.254
- Each site gets its own IP automatically:
  - **Linux/Windows:** No sudo required (loopback IPs always available)
  - **macOS:** Automatic IP binding with sudo (passwordless sudo recommended - see [Q87](#q87))
- All sites can use the same ports (e.g., all on port 80/443) since they're on different IPs

**With shared IPs (using `--container-ip` to reuse IPs):**
- **No IP-based limit** — create as many sites as your system resources allow
- Limited by: CPU cores, available RAM, disk space, and available ports
- Each site on the same IP must use different ports (e.g., 8080, 8081, 8082, etc.)
- Practical limit typically 10-50 sites depending on hardware specs

**Example with shared IP:**
```bash
# All sites on same IP, different ports
wpstaging add site1.local --container-ip=127.3.2.1 --https-port=8443
wpstaging add site2.local --container-ip=127.3.2.1 --https-port=8444
wpstaging add site3.local --container-ip=127.3.2.1 --https-port=8445
```

**System resource considerations:**
- **CPU**: 2-4 cores recommended per 10 sites
- **RAM**: ~500MB per site (PHP + MariaDB + Nginx)
- **Disk**: ~1GB per site (WordPress files + database)

<a name="q27"></a>
**Q27: How can I configure PHP version or ports?**  
**A27:**
PHP version and ports can be configured in several ways:

**1. During site creation (using `add` command):**
```bash
wpstaging add mysite.local --php=8.3 --http-port=8080 --https-port=8443
```

**2. Switch PHP version (using `switch-php` command):**
```bash
wpstaging switch-php mysite.local 8.4
```
This updates the configuration, regenerates Docker files, and restarts the containers automatically. Supported PHP versions: 7.4, 8.1, 8.2, 8.3, 8.4.

**3. Switch WordPress version (using `switch-wp` command):**
```bash
wpstaging switch-wp mysite.local 6.5
wpstaging switch-wp mysite.local 6.7-beta1
wpstaging switch-wp mysite.local latest
wpstaging switch-wp mysite.local nightly
```
Supported version formats: `X.Y`, `X.Y.Z`, `X.Y-beta1`, `X.Y-RC1`, `latest`, `nightly`.
This replaces only the WordPress core files while preserving the database, themes, plugins, and uploads. Containers must be running before switching.

**4. Edit the `.env` file manually:**
```bash
# Edit ~/wpstaging/sites/<hostname>/.env
PHP_VERSION=8.3
HTTP_PORT=8080
HTTPS_PORT=8443
```

Then restart the site for changes to take effect:
```bash
wpstaging restart mysite.local
```

**Available flags for `add` command:**
- `--php=<version>` (default: 8.1)
- `--http-port=<port>` (default: 80)
- `--https-port=<port>` (default: 443)

**Note:** Port settings can only be set during initial creation or by editing `.env` manually. PHP version can be changed at any time using the `switch-php` command. WordPress version can be changed using the `switch-wp` command.

<a name="q28"></a>
**Q28: How do I configure MariaDB?**  
**A28:**
You can set `--db-port=<port>` (default `3306`) and `--db-root=<password>` for root password (default `123456`). Database credentials use default values (admin/123456) unless you specify `--secure-credentials` which generates cryptographically secure random passwords. All credentials are stored in the site's `.env` file. You can also use an external database with `--external-db` which disables the MariaDB container.

**Q29: Can I modify or use a custom docker-compose.yml file?**  
**A29:**
The `docker-compose.yml` file is **auto-generated** and recreated when:
- Using the `add` command to create a site
- The `.env` file is modified
- Any ports or IP configuration changes

**Using a custom compose file location:**
Use `--compose-file` to specify a different compose file path. The file **will stay in sync** with wpstaging's workflow as long as you consistently use the same path:

```bash
# Create site with custom compose file
wpstaging add mysite.local --compose-file=/path/to/custom-compose.yml

# Start/restart/stop must use the same path
wpstaging start mysite.local --compose-file=/path/to/custom-compose.yml
wpstaging restart mysite.local --compose-file=/path/to/custom-compose.yml
```

**Better approach - Add to config file:**
To avoid specifying `--compose-file` every time, add it to your config file (e.g., `~/.config/wpstaging/wpstaging.conf` on Linux — see [Q18](#q18) for OS-specific paths):

```ini
--compose-file /path/to/custom-compose.yml
```

Now all commands will automatically use your custom compose file path, and it will stay synchronized with your configuration changes.

**Note:** If you manually edit the compose file outside of wpstaging, those changes will be overwritten when wpstaging regenerates it.

<a name="q30"></a>
**Q30: How do I configure WordPress settings?**  
**A30:**
The `add` command supports various WordPress configuration flags:

**Database settings (for WordPress):**
- `--db-host` - Database host (default: `localhost`)
- `--db-name` - Database name (default: sanitized from hostname, e.g., `example_local`)
- `--db-user` - Database user (default: `user_<dbname>`)
- `--db-pass` - Database password (default: `admin`, or secure random with `--secure-credentials`)
- `--db-prefix` - Table prefix (default: `wp_`)
- `--db-ssl` - Enable SSL connection to database

**Admin settings (for WordPress):**
- `--admin-user` - Admin username (default: `admin`)
- `--admin-pass` - Admin password (default: `admin`, or secure random with `--secure-credentials`)
- `--admin-email` - Admin email (default: `admin@<sitename>`)

**WordPress options:**
- `--wp` - WordPress version to install (default: `latest`). Accepts `X.Y`, `X.Y.Z`, `X.Y-beta1`, `X.Y-RC1`, `latest`, or `nightly`. The actual installed version is stored in `.env` (e.g. `6.7.2`). Use `switch-wp` to change it later without reinstalling.
- `--multisite` - Install as WordPress Multisite (subdirectory mode by default)
- `--subdomains` - Enable subdomain multisite mode (implies `--multisite`). Optional: pass comma-separated hostnames to pre-register, e.g. `--subdomains=blog.mysite.local,shop.mysite.local`

**Note:** When using `--from` with a multisite backup, `--multisite` is auto-detected from the backup. Subdomain mode is also auto-detected from the restored database. You don't need to pass these flags manually.

Example:
```bash
# Subdirectory multisite
wpstaging add mysite.local --multisite

# Subdomain multisite
wpstaging add mysite.local --subdomains

# Subdomain multisite with pre-registered hostnames
wpstaging add mysite.local --subdomains=blog.mysite.local,shop.mysite.local

# Auto-detect from backup (no flags needed)
wpstaging add mysite.local --from=backup.wpstg
```

<a name="q31"></a>
**Q31: How do I disable or re-enable the Mailpit container?**  
**A31:**
Pass `--disable-mailpit` when creating, resetting, or regenerating a site:

```bash
wpstaging add mysite.local --disable-mailpit
wpstaging reset mysite.local --disable-mailpit
wpstaging generate-docker-file mysite.local --disable-mailpit
wpstaging reconfigure mysite.local --disable-mailpit
```

The `DISABLE_MAILPIT=true` setting is saved in the site's `.env` file so future runs keep Mailpit off.

To re-enable Mailpit on a site where it was previously disabled, pass `--disable-mailpit=false`:

```bash
wpstaging reconfigure mysite.local --disable-mailpit=false
wpstaging reset mysite.local --disable-mailpit=false
```

`reconfigure --disable-mailpit=false` updates the configuration and recreates the containers, so the Mailpit container is added back without losing WordPress files or database data. `reset --disable-mailpit=false` does the same after reinstalling WordPress core.

<a name="q32"></a>
**Q32: How do I use secure random passwords?**  
**A32:**
By default, sites use simple default credentials (admin/admin, root password: 123456) for convenience during development. To generate cryptographically secure random passwords, use the `--secure-credentials` flag:
```bash
wpstaging add mysite.local --secure-credentials
```

This will auto-generate:
- Database password (32 characters)
- Database root password (32 characters)
- WordPress admin password (24 characters)

All passwords are stored in the site's `.env` file. You can also manually specify individual passwords:
```bash
wpstaging add mysite.local --admin-pass=MySecurePass123 --db-pass=DbSecurePass456
```

<a name="q33"></a>
**Q33: How do I use an external database?**  
**A33:**
Use the `--external-db` flag along with database connection details to use an external database instead of the containerized MariaDB:
```bash
# Option 1: Specify port in host
wpstaging add mysite.local --external-db \
  --db-host=192.168.1.100:3306 \
  --db-name=wordpress_db \
  --db-user=dbuser \
  --db-pass=dbpass

# Option 2: Specify port separately
wpstaging add mysite.local --external-db \
  --db-host=192.168.1.100 \
  --db-port=3307 \
  --db-name=wordpress_db \
  --db-user=dbuser \
  --db-pass=dbpass
```

**Requirements:**
- Database server must be accessible from the Docker containers
- Database must already exist on the server
- User must have appropriate permissions

The tool will validate the connection during setup. If validation fails, `EXTERNAL_DB` will be removed from the `.env` file and you'll need to fix the connection details before trying again.

**Note:** When using `--external-db`:
- The MariaDB container is not created
- `--db-port` can be used to specify the external database port (default: 3306)
- The `DB_HOST` value is saved to the `.env` file

<a name="q33b"></a>
**Q33b: What database permissions are required for external databases?**  
**A33b:**
When using an external database, the WordPress installation script uses smart detection to determine the best setup approach.

**How It Works:**

The script follows this logic:
1. **First**, it checks if the provided user credentials already work:
   - Can connect to the database server
   - Database exists
   - User has access to the database
   - User has required privileges (CREATE TABLE, DROP TABLE)
2. **If user credentials work** - proceeds directly with WordPress installation (no root needed)
3. **If user credentials don't work** - uses root credentials (if provided) to create database/user
4. **If no root credentials** - falls back to `wp db create` (requires CREATE DATABASE privilege)

**Option 1: Pre-configured Database (Recommended for External DB)**

If your database and user are already set up with proper permissions, you don't need root credentials:

```bash
wpstaging add mysite.local --external-db \
  --db-host=192.168.1.100:3306 \
  --db-name=wordpress_db \
  --db-user=wpuser \
  --db-pass=secure_password
```

The script will verify the credentials work and proceed directly.

**Option 2: With Root Credentials**

If the database or user doesn't exist, provide root credentials to create them:

```bash
wpstaging add mysite.local --external-db \
  --db-host=192.168.1.100:3306 \
  --db-name=wordpress_db \
  --db-user=wpuser \
  --db-pass=userpass \
  --db-root=root_password
```

The script will:
1. Check if user credentials work first (skips root setup if they do)
2. If not, wait for database connection with retry logic (up to 20 seconds)
3. Create the database if it doesn't exist
4. Create the database user and grant privileges
5. Proceed with WordPress installation

**Required Database User Permissions:**

| Privilege | Required | Purpose |
|-----------|----------|---------|
| SELECT | Yes | Read data |
| INSERT | Yes | Add data |
| UPDATE | Yes | Modify data |
| DELETE | Yes | Remove data |
| CREATE | Yes | Create tables |
| DROP | Yes | Drop/reset tables |
| ALTER | Yes | Modify table structure |
| INDEX | Yes | Manage indexes |

**Recommended Setup for External Databases:**

```sql
-- Run on your external database server (as admin)

-- 1. Create the database
CREATE DATABASE wordpress_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2. Create user with full privileges on that database
CREATE USER 'wpuser'@'%' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wpuser'@'%';
FLUSH PRIVILEGES;
```

Then use:
```bash
wpstaging add mysite.local --external-db \
  --db-host=your-db-server:3306 \
  --db-name=wordpress_db \
  --db-user=wpuser \
  --db-pass=secure_password
```

**Common Issues:**

| Error | Cause | Solution |
|-------|-------|----------|
| `Access denied` | Invalid credentials | Verify username/password |
| `Unknown database` | Database doesn't exist | Pre-create the database or use `--db-root` |
| `CREATE command denied` | Missing privilege | Grant CREATE privilege or pre-create DB |
| `Connection refused` | Network/firewall issue | Ensure DB is accessible from Docker network |

**Q34: How do I connect to SSL-enabled external databases?**  
**A34:**
The CLI automatically handles SSL-enabled external databases with certificate verification disabled for development environments. If your external database has SSL enabled:

```bash
# SSL is handled automatically - no additional flags needed
wpstaging add mysite.local --external-db \
  --db-host=192.168.1.100:3306 \
  --db-name=wordpress_db \
  --db-user=dbuser \
  --db-pass=dbpass
```

**Optional:** Use `--db-ssl` flag to explicitly enable SSL in WordPress configuration:
```bash
wpstaging add mysite.local --external-db \
  --db-host=192.168.1.100:3306 \
  --db-name=wordpress_db \
  --db-user=dbuser \
  --db-pass=dbpass \
  --db-ssl
```

**What happens automatically:**
- MySQL/MariaDB CLI commands use `--ssl-verify-server-cert=0` to skip certificate verification
- WP-CLI database commands work transparently through wrapper scripts
- WordPress database connections use `MYSQLI_CLIENT_SSL_DONT_VERIFY_SERVER_CERT` when `--db-ssl` is specified

**Technical Details:**
The CLI creates wrapper scripts for `mysql`, `mariadb`, and `mysqldump` commands in `~/.wp-cli/bin/` that automatically add SSL flags. These wrappers:
- Skip certificate verification (appropriate for development/testing)
- Filter out unsupported `--no-defaults` flag
- Work transparently with WP-CLI database operations

For production environments requiring proper certificate validation, configure the database server with trusted certificates and provide the CA certificate to WordPress.

**Q35: Can I switch from external database to internal database?**  
**A35:**
Yes, but you must use the `reset` command to properly reconfigure the site. Simply changing `EXTERNAL_DB=false` in the `.env` file will not work.

**Why the restriction?**
When you switch from external to internal database:
- The MariaDB container needs to be created in `docker-compose.yml`
- A new database needs to be initialized
- WordPress needs to be reinstalled with the new database

**How to switch:**
```bash
# 1. Stop the site
wpstaging stop mysite.local

# 2. Edit the .env file to remove or change EXTERNAL_DB
nano /path/to/sites/mysite.local/.env
# Remove the line: EXTERNAL_DB=true
# Or change it to: EXTERNAL_DB=false

# 3. Run reset to reconfigure and reinstall
wpstaging reset mysite.local
```

**Note:** The `reset` command will reinstall WordPress and erase all site data. If the site was multisite, `reset` preserves the multisite setting from the `.env` file. If you have a backup, you can reset and restore in one step:
```bash
wpstaging reset mysite.local --from=backup.wpstg
```

**What happens if I try to start without reset?**
The CLI will detect the mismatch and show an error:
```
MariaDB container not found in docker-compose.yml for mysite.local.
This site was configured with --external-db previously.
To create the database and reinstall WordPress, run:
  wpstaging reset mysite.local
```

This protection prevents you from starting a site with a broken database configuration.

## Debugging & Misc

<a name="q36"></a>
**Q36: How do I enable debug messages?**  
**A36:**
Use `-d` or `--debug`.

<a name="q37"></a>
**Q37: Can I suppress output?**  
**A37:**
Yes, use `-q` or `--quiet`.

<a name="q38"></a>
**Q38: How do I verify the integrity of extracted files?**  
**A38:**
Use the `--verify` flag.

<a name="q39"></a>
**Q39: How do I enable debug messages?**  
**A39:**
Use `-d` or `--debug`.

<a name="q40"></a>
**Q40: Can I suppress output?**  
**A40:**
Yes, use `-q` or `--quiet`.

<a name="q41"></a>
**Q41: How do I verify the integrity of extracted files?**  
**A41:**
Use the `--verify` flag.

<a name="q42"></a>
**Q42: How can I test what the CLI extracts from docker-compose.yml?**  
**A42:**
Use the `compose-info` command to display all data parsed from the compose file:

```bash
wpstaging compose-info
```

This command is useful for debugging and verifying what configuration values the CLI tool extracts from your `docker-compose.yml`. It displays data in an alphabetically sorted, formatted output:

```
CONTAINER_IP  : 172.20.0.1
EXTRA_HOST    : aaa.local=127.5.6.8
EXTRA_HOST_2  : wp-staging.local=127.5.6.8
EXTRA_HOST_3  : xdebug.host=127.5.6.8
MARIADB_PORT  : 3306
NGINX_PORT    : 80
NGINX_PORT_2  : 443
PHP_VERSION   : 8.2
```

The extracted data includes:
- **PHP_VERSION** - PHP version from the image tag
- **CONTAINER_IP** - Host IP for port mappings
- **NGINX_PORT**, **NGINX_PORT_2** - HTTP and HTTPS ports
- **MARIADB_PORT** - Database port
- **MAILPIT_PORT** - Mailpit HTTP port
- **EXTRA_HOST**, **EXTRA_HOST_2**, etc. - Extra hosts entries

This is particularly helpful when troubleshooting port conflicts or verifying custom configurations.

<a name="q43"></a>
**Q43: I get "port already in use" error when using the Docker environment. What should I do?**  
**A43:**
The CLI now has **automatic port conflict detection and resolution**! The tool automatically detects port conflicts and tries alternative ports.

### Automatic Port Resolution

When you run `add` or `start` commands, the CLI automatically:

1. **Checks if ports are available** — including ports claimed by other wpstg sites, ports used by non-wpstg Docker containers (see [Q101c](#q101c)), and OS-level port checks
2. **Tries predefined fallback ports** if the default is in use
3. **Generates random ports** if all fallbacks are occupied
4. **Notifies you** of the port changes

**Default ports and their fallback ranges:**

| Service | Default | Fallback Ports | Count | Random Range |
|---------|---------|----------------|-------|--------------|
| HTTP (Nginx) | 80 | 8844, 8845, 8846, 8855, 8866, 8888, 8899, 8877, 8878, 8879, 8889 | 10 | 49152-65535 |
| HTTPS (Nginx) | 443 | 4444, 4445, 4446, 4455, 4466, 4488, 4499, 4456, 4467, 4468, 4477 | 10 | 49152-65535 |
| MariaDB | 3306 | 3344, 3345, 3346, 3355, 3366, 3388, 3399, 3356, 3357, 3358, 3359, 3360, 3370 | 10 | 49152-65535 |
| Mailpit | 8025 | 8044, 8045, 8046, 8055, 8066, 8088, 8099, 8056, 8067, 8077 | 10 | 49152-65535 |

**Example output when port is in use:**
```
HTTPS port 443 is already in use. Automatically switching to port 4444.
```

### Manual Port Configuration

You can specify custom ports when creating a new site using the `add` command. Each site has its own configuration, so you can customize ports per site.

**For NGINX (HTTP/HTTPS):**
```bash
wpstaging add mysite.local --http-port=8080 --https-port=8443
```

**For MariaDB:**
```bash
wpstaging add mysite.local --db-port=3307
```

**For Mailpit:**
```bash
wpstaging add mysite.local --mailpit-http-port=8026
```

**Change container IP:**
```bash
wpstaging add mysite.local --container-ip=127.3.2.5
```

**Configure all ports at once:**
```bash
wpstaging add mysite.local \
  --http-port=8080 --https-port=8443 \
  --db-port=3307 --mailpit-http-port=8026
```

**Note:** Each site maintains its own configuration in its `.env` file, so different sites can use different ports and settings.

### Checking Port Usage

**Check which process is using a port:**
- Linux/macOS: `sudo lsof -i :80` or `sudo netstat -tulpn | grep :80`
- Windows: `netstat -ano | findstr :80`

### Disabling Services

**Alternative solution - Disable unused services:**
```bash
# If you're using an external database (disables MariaDB container)
wpstaging add mysite.local --external-db --db-host=your-db-host --db-name=your-db --db-user=your-user --db-pass=your-pass

# If you don't need Mailpit
wpstaging add mysite.local --disable-mailpit
```

When services are disabled, their port validation is automatically skipped.

## Command-Specific Flags Questions

<a name="q44"></a>
**Q44: Why can't I use `--site-url` with the root command?**  
**A44:**
Flags like `--site-url`, `--db-prefix`, `--normalizedb`, and `--verify` are command-specific. You must use them with their respective commands:
- `--site-url` and `--db-prefix` work with both `extract` and `restore`
- `--normalizedb` only works with `extract`
- Use: `wpstaging extract --site-url=https://example.com backup.wpstg`
- Not: `wpstaging --site-url=https://example.com extract backup.wpstg`

<a name="q45"></a>
**Q45: What flags are available globally vs command-specific?**  
**A45:**
**Global flags** (work with all commands):
- `--working-dir`, `--debug`, `--quiet`, `--yes`, `--allow-root`, `--json`, `--page`, `--page-size`, `--verbose`

**Extract-specific flags**:
- `--normalizedb`, `--overwrite`, `--site-url`, `--db-prefix`, `--verify`

**Restore-specific flags**:
- `--path`, `--site-url`, `--db-prefix`, `--verify`, `--skip-extract`, `--overwrite`, `--overwrite-db`, `--overwrite-wproot`, all `--db-*` flags

**Docker-specific flags**:
- `--env-path`, `--compose-file`, `--container-ip`, `--php`, `--http-port`, `--https-port`, `--wp-site-url`, etc.

**Q46: Are there short aliases for common flags?**  
**A46:**
Yes, several flags have convenient aliases:

**Environment Path:**
- `--env-path` (or `--dockerize-path` as hidden alias)

**Container IP:**
- `--container-ip` or `--ip` (both work the same)

**Output Directory (for dump commands):**
- All dump commands (`dump-header`, `dump-metadata`, `dump-index`) now support `--outputdir` flag

**Example:**
```bash
# These are equivalent
wpstaging add site.local --env-path=/custom/path --container-ip=127.3.2.5
wpstaging add site.local --env-path=/custom/path --ip=127.3.2.5

# Dump commands with output directory
wpstaging dump-header backup.wpstg --outputdir=/tmp/output
```

## License & Authentication Questions

<a name="q47"></a>
**Q47: When does license validation occur?**  
**A47:**
License validation happens automatically when you run any backup-related or Docker command (extract, restore, dump-*, add, etc.). Commands like `help`, `register`, `clean`, `status`, and `list` skip license validation for faster access.

<a name="q48"></a>
**Q48: Do I need a license to view help messages?**  
**A48:**
No. Running `wpstaging --help` or `wpstaging extract --help` does not require license validation. You only need a valid license when executing actual operations.

<a name="q49"></a>
**Q49: How is my license stored and validated?**  
**A49:**
After you register your license using `wpstaging register`, the key is encrypted and stored locally. The CLI automatically validates your license when running backup-related or Docker commands, and caches the validation results for 4 hours to minimize API calls.

<a name="q49a"></a>
**Q49a: What happens when my license expires?**  
**A49a:**
When your license expires, the CLI displays your license information (licensee name and expiration date) and exits with an error message. The license key is preserved (not deleted) so you can see who the license belongs to and when it expired.

**Example output:**
```
WP Staging CLI
Licensed to John Doe
Valid through 27.02.2026 | Expired - Extend License https://wp-staging.com/

Error: License expired - Extend License https://wp-staging.com/
```

**To resolve:** Extend your license at https://wp-staging.com/your-account. Once renewed, the CLI will work automatically on the next command.

## Troubleshooting Questions

<a name="q50"></a>
**Q50: I get "Error: Backup file does not exist" but the file is there. Why?**  
**A50:**
Make sure you're providing the correct path to the `.wpstg` file. Use absolute paths if running from a different directory:
```bash
wpstaging extract /full/path/to/backup.wpstg
```

<a name="q51"></a>
**Q51: Can I run multiple extraction/restore operations simultaneously?**  
**A51:**
No. The CLI uses file-based locking to prevent concurrent operations on the same backup file. If you need parallel operations, use different backup files.

<a name="q52"></a>
**Q52: What does "This application cannot be run as root" mean?**  
**A52:**
On **Linux/macOS**, the CLI blocks root execution by default as a security best practice.

**Note:** This check does **not** apply to Windows. Windows users can run elevated (Administrator) without issues because Windows uses a different permission model (ACLs vs Unix uid/gid).

**Why running as root creates issues on Linux/macOS:**

1. **File Ownership:**
   - Extracted files will be owned by root (UID 0)
   - Web server (www-data, nginx, apache) cannot read/write these files
   - WordPress will not function properly
   - Requires manual permission fixes: `chown -R www-data:www-data /path`

2. **System Protection:**
   - Reduces risk of accidental modifications to system directories
   - Follows the principle of least privilege
   - Standard approach for CLI tools performing file operations

**If you must use --allow-root (Linux/macOS only):**
```bash
# Only in Docker containers or isolated environments
sudo wpstaging extract --allow-root backup.wpstg

# Fix ownership immediately after
sudo chown -R www-data:www-data ./wpstaging-output
```

<a name="q53"></a>
**Q53: I get "Error: Failed to open the backup file" on Windows. Help?**  
**A53:**
Ensure:
1. The file path doesn't contain special characters
2. You have read permissions on the file
3. The file isn't locked by another program
4. Use quotes around paths with spaces: `wpstaging extract "C:\My Backups\backup.wpstg"`

## Performance Questions

<a name="q54"></a>
**Q54: How can I speed up extraction?**  
**A54:**
- Use fast storage (SSD/NVMe) for both source and destination
- Skip unnecessary parts with `--skip-*` flags
- Disable verification (`--verify` adds overhead)
- Run on systems with good I/O performance

<a name="q55"></a>
**Q55: Does the CLI support multi-threading?**  
**A55:**
The CLI is optimized for single-threaded sequential extraction with efficient streaming. Multi-threading isn't needed as disk I/O is typically the bottleneck.

<a name="q56"></a>
**Q56: How much memory does the CLI require?**  
**A56:**
Memory usage is minimal (typically <100MB) even for large backups because the CLI uses streaming extraction rather than loading entire files into memory.

## SSL Certificate and Browser Trust Questions

<a name="q57"></a>
**Q57: Why does my browser show "Your connection is not private" or "Not Secure" warnings?**  
**A57:**
This warning appears when your browser does not trust the SSL certificate used by your local site. The most common cause is that the WP Staging CLI Certificate Authority (CA) has not been installed in your system trust store.

**How to fix this:**

1. **Let the tool install it automatically (recommended):**
   ```bash
   wpstaging add mysite.local
   ```
   When you create a site, the tool prompts you to install the CA. Choose "Yes". This is a one-time operation and covers all future sites.

2. **If you skipped the prompt, reinstall the CA:**
   ```bash
   wpstaging reinstall-ca
   ```
   This generates a fresh CA, installs it to your system trust store, and re-signs all site certificates.

3. **Manual bypass (not recommended):**
   Click "Advanced" → "Proceed to site" in your browser. This only works for the current session.

<a name="q58"></a>
**Q58: How does WP Staging CLI manage SSL certificates?**  
**A58:**
WP Staging CLI generates and manages SSL certificates using built-in Go code. No external tool is downloaded or required.

**How it works:**
- Generates a root Certificate Authority (CA) on your computer
- Installs the CA to your system trust store so browsers trust it
- Issues a per-site TLS certificate for each local site you create
- CA and certificates are stored in `~/wpstaging/stack/localcert/`

**Why not self-signed certificates?**

Self-signed certificates require a manual browser bypass for every site and break some browser features. A local CA solves this:
- Automatically trusted by all major browsers after a one-time install
- No browser warnings -- green padlock icon
- Identical HTTPS behavior to production
- Service Workers, PWA features, and secure cookies work as expected

<a name="q59"></a>
**Q59: Why not just use HTTP instead of HTTPS for local development?**  
**A59:**
While HTTP is simpler, using HTTPS for local development is strongly recommended for several important reasons:

**1. Production Parity:**
- Most production WordPress sites use HTTPS (required for SEO, security, trust)
- Developing with HTTP can hide HTTPS-related bugs that only appear in production
- Mixed content issues (HTTP resources on HTTPS pages) won't be caught during development

**2. Modern Browser Features Require HTTPS:**
- Service Workers (Progressive Web Apps, offline functionality)
- Web Push Notifications
- Geolocation API (in some browsers)
- Camera/Microphone access (getUserMedia API)
- Payment Request API
- Clipboard API
- HTTP/2 and HTTP/3 protocols
- Some third-party APIs only work over HTTPS

**3. WordPress-Specific Issues:**
- WordPress admin over HTTPS prevents cookie hijacking
- Many WordPress plugins require HTTPS for certain features
- WooCommerce and payment gateways require HTTPS
- WordPress recommends HTTPS for login pages to protect credentials

**4. Cookie Security:**
- Secure cookies (Secure flag) only work over HTTPS
- SameSite cookie attributes behave differently over HTTP
- Session hijacking is easier over HTTP

**5. Developer Tools and Testing:**
- Some browser DevTools features only work over HTTPS
- Can't properly test HTTPS redirects and headers over HTTP
- Performance testing differs (HTTP/2, TLS overhead)

**Using mkcert solves all these issues while keeping local development simple and warning-free.**

<a name="q60"></a>
**Q60: Why does CA installation require sudo (Linux/macOS) or a confirmation prompt (Windows)?**  
**A60:**
Installing a Certificate Authority (CA) to the trust store is a security-sensitive operation. Linux and macOS require elevated privileges (sudo or administrator password); Windows shows a built-in security confirmation dialog before adding the CA to the current user's Trusted Root store, but no administrator elevation is needed.

**What the installation does:**
1. **Creates a root CA certificate** in `~/wpstaging/stack/localcert/ca/`
2. **Installs the CA to trust stores:**
   - **Linux:** distro anchor directory (requires sudo), then Chrome/Firefox NSS databases (no sudo)
   - **macOS:** System Keychain (requires admin password)
   - **Windows:** current-user Trusted Root store (Windows shows a confirmation dialog; no administrator required)

**Why this approval is required:**
- The trust store decides which certificates your browser accepts as authentic
- Adding a CA grants it the ability to sign certificates that look valid to your browser
- Security measure to prevent rogue software from installing untrusted CAs
- One-time operation -- subsequent certificate generation does not need another approval

**What if I skip the sudo installation?**
- The CA files are still created locally
- SSL certificates are generated and used by Nginx
- Your browser will not trust them and will show warnings
- Run `wpstaging reinstall-ca` at any time to install the CA

**Security note:** The CA is stored locally and never leaves your computer. It is only used to sign certificates for your local development sites.

<a name="q61"></a>
**Q61: Does the CA installation affect my system security?**  
**A61:**
The CA is designed specifically for local development and is safe to install. Here's what you should know:

**Security design:**
- ✅ CA private key is stored locally only (`~/wpstaging/stack/localcert/ca/rootCA-key.pem`)
- ✅ Never transmitted over network
- ✅ Only used for local development sites
- ✅ Cannot be used to intercept real websites (different domains)
- ✅ Standard practice used by thousands of developers worldwide

**Best practices:**
- Keep the CA private key secure (don't share or commit to git)
- Only install CAs you created yourself
- Uninstall the CA when you stop using local development (optional)
- The CLI stores CA in project directory for isolation

**To remove Docker environment (if needed):**
1. Stop and remove Docker environment:
   ```bash
   wpstaging remove
   ```
2. Remove the CA from your system trust store (optional). The simplest way is:
   ```bash
   wpstaging sweep-ca-trust --include-legacy
   ```
   This removes both current `WP Staging CLI development CA` entries and any legacy `mkcert development CA` entries left by older builds. See [Q120](#q120).

   To remove manually, look for `WP Staging CLI development CA` in:
   - Linux: `/usr/local/share/ca-certificates/` (system) and `~/.pki/nssdb/` (Chrome)
   - macOS: Keychain Access (search "WP Staging CLI")
   - Windows: Certificate Manager, under Trusted Root Certification Authorities (search "WP Staging CLI")

<a name="q62"></a>
**Q62: What happens when I'm asked about security certificate installation?**  
**A62:**
When you create your first WordPress site with the `add` command, you'll see a prompt like this:

```
════════════════════════════════════════════════════════════════════════════════
The next action will install a security certificate to your system.
This allows your browser to trust the SSL certificates created by this tool.

Sudo permission is required.
════════════════════════════════════════════════════════════════════════════════
Continue to install? [y/N]:
```

**If you choose "Yes" (recommended):**
1. You'll be prompted for your sudo/admin password (one-time)
2. The tool installs the `WP Staging CLI development CA` to your system trust store
3. Platform-specific browser coverage:
   - **Linux:** Also installs into Chromium and Firefox NSS databases
   - **macOS:** System Keychain covers Safari and Chrome
   - **Windows:** Trusted Root Certification Authorities covers all major browsers
4. All current and future local sites will be automatically trusted
5. You'll see green padlock in browser - no warnings
6. This is a one-time operation - you won't be prompted again

**If you choose "No" or skip:**
1. The tool creates local CA files anyway (for certificate generation)
2. SSL certificates are generated and used by Nginx
3. Your browser will show "Not Secure" warnings
4. You'll need to manually bypass warnings with "Advanced → Proceed to site"
5. You can create another site later and install the CA when prompted again

**Important:** This prompt only appears once. If the CA is already installed in your system trust store (detected via X.509 verification), the prompt is skipped automatically.

**Note:** On systems with cached sudo credentials or passwordless sudo (NOPASSWD), neither the `Sudo permission is required.` line nor the password prompt appears.

<a name="q63"></a>
**Q63: My browser still shows warnings after installing the CA. What's wrong?**  
**A63:**
If you're still seeing warnings after confirming CA installation, try these troubleshooting steps:

**1. Verify CA is actually installed:**
- **Linux:** `ls /usr/local/share/ca-certificates/ | grep -i 'WP_Staging_CLI'` (should show the CA file)
- **macOS:** Open Keychain Access, search for "WP Staging CLI" (should appear in System keychain)
- **Windows:** Open certmgr.msc, check "Trusted Root Certification Authorities"

**2. For Chrome/Chromium on Linux specifically:**
The CA must be installed to both the system trust store AND the NSS database. The CLI does this automatically, but you can verify:
```bash
certutil -d sql:$HOME/.pki/nssdb -L | grep -E 'mkcert development CA|WP Staging CLI'
```

If missing, the CLI should have installed it, but you can manually add:
```bash
certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n "WP Staging CLI CA" -i ~/wpstaging/stack/localcert/ca/rootCA.pem
```

Manually added entries are not tracked by `wpstaging sweep-ca-trust`; remove them with `certutil -D -d sql:$HOME/.pki/nssdb -n "WP Staging CLI CA"` if you ever need to clean up.

**3. Restart your browser:**
After CA installation, close and reopen your browser completely (not just the tab).

**4. Check certificate details in browser:**
- Click the "Not Secure" warning in address bar
- View certificate details
- Verify the certificate includes your site's hostname and the container IP

**5. Verify certificate was generated:**
```bash
ls ~/wpstaging/sites/yoursite.local/docker/nginx/certs/
```
Should show `yoursite.local.crt` and `yoursite.local.key` (not self-signed.crt).

**6. Recreate the site to regenerate everything:**
```bash
wpstaging del yoursite.local
wpstaging add yoursite.local
```

**7. Clear browser SSL cache:**
- **Chrome:** Go to `chrome://settings/security` → "Manage certificates" → Clear SSL state
- **Firefox:** Settings → Privacy & Security → Certificates → View Certificates → Servers → Delete cached certificates

<a name="q64"></a>
**Q64: Can I use my own SSL certificates instead of mkcert?**  
**A64:**
Yes, but it's not recommended for local development. If you still want to use custom certificates:

**Option 1: Replace generated certificates**
After creating a site, replace the certificate files:
```bash
cp your-cert.crt ~/wpstaging/sites/yoursite.local/config/nginx/certs/yoursite.local.crt
cp your-key.key ~/wpstaging/sites/yoursite.local/config/nginx/certs/yoursite.local.key
wpstaging restart yoursite.local
```

**Option 2: Disable mkcert (use self-signed fallback)**
If mkcert download or CA installation fails, the CLI automatically falls back to self-signed certificates. You'll see browser warnings but the site will still work.

**Why mkcert is better:**
- No manual certificate generation or management
- Automatic trust - no browser warnings
- Per-site certificates with proper SANs (hostname + IPs)
- Works across all browsers without configuration

## Advanced Docker Questions

<a name="q65"></a>
**Q65: Can I use external databases with the Docker environment?**  
**A65:**
Yes, use `--external-db` flag to disable the MariaDB container and connect to your external database:
```bash
wpstaging add mysite.local --external-db \
  --db-host=external-db.example.com \
  --db-name=mydb --db-user=user --db-pass=pass
```

This disables the local MariaDB container and configures WordPress to use your external database server.

<a name="q66"></a>
**Q66: How do I manage multiple WordPress sites in Docker?**  
**A66:**
Use the site management commands:
```bash
# Add new sites (one at a time)
wpstaging add site1.local
wpstaging add site2.local

# List sites
wpstaging list                           # List all sites
wpstaging list site1.local               # Show details for one site
wpstaging list site1.local site2.local   # Show details for multiple sites

# Check status
wpstaging status                           # Show all sites status
wpstaging status site1.local site2.local   # Show status for specific sites

# Manage individual sites
wpstaging stop site1.local
wpstaging start site1.local
wpstaging shell site1.local

# Delete sites
wpstaging del site1.local                  # Delete one site
wpstaging del site1.local site2.local      # Delete multiple sites
wpstaging del                              # Delete all sites (with confirmation)

# Manage all sites at once
wpstaging start          # Start all sites
wpstaging stop           # Stop all sites
wpstaging restart        # Restart all sites
```

Each site runs in its own isolated set of containers with unique IPs and ports.

<a name="q66b"></a>
**Q66b: Why can't I add multiple sites at once with the `add` command?**  
**A66b:**
The `add` command only accepts one site URL at a time because each site requires unique configuration:

- Different container IP (auto-assigned from 127.3.2.1-254 range)
- Different database credentials (especially with `--secure-credentials`)
- Different ports (if conflicts exist)
- Site-specific SSL certificates

**To add multiple sites quickly, use a loop:**
```bash
# Bash (Linux/macOS)
for site in site1.local site2.local site3.local; do
  wpstaging add $site --yes
done

# PowerShell (Windows)
@("site1.local", "site2.local", "site3.local") | ForEach-Object {
  wpstaging add $_ --yes
}
```

**Note:** The `--yes` flag auto-confirms prompts for unattended operation.

<a name="q67"></a>
**Q67: How can I check the status of my sites?**  
**A67:**
There are two commands for checking site status:

**1. The `list` command** shows site configuration details:

```bash
# List all sites with status
wpstaging list

# Check specific site
wpstaging list mysite.local
```

**List Status Information:**
- **Enabled - Running**: Site is configured and containers are running
- **Enabled - Stopped**: Site is configured but containers are stopped
- **Disabled - Stopped**: Site has been disabled (use `enable` to re-enable)
- **Missing root path**: Site directory is missing
- **Missing compose file**: docker-compose.yml file is missing

**Example `list` Output:**
```
Host   : mysite.local
URL    : https://mysite.local
Path   : ~/wpstaging/sites/mysite.local/www/mysite.local
Status : Enabled - Running

Total: 3, Running: 2, Stopped: 1
```

**2. The `status` command** shows container-level details:

```bash
# Show all containers
wpstaging status

# Check specific site containers
wpstaging status mysite.local
```

**Status Output Format:**
The output is organized into three sections with separators:
1. **Active** - Currently running containers
2. **Stopped** - Containers stopped with `stop` command (can be started again)
3. **Disabled** - Containers disabled with `disable` command (need `enable` first)

**Example `status` Output:**
```
CONTAINER                   STATUS                   PORTS
-----------------------------------------------------------------------------------
wpstg-site1-local-nginx     Up 5 minutes             127.3.2.1:80->80/tcp, 127.3.2.1:443->443/tcp
wpstg-site1-local-php       Up 5 minutes             9000/tcp
wpstg-site1-local-mariadb   Up 5 minutes             127.3.2.1:3306->3306/tcp
wpstg-site1-local-mailpit   Up 5 minutes (healthy)   1025/tcp, 1110/tcp, 127.3.2.1:8025->8025/tcp
-----------------------------------------------------------------------------------
wpstg-site2-local-nginx     Stopped                  127.3.2.2:80->80/tcp, 127.3.2.2:443->443/tcp
wpstg-site2-local-php       Stopped                  9000/tcp
wpstg-site2-local-mariadb   Stopped                  127.3.2.2:3306->3306/tcp
wpstg-site2-local-mailpit   Stopped                  1025/tcp, 1110/tcp, 127.3.2.2:8025->8025/tcp
-----------------------------------------------------------------------------------
wpstg-site3-local-nginx     Disabled                 127.3.2.3:80->80/tcp, 127.3.2.3:443->443/tcp
wpstg-site3-local-php       Disabled                 9000/tcp
wpstg-site3-local-mariadb   Disabled                 127.3.2.3:3306->3306/tcp
wpstg-site3-local-mailpit   Disabled                 1025/tcp, 1110/tcp, 127.3.2.3:8025->8025/tcp
```

<a name="q68"></a>
**Q68: Can I change a site's configuration after creation?**  
**A68:**
Configuration is stored in each site's `.env` file. To change configuration:

1. **Stop the site:**
   ```bash
   wpstaging stop mysite.local
   ```

2. **Edit the .env file:**
   ```bash
   nano ~/wpstaging/sites/mysite.local/.env
   ```

3. **Start the site to apply changes:**
   ```bash
   wpstaging start mysite.local
   ```

Alternatively, delete and recreate the site with new configuration:
```bash
wpstaging del mysite.local
wpstaging add mysite.local --http-port=8080 --https-port=8443
```

<a name="q69"></a>
**Q69: Where are Docker logs stored?**  
**A69:**
Docker container logs are accessible via `docker logs`. The CLI stores configuration files in `~/wpstaging/` by default (or your custom `--env-path`).

<a name="q70"></a>
**Q70: How does the per-site container architecture work?**  
**A70:**
The CLI uses a per-site container architecture where each WordPress site runs in its own isolated set of containers. This means:

**Key Features:**
- Each site gets its own containers: `wpstg-sitename-php`, `wpstg-sitename-nginx`, `wpstg-sitename-mariadb`, `wpstg-sitename-mailpit`
- Automatic IP allocation from reserved range (127.3.2.1 - 127.3.2.254) on Linux/Windows
- Automatic port assignment to avoid conflicts (all platforms)
- Per-site .env configuration file stores all settings
- No interference between sites - they run completely independently

**Example:**
```bash
# First site gets 127.3.2.1 with ports 8080, 8443, 3306, 8025
wpstaging add site1.local

# Second site gets 127.3.2.2 with ports 8081, 8444, 3307, 8026
wpstaging add site2.local

# List all running sites
wpstaging list
```

**Benefits:**
- Run multiple sites simultaneously without conflicts
- Each site has isolated database, PHP version, and configuration
- Start/stop/delete sites independently
- Configuration is preserved in `.env` files across restarts

<a name="q71"></a>
**Q71: How does automatic IP allocation work (Linux/Windows)?**  
**A71:**
On Linux and Windows, the CLI automatically manages IP addresses from a reserved loopback range:

**How it works:**
1. When you add a site without specifying `--container-ip`, the CLI automatically assigns the next available IP from range 127.3.2.1-254
2. The assigned IP is saved in the site's `.env` file
3. On restart, the site reuses its saved IP
4. If the saved IP is in use by another container, the CLI automatically finds the next available IP

**Example:**
```bash
# First site - automatically assigned 127.3.2.1
wpstaging add site1.local
# Saved in ~/wpstaging/sites/site1.local/.env

# Second site - automatically assigned 127.3.2.2
wpstaging add site2.local

# Restart site1 - reuses 127.3.2.1 from .env
wpstaging start site1.local
```

**Why this matters:**
- No manual IP configuration needed
- No IP conflicts between sites
- Each site can use same port numbers (e.g., both use port 8080) because they're on different IPs
- Configuration persists across restarts

<a name="q72"></a>
**Q72: How does IP allocation work on macOS?**  
**A72:**
On macOS, **automatic IP alias binding is enabled by default**. The CLI automatically assigns each site a unique IP from the loopback range **127.3.2.1 - 127.3.2.254** and binds it for you (requires sudo). This allows multiple sites to use the same port numbers (like 80/443) on different IPs without conflicts.

**Default behavior (automatic IP binding enabled):**
```bash
# First site - automatically assigned 127.3.2.1
wpstaging add site1.local

# Second site - automatically assigned 127.3.2.2
wpstaging add site2.local

# Both sites can use the same ports (e.g., 80/443) on different IPs
# Requires sudo for IP binding (prompted automatically)
```

**How it works:**
1. On first `add`, the CLI installs a macOS LaunchDaemon that reads site configurations and creates loopback aliases only for existing sites at boot
2. Only one sudo prompt is needed for installation
3. Aliases persist across reboots automatically
4. The daemon is removed when you run `wpstaging remove`

**Fallback:** If daemon installation fails, the CLI falls back to creating a single IP alias for the current site (as before).

**Passwordless sudo (recommended for macOS):**
On macOS, the LaunchDaemon install requires one sudo prompt. To avoid the prompt, see [Q87](#q87) for passwordless sudo setup.

**Summary:** On macOS, a LaunchDaemon reads site configurations and creates loopback aliases only for existing sites at boot. One-time sudo on first `add`, aliases survive reboots. Linux/Windows don't need this because loopback IPs are always available. Use `--skip-macos-auto-ip` on macOS to skip daemon installation.

**Q73: How can I disable automatic IP alias binding on macOS?**  
**A73:**
Automatic IP alias binding from the loopback range **127.3.2.1 - 127.3.2.254** is enabled by default on macOS (Linux/Windows don't need this since loopback IPs are always available). If you prefer manual IP alias binding without sudo requirements, use the `--skip-macos-auto-ip` flag:

```bash
# Disable automatic IP alias binding on macOS (manual ifconfig lo0 alias required)
wpstaging add site1.local --skip-macos-auto-ip

# Then manually bind each IP as needed (one-time per boot, requires password)
sudo ifconfig lo0 alias 127.3.2.1 netmask 255.255.255.255
sudo ifconfig lo0 alias 127.3.2.2 netmask 255.255.255.255
# ... and so on for each site
```

**Note:** With automatic IP binding enabled (default), passwordless sudo is highly recommended for the best experience. See [Q87](#q87) for setup instructions.

## Database Operations Questions

<a name="q74"></a>
**Q74: What does `--normalizedb` actually do?**  
**A74:**
It replaces WP Staging placeholders in the database SQL file with actual values:
- `{WPSTG_TMP_PREFIX}` → temporary table prefix
- `{WPSTG_FINAL_PREFIX}` → final table prefix
- `{WPSTG_NULL}` → SQL NULL
- This is required before manually importing the database to MySQL.

<a name="q74a"></a>
**Q74a: Can I restore a multisite backup to a single-site WordPress?**  
**A74a:**
A full multisite network backup (`multi`) cannot be restored to a single-site WordPress. The restore command will stop with an error. Network subsite and main-site backups can be restored to a single-site.

<a name="q74b"></a>
**Q74b: How do I set up subdomain multisite?**  
**A74b:**
Use the `--subdomains` flag when creating a site. This configures WordPress for subdomain mode, sets up wildcard SSL certificates, and adds wildcard nginx routing.

```bash
# Basic subdomain multisite
wpstaging add mysite.local --subdomains

# With pre-registered subsite hostnames (both forms are equivalent)
wpstaging add mysite.local --subdomains=blog.mysite.local
wpstaging add mysite.local --subdomains blog.mysite.local
```

The `--subdomains` flag automatically enables `--multisite`. You don't need to pass both.

When hostnames are provided, the CLI auto-creates WordPress subsites:
- **Subdomains** (e.g., `blog.mysite.local`) are created via `wp site create --slug=blog`
- **Custom domains** (e.g., `custom.local`) are created with native domain mapping on WordPress 4.5+. On older WordPress versions, custom domains are skipped.

Custom domains automatically install `sunrise.php` so that login and cookies work correctly on the custom domain.

You can also add more subsites later in the WordPress admin under Network Admin > Sites. Then run `update-subdomains` to sync the new hostnames:

```bash
wpstaging update-subdomains mysite.local
```

<a name="q74c"></a>
**Q74c: What does `update-subdomains` do?**  
**A74c:**
The `update-subdomains` command (alias: `usub`) queries WordPress for all subsites and updates the local environment:

1. Runs `wp site list` inside the container to discover all subsite domains
2. Regenerates the nginx config with the discovered hostnames in `server_name`
3. Regenerates the SSL certificate to cover all discovered hostnames
4. Updates the docker-compose file with DNS aliases for cross-site communication
5. Restarts containers to apply the changes
6. Updates `/etc/hosts` with entries for each subsite

```bash
wpstaging update-subdomains mysite.local
```

Run this command after creating, removing, or modifying subsites in WordPress admin.

<a name="q74d"></a>
**Q74d: Is subdomain multisite auto-detected from backups?**  
**A74d:**
Yes. When restoring a multisite backup with `--from`, the CLI auto-detects both multisite mode and subdomain mode from the restored database. It then discovers all subsites and configures nginx, SSL, and `/etc/hosts` automatically. No flags needed:

```bash
wpstaging add mysite.local --from=backup.wpstg
```

<a name="q74e"></a>
**Q74e: Can I use custom domain names for subsites?**  
**A74e:**
Yes, but only with local development TLDs (`.local`, `.test`, `.dev`, `.home`, etc.). Custom domains can be set up in two ways:

**Option 1: During site creation** (WordPress 4.5+ required):
```bash
wpstaging add mysite.local --subdomains=custom.local
```
The CLI auto-creates the subsite and maps the custom domain using native WordPress domain mapping.

**Option 2: After site creation:**
Map a custom domain in WordPress admin (Network Admin > Sites > Edit), then run `update-subdomains` to update nginx, SSL, and hosts:
```bash
wpstaging update-subdomains mysite.local
```

Public TLDs (`.com`, `.org`, etc.) are not supported. The tool is designed for local development only.

<a name="q74f"></a>
**Q74f: Does `reset` preserve subdomain multisite settings?**  
**A74f:**
Yes. The `reset` command reads `IS_SUBDOMAIN_MULTISITE` and `SUBDOMAIN_HOSTNAMES` from the site's `.env` file and reinstalls WordPress with the same subdomain multisite configuration.

<a name="q75"></a>
**Q75: Can I restore only the database without files?**  
**A75:**
Yes, combine filters:
```bash
wpstaging restore --only-dbfile --path=/var/www/site backup.wpstg
```

<a name="q76"></a>
**Q76: How do I change the database prefix during restore?**  
**A76:**
Use `--db-prefix`:
```bash
wpstaging restore --path=/var/www/site --db-prefix=newwp_ backup.wpstg
```

<a name="q77"></a>
**Q77: Does restore support database SSL connections?**  
**A77:**
Yes, use SSL-related flags:
```bash
wpstaging restore --path=/var/www/site \
  --db-ssl-ca-cert=/path/to/ca.pem \
  --db-ssl-cert=/path/to/client-cert.pem \
  --db-ssl-key=/path/to/client-key.pem \
  --db-ssl-mode=preferred \
  backup.wpstg
```

## Security Questions

<a name="q78"></a>
**Q78: Is my license key stored securely?**  
**A78:**
The license key is stored encrypted in `.dataIndex*` files within the working directory (`~/.config/wpstaging/` on Linux). The encrypted data is protected and requires proper file permissions.

If you store the license key in the config file, ensure it has proper permissions:
```bash
# Linux/macOS - Protect config file
chmod 600 ~/.config/wpstaging/wpstaging.conf

# macOS (alternative location)
chmod 600 ~/Library/Application\ Support/wpstaging/wpstaging.conf

# Also protect the entire working directory
chmod 700 ~/.config/wpstaging/
```

**Windows:** The working directory is `%APPDATA%\wpstaging\` with default Windows ACL permissions.

<a name="q79"></a>
**Q79: Can I use the CLI in CI/CD pipelines?**  
**A79:**
Yes, use environment variables and `--yes` flag for non-interactive operation:
```bash
export WPSTGPRO_LICENSE=YOUR_KEY
wpstaging extract --yes backup.wpstg
```

<a name="q80"></a>
**Q80: Does the CLI validate SSL certificates for license checks?**  
**A80:**
Yes, the CLI uses HTTPS for license validation and enforces SSL certificate verification for security.

## Backup Format Questions

<a name="q81"></a>
**Q81: What backup versions are supported?**  
**A81:**
The CLI supports WP Staging backup format versions 1 and 2. Version detection happens automatically when parsing the backup header.

<a name="q82"></a>
**Q82: Can I inspect backup contents without extracting?**  
**A82:**
Yes, use dump commands:
```bash
wpstaging dump-header backup.wpstg
wpstaging dump-metadata backup.wpstg
wpstaging dump-index backup.wpstg
wpstaging dump-index --data backup.wpstg  # detailed file list

# All dump commands support --json for structured output
wpstaging dump-header --json backup.wpstg
wpstaging dump-metadata --json backup.wpstg
wpstaging dump-index --json backup.wpstg
```

<a name="q83"></a>
**Q83: Are compressed backups supported?**  
**A83:**
Yes, the CLI automatically handles compressed chunks within the `.wpstg` backup format. No additional decompression needed.

## Miscellaneous Questions

<a name="q84"></a>
**Q84: Can I extract to a custom directory?**  
**A84:**
Yes, use `--output-dir`:
```bash
wpstaging extract --output-dir=/custom/path backup.wpstg
```
Files land in a `wpstaging-output` folder under the path you pass (`/custom/path/wpstaging-output/`) so the command does not overwrite unrelated files in the path you supply. The older `--outputdir` name still works as a hidden alias.

<a name="q84a"></a>
**Q84a: Can I choose where remote backups download to?**  
**A84a:**
Yes, use `--download-dir` on commands that take a remote backup URL (`extract`, `restore`, `add`, `reset`):
```bash
wpstaging extract --download-dir=/custom/path --from=https://example.com/backup.wpstg
```
Files land in a `wpstaging-download` folder under the path you pass (`/custom/path/wpstaging-download/`) so downloaded backups stay separate from other files in the path you supply.

<a name="q85"></a>
**Q85: How do I update the CLI to the latest version?**  
**A85:**
Use the built-in update command:

```bash
# Update to latest binary
wpstaging update

# Only check for available updates
wpstaging update --check

# Show the update and announcement status
wpstaging update --status

# Update using install script (also updates current binary location)
wpstaging update --full

# Update or downgrade to a specific version
wpstaging update --version 1.5.0
wpstaging update --version v1.5.0

# Target a pre-release version
wpstaging update --version 1.6.0-beta.1

# Check whether a specific version exists
wpstaging update --version 1.5.0 --check

# Downgrade using install script
wpstaging update --version 1.5.0 --full

# Refresh the daily update check and announcement cache
wpstaging update --clear-cache
```

The CLI also checks for updates automatically once per day and shows a notice if a new version is available.

Use `update --status` for a quick status view. Use `update --check` when you want to check the server for the latest version right away.

**Version comparison results:**
- If your version matches the latest release: `Already up to date (vX.Y.Z).`
- If your version is ahead of the latest release (e.g., a pre-release build): `Current version (vX.Y.Z) is ahead of latest release (vA.B.C).`
- If a newer version is available: shows an update banner with instructions

**How `update` works (default):**
- Asks for confirmation before downloading
- Downloads the new binary in chunks with progress display and resume support (up to 3 retries)
- Verifies the SHA256 checksum, then replaces the current binary
- If the binary is in a user-writable location (e.g., `~/.local/bin/`), replacement is done directly
- If the binary is in a system directory (e.g., `/usr/local/bin/`), sudo is used automatically
- On Windows, a helper script replaces the binary after the process exits (Windows locks running executables)

**How `update --version` works:**
- Accepts both `1.5.0` and `v1.5.0` formats, including pre-release versions like `1.5.0-beta.1`
- Skips fetching the latest stable tag and targets the specified version directly
- Allows both upgrading and downgrading, except v1.10.0 and v1.11.0 which are refused (those releases have a bug that breaks the built-in update; see [Q85a](#q85a))
- Shows a warning when downgrading to a version before v1.7.0 (where the `update` command was introduced), with instructions to upgrade again using the install script
- Validates the version by fetching its manifest from GitHub
- With `--check`, only checks whether the version exists without installing
- Works with both `--full` (installer script) and default (binary replacement) modes

**How `update --full` works:**
- Downloads and runs the installer script from wp-staging.com (sets up aliases, shell completions, PATH)
- After the installer finishes, if the current binary is at a different location than the installed one (e.g., running from `/tmp/wpstaging`), copies the installed binary to replace it
- When combined with `--version`, passes `-v <version>` (with `v` prefix) to the installer script. The installer scripts also normalise the prefix independently, so direct usage like `install.sh -v 1.7.0` works.
- Preserves original file permissions and uses sudo if needed
- On Windows, a detached wrapper script handles the copy after the installer completes

<a name="q85a"></a>
**Q85a: `wpstaging update` says "Update check skipped for development version" on a real release. What do I do?**  
**A85a:**
This affects users currently on v1.10.0 or v1.11.0. Those two releases have a bug where the built-in `update` command always reports them as a development build and refuses to check for new versions. The automatic daily update check is also affected, so no upgrade banner appears either.

To recover, reinstall from the official installer one time:

```bash
curl -fsSL https://wp-staging.com/install.sh | bash
```

This overwrites the binary in place and brings you to v1.11.1 or later, where `update` works as expected. Your sites, license, and configuration are not touched. From v1.11.1 onwards the daily update check and `wpstaging update` work normally again.

<a name="q85b"></a>
**Q85b: What is the "Announcement" banner I sometimes see before update output?**  

**A85b:**
The CLI fetches a short notice from wp-staging.com and prints it before any update output. It is used for time-sensitive messages, such as incident alerts or guidance for a recent release. The notice is informational and never blocks the update or any other command. If the server is unreachable or no notice is published, no banner appears.

If a notice can be dismissed, the banner shows the command to hide it (`wpstaging update --acknowledge <id>`, or `--acknowledge all` for every message). Critical notices cannot be dismissed. Separately, on the automatic daily check every notice -- dismissible or critical -- shows at most once a day, not after every command; running `wpstaging update` yourself always shows it.

<a name="q85c"></a>
**Q85c: I built the CLI from source. Why does it say "Update check skipped for development version" and never show an update banner?**  

**A85c:**
This is on purpose. A binary you compile yourself reports its version as `0.0.0-dev` (or `unknown` when you run it with `go run`). On such a build, both the automatic daily update check and the `wpstaging update` command are turned off.

There are three reasons for this:

1. **No real version to compare.** A development build has no release version number, so it cannot be measured against the latest release. It would always look out of date and show the update banner after every command.
2. **It protects your own build.** The `update` command replaces the running binary. On a build you compiled yourself, that would overwrite your local binary with an official release and lose your work.
3. **Development builds are for testing.** They are not meant to be kept up to date like an installed release.

If you want to test the update flow on a development build, run `wpstaging update --force`. The `--force` flag bypasses the skip and runs the full update. You can also build with a real version number instead of the default `0.0.0-dev`.

This is different from [Q85a](#q85a). Q85a is a bug in the real v1.10.0 and v1.11.0 releases, which were wrongly treated as development builds. The behavior described here is the normal, intended behavior for a binary you build yourself.

<a name="q86"></a>
**Q86: Where can I report bugs or request features?**  
**A86:**
Visit the official WP Staging support at https://wp-staging.com/support/ or check the CLI documentation for the issue tracker URL.

<a name="q87"></a>
**Q87: How do I set up passwordless sudo for the wpstaging binary?**  
**A87:**
The wpstaging binary uses sudo for these operations:
1. **Updating /etc/hosts file** - Adding hostname entries for local sites (all platforms)
2. **LaunchDaemon install/remove** - Installing persistent loopback IP daemon (macOS only, one-time)
3. **IP alias binding** - Creating loopback IP aliases if daemon install fails (macOS only, fallback)

To set up passwordless sudo:

1. **Find the wpstaging binary path:**
   ```bash
   which wpstaging
   # Or if installed manually:
   /path/to/wpstaging
   ```

2. **Create a sudo configuration file:**
   ```bash
   sudo visudo -f /etc/sudoers.d/wpstaging
   ```

3. **Add the following lines (replace `username` and `/path/to/wpstaging`):**
   ```
   # Hosts file update (all platforms)
   username ALL=(ALL) NOPASSWD: /path/to/wpstaging update-hosts-file*

   # LaunchDaemon and loopback IP alias (macOS only - skip these lines on Linux)
   username ALL=(ALL) NOPASSWD: /bin/cp /tmp/com.wp-staging.cli-loopback-*.plist /Library/LaunchDaemons/com.wp-staging.cli-loopback.plist
   username ALL=(ALL) NOPASSWD: /usr/sbin/chown root\:wheel /Library/LaunchDaemons/com.wp-staging.cli-loopback.plist
   username ALL=(ALL) NOPASSWD: /bin/chmod 644 /Library/LaunchDaemons/com.wp-staging.cli-loopback.plist
   username ALL=(ALL) NOPASSWD: /bin/launchctl bootstrap system /Library/LaunchDaemons/com.wp-staging.cli-loopback.plist
   username ALL=(ALL) NOPASSWD: /bin/launchctl bootout system/com.wp-staging.cli-loopback
   username ALL=(ALL) NOPASSWD: /bin/launchctl load -w /Library/LaunchDaemons/com.wp-staging.cli-loopback.plist
   username ALL=(ALL) NOPASSWD: /bin/launchctl unload /Library/LaunchDaemons/com.wp-staging.cli-loopback.plist
   username ALL=(ALL) NOPASSWD: /bin/rm -f /Library/LaunchDaemons/com.wp-staging.cli-loopback.plist
   username ALL=(ALL) NOPASSWD: /bin/bash -c *ifconfig lo0*
   username ALL=(ALL) NOPASSWD: /sbin/ifconfig lo0 alias 127.3.2.* netmask 255.255.255.255
   ```

   For example:
   ```
   bob ALL=(ALL) NOPASSWD: /usr/local/bin/wpstaging update-hosts-file*
   bob ALL=(ALL) NOPASSWD: /bin/cp /tmp/com.wp-staging.cli-loopback-*.plist /Library/LaunchDaemons/com.wp-staging.cli-loopback.plist
   bob ALL=(ALL) NOPASSWD: /usr/sbin/chown root\:wheel /Library/LaunchDaemons/com.wp-staging.cli-loopback.plist
   bob ALL=(ALL) NOPASSWD: /bin/chmod 644 /Library/LaunchDaemons/com.wp-staging.cli-loopback.plist
   bob ALL=(ALL) NOPASSWD: /bin/launchctl bootstrap system /Library/LaunchDaemons/com.wp-staging.cli-loopback.plist
   bob ALL=(ALL) NOPASSWD: /bin/launchctl bootout system/com.wp-staging.cli-loopback
   bob ALL=(ALL) NOPASSWD: /bin/launchctl load -w /Library/LaunchDaemons/com.wp-staging.cli-loopback.plist
   bob ALL=(ALL) NOPASSWD: /bin/launchctl unload /Library/LaunchDaemons/com.wp-staging.cli-loopback.plist
   bob ALL=(ALL) NOPASSWD: /bin/rm -f /Library/LaunchDaemons/com.wp-staging.cli-loopback.plist
   bob ALL=(ALL) NOPASSWD: /bin/bash -c *ifconfig lo0*
   bob ALL=(ALL) NOPASSWD: /sbin/ifconfig lo0 alias 127.3.2.* netmask 255.255.255.255
   ```

4. **Save and exit the editor**

**Alternative:** If you cannot set up passwordless sudo or prefer not to, you can use the `--skip-update-hosts-file` flag:
```bash
wpstaging add https://mysite.local --skip-update-hosts-file
```

Note: When using `--skip-update-hosts-file`, you will need to manually add entries to your `/etc/hosts` file for local development.

---

<a name="q88"></a>
**Q88: I get "Error response from daemon: could not find an available, non-overlapping IPv4 address pool" when creating sites. How do I fix this?**  
**A88:**
This error occurs when Docker runs out of available IP address pools for creating new networks. This typically happens when you have many Docker networks created (e.g., from running multiple tests or creating many sites).

**Solution 1: Clean up unused Docker networks (Recommended)**
```bash
# Remove all unused networks
docker network prune -f

# Or remove specific test networks
docker network ls --filter "name=wpstg-" --format "{{.Name}}" | xargs docker network rm
```

**Solution 2: Stop and remove containers first, then clean up networks**
```bash
# Stop all test site containers
docker ps -a --filter "name=wpstg-" --format "{{.Names}}" | xargs docker rm -f

# Then prune networks
docker network prune -f
```

**Solution 3: Restart Docker daemon (if the above doesn't work)**
```bash
# On Linux with systemd
sudo systemctl restart docker

# On macOS/Windows
# Restart Docker Desktop from the application menu
```

**Prevention:** After running tests or deleting sites, run `docker network prune -f` to clean up unused networks and prevent this issue from occurring.

**Note:** The test suite automatically runs `docker network prune -f` in the teardown function to prevent this issue during testing.

---

<a name="q89"></a>
**Q89: I get "`docker` is running in Windows container mode" error on Windows. How do I fix this?**  
**A89:**
WP Staging CLI requires Docker to run in **Linux container mode** because all the container images (PHP, Nginx, MariaDB, Mailpit) are Linux-based.

**Solution: Switch to Linux containers**

**Option 1: Automatic switch (recommended)**

When WP Staging CLI detects Windows container mode, it will prompt you:
```
Docker requirement check failed:
──────────────────────────────────────────────────────────────────────────
`docker` is running in Windows container mode

WP Staging CLI requires Linux containers to work properly.

The next action will switch to Linux containers automatically.
Continue? [y/N]: y
Switching to Linux containers...
Successfully switched to Linux containers.
Please run your command again.
──────────────────────────────────────────────────────────────────────────
```
Simply press `y` to let the CLI switch Docker to Linux containers automatically.

**Option 2: Using Docker Desktop UI**
1. Right-click the Docker Desktop icon in the system tray (bottom-right corner)
2. Select **"Switch to Linux containers..."**
3. Wait for Docker to restart
4. Run your wpstaging command again

**Option 3: Using command line manually**
```powershell
# PowerShell
& "C:\Program Files\Docker\Docker\DockerCli.exe" -SwitchLinuxEngine
```
```cmd
# CMD
"C:\Program Files\Docker\Docker\DockerCli.exe" -SwitchLinuxEngine
```

**To verify current mode:**
```bash
docker version --format "{{.Server.Os}}"
```
- Output `linux` = Correct mode ✅
- Output `windows` = Wrong mode, switch to Linux containers

**Note:** Docker Desktop defaults to Linux container mode. If you previously switched to Windows containers for .NET or Windows-based development, you'll need to switch back for WP Staging CLI.

---

<a name="q89b"></a>
**Q89b: I get "Host 'x.x.x.x' is not allowed to connect to this MariaDB server" error. What's wrong?**  
**A89b:**
This error occurs on Windows and macOS when the CLI tries to connect to MariaDB during database setup. The error looks like:
```
Failed to set up database: mysite_local: failed to connect to database after 10 attempts:
Error 1130: Host '172.25.0.1' is not allowed to connect to this MariaDB server
```

**Cause:**
Docker Desktop routes host-to-container connections through the bridge network. The connection appears to come from the bridge gateway IP (e.g., `172.25.0.1` or `172.18.0.1`) instead of localhost. MariaDB by default only allows root connections from localhost.

**Solution:**
This issue was fixed by:
1. Using MariaDB 11.8 image (`mariadb:11.8`) instead of `latest`
2. Adding `MARIADB_ROOT_HOST=%` environment variable to allow root connections from any host

If you encounter this error with an older version:
1. Update to the latest version of WP Staging CLI
2. Delete the affected site and recreate it:
   ```bash
   wpstaging del mysite.local
   wpstaging add mysite.local
   ```

The new site will use MariaDB 11.8 with the correct configuration.

---

<a name="q89c"></a>
**Q89c: I get "Access denied for user 'root'@'localhost'" on Docker Desktop. What's wrong?**  
**A89c:**
This error can occur on Docker Desktop (Windows, macOS, or Linux with Docker Desktop) when MariaDB fails to set the root password from the `MARIADB_ROOT_PASSWORD` environment variable during first initialization.

**Cause:**
Docker Desktop has a known issue where MariaDB may not properly initialize the root password from environment variables if the data directory is not completely empty at startup.

**How WP Staging CLI handles this:**
The CLI automatically detects Docker Desktop and applies two fixes:
1. **Clears MariaDB data directory** before first WordPress installation to ensure fresh initialization
2. **Uses init SQL script** in `/docker-entrypoint-initdb.d/` as a backup mechanism to set the root password

**If you still encounter this error:**
1. Delete the affected site:
   ```bash
   wpstaging del mysite.local
   ```
2. Recreate the site:
   ```bash
   wpstaging add mysite.local
   ```

The CLI will automatically clear the MariaDB data directory and set up the password correctly.

**Manual fix (if needed):**
Delete the MariaDB data directory manually before creating the site:
```bash
rm -rf ~/wpstaging/sites/<hostname>/data/mariadb/*
wpstaging add <hostname>
```

---

<a name="q89d"></a>
**Q89d: Database connection fails after running `remove` then `add`. What's wrong?**  
**A89d:**
This can happen when MariaDB hasn't fully initialized before the CLI attempts to connect.

**Cause:**
After `remove`, all container data is deleted. When `add` runs, MariaDB starts fresh and needs time to initialize (especially on slower systems or Docker Desktop).

**How WP Staging CLI handles this:**
The CLI uses two mechanisms to ensure database readiness:
1. **MariaDB healthcheck** - The container reports healthy only when MariaDB accepts connections and InnoDB is initialized
2. **Docker Compose --wait flag** - CLI waits for the healthcheck to pass before proceeding

**If you still encounter this error:**
The issue is usually transient. Simply retry:
```bash
wpstaging del mysite.local
wpstaging add mysite.local
```

**Technical details:**
The MariaDB service includes a healthcheck configuration with platform-specific timings:

Docker Engine:
```yaml
healthcheck:
  test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
  start_period: 30s
  interval: 10s
  timeout: 5s
  retries: 3
```

Docker Desktop uses longer timings because bind-mounted volumes are slower:
```yaml
healthcheck:
  test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
  start_period: 90s
  interval: 10s
  timeout: 5s
  retries: 5
```

This ensures the database is fully ready before WordPress installation begins.

---

<a name="q89e"></a>
**Q89e: MariaDB fails with "InnoDB: Cannot open './ibdata1'" on macOS. What's wrong?**  
**A89e:**
This error occurs on Docker Desktop for Mac (especially macOS 26+) when InnoDB's native I/O operations are incompatible with the virtualized filesystem.

**Error message:**
```
InnoDB: Operating system error number 20 in a file operation.
InnoDB: Error number 20 means 'Not a directory'
InnoDB: Cannot open './ibdata1'.
InnoDB: Database creation was aborted with error Generic error.
Plugin 'InnoDB' registration as a STORAGE ENGINE failed.
```

**Cause:**
Docker Desktop for Mac uses VirtioFS or gRPC-FUSE for filesystem virtualization. InnoDB's Native Asynchronous I/O and default flush methods don't work correctly with this virtualized filesystem layer, particularly on newer macOS versions (26+) and Docker Desktop versions.

**How WP Staging CLI handles this:**
The CLI includes MariaDB configuration that disables problematic I/O features:
```ini
innodb_use_native_aio = 0
innodb_flush_method = fsync
```

These settings are safe for all platforms with minimal performance impact for development environments.

**If you encounter this error:**
1. Update to the latest version of WP Staging CLI
2. Reset the site (optionally restore from backup):
   ```bash
   wpstaging reset mysite.local
   # Or reset and restore in one step:
   wpstaging reset mysite.local --from=backup.wpstg
   ```

**Manual fix for existing sites:**
Update the MariaDB config file:
```bash
# Edit the config file
echo "innodb_use_native_aio = 0" >> ~/wpstaging/sites/<hostname>/docker/mariadb/config/mysqld.cnf
echo "innodb_flush_method = fsync" >> ~/wpstaging/sites/<hostname>/docker/mariadb/config/mysqld.cnf

# Reset the site
wpstaging reset <hostname>
```

---

<a name="q90"></a>
**Q90: Browser shows "Your connection is not private" or certificate not trusted. How do I fix this?**  
**A90:**
This happens when the mkcert Certificate Authority (CA) is not installed in your system trust store. This can occur if you declined the CA installation prompt during site setup.

**Symptoms:**
- Browser shows "Your connection is not private"
- ERR_CERT_AUTHORITY_INVALID error
- Certificate appears invalid

**Solution 1: Use reinstall-ca (recommended)**
```bash
# Rotate the certificate authority and re-sign every site in one pass.
# This is the right command whenever browsers stop trusting your sites.
wpstaging reinstall-ca

# Equivalent alias on reinstall-cert (same effect, with or without a hostname):
wpstaging reinstall-cert --reinstall-ca
wpstaging reinstall-cert <hostname> --reinstall-ca

# Running sites are restarted automatically after the rotation.
```

**Solution 2: Delete CA and re-add site**
```bash
# Delete CA to trigger re-prompt
rm -rf ~/wpstaging/stack/mkcert/ca/

# Add a new site and accept the CA installation prompt
wpstaging add newsite.local
```

**Solution 3: Manually install existing CA**

**Linux (Chrome/Chromium):**
```bash
certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n "mkcert CA" \
  -i ~/wpstaging/stack/mkcert/ca/rootCA.pem

# Restart Chrome
killall chrome
```

**Linux (Firefox):**
```bash
PROFILE=$(find ~/.mozilla/firefox -name "*.default*" | head -1)
certutil -d sql:$PROFILE -A -t "C,," -n "mkcert CA" \
  -i ~/wpstaging/stack/mkcert/ca/rootCA.pem
```

**macOS:**
```bash
sudo security add-trusted-cert -d -r trustRoot \
  -k /Library/Keychains/System.keychain \
  ~/wpstaging/stack/mkcert/ca/rootCA.pem
```

**Windows (PowerShell as Administrator):**
```powershell
certutil -addstore -f "ROOT" $env:USERPROFILE\wpstaging\stack\mkcert\ca\rootCA.pem
```

---

<a name="q91"></a>
**Q91: How do I check if the mkcert CA is installed correctly?**  
**A91:**
Use these commands to verify CA installation:

**Linux (Chrome NSS database):**
```bash
certutil -d sql:$HOME/.pki/nssdb -L | grep mkcert
```

**macOS:**
```bash
security find-certificate -c "mkcert" -a
```

**Windows:**
```cmd
certutil -store -user root | findstr mkcert
```

**Verify certificate is signed by CA:**
```bash
openssl verify -CAfile ~/wpstaging/stack/mkcert/ca/rootCA.pem \
  ~/wpstaging/sites/<hostname>/docker/nginx/certs/<hostname>.crt

# Should output: <hostname>.crt: OK
```

---

<a name="q92"></a>
**Q92: I get "mkcert binary not found" error. How do I fix it?**  
**A92:**
This happens if the mkcert binary wasn't downloaded or was deleted.

**Solution 1: Add a new site (auto-downloads mkcert)**
```bash
wpstaging add site.local
# Will copy from system or download from GitHub automatically
```

**Solution 2: Install mkcert system-wide first**

**Linux (Homebrew):**
```bash
brew install mkcert
```

**Linux (manual):**
```bash
curl -LO https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64
sudo mv mkcert-v1.4.4-linux-amd64 /usr/local/bin/mkcert
sudo chmod +x /usr/local/bin/mkcert
```

**macOS:**
```bash
brew install mkcert
```

**Windows (Chocolatey):**
```powershell
choco install mkcert
```

After installing system-wide, WP Staging CLI will copy it automatically when you add a new site.

---

<a name="q93"></a>
**Q93: I get NET::ERR_CERT_DATE_INVALID or certificate expired error. How do I fix it?**  
**A93:**
This is usually caused by incorrect system clock or corrupted certificate files.

**Check system time:**
```bash
date
```

**Regenerate certificates:**
```bash
# Delete certificate files
rm ~/wpstaging/sites/<hostname>/docker/nginx/certs/<hostname>.crt
rm ~/wpstaging/sites/<hostname>/docker/nginx/certs/<hostname>.key

# Restart to regenerate
wpstaging restart <hostname>
```

**Note:** Mkcert certificates are valid for 10 years, so expiration is rare unless system clock is wrong.

---

<a name="q94"></a>
**Q94: How do I regenerate SSL certificates for a site?**  
**A94:**
Use the `reinstall-cert` command (requires `--show-all` flag to see in help):

```bash
# Regenerate certificate for a single site
wpstaging reinstall-cert <hostname>

# Or regenerate certificates for every site in one command
wpstaging reinstall-cert

# Restart to apply changes
wpstaging restart <hostname>
```

To also rotate the certificate authority (wipe the CA, install a fresh one
into the system trust store, and re-sign every site's leaf):
```bash
# Dedicated command for CA rotation
wpstaging reinstall-ca

# Equivalent alias on reinstall-cert (same effect with or without a hostname)
wpstaging reinstall-cert --reinstall-ca
wpstaging reinstall-cert <hostname> --reinstall-ca
```

The previous CA is also removed from the system trust store automatically. If you have older orphan entries from before this change, see [Q121](#q121).

**Alternative manual method:**
```bash
# Delete certificates manually
rm ~/wpstaging/sites/<hostname>/docker/nginx/certs/<hostname>.crt
rm ~/wpstaging/sites/<hostname>/docker/nginx/certs/<hostname>.key

# Restart to regenerate
wpstaging restart <hostname>
```

---

<a name="q95"></a>
**Q95: Certificate works for hostname but not for IP access. Why?**  
**A95:**
The certificate must include the container IP in its Subject Alternative Names (SAN).

**Check certificate SANs:**
```bash
openssl x509 -in ~/wpstaging/sites/<hostname>/docker/nginx/certs/<hostname>.crt \
  -noout -text | grep -A5 "Subject Alternative Name"

# Should show: IP Address:127.3.2.x (your container IP)
```

**If container IP is missing, regenerate:**
```bash
rm ~/wpstaging/sites/<hostname>/docker/nginx/certs/<hostname>.crt
rm ~/wpstaging/sites/<hostname>/docker/nginx/certs/<hostname>.key
wpstaging restart <hostname>
```

---

<a name="q96"></a>
**Q96: I get "`docker` is not installed" error. How do I install Docker?**  
**A96:**
The CLI displays OS-specific installation instructions when Docker is not found. Here's a summary:

**Linux:**
```bash
# Quick install via official script
curl -fsSL https://get.docker.com | sh

# Add your user to docker group (to run without sudo)
sudo usermod -aG docker $USER
# Log out and back in for group change to take effect
```

**macOS:**
- Download Docker Desktop from: https://docs.docker.com/desktop/setup/install/mac-install/
- Or install via Homebrew: `brew install --cask docker`

**Windows:**
- Download Docker Desktop from: https://docs.docker.com/desktop/setup/install/windows-install/

---

<a name="q97"></a>
**Q97: I get "`docker` version too old" or "`docker compose` version too old" error. How do I update?**  
**A97:**
WP Staging CLI requires:
- Docker >= 20.10.0
- Docker Compose >= 2.19.0

**To update Docker:**

- **Linux:**
  ```bash
  curl -fsSL https://get.docker.com | sh
  ```

- **macOS:**
  - Open Docker Desktop and check for updates
  - Or reinstall from: https://docs.docker.com/desktop/setup/install/mac-install/

- **Windows:**
  - Open Docker Desktop and check for updates
  - Or reinstall from: https://docs.docker.com/desktop/setup/install/windows-install/

**To update Docker Compose:**

- **Linux:**
  ```bash
  sudo apt-get update && sudo apt-get install docker-compose-plugin  # Debian/Ubuntu
  sudo dnf install docker-compose-plugin                              # Fedora/RHEL
  ```
  Or see: https://docs.docker.com/compose/install/linux/

- **macOS/Windows:**
  - Update Docker Desktop to get the latest Docker Compose

**Verify versions:**
```bash
docker version
docker compose version
```

---

<a name="q98"></a>
**Q98: How do I restore a remote backup to a dockerized site?**  
**A98:**
The simplest way is to use `add --from` which creates a new site and restores from a backup in one step. For existing sites, database credentials are auto-detected from the site's `.env` file.

**Single command (recommended for new sites):**
```bash
# From local backup file
wpstaging add mysite.local --from=backup.wpstg

# From remote URL
wpstaging add mysite.local --from=https://example.com/backup.wpstg
```

This creates the site, installs WordPress, and then restores from the backup file using the database credentials from the site's `.env` file automatically.

After restoration, you'll see helpful information:
```
Login credentials:
* Site     : https://mysite.local
* User     : Login with same username as in https://original-site.com
* Password : Login with same password as in https://original-site.com

Paths:
* Site data      : ~/wpstaging/sites/mysite.local/www
* Docker Compose : ~/wpstaging/sites/mysite.local/docker-compose.yml
* Env File       : ~/wpstaging/sites/mysite.local/.env
```

**Reset existing site with backup (recommended for existing sites):**

If the site already exists and you want to reset it with a backup:
```bash
# From local backup file
wpstaging reset mysite.local --from=backup.wpstg

# From remote URL
wpstaging reset mysite.local --from=https://example.com/backup.wpstg

# Reset with a specific WordPress version
wpstaging reset mysite.local --wp=6.5

# Combine --wp and --from
wpstaging reset mysite.local --wp=6.5 --from=backup.wpstg
```

This reinstalls WordPress and restores from the backup, using the existing site's database credentials from `.env`. The `--wp` flag updates the `WP_VERSION` in the `.env` file with the actual installed version.

**Tip:** To change the WordPress version without reinstalling, use `switch-wp` instead:
```bash
wpstaging switch-wp mysite.local 6.5
```
This replaces only the WordPress core files while preserving your database, themes, plugins, and uploads.

**Alternative: Manual restore to existing site**

If the site already exists and you want to restore manually without reset:

```bash
# Make sure site is running
wpstaging start mysite.local

# Restore the backup (simple hostname format)
wpstaging restore mysite.local backup.wpstg

# Or with remote URL
wpstaging restore mysite.local --from=https://example.com/backup.wpstg
```

The CLI automatically detects the site path and reads database credentials from the `.env` file. You'll see:
```
Restoring to dockerized site: mysite.local
Using database credentials from dockerized site: mysite.local
```

**Alternative: Using --path flag (legacy format)**

You can also specify the full path explicitly:
```bash
wpstaging restore --path=$HOME/wpstaging/sites/mysite.local/www backup.wpstg
wpstaging restore --path=$HOME/wpstaging/sites/mysite.local/www --from=https://example.com/backup.wpstg
```

**Complete workflow in one script:**
```bash
# Set your site hostname and backup URL
SITE="mysite.local"
BACKUP_URL="https://mysite.com/wp-content/uploads/wp-staging/backups/backup.wpstg"

# Create site (skip if exists)
wpstaging add $SITE

# Make sure site is running (database must be accessible)
wpstaging start $SITE

# Restore - credentials auto-detected from .env
wpstaging restore $SITE --from="$BACKUP_URL"
```

**Note:** CLI flags always take priority over auto-detected values. If you need to override a specific credential, just pass the flag:
```bash
wpstaging restore mysite.local --db-prefix=custom_ backup.wpstg
```

For dockerized sites, if you specify `--site-url`, the hostname must match the `SITE_URL` in the site's `.env` file. The CLI will show an error if there's a mismatch:

```
error: Site URL hostname 'different.local' does not match the dockerize site URL hostname 'mysite.local' from .env file.
When restoring to a dockerize site, the --site-url hostname must match the site's configured URL.
Either use --site-url=https://mysite.local or remove the --site-url flag to auto-detect.
```

Database credentials are stored in `~/wpstaging/sites/<hostname>/.env` (auto-generated by `wpstaging add`).

---

<a name="q99"></a>
**Q99: What happens if an external service is using the same IP range as wpstaging?**  
**A99:**
The CLI uses the IP range `127.3.2.1 - 127.3.2.254` for Docker containers. If an external service (like Apache, nginx, or MySQL) is using an IP in this range:

**For new sites (`wpstaging add`):**
The CLI automatically detects the conflict and switches to the next available IP:
```
Container IP 127.3.2.1 is in use by external service, switching to 127.3.2.2
```

**For existing sites (`wpstaging start` or `wpstaging restart`):**
The CLI cannot auto-switch (the IP is already configured in `.env`). Instead, it shows an error with details:
```
Cannot start site. External services are using IP 127.3.2.1:
  - HTTP (port 80): external service
  - HTTPS (port 443): external service

Please stop these services or delete the site and recreate it to assign a new IP.
```

**Solutions:**
1. Stop the conflicting external service
2. Delete and recreate the site: `wpstaging del mysite.local && wpstaging add mysite.local`
3. Use a specific IP: `wpstaging add mysite.local --container-ip=127.3.2.50`

---

<a name="q100"></a>
**Q100: Why does my site fail to start on macOS with "can't assign requested address"?**  
**A100:**
On macOS, loopback IP addresses other than `127.0.0.1` require explicit aliases. If you see an error like:
```
bind: can't assign requested address
```

The CLI now provides a clear message:
```
Container IP address 127.3.2.1 is not configured on macOS.

macOS requires explicit loopback IP aliases. Please run:
  sudo ifconfig lo0 alias 127.3.2.1 netmask 255.255.255.255

Or use --skip-macos-auto-ip flag to use port-based separation instead.
```

**Solutions:**
1. Run `wpstaging start <site>` — the CLI automatically creates the missing IP alias
2. Run `wpstaging add <site>` again — the CLI installs a LaunchDaemon for persistent aliases
3. Run the suggested `sudo ifconfig` command for a quick manual fix
4. Use `--skip-macos-auto-ip` flag when adding sites (uses port-based separation instead of IP-based)

**Note:** The CLI installs a LaunchDaemon that creates loopback aliases for existing sites at boot. Aliases persist across reboots automatically. The `start` and `restart` commands also auto-create missing aliases.

---

<a name="q101"></a>
**Q101: What happens when I start or restart all sites and some have conflicts?**  
**A101:**
When running `wpstaging start` or `wpstaging restart` without specifying a hostname (to affect all sites), the CLI:

1. Pre-scans all sites for external service conflicts
2. Skips sites with conflicts and continues starting others
3. Shows a summary at the end with diagnostic commands

**Example output:**
```
All containers started successfully
--------------------------------------------------------------------------------
The following sites could not start due to conflict with external services:
  - site1.local: HTTP (port 80) used by external service

Please stop these services or delete the affected sites and recreate them
to assign new IPs.

To check which service is using a port:
  sudo lsof -i :80
  or: sudo ss -tlnp | grep 80
--------------------------------------------------------------------------------
```

This ensures that one conflicting site doesn't prevent other sites from starting.

---

<a name="q101b"></a>
**Q101b: What happens if an external service is bound to all interfaces (wildcard binding)?**  
**A101b:**
When an external service (like nginx or Apache) binds to `0.0.0.0:80` or `*:443` (wildcard binding), it listens on ALL IP addresses. This means Docker cannot bind to any specific IP on that port, even in the `127.3.2.x` range.

**How the CLI detects wildcard bindings:**
- Tests if the port responds on both `127.0.0.1` and another IP (like `127.3.2.1`)
- If both respond, it's a wildcard binding

**Behavior when wildcard is detected:**
- Port rotation is triggered (not IP rotation, since IP rotation won't help)
- Enhanced message indicates the wildcard binding:
```
HTTP port 80 is in use by external service bound to all interfaces (*:80).
Switching to port 8844.
```

**Common causes:**
- System nginx configured with `listen 80;` (defaults to all interfaces)
- Apache with `Listen 80` in httpd.conf
- Other web servers or proxies

**Solutions:**
1. Stop the conflicting service: `sudo systemctl stop nginx`
2. Reconfigure the service to bind to a specific IP: `listen 127.0.0.1:80;`
3. Let the CLI use alternate ports (automatic)

**Note:** On macOS with `--skip-macos-auto-ip`, external service checks for the IP range are skipped since port-based separation is used instead.

---

<a name="q101c"></a>
**Q101c: A non-wpstg Docker container (e.g., standalone MySQL) is using a port. Will the CLI detect this?**  
**A101c:**
Yes. The CLI detects port conflicts from **any** running Docker container, not just wpstg containers. This is important because Docker's internal port allocator may use iptables-based forwarding that doesn't create host-level sockets, so standard OS-level port checks (TCP connect and bind) can miss these conflicts.

**How it works:**
- The CLI queries all running Docker containers via `docker ps` to get their published port mappings
- It checks Docker's own conflict rules:
  - `0.0.0.0:PORT` (wildcard) conflicts with any IP on that port
  - `:::PORT` (IPv6 wildcard) conflicts with any IP on that port
  - Exact `IP:PORT` match conflicts
- Containers managed by wpstg (`wpstg-*`) are excluded (handled separately)

**Example scenario:**
A standalone MySQL container is running with `docker run -p 3306:3306 mysql`. When you create a wpstg site:
```bash
wpstaging add mysite.local
```

The CLI detects the Docker port conflict and auto-switches:
```
MariaDB port 3306 on IP 127.3.2.1 conflicts with Docker container 'mysql'.
Automatically switching to port 3344.
```

**What ports are checked:**
All 4 port types are covered: HTTP, HTTPS, MariaDB, and Mailpit.

**Fallback behavior:**
The same fallback mechanism as Q43 applies — the CLI tries predefined fallback ports first, then random ports in the 49152-65535 range.

**Why OS-level checks are not enough:**
When Docker routes traffic using iptables (e.g., a container bound to `0.0.0.0:3306`), no host-level socket may exist on the specific loopback IP (like `127.3.2.1`). A TCP connect test to `127.3.2.1:3306` returns "connection refused" (port appears free), but Docker will reject binding `127.3.2.1:3306` because `0.0.0.0:3306` already claims all IPs. The Docker-level check catches this.

---

## Environment Variables

<a name="q102"></a>
**Q102: What environment variables does wpstaging CLI support?**  
**A102:**
The CLI supports several environment variables for configuration:

| Variable | Purpose | Example |
|----------|---------|---------|
| `WPSTGPRO_LICENSE` | Provide license key | `export WPSTGPRO_LICENSE=abc123...` |
| `WPSTGCLI_JSON_OUTPUT` | Enable structured JSON output | `export WPSTGCLI_JSON_OUTPUT=1` |
| `WPSTGCLI_JSON_PAGE` | Page number for paginated JSON output | `export WPSTGCLI_JSON_PAGE=2` |
| `WPSTGCLI_JSON_PAGE_SIZE` | Items per page for paginated JSON output | `export WPSTGCLI_JSON_PAGE_SIZE=50` |
| `WPSTGCLI_DEBUG` | Enable debug output | `export WPSTGCLI_DEBUG=1` |
| `WPSTGCLI_VERBOSE` | Show detailed per-file output | `export WPSTGCLI_VERBOSE=1` |
| `WPSTGCLI_QUIET` | Suppress informational output | `export WPSTGCLI_QUIET=1` |
| `WPSTGCLI_ALLOW_ROOT` | Allow running as root user | `export WPSTGCLI_ALLOW_ROOT=1` |

Boolean environment variables accept truthy values: `1`, `true`, `yes`, `on` (case-insensitive).

---

<a name="q103"></a>
**Q103: How do I enable debug output?**  
**A103:**
Use either the `--debug` flag or the environment variable:

```bash
# Using flag
wpstaging extract --debug backup.wpstg

# Using environment variable
export WPSTGCLI_DEBUG=1
wpstaging extract backup.wpstg
```

Debug output shows detailed execution traces to stderr prefixed with `[DEBUG]`.

---

<a name="q104"></a>
**Q104: How do I suppress all informational output?**  
**A104:**
Use the `--quiet` flag or environment variable for silent operation:

```bash
# Using flag
wpstaging extract --quiet backup.wpstg

# Using environment variable
export WPSTGCLI_QUIET=1
wpstaging extract backup.wpstg
```

This is useful for scripting and CI/CD pipelines.

---

<a name="q105"></a>
**Q105: How do I run wpstaging as root user?**  
**A105:**
By default, running as root is blocked for security. To allow it:

```bash
# Using flag
sudo wpstaging extract --allow-root backup.wpstg

# Using environment variable
export WPSTGCLI_ALLOW_ROOT=1
sudo wpstaging extract backup.wpstg
```

**Important:** Don't use this on your regular system. Only use it when you're already in a sandboxed/isolated environment where running as root is expected and safe (e.g., Docker containers, CI/CD pipelines, virtual machines).

---

<a name="q106"></a>
**Q106: Can I extract or restore a backup directly from a URL?**  
**A106:**
Yes, you can extract or restore backups directly from HTTP/HTTPS URLs without downloading them manually first.

**Using `--from` flag:**
```bash
# Extract from remote URL
wpstaging extract --from=https://example.com/backups/backup.wpstg

# Restore from remote URL
wpstaging restore --path=/var/www/html --from=https://example.com/backups/backup.wpstg
```

**Or pass URL directly as argument:**
```bash
wpstaging extract https://example.com/backups/backup.wpstg
```

**What happens:**
1. The CLI validates the URL (must end with `.wpstg`)
2. Performs a preflight check (file size and backup format validation)
3. Displays backup information (filename, size, format type)
4. Asks for confirmation before downloading
5. Downloads with progress indicator; resumes interrupted downloads when safe, otherwise restarts from scratch
6. Caches downloaded files for reuse

**Supported backup formats:**
- WP Staging Backup v1
- WP Staging Backup v2
- WP Staging SQL Dump

---

## Cross-Site Communication and SSL

<a name="q107"></a>
**Q107: Can one dockerized site send HTTPS requests to another site?**  
**A107:**
Yes. All sites share a Docker network called `wpstg-site-shared-network`. Each site's Nginx registers its hostname as a DNS alias on this network. When site1's PHP sends a request to `https://site2.local`, Docker DNS resolves the hostname to site2's Nginx container.

This works for:
- Cross-site requests (site1 to site2)
- Self-referral (site1 to itself)
- WordPress features like wp-cron, health checks, and WP Staging Remote Sync

The shared network is created automatically when you run `wpstaging start`. No extra setup is needed.

<a name="q108"></a>
**Q108: Why does `curl` inside the container fail with "unable to get local issuer certificate"?**  
**A108:**
This happens when the container does not trust the mkcert CA certificate. The fix is to regenerate the site's config files:

```bash
wpstaging generate-docker-file <hostname>   # single site
wpstaging generate-docker-file              # all sites
wpstaging start <hostname>
```

This creates a combined CA bundle that includes both system CAs (for public websites) and the mkcert CA (for local sites). The bundle is mounted at `/etc/ssl/certs/ca-certificates.crt` inside the container, so both PHP and shell `curl` trust it.

If the issue still happens on a fresh site, make sure you are running the latest binary.

<a name="q109"></a>
**Q109: Does the shell prompt show the site hostname?**  
**A109:**
Yes. When you open a shell with `wpstaging shell <hostname>`, the prompt shows the site hostname:

```
[www-data@example.local ~]$
```

For root shell (`wpstaging shell <hostname> root`):
```
[root@example.local ~]#
```

<a name="q110"></a>
**Q110: What is the `wpstg-site-shared-network` network?**  
**A110:**
It is a Docker bridge network that exists only inside Docker. Containers use it to talk to each other. The host machine (your computer) cannot access containers through this network.

| From | To | How |
|------|----|-----|
| Host machine (browser) | Container | Loopback IP port binding (`127.3.2.x`) |
| Container | Container | Shared network Docker DNS (`wpstg-site-shared-network`) |

The network is created when you run `wpstaging start`. It is removed when you run `wpstaging stop` (without a hostname).

<a name="q111"></a>
**Q111: How do I set up the Docker development environment on macOS?**  
**A111:**
macOS with Docker Desktop requires extra setup because containers cannot reach the Docker gateway IP (`172.201.0.1`) directly, unlike Linux where the gateway forwards traffic by port.

**Initial setup:**
```bash
# 1. Copy the macOS environment overrides
cp .env.local.example .env.local
# Edit HOST_UID/HOST_GID if needed (defaults: 501/20 for first macOS user)

# 2. Build and start (Makefile handles macOS automatically)
make build
make docker-up        # Adds loopback alias and uses macOS overlay
make docker-site-setup
```

**What the Makefile does automatically on macOS:**
- Adds a loopback alias (`sudo ifconfig lo0 alias 172.201.0.1`) for host-side port binding
- Uses `docker-compose.macos.yml` overlay alongside `docker-compose.yml`
- Builds the correct binary architecture (ARM64 or AMD64) for integration tests

**How the macOS overlay works:**
- Removes `extra_hosts` from the PHP container (gateway IP is unreachable)
- Adds nginx network aliases so container hostnames resolve directly to nginx
- Loads a custom `nginx-macos.conf` with a TCP stream proxy that forwards MySQL traffic (port 3306) from nginx to the database container

**Running tests:**
```bash
make tests-backup                # Backup/extract tests
make tests-docker-integration    # Docker integration tests (external DB tests auto-skip on macOS)
```

**Note:** The loopback alias does not persist after reboot. Run `make docker-up` again after each restart, or manually run `sudo ifconfig lo0 alias 172.201.0.1`.

---

<a name="q112"></a>
**Q112: I use OrbStack instead of Docker Desktop. Is it supported?**  
**A112:**
No. OrbStack is not supported. OrbStack's networking does not support binding to loopback IP aliases (127.3.2.x) that the CLI uses. Containers start and appear healthy, but sites are not reachable in the browser.

The CLI auto-detects OrbStack's Docker context and switches to Docker Desktop (`desktop-linux`) or Docker Engine (`default`). You will see a notice:

```
OrbStack Docker context detected. OrbStack is not supported at the moment.
Switched Docker context to "desktop-linux".
```

If no alternative context is found, the CLI shows an error. Switch manually:

```bash
# List available contexts
docker context ls

# Switch to Docker Desktop
docker context use desktop-linux

# Or switch to Docker Engine
docker context use default
```

**Note:** The OrbStack Docker context stays active even after you quit OrbStack. The Docker CLI silently uses OrbStack's socket until you switch contexts.

---

## Docker Bind Mount Problems

<a name="q113"></a>
**Q113: I get "is a directory" error when running `wpstaging add` or `wpstaging reset`. How do I fix it?**  
**A113:**
This happens when Docker creates bind mount source paths as directories instead of files. Older Docker Compose versions may ignore the `create_host_path: false` setting and create directories at paths where config files are expected (e.g., `php.ini`, `ext-redis.ini`).

Since v1.6.3, the CLI automatically detects and removes these stale directories before generating config files. You should see a message like:

```
Found directories where config files are expected:
  /path/to/docker/php/config/php.ini
  /path/to/docker/php/config/ext-redis.ini
Removing and recreating as files...
```

If you're on an older version, run:
```bash
wpstaging remove example.local
wpstaging add example.local
```

This clears the site directory and recreates it cleanly.

---

<a name="q114"></a>
**Q114: How do I get JSON output from the CLI?**  
**A114:**
Use the `--json` global flag or set the `WPSTGCLI_JSON_OUTPUT=1` environment variable. All output switches to structured JSON on stdout. Each JSON response is pretty-printed with 2-space indentation and may span multiple lines. Consumers should parse complete JSON objects rather than assume one object per line.

Examples:
```bash
# List all sites as JSON
wpstaging list --json

# Paginated JSON output (default: 100 items per page)
wpstaging list --json --page=1 --page-size=50

# Container status as JSON
wpstaging status --json

# Backup file index as JSON (raw lines)
wpstaging dump-index backup.wpstg --json

# Backup file index as structured entries
wpstaging dump-index --data backup.wpstg --json

# Using environment variable
WPSTGCLI_JSON_OUTPUT=1 wpstaging list
```

Each JSON object has a `command` field: `message` (progress), `prompt` (waiting for input), `list`, `status`, `dump_header` (backup header), `dump_metadata` (backup metadata), `dump_index` (backup file index), `wp_installed` (installation summary), `site_delete_confirm` (deletion list), `port_conflict` (port conflict errors), `restore_confirm` (restore confirmation), `remote_backup_info` (remote backup details), or `license` (license operations).
Commands that return lists (`list`, `status`, `dump-index`) support `--page` and `--page-size` flags. Default is 100 items per page. Set `--page-size=0` to return all items.
Errors are written to stderr with `"success": false`. See [GUI Integration Guide](GUI-INTEGRATION.md) for the full JSON protocol documentation.

When a confirmation prompt appears, the CLI outputs a prompt object and waits for `y` or `n` on stdin:
```json
{
  "success": true,
  "command": "prompt",
  "data": {
    "message": "Continue?",
    "type": "confirm",
    "accept": ["y", "n"]
  }
}
```

When the CLI needs sudo, it outputs a sudo prompt and waits for the password on stdin (followed by a newline):
```json
{
  "success": true,
  "command": "prompt",
  "data": {
    "message": "Sudo password is required to update /etc/hosts for local domain resolution.",
    "type": "sudo"
  }
}
```
The GUI wrapper shows a password dialog with the `message` text and writes the password to stdin. If sudo credentials are already cached, the prompt is skipped.

---

<a name="q115"></a>
**Q115: How do I change the PHP version for an existing site?**  
**A115:**
Use the `switch-php` command to change the PHP version for an existing dockerized site:

```bash
wpstaging switch-php mysite.local 8.4
wpstaging switch-php mysite.local 8.1
```

**Supported PHP versions:** 7.4, 8.1, 8.2, 8.3, 8.4 (default: 8.1)

**What happens:**
1. Validates the PHP version is supported
2. Updates the `PHP_VERSION` setting in the site's `.env` file
3. Pulls the Docker image if not available locally
4. Regenerates Docker Compose and PHP configuration files
5. Restarts containers automatically if they are running

**Notes:**
- If containers are not running, configuration is updated but containers are not started
- All other site settings (database, ports, WordPress) remain unchanged
- The command requires exactly two arguments: hostname and PHP version

---

<a name="q116"></a>
**Q116: How do I change the WordPress version for an existing site?**  
**A116:**
Use the `switch-wp` command to change the WordPress version for an existing dockerized site:

```bash
wpstaging switch-wp mysite.local 6.5
wpstaging switch-wp mysite.local latest
wpstaging switch-wp mysite.local nightly
wpstaging switch-wp mysite.local 6.7-beta1
```

**Accepted version formats:** `X.Y`, `X.Y.Z`, `X.Y-beta1`, `X.Y-RC1`, `latest`, `nightly`

**What happens:**
1. Validates the WordPress version format
2. Regenerates PHP files to ensure the switch script is available
3. Executes the version switch inside the running container
4. Downloads WordPress core files for the target version
5. Updates the database schema if needed
6. Stores the actual resolved version in the site's `.env` file

**Notes:**
- Containers must be running (the switch runs inside the container via `docker exec`)
- Database, themes, plugins, and uploads are preserved
- Symbolic versions like `latest` are resolved to concrete versions (e.g. `6.7.2`) in `.env`

---

<a name="q117"></a>
**Q117: Why should I use VirtioFS on macOS?**  

**A117:**
On macOS, Docker shares files between your Mac and the running containers whenever WordPress inside a container reads or writes a file. The default sharing backend is slow, so sites start up slowly and any workflow that touches many files inside the container takes longer than it should. VirtioFS is a faster backend that removes most of this overhead, so sites feel more responsive and file-heavy container work finishes sooner.

VirtioFS does not speed up host-side archive extraction itself, but it improves the parts of `add`, `reset`, and `restore` that run inside the container once the site is up.

**To enable VirtioFS:**
1. Open Docker Desktop.
2. Go to Settings → General → Virtual file sharing.
3. Select **VirtioFS**.
4. Click **Apply & Restart**.

The CLI shows a tip during `add`, `reset`, `extract`, and `restore` if VirtioFS is not the active file-sharing mechanism. It fires once per switch away: once you enable VirtioFS the tip goes silent, and if you later switch back to a different mechanism the tip is shown again on the next run. This applies to macOS only.

---

<a name="q118"></a>
**Q118: How do I access the database GUI for a dockerized site?**  
**A118:**
By default, dockerized sites ship with a bundled Adminer database UI. Open `https://adminer.<site>` in your browser. The `/adminer/` subpath on the main site is not routed -- the dedicated subdomain is the only Adminer URL.

The login form is pre-filled with the database server, username, and database name. Enter the password shown when the site was created (also available in the site's `.env` file as `DB_PASSWORD`).

To disable Adminer, add `--disable-adminer` when creating, resetting, or regenerating a site:

```bash
wpstaging add https://mysite.local --disable-adminer
wpstaging reset mysite.local --disable-adminer
wpstaging generate-docker-file mysite.local --disable-adminer
wpstaging reconfigure mysite.local --disable-adminer
```

`reconfigure --disable-adminer` turns Adminer off on a live site without losing data: it updates the site's configuration and relaunches it, while WordPress files and the database are preserved.

The `DISABLE_ADMINER=true` setting is persisted in the site's `.env` file so future regenerations keep Adminer off.

If you upgraded from a CLI version that did not include Adminer, `start` and `restart` create the missing Adminer files automatically the first time -- no manual step is required.

---

<a name="q119"></a>
**Q119: How do I roll an older site forward after a CLI upgrade?**  
**A119:**
Run:

```bash
wpstaging reconfigure <site>
```

`reconfigure` updates the site's Docker setup (compose, nginx, PHP, SSL certificate) and relaunches the site. WordPress files and the database are preserved.

Use this to apply new defaults introduced by a CLI release (for example, to refresh the SSL certificate after the hostname list changed, or to pick up updated PHP-FPM or Nginx config after a CLI upgrade). For Adminer specifically, you do not need `reconfigure` -- `start` and `restart` regenerate the missing Adminer files automatically on sites created before Adminer support.

If you omit the hostname, all sites are reconfigured:

```bash
wpstaging reconfigure
```

---

<a name="q120"></a>
**Q120: What does the `sweep-ca-trust` command do?**  

**A120:**
`sweep-ca-trust` scans your system trust stores and removes stale WP Staging CLI certificate authority entries. Stale means the entry's fingerprint does not match the current active CA on disk. It checks the macOS keychain, Linux NSS database, Firefox profiles, and the Windows CurrentUser Root store. Other CAs (third-party, system, browser bundles) are not touched.

The command is hidden by default. Use `--show-all` to see it in help. It accepts two flags:

- `--dry-run` -- shows what would be removed without changing anything.
- `--include-legacy` -- also removes legacy `mkcert development CA` entries left by older builds. Asks for confirmation before running.

Run it when you want to clean up trust store bloat:

```bash
wpstaging sweep-ca-trust --dry-run            # preview only
wpstaging sweep-ca-trust                      # remove stale WP Staging CLI entries
wpstaging sweep-ca-trust --include-legacy     # also remove old mkcert-branded entries
```

This command does not need Docker to be running.

---

<a name="q121"></a>
**Q121: Why does my system trust store have so many `mkcert development CA` entries?**  

**A121:**
Older WP Staging CLI builds left a trust store entry behind every time you ran `reinstall-ca` (or its `reinstall-cert --reinstall-ca` alias) or `remove`. Each cycle generated a new CA but never deleted the old one. Over time these entries pile up.

The entries do not break anything. They are harmless trust orphans.

To clean them up, run:

```bash
wpstaging sweep-ca-trust --include-legacy
```

The command lists how many entries it found and asks you to confirm before removing them. It keeps the current active CA intact.

Going forward, this problem stops growing. Newer builds brand the CA as `WP Staging CLI development CA` and clean up stale entries automatically every time you run `reinstall-ca`.

---

<a name="q122"></a>
**Q122: What happens when my local site's SSL certificate expires?**  

**A122:**
WP Staging CLI rotates local site SSL certificates automatically before they expire. Each leaf certificate is valid for 2 years and 3 months. When a certificate is within 30 days of its expiry date, the next `start`, `restart`, `add`, or `reinstall-cert` command for that site re-issues the certificate using the same CA. You do not need to take any action.

This means active sites never show a "certificate expired" warning in the browser. If you have a site you have not run for more than two years, the next site command rotates its certificate before serving traffic.

The CA itself is valid for 10 years and stays in your system trust store. Only the per-site leaf certificate rotates.

If you want to force a rotation early (for example, after changing the hostname), run:

```bash
wpstaging reinstall-cert <hostname>
```

The site is restarted automatically when the certificate is re-issued. Pass `--skip-restart` if you want to defer the restart and apply it yourself later.

---

<a name="q123"></a>
**Q123: How do I check if my SSL certificate is trusted across browsers?**  

**A123:**
Run `wpstaging verify-cert`. The command audits the certificate authority across every browser trust store and inspects each site's leaf certificate. It reports the trust state for every store and per site. The command does not modify anything.

The trust stores it checks differ by platform:

- Linux: the user NSS database at `~/.pki/nssdb` (shared by Chrome, Edge, Brave, and other Chromium-family browsers) and each Firefox profile.
- macOS: the System keychain (used by Safari, Chrome, Edge, and Brave).
- Windows: the CurrentUser Root store (used by Edge, Chrome, and Internet Explorer).

The Linux system trust store at `/etc/ssl/certs` is not part of this audit. That store backs CLI tools like `curl` and `openssl`, not browsers. To inspect it, use `wpstaging sweep-ca-trust --dry-run`.

Pass a hostname to scope the per-site section to one site:

```bash
wpstaging verify-cert mysite.local
```

Pass `--live` to open a TLS connection to each site and compare the served certificate against the on-disk file. This helps you spot a stopped site or a container serving an older certificate:

```bash
wpstaging verify-cert --live
```

Pass `--json` for a machine-readable report that scripts and integrations can parse.

The command exits with code `0` when everything is trusted and non-zero otherwise, so you can use it in shell scripts to detect when action is needed.

---

<a name="q124"></a>
**Q124: How do I skip the auto-restart after `reinstall-cert` or `reinstall-ca`?**  

**A124:**
Pass the `--skip-restart` flag. Both commands accept it:

```bash
wpstaging reinstall-cert <hostname> --skip-restart
wpstaging reinstall-ca --skip-restart
```

The certificate files on disk are still regenerated as usual. The command prints a hint that tells you the exact `wpstaging restart` command to run later when you are ready.

Use `--skip-restart` when you want to schedule the restart yourself. For example, when you do not want to interrupt a running test, or when you plan to apply other configuration changes before bringing the containers back up.

<a name="q125"></a>
**Q125: Why does `wpstaging` only ask for my sudo password once now?**  

**A125:**
On Linux and macOS, the first command that needs sudo prompts for your password as before. After that, `wpstaging` keeps the credentials warm with a small background helper. While the same terminal stays open, you will not be asked again, even if a later command also needs sudo (for example, to update `/etc/hosts`, install an SSL certificate, or set up a loopback IP).

The helper:

- Runs as a detached background process tied to your terminal.
- Refreshes the sudo timestamp every 4 minutes (sudo's own cache lasts 5 minutes by default).
- Stops automatically when you close the terminal.
- Stops automatically after 12 hours by default, even if the terminal is still open. After that you will be asked for your sudo password again on the next command that needs it.
- Is skipped on Windows (Windows uses UAC dialogs instead) and when you are already running as root.

To change the 12-hour limit, set the environment variable before the command. Use a duration like `6h` or `30m`:

```bash
WPSTGCLI_SUDO_KEEPALIVE_MAX_LIFETIME=6h wpstaging add example.local
```

To turn the helper off for a single command, set the environment variable before the command:

```bash
WPSTGCLI_DISABLE_SUDO_KEEPALIVE=1 wpstaging add example.local
```

To turn it off for the whole shell session:

```bash
export WPSTGCLI_DISABLE_SUDO_KEEPALIVE=1
```

This is useful in CI scripts or other automated runs where you want sudo to behave the way it did before.

<a name="q125a"></a>
**Q125a: I have Touch ID enabled for sudo on macOS. Will the helper trigger Touch ID prompts in the background?**  

**A125a:**
No. The background helper runs `sudo -n -v` in non-interactive mode. The macOS Touch ID PAM module (`pam_tid.so`) respects the non-interactive flag and does not show a dialog. You see Touch ID one time at the start of the terminal session, when sudo first asks for authentication. After that, the helper refreshes the cache silently in the background and Touch ID stays quiet for the rest of the session.

<a name="q125b"></a>
**Q125b: I see a `wpstaging sudo-keepalive` process in `ps`. Should I be worried?**  

**A125b:**
No. That is the small background helper described in [Q125](#q125). One copy runs per terminal session that has used `wpstaging` with a sudo command. It refreshes your sudo timestamp every 4 minutes so you do not get asked for the password again. It uses very little memory and does almost nothing between refreshes.

The full command line looks like:

```
wpstaging sudo-keepalive --pid-file <TMPDIR>/wpstaging-sudo-keepalive-<uid>-<sid>.pid --leader-sid <pid> --max-lifetime 12h0m0s
```

- `<uid>` is your Linux or macOS user ID.
- `<sid>` and the `--leader-sid` value are the same number: the PID of your shell (the session leader of your terminal).
- `<TMPDIR>` is your system's temporary directory. On Linux it is usually `/tmp`. On macOS it is usually under `/var/folders/...`; run `echo $TMPDIR` to see your exact path.
- The PID file is a small marker that stops a second helper from starting in the same terminal.
- `--max-lifetime` is the upper bound on how long the helper may run before exiting on its own (default 12 hours; see [Q125](#q125) to change it).

The helper stops on its own when:

- You close the terminal, or your SSH session ends.
- You remove its PID file. The helper notices within about 30 seconds and exits:

  ```bash
  rm "${TMPDIR:-/tmp}"/wpstaging-sudo-keepalive-*.pid
  ```

- You stop it directly:

  ```bash
  pkill -f "wpstaging sudo-keepalive"
  ```

If you do not want the helper to start at all, see [Q125](#q125) for the `WPSTGCLI_DISABLE_SUDO_KEEPALIVE=1` environment variable.

<a name="q125c"></a>
**Q125c: After my Mac wakes from idle, `sudo` asks for my password again. Is the helper broken?**  

**A125c:**
No. macOS wipes the sudo timestamp when the system goes idle and sleeps, even though the `wpstaging sudo-keepalive` helper is still running. A manual screen lock (Ctrl+Cmd+Q, hot corner) does not wipe the timestamp — only the idle-triggered sleep does.

The helper uses `sudo -n -v` in non-interactive mode (see [Q125a](#q125a)). That mode can extend an existing sudo ticket but cannot create one from scratch, so it has nothing to refresh until you authenticate again.

After you enter your password (or use Touch ID) on the next `sudo` command, the timestamp comes back on the same terminal. The helper's next refresh, within 4 minutes, sees the warm ticket and starts extending it again. You will not be asked again until the next idle sleep or the 12-hour lifetime cap (see [Q125](#q125)).

This is a one-time prompt per idle-sleep cycle, not a bug. macOS clears the sudo timestamp on system sleep on purpose, and a non-interactive helper has no way to re-arm it without you typing the password.

---

**Q125: How do I clear the WP-CLI download cache?**  

**A125:**
Run `wpstaging clean wpcli`. The command removes three directories shared across all your dockerized sites:

- `<env-path>/wpstaging/stack/wp-cli/cache/plugin/`
- `<env-path>/wpstaging/stack/wp-cli/cache/core/`
- `<env-path>/wpstaging/stack/wp-cli/wp-staging-pro/`

By default `<env-path>` is `~/wpstaging`. Pass `--env-path` to target a custom location.

The cache holds downloaded plugin ZIP files, WordPress core archives, and the WP Staging Pro plugin used during site setup. Deleting it forces the next `add` or `reset` to download fresh copies. The directories are recreated on demand, so this is safe to run at any time.

`wpstaging clean all` also clears these directories, on top of the general cache and the stored license key.

---

<a name="q126"></a>
**Q126: What happens if I press Ctrl-C while `wpstaging add` is running?**  

**A126:**
The CLI catches the signal and runs a rollback before it exits:

1. It stops and removes the per-site Docker containers.
2. It deactivates the WP Staging Pro license for the site URL.
3. It removes the half-created site directory **only when the directory did not exist before this `add` started**. If you ran `add` over an existing partial site, the directory is kept so you do not lose your earlier data.

You will see two lines on stdout that confirm the rollback ran. The first line is always the same; the second line depends on whether the site directory was kept:

```
Cancelled, rolling back partial site: <hostname>
Rollback complete: <hostname>
```

If `add` ran over a site directory that already existed, the second line is instead:

```
Rollback complete (kept existing site directory): <hostname>
```

The same handler works for `SIGINT` (Ctrl-C) and `SIGTERM`. `SIGKILL` cannot be caught by any program, so it bypasses the rollback.

You can safely re-run `wpstaging add <hostname>` afterwards. The CLI cleans up any leftover container from the prior cancelled run, so the next attempt starts clean.

---

<a name="q127"></a>
**Q127: How does wp-admin auto-login work, and how do I turn it off?**  

**A127:**
Sites you create with `wpstaging add` print a one-time magic-link URL on success. Open the URL in any browser and the site sets the auth cookie for the lowest-ID administrator and redirects you to the WordPress dashboard. You do not need to type a username or password.

The magic-link is single-use: clicking it consumes the token. Run `wpstaging list <site>` to see the current URL -- the command auto-refreshes the URL when the previous one has expired, so the printed link is always usable. Run `wpstaging magic-link <site>` to force-issue a new URL on demand. The regular `/wp-login.php` form is always available alongside the magic-link if you want to sign in as a different user.

The auto-login script lives outside the WordPress webroot, in the site's Docker configuration directory at `<site>/docker/php/magiclink/`. It is never copied into `.wpstg` backups and never pushed to production.

To turn the magic-link feature off, add `--disable-magic-link` when creating, resetting, or regenerating a site:

```bash
wpstaging add https://mysite.local --disable-magic-link
wpstaging reset mysite.local --disable-magic-link
wpstaging generate-docker-file mysite.local --disable-magic-link
wpstaging reconfigure mysite.local --disable-magic-link
```

`reconfigure --disable-magic-link` turns auto-login off on a live site without losing data. It updates the site's configuration and relaunches it, while WordPress files and the database are preserved.

The `DISABLE_MAGIC_LINK=true` setting is persisted in the site's `.env` file so future regenerations keep auto-login off. Pass `--disable-magic-link=false` to a later `reconfigure` to turn it back on.

To reach the regular WordPress login form, open `/wp-login.php` directly. The auto-login URL is single-use and only triggers on its own dedicated path, so the standard WordPress login form is always available alongside it.

---

<a name="q128"></a>
**Q128: How do I give my site a friendly display name?**  

**A128:**
Pass `--label` when you create the site: `wpstaging add staging.local --label "Acme Production Staging"`. To change the label on an existing site, run `wpstaging reconfigure <hostname> --site-label "<new label>"` without restarting any container.

The label appears in `wpstaging list` and in the `label` field of `wpstaging list --json`. The hostname stays as the unique identifier you use to target the site with other commands.

---

<a name="q129"></a>
**Q129: How do I replace the CA without re-signing my site certificates?**  

**A129:**
Pass the `--skip-leaf` flag to `reinstall-ca`:

```bash
wpstaging reinstall-ca --skip-leaf
```

This generates a new certificate authority, installs it into your system trust stores, and stops there. Existing site certificates are not re-signed and stay on disk.

Browsers will not trust the existing certificates anymore because they still chain to the old CA. To restore trust for one site, run `wpstaging reinstall-cert <hostname>`. To re-sign every site in one pass, run `wpstaging reinstall-ca` again without `--skip-leaf`.

Use `--skip-leaf` when you want to install a new CA and re-sign sites on your own schedule. For example, before a planned maintenance window where you control when each site is restarted.

---

<a name="q130"></a>
**Q130: How do I show announcements I previously dismissed?**  

**A130:**
Pass the `--clear-acks` flag to `update`:

```bash
wpstaging update --clear-acks
```

This clears the acknowledgement cache. Announcements you previously dismissed with `update --acknowledge <id>` or `update --acknowledge all` will re-appear on the next `update` run or daily background check.

The flag does not touch the update or announcement content cache. To force a fresh fetch of announcements from `wp-staging.com`, use `update --clear-cache` instead.

`wpstaging clean cache` does not clear acknowledgements either. Only `update --clear-acks` removes them.

---

<a name="q131"></a>
**Q131: How do I force a reinstall of the same version of `wpstaging`?**  

**A131:**
Pass the `--force` flag to `update`. This bypasses the "already at latest" check and reinstalls the latest stable binary on top of the running one:

```bash
wpstaging update --force
```

You can also force a reinstall of a specific version:

```bash
wpstaging update --force --version <version>
```

This is an escape hatch for edge cases, for example when a previous update wrote the binary correctly but left on-disk state in a bad shape, or when you want to repeat a recent install. The CLI hides `--force` from regular `--help` output for that reason.

**If `wpstaging` does not run at all** (corrupted binary, missing file, or any state that `--force` cannot work around), re-run the install script instead. It does not depend on the existing binary:

```bash
# Linux / macOS
curl -fsSL https://wp-staging.com/install.sh | bash

# Windows PowerShell
irm https://wp-staging.com/install.ps1 | iex
```

---

<a name="q132"></a>
**Q132: On Windows my new site's files are in a Docker volume instead of a normal folder. What is "fast mode" and how do I turn it off?**  
**A132:**
On Windows, Docker Desktop shares host files into containers over a slow bridge (NTFS through 9p), which makes creating and running sites far slower than on macOS or Linux. To avoid this, `wpstaging` turns on **fast mode** by default on Windows: it stores the WordPress webroot in a fast Docker volume (on the WSL2 Linux filesystem) so the container reads and writes at native speed, and it runs a small sidecar container that mirrors that volume to the browsable folder at `sites/<hostname>/www`. You still edit your themes and plugins in that folder in Explorer as usual — your changes sync into the volume, and files WordPress writes (uploads, cache) appear back in the folder.

Fast mode is Windows only. macOS and Linux are unaffected (their bind mounts are already fast), so the flag has no effect there.

To create a site **without** fast mode (a classic bind mount, files stored directly in `sites/<hostname>/www`), pass `--fast-mode=false`:

```bash
wpstaging add mysite.local --fast-mode=false
```

The choice is saved per site (as `FAST_MODE` in the site's `.env`), so `start`, `restart`, and `reconfigure` keep it. It only applies when the site is created — there is no in-place switch, so to change an existing site's mode you recreate it.

To check whether a site uses fast mode and whether its file sync is running:

```bash
wpstaging sync-status mysite.local
```

Tip: for the fastest sync, exclude the site's synced folder from Windows Defender real-time scanning. The CLI prints the exact `Add-MpPreference` command after it creates a fast-mode site.

---

**Last Updated:** 2026-07-05 17:45:00 UTC
