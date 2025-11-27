# WP Staging CLI FAQ

## General Questions

<a name="q0"></a>
**Q1: What is `wpstaging`?**  
**A1:** `wpstaging` is a high-performance command-line tool to process WP Staging backup files (`.wpstg`). It allows you to extract, normalize, inspect, and restore backups without using WordPress itself.

<a name="q1"></a>
**Q2: Which operating systems are supported?**  
**A2:**
Windows, Linux, and macOS. Pre-built binaries are available for all major OSes.

<a name="q2"></a>
**Q3: Do I need a license to use this tool?**  
**A3:**
Yes. You need a valid WP Staging Agency or Developer license key to access backup files.

<a name="q3"></a>
**Q4: How fast is it?**  
**A4:**
Benchmarks show it can extract a 20GB backup in under 36 seconds on an AMD Ryzen 7 PRO 7840U with a fast SSD running Ubuntu 20.04.

## Installation Questions

<a name="q4"></a>
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
- Install bash completion (Linux/macOS)

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

For complete installation details, see the [Installation section in README](../README-RELEASES.md#installation).

<a name="q5"></a>
**Q6: Can I use it without installing?**
**A6:**
Yes, you can run the binary directly from the extracted folder.

<a name="q6a"></a>
**Q6a: How do I uninstall wpstaging?**
**A6b:**
Use the quick uninstall script (recommended):

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

The uninstaller will remove:
- The wpstaging binary and aliases
- PATH entries
- License key environment variable
- Cache directories

**Note:** If you've used Docker features, run `wpstaging uninstall` first to remove Docker containers and data before uninstalling the CLI.

For complete uninstallation details, see the [Uninstallation section in README](../README-RELEASES.md#uninstallation).

## Usage Questions

<a name="q6"></a>
**Q7: How do I run `wpstaging`?**  
**A7:**
Use the following command:
```bash
wpstaging [commands] [flags] <backupfile.wpstg>
```
Commands must come first. Flags and the backup file can appear in any order.

<a name="q7"></a>
**Q8: What are the main commands?**  
**A8:**
WP Staging CLI has four main command groups:

**Site Commands:**
- `add` – Add a new WordPress site
- `list` – List all sites or show details for a specific site
- `del` – Delete a WordPress site
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
- `status [hostname]` – Display container status (all sites or specific site)
- `shell <hostname> [root]` – Open an interactive shell in the PHP container
- `uninstall` – Stop containers and remove all Docker data
- `update-hosts-file` – Update the local hosts file with site entries
- `generate-compose-file` – Generate a docker-compose.yml file
- `generate-docker-file` – Generate Docker configuration files

**Other Commands:**
- `register` – Activate your WP Staging Pro license
- `clean` – Clean up cached data, license info, and temporary files
- `help` – Help about any command

Use `wpstaging [command] --help` for detailed information about each command.

<a name="q8"></a>
**Q9: How do I register my license?**  
**A9:**
You can provide your license in three ways:

**Option 1: Register Your License (Recommended)**
```bash
# Interactive mode (prompts for license key)
wpstaging register

# Non-interactive mode (useful for scripts/automation)
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

<a name="q9"></a>
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

<a name="q10"></a>
**Q11: How can I extract and normalize the database file?**  
**A11:**
```bash
wpstaging extract --normalizedb backupfile.wpstg
```

<a name="q11"></a>
**Q12: How can I restore to a different WordPress path?**  
**A12:**
Use the `--path` flag:
```bash
wpstaging restore --path=/var/www/site backupfile.wpstg
```
If running from the WP root, `--path` is optional.

## Filter Flags Questions

<a name="q12"></a>
**Q13: Can I extract only specific parts of the backup?**  
**A13:**
Yes, using “Only-Filters”:
- `--only-wpcontent` – Only extract `wp-content`.
- `--only-plugins` – Only extract plugins.
- `--only-file=<string>` – Extract only matching files.

<a name="q13"></a>
**Q14: Can I skip certain parts?**  
**A14:**
Yes, using "Skip-Filters":
- `--skip-wpcontent` – Skip `wp-content`.
- `--skip-uploads` – Skip uploads.
- `--skip-file=<string>` – Skip files matching a string.

<a name="q14"></a>
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

<a name="q15"></a>
**Q16: How do I restore to an external database?**  
**A16:**
Use DB-related flags:
```bash
wpstaging restore --path=/var/www/site \
  --db-name=dbname --db-user=user --db-pass=pass --db-host=host backupfile.wpstg
```

<a name="q16"></a>
**Q17: Can I overwrite existing files or DB tables?**  
**A17:**
Yes, use:
- `--overwrite=<yes|no>` – Overwrite target directory.
- `--overwrite-db=<yes|no>` – Remove DB tables not in backup.
- `--overwrite-wproot=<yes|no>` – Remove WP root files not in backup or core.

## Config File Questions

<a name="q17"></a>
**Q18: What is the default configuration file used for?**  
**A18:**
The config file is used to store **flags only**, not commands. It allows you to avoid repeatedly typing commonly used flags, such as paths, database credentials, filters, or Docker flags.

**Default config file location (OS-specific):**
- **Linux/Unix:** `~/.config/wpstaging/wpstaging.conf`
- **macOS:** `~/Library/Application Support/wpstaging/wpstaging.conf`
- **Windows:** `%APPDATA%\wpstaging\wpstaging.conf`

<a name="q18"></a>
**Q19: Can I skip reading the config file?**  
**A19:**
Yes, use the `--skip-config` flag when running any command. This ensures the CLI ignores the config file entirely and only uses flags provided on the command line.

<a name="q19"></a>
**Q20: Do CLI flags override the config file?**  
**A20:**
Yes. Any flag provided directly in the CLI command will override the corresponding value in the config file.

<a name="q20"></a>
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

<a name="q21"></a>
**Q22: Can I use multiple config files?**  
**A22:**
WP-Staging-CLI only reads one config file at a time. By default, it uses the OS-specific config location (see [Q18](#q18)), but you can override it with a custom file using `--config=file.conf`. You can also temporarily bypass it using `--skip-config` and pass all flags directly on the CLI.

## Docker Questions

<a name="q22"></a>
**Q23: Where is the Docker environment setup?**  
**A23:**
By default, Docker-related files are stored in `~/wpstaging/`. Each WordPress site has its own isolated directory in `~/wpstaging/sites/<sitename>/`. You can change the parent location with the `--env-path=<path>` flag.

**Note:** The `--env-path` specifies a parent path. The CLI automatically appends `wpstaging/` to it. For example:
- `--env-path=/tmp/test` → actual path: `/tmp/test/wpstaging/`
- Site directory: `/tmp/test/wpstaging/sites/<hostname>/`

<a name="q23"></a>
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

<a name="q24"></a>
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

<a name="q26"></a>
**Q27: How can I configure PHP version or ports?**  
**A27:**
PHP version and ports can be configured in two ways:

**1. During site creation (using `add` command):**
```bash
wpstaging add mysite.local --php=8.3 --http-port=8080 --https-port=8443
```

**2. After site creation (edit the `.env` file):**
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

**Note:** These settings cannot be changed via the `start` command — only during initial creation or by editing `.env` manually.

<a name="q27"></a>
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
To avoid specifying `--compose-file` every time, add it to your config file `~/.wpstaging/wpstaging.conf`:

```ini
--compose-file /path/to/custom-compose.yml
```

Now all commands will automatically use your custom compose file path, and it will stay synchronized with your configuration changes.

**Note:** If you manually edit the compose file outside of wpstaging, those changes will be overwritten when wpstaging regenerates it.

<a name="q29"></a>
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
- `--wp` - WordPress version to install (default: `latest`)
- `--multisite` - Install as multisite

Example:
```bash
wpstaging add mysite.local \
  --wp=6.4 \
  --admin-user=johndoe \
  --admin-email=john@example.com \
  --multisite
```

<a name="q30"></a>
**Q31: How do I disable the Mailpit container?**  
**A31:**
Use `--disable-mailpit` when creating a site to prevent the Mailpit container from running:
```bash
wpstaging add mysite.local --disable-mailpit
```

<a name="q31"></a>
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

<a name="q32"></a>
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
- `--db-root` flag is ignored (no root user needed)
- `--db-port` can be used to specify the external database port (default: 3306)
- The `DB_HOST` value is saved to the `.env` file

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

**Note:** The `reset` command will reinstall WordPress and erase all site data. If you want to preserve your data, first create a backup using the WP Staging plugin, then use the `restore` command:
```bash
wpstaging restore --path=/path/to/sites/mysite.local/www backup.wpstg
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

<a name="q35"></a>
**Q36: How do I enable debug messages?**  
**A36:**
Use `-d` or `--debug`.

<a name="q36"></a>
**Q37: Can I suppress output?**  
**A37:**
Yes, use `-q` or `--quiet`.

<a name="q37"></a>
**Q38: How do I verify the integrity of extracted files?**  
**A38:**
Use the `--verify` flag.

<a name="q38"></a>
**Q39: How do I enable debug messages?**  
**A39:**
Use `-d` or `--debug`.

<a name="q39"></a>
**Q40: Can I suppress output?**  
**A40:**
Yes, use `-q` or `--quiet`.

<a name="q40"></a>
**Q41: How do I verify the integrity of extracted files?**  
**A41:**
Use the `--verify` flag.

<a name="q41"></a>
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

<a name="q42"></a>
**Q43: I get "port already in use" error when using the Docker environment. What should I do?**  
**A43:**
The CLI now has **automatic port conflict detection and resolution**! The tool automatically detects port conflicts and tries alternative ports.

### Automatic Port Resolution

When you run `add` or `start` commands, the CLI automatically:

1. **Checks if ports are available**
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
# If you don't need MariaDB (using external database)
wpstaging add mysite.local --disable-mariadb

# If you don't need Mailpit
wpstaging add mysite.local --disable-mailpit
```

When services are disabled, their port validation is automatically skipped.

## Command-Specific Flags Questions

<a name="q43"></a>
**Q44: Why can't I use `--site-url` with the root command?**  
**A44:**
Flags like `--site-url`, `--db-prefix`, `--normalizedb`, and `--verify` are command-specific. You must use them with their respective commands:
- `--site-url` and `--db-prefix` work with both `extract` and `restore`
- `--normalizedb` only works with `extract`
- Use: `wpstaging extract --site-url=https://example.com backup.wpstg`
- Not: `wpstaging --site-url=https://example.com extract backup.wpstg`

<a name="q44"></a>
**Q45: What flags are available globally vs command-specific?**  
**A45:**
**Global flags** (work with all commands):
- `--outputdir`, `--workingdir`, `--debug`, `--quiet`, `--yes`, `--allow-root`

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

<a name="q46"></a>
**Q47: When does license validation occur?**  
**A47:**
License validation happens automatically when you run any backup-related or Docker command (extract, restore, dump-*, add, start, etc.). Commands like `help`, `register`, and `clean` skip license validation.

<a name="q47"></a>
**Q48: Do I need a license to view help messages?**  
**A48:**
No. Running `wpstaging --help` or `wpstaging extract --help` does not require license validation. You only need a valid license when executing actual operations.

<a name="q48"></a>
**Q49: How is my license stored and validated?**  
**A49:**
After you register your license using `wpstaging register`, the key is encrypted and stored locally. The CLI automatically validates your license when running backup-related or Docker commands, and caches the validation results for 4 hours to minimize API calls.

## Troubleshooting Questions

<a name="q49"></a>
**Q50: I get "Error: Backup file does not exist" but the file is there. Why?**  
**A50:**
Make sure you're providing the correct path to the `.wpstg` file. Use absolute paths if running from a different directory:
```bash
wpstaging extract /full/path/to/backup.wpstg
```

<a name="q50"></a>
**Q51: Can I run multiple extraction/restore operations simultaneously?**  
**A51:**
No. The CLI uses file-based locking to prevent concurrent operations on the same backup file. If you need parallel operations, use different backup files.

<a name="q51"></a>
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

<a name="q52"></a>
**Q53: I get "Error: Failed to open the backup file" on Windows. Help?**  
**A53:**
Ensure:
1. The file path doesn't contain special characters
2. You have read permissions on the file
3. The file isn't locked by another program
4. Use quotes around paths with spaces: `wpstaging extract "C:\My Backups\backup.wpstg"`

## Performance Questions

<a name="q53"></a>
**Q54: How can I speed up extraction?**  
**A54:**
- Use fast storage (SSD/NVMe) for both source and destination
- Skip unnecessary parts with `--skip-*` flags
- Disable verification (`--verify` adds overhead)
- Run on systems with good I/O performance

<a name="q54"></a>
**Q55: Does the CLI support multi-threading?**  
**A55:**
The CLI is optimized for single-threaded sequential extraction with efficient streaming. Multi-threading isn't needed as disk I/O is typically the bottleneck.

<a name="q55"></a>
**Q56: How much memory does the CLI require?**  
**A56:**
Memory usage is minimal (typically <100MB) even for large backups because the CLI uses streaming extraction rather than loading entire files into memory.

## SSL Certificate and Browser Trust Questions

<a name="q56"></a>
**Q57: Why does my browser show "Your connection is not private" or "Not Secure" warnings?**  
**A57:**
This warning appears when your browser doesn't trust the SSL certificate used by your local development site. There are two common scenarios:

**Scenario 1: Using self-signed certificates (default without mkcert)**
- Self-signed certificates are not trusted by browsers by default
- You'll see warnings like "NET::ERR_CERT_AUTHORITY_INVALID"
- You can click "Advanced" → "Proceed to site" to bypass (not recommended for production)

**Scenario 2: mkcert CA not installed in system trust store**
- The mkcert Certificate Authority (CA) needs to be installed to your system
- This happens automatically during first setup when you confirm the installation prompt
- If you skipped the installation, you'll still see browser warnings

**How to fix this:**

1. **Recommended: Use mkcert (automatic when creating a site)**
   ```bash
   wpstaging add mysite.local
   ```
   When creating your first site, you'll be prompted to install the security certificate. Choose "Yes" to install the CA to your system trust store. This is a one-time operation that works for all future sites.

2. **If you skipped CA installation, create another site:**
   ```bash
   wpstaging add anothersite.local
   ```
   The tool will detect that the CA isn't installed and prompt you again.

3. **Manual bypass (not recommended):**
   Click "Advanced" → "Proceed to site" in your browser. This only works for the current session and doesn't actually solve the trust issue.

<a name="q57"></a>
**Q58: What is mkcert and why does WP Staging CLI use it?**  
**A58:** mkcert is a trusted tool for creating locally-trusted SSL certificates for development environments. WP Staging CLI uses mkcert to provide a seamless HTTPS development experience.

**What mkcert does:**
- Creates a local Certificate Authority (CA) on your computer
- Generates SSL certificates signed by this CA
- Installs the CA to your system's trust store (browsers, OS)
- Makes your local sites trusted automatically - no more browser warnings

**Why we use mkcert instead of self-signed certificates:**

**Self-signed certificates (old approach):**
- ❌ Browser shows scary "Not Secure" warnings
- ❌ Requires manual bypass for every site
- ❌ Breaks some JavaScript features requiring HTTPS
- ❌ Service Workers and PWA features don't work
- ❌ Different behavior from production environments
- ❌ Chrome requires additional flags to bypass warnings

**mkcert certificates (current approach):**
- ✅ Automatically trusted by all major browsers (Chrome, Firefox, Safari, Edge)
- ✅ No browser warnings - green padlock icon
- ✅ Identical HTTPS behavior to production
- ✅ Service Workers, PWA, and secure features work properly
- ✅ Better testing environment - catches HTTPS-related issues early
- ✅ One-time setup, works for all local sites

<a name="q58"></a>
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

<a name="q59"></a>
**Q60: Why does mkcert installation require sudo (Linux/macOS) or administrator permission (Windows)?**  
**A60:**
Installing a Certificate Authority (CA) to the system trust store is a system-level operation that requires elevated privileges. Here's why:

**What the installation does:**
1. **Creates a root CA certificate** in `~/wpstaging-dockerize/docker/nginx/ca/`
2. **Installs the CA to system trust stores:**
   - **Linux:** `/usr/local/share/ca-certificates/` (requires sudo)
   - **macOS:** System Keychain (requires admin password)
   - **Windows:** Certificate Manager (requires administrator)
3. **Updates browser trust stores:**
   - **Linux:** Chrome/Chromium NSS database (no sudo needed)
   - **macOS:** Explicitly sets trustRoot policy for Firefox compatibility
   - **Windows:** Uses Windows certificate store (all browsers)

**Why sudo/admin is required:**
- System trust stores are protected locations
- Modifying them affects all users on the system
- Security measure to prevent malware from installing rogue CAs
- One-time operation - subsequent certificate generation doesn't need sudo

**What if I skip the sudo installation?**
- The CA files are still created locally
- SSL certificates are generated and used by Nginx
- BUT: Your browser won't trust them (shows warnings)
- You can still bypass warnings manually with "Proceed to site"

**Security note:** The CA created by mkcert is stored locally and never leaves your computer. It's only used to sign certificates for your local development sites.

<a name="q60"></a>
**Q61: Does the mkcert CA installation affect my system security?**  
**A61:**
The mkcert CA is designed specifically for local development and is safe to install. Here's what you should know:

**Security design:**
- ✅ CA private key is stored locally only (`~/wpstaging-dockerize/docker/nginx/ca/rootCA-key.pem`)
- ✅ Never transmitted over network
- ✅ Only used for local development sites
- ✅ Cannot be used to intercept real websites (different domains)
- ✅ Standard practice used by thousands of developers worldwide

**Best practices:**
- Keep the CA private key secure (don't share or commit to git)
- Only install CAs you created yourself
- Uninstall the CA when you stop using local development (optional)
- The CLI stores CA in project directory for isolation

**To uninstall (if needed):**
1. Stop and remove Docker environment:
   ```bash
   wpstaging uninstall
   ```
2. Manually remove CA from system (optional):
   - Linux: `sudo rm /usr/local/share/ca-certificates/rootCA.pem && sudo update-ca-certificates`
   - macOS: Open Keychain Access, search "mkcert", delete the certificate
   - Windows: Open Certificate Manager, remove "mkcert" from Trusted Root CAs

<a name="q61"></a>
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
2. The tool installs the mkcert CA to your system trust store (Safari/Chrome trust it immediately)
3. Platform-specific browser support is configured automatically:
   - **Linux:** Installs to Chrome's NSS database
   - **macOS:** Sets trustRoot policy for Firefox (Safari/Chrome already covered by step 2)
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

<a name="q62"></a>
**Q63: My browser still shows warnings after installing the CA. What's wrong?**  
**A63:**
If you're still seeing warnings after confirming CA installation, try these troubleshooting steps:

**1. Verify CA is actually installed:**
- **Linux:** `ls /usr/local/share/ca-certificates/ | grep rootCA` (should show rootCA.pem)
- **macOS:** Open Keychain Access, search for "mkcert" (should appear in System keychain)
- **Windows:** Open certmgr.msc, check "Trusted Root Certification Authorities"

**2. For Chrome/Chromium on Linux specifically:**
The CA must be installed to both the system trust store AND the NSS database. The CLI does this automatically, but you can verify:
```bash
certutil -d sql:$HOME/.pki/nssdb -L | grep mkcert
```

If missing, the CLI should have installed it, but you can manually add:
```bash
certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n "mkcert CA" -i ~/wpstaging-dockerize/docker/nginx/ca/rootCA.pem
```

**3. Restart your browser:**
After CA installation, close and reopen your browser completely (not just the tab).

**4. Check certificate details in browser:**
- Click the "Not Secure" warning in address bar
- View certificate details
- Verify the certificate includes your site's hostname and the container IP

**5. Verify certificate was generated:**
```bash
ls ~/wpstaging/sites/yoursite.local/config/nginx/certs/
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

<a name="q63"></a>
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

<a name="q64"></a>
**Q65: Can I use external databases with the Docker environment?**  
**A65:**
Yes, use `--disable-mariadb` and point to your external database:
```bash
wpstaging add mysite.local --disable-mariadb \
  --wp-db-host=external-db.example.com \
  --wp-db-name=mydb --wp-db-user=user --wp-db-pass=pass
```

<a name="q65"></a>
**Q66: How do I manage multiple WordPress sites in Docker?**  
**A66:**
Use the site management commands:
```bash
# Add new sites
wpstaging add site1.local
wpstaging add site2.local

# List all sites
wpstaging list

# Manage individual sites
wpstaging stop site1.local
wpstaging start site1.local
wpstaging shell site1.local
wpstaging del site2.local

# Manage all sites at once
wpstaging start          # Start all sites
wpstaging stop           # Stop all sites
wpstaging restart        # Restart all sites
wpstaging status         # Show status of all sites
```

Each site runs in its own isolated set of containers with unique IPs and ports.

<a name="q66"></a>
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

<a name="q67"></a>
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

<a name="q68"></a>
**Q69: Where are Docker logs stored?**  
**A69:**
Docker container logs are accessible via `docker logs`. The CLI stores configuration files in `~/wpstaging/` by default (or your custom `--env-path`).

<a name="q69"></a>
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

<a name="q70"></a>
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
# Saved in ~/.wpstaging/sites/site1.local/.env

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

<a name="q71"></a>
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
1. CLI automatically finds the next available IP in the 127.3.2.x range
2. Binds the IP using `sudo ifconfig lo0 alias 127.3.2.X netmask 255.255.255.255`
3. Creates the site with the assigned IP
4. You'll be prompted for your password (per terminal session, 5-15 min timeout)

**Passwordless sudo (recommended for macOS):**
On macOS, automatic IP alias binding is enabled by default for seamless multi-site setups using loopback IP range **127.3.2.1 - 127.3.2.254**. This requires sudo for IP binding and hosts file updates. To avoid repeated password prompts, see [Q87](#q87) for complete passwordless sudo setup instructions.

**About sudo password prompts on macOS:**
By default, sudo uses per-terminal session authentication (5-15 minute timeout). You'll be prompted for your password in each new terminal window when adding sites. Options:
- **Recommended:** Set up passwordless sudo (see [Q87](#q87)) for seamless automatic IP binding from the 127.3.2.x range — **this is the intended workflow**
- **Alternative:** Use `--skip-macos-auto-ip` flag to disable automatic IP binding and perform manual `ifconfig lo0 alias` commands for each IP in the range

**Summary:** On macOS, automatic IP alias binding is enabled by default for the loopback range **127.3.2.1 - 127.3.2.254** (requires sudo), allowing multiple sites to use the same port numbers on different IPs. Linux/Windows don't need this because loopback IPs are always available. Use `--skip-macos-auto-ip` on macOS if you prefer manual IP binding.

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

<a name="q73"></a>
**Q74: What does `--normalizedb` actually do?**  
**A74:**
It replaces WP Staging placeholders in the database SQL file with actual values:
- `{WPSTG_TMP_PREFIX}` → temporary table prefix
- `{WPSTG_FINAL_PREFIX}` → final table prefix
- `{WPSTG_NULL}` → SQL NULL
- This is required before manually importing the database to MySQL.

<a name="q74"></a>
**Q75: Can I restore only the database without files?**  
**A75:**
Yes, combine filters:
```bash
wpstaging restore --only-dbfile --path=/var/www/site backup.wpstg
```

<a name="q75"></a>
**Q76: How do I change the database prefix during restore?**  
**A76:**
Use `--db-prefix`:
```bash
wpstaging restore --path=/var/www/site --db-prefix=newwp_ backup.wpstg
```

<a name="q76"></a>
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

<a name="q77"></a>
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

<a name="q78"></a>
**Q79: Can I use the CLI in CI/CD pipelines?**  
**A79:**
Yes, use environment variables and `--yes` flag for non-interactive operation:
```bash
export WPSTGPRO_LICENSE=YOUR_KEY
wpstaging extract --yes backup.wpstg
```

<a name="q79"></a>
**Q80: Does the CLI validate SSL certificates for license checks?**  
**A80:**
Yes, the CLI uses HTTPS for license validation and enforces SSL certificate verification for security.

## Backup Format Questions

<a name="q80"></a>
**Q81: What backup versions are supported?**  
**A81:**
The CLI supports WP Staging backup format versions 1 and 2. Version detection happens automatically when parsing the backup header.

<a name="q81"></a>
**Q82: Can I inspect backup contents without extracting?**  
**A82:**
Yes, use dump commands:
```bash
wpstaging dump-header backup.wpstg
wpstaging dump-metadata backup.wpstg
wpstaging dump-index backup.wpstg
wpstaging dump-index --data backup.wpstg  # detailed file list
```

<a name="q82"></a>
**Q83: Are compressed backups supported?**  
**A83:**
Yes, the CLI automatically handles compressed chunks within the `.wpstg` backup format. No additional decompression needed.

## Miscellaneous Questions

<a name="q83"></a>
**Q84: Can I extract to a custom directory?**  
**A84:**
Yes, use `--outputdir`:
```bash
wpstaging extract --outputdir=/custom/path backup.wpstg
```

<a name="q84"></a>
**Q85: How do I update the CLI to the latest version?**  
**A85:**
Download the latest binary from the [releases repository](https://github.com/wp-staging/wp-staging-cli-release) and replace your existing binary.

<a name="q85"></a>
**Q86: Where can I report bugs or request features?**  
**A86:**
Visit the official WP Staging support at https://wp-staging.com/support/ or check the CLI documentation for the issue tracker URL.

<a name="q86"></a>
**Q87: How do I set up passwordless sudo for the wpstaging binary?**  
**A87:**
The wpstaging binary uses sudo for two operations:
1. **Updating /etc/hosts file** - Adding hostname entries for local sites (all platforms)
2. **IP alias binding** - Binding loopback IPs (macOS only)

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

   # Loopback IP alias (macOS only - skip this line on Linux)
   username ALL=(ALL) NOPASSWD: /sbin/ifconfig lo0 alias 127.3.2.* netmask 255.255.255.255
   ```

   For example:
   ```
   nawawi ALL=(ALL) NOPASSWD: /usr/local/bin/wpstaging update-hosts-file*
   nawawi ALL=(ALL) NOPASSWD: /sbin/ifconfig lo0 alias 127.3.2.* netmask 255.255.255.255
   ```

4. **Save and exit the editor**

**Alternative:** If you cannot set up passwordless sudo or prefer not to, you can use the `--skip-update-hosts-file` flag:
```bash
wpstaging add https://mysite.local --skip-update-hosts-file
```

Note: When using `--skip-update-hosts-file`, you will need to manually add entries to your `/etc/hosts` file for local development.

---

<a name="q87"></a>
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

<a name="q88"></a>
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

<a name="q90"></a>
**Q90: Browser shows "Your connection is not private" or certificate not trusted. How do I fix this?**
**A90:**
This happens when the mkcert Certificate Authority (CA) is not installed in your system trust store. This can occur if you declined the CA installation prompt during site setup.

**Symptoms:**
- Browser shows "Your connection is not private"
- ERR_CERT_AUTHORITY_INVALID error
- Certificate appears invalid

**Solution 1: Use reinstall-cert command (recommended)**
```bash
# Reinstall certificate and CA for a site
wpstaging reinstall-cert <hostname> --reinstall-ca

# Restart to apply changes
wpstaging restart <hostname>
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
# Regenerate certificate for a site
wpstaging reinstall-cert <hostname>

# Restart to apply changes
wpstaging restart <hostname>
```

To also reinstall the mkcert CA to the system trust store:
```bash
wpstaging reinstall-cert <hostname> --reinstall-ca
```

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

**Linux:**
```bash
# Reinstall latest Docker
curl -fsSL https://get.docker.com | sh

# Update docker-compose-plugin
sudo apt-get update && sudo apt-get install docker-compose-plugin  # Debian/Ubuntu
sudo dnf install docker-compose-plugin                              # Fedora/RHEL
```

**macOS/Windows:**
- Open Docker Desktop and check for updates
- Or download and reinstall the latest version from Docker's website

**Verify versions:**
```bash
docker version
docker compose version
```

---

<a name="q98"></a>
**Q98: How do I restore a remote backup to a dockerized site?**  
**A98:**
You can download a WP Staging backup from a remote URL and restore it to a dockerized site with a few commands.

**Step 1: Create a new site (skip if site already exists)**
```bash
wpstaging add mysite.local
```

**Step 2: Make sure the site is running**
```bash
wpstaging start mysite.local
```

**Step 3: Download the backup to current directory**
```bash
curl -LO "https://example.com/backup.wpstg"
```

**Step 4: Restore the backup**
```bash
SITE=mysite.local && \
export $(grep -E "^(DB_|CONTAINER_IP)" $HOME/wpstaging/sites/$SITE/.env | xargs) && \
wpstaging restore \
  --path=$HOME/wpstaging/sites/$SITE/www \
  --db-host=$CONTAINER_IP:$DB_PORT \
  --db-name=$DB_NAME \
  --db-user=$DB_USER \
  --db-password=$DB_PASSWORD \
  --db-prefix=$DB_PREFIX \
  backup.wpstg
```

**Complete workflow in one script:**
```bash
# Set your site hostname and backup URL
SITE="mysite.local"
BACKUP_URL="https://mysite.com/wp-content/uploads/wp-staging/backups/mysite.local_***.wpstg"

# Create site (skip if exists)
wpstaging add $SITE

# Make sure site is running (database must be accessible)
wpstaging start $SITE

# Download backup to current directory
curl -LO "$BACKUP_URL"

# Load credentials and restore
export $(grep -E "^(DB_|CONTAINER_IP)" $HOME/wpstaging/sites/$SITE/.env | xargs)
wpstaging restore \
  --path=$HOME/wpstaging/sites/$SITE/www \
  --db-host=$CONTAINER_IP:$DB_PORT \
  --db-name=$DB_NAME \
  --db-user=$DB_USER \
  --db-password=$DB_PASSWORD \
  --db-prefix=$DB_PREFIX \
  backup.wpstg
```

**Note:** The `--site-url` flag is optional — the CLI automatically reads the site URL from the existing `wp-config.php` when `--path` points to a WordPress root directory. If you do specify `--site-url` and `--path` points to a dockerized site (e.g., `~/wpstaging/sites/mysite.local/www`), the hostname in `--site-url` must match the `SITE_URL` configured in the site's `.env` file. The CLI will show an error if there's a mismatch:

```
error: Site URL hostname 'different.local' does not match the dockerize site URL hostname 'mysite.local' from .env file.
When restoring to a dockerize site, the --site-url hostname must match the site's configured URL.
Either use --site-url=https://mysite.local or remove the --site-url flag to auto-detect.
```

The database credentials (CONTAINER_IP, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD, DB_PREFIX) are stored in `~/wpstaging/sites/<hostname>/.env` and are automatically generated when you run `wpstaging add`.

---

**Last Updated:** 2025-11-27 21:36:01 UTC
