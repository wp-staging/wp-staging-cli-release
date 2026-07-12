# Table of Contents

- [wpstaging](#root-command)
- [add](#command-add)
- [list](#command-list)
- [del](#command-del)
- [enable](#command-enable)
- [disable](#command-disable)
- [reset](#command-reset)
- [switch-php](#command-switch-php)
- [switch-wp](#command-switch-wp)
- [magic-link](#command-magic-link)
- [sync-status](#command-sync-status)
- [open](#command-open)
- [extract](#command-extract)
- [restore](#command-restore)
- [dump-header](#command-dump-header)
- [dump-index](#command-dump-index)
- [dump-metadata](#command-dump-metadata)
- [start](#command-start)
- [stop](#command-stop)
- [restart](#command-restart)
- [status](#command-status)
- [shell](#command-shell)
- [remove](#command-remove)
- [update-subdomains](#command-update-subdomains)
- [update-hosts-file](#command-update-hosts-file)
- [generate-compose-file](#command-generate-compose-file)
- [generate-docker-file](#command-generate-docker-file)
- [reconfigure](#command-reconfigure)
- [reinstall-cert](#command-reinstall-cert)
- [reinstall-ca](#command-reinstall-ca)
- [verify-cert](#command-verify-cert)
- [docker-start](#command-docker-start)
- [docker-image](#command-docker-image)
- [diagnostics](#command-diagnostics)
- [register](#command-register)
- [update](#command-update)
- [uninstall](#command-uninstall)
- [clean](#command-clean)
- [clean all](#command-clean-all)
- [clean cache](#command-clean-cache)
- [clean license](#command-clean-license)
- [clean wpcli](#command-clean-wpcli)

**Hidden Commands:**
- [deactivate](#hidden-command-deactivate)
- [shell-db](#hidden-command-shell-db)
- [sweep-ca-trust](#hidden-command-sweep-ca-trust)
- [compose-info](#hidden-command-compose-info)
- [dump-all-help](#hidden-command-dump-all-help)
- [sudo-keepalive](#hidden-command-sudo-keepalive)

<a name="root-command"></a>
# Root Command Help

```
WP STAGING CLI
Copyright (c) 2025-present WP STAGING — https://wp-staging.com
All rights reserved.

Description:
  WP STAGING CLI provides commands to extract and restore WP STAGING backup files,
  and to create isolated WordPress environments using Docker containers.

  This tool is designed for developers and system administrators who want to
  automate WordPress site cloning, migration, and environment setup.

Usage:
  wpstaging [flags]
  wpstaging [command]

Site Commands:
  add                   Add a new WordPress site
  list                  List all sites or show details for specific sites
  del                   Delete one or more sites, or all sites
  enable                Enable a WordPress site
  disable               Disable a WordPress site
  reset                 Reset a WordPress site
  switch-php            Switch PHP version for a site
  switch-wp             Switch WordPress version for a site
  magic-link            Issue a fresh wp-admin auto-login URL for a site
  sync-status           Show a fast-mode site's file sync status
  open                  Open a site's files in the file manager

Backup Commands:
  extract               Extract files, database, or metadata from a WP STAGING backup
  restore               Restore a WordPress site from a WP STAGING backup
  dump-header           View backup header details
  dump-index            View backup index details
  dump-metadata         View metadata from a backup file

Docker Commands:
  start                 Start containers for a site or all sites
  stop                  Stop containers for a site or all sites
  restart               Restart containers for a site or all sites
  status                Display container status for sites
  shell                 Open an interactive shell in the PHP container
  remove                Stop containers and remove all Docker data
  update-subdomains     Sync subdomain multisite hostnames from WordPress
  update-hosts-file     Update the local hosts file with site entries
  generate-compose-file Generate a docker-compose.yml file
  generate-docker-file  Generate Docker configuration files
  reconfigure           Reconfigure a site docker-related config and apply the changes
  reinstall-cert        Reinstall WP Staging CLI SSL certificate for a site
  reinstall-ca          Rotate the WP Staging CLI certificate authority
  verify-cert           Audit WP Staging CLI SSL certificate trust state
  docker-start          Start the supported Docker runtime and wait for the daemon
  docker-image          Check and pull the Docker images required to run a site
  diagnostics           Print setup and site details for support

Other Commands:
  register              Activate your WP Staging Pro license
  update                Update WP Staging CLI to the latest version
  uninstall             Uninstall WP Staging CLI from the system
  clean                 Clean up cached data, license info, and temporary files
  help                  Help about any command

Global Flags:
  -l, --license string       Provide WP Staging Pro license key for this command
      --working-dir string   Working directory for config files
      --skip-config          Skip loading the default config file
      --config string        Load settings from a custom config file
      --prompt-timeout int   Timeout for user input in seconds (0 = no timeout) (default "180")
      --yes                  Automatically confirm all prompts
  -d, --debug                Show debug messages
  -q, --quiet                Suppress all output
      --verbose              Show detailed per-file output during extraction
  -v, --version              Display application version
      --about                Display license and support notice
      --json                 Output in JSON format
      --page int             Page number for paginated output (requires --json) (default "1")
      --page-size int        Items per page, 0 = all (requires --json) (default "100")

Use "wpstaging [command] --help" for more information and available flags for a command.

Note:
  WP STAGING CLI is an independent project and is not affiliated with or
  endorsed by Docker, Inc. "Docker" is a trademark of Docker, Inc.

```

# Environment Variables

```
Environment Variables:
  WPSTGPRO_LICENSE             WP Staging Pro license key
  WPSTGCLI_JSON_OUTPUT         Enable JSON output (equivalent to --json flag)
  WPSTGCLI_JSON_PAGE           Page number for paginated output (equivalent to --page)
  WPSTGCLI_JSON_PAGE_SIZE      Items per page (equivalent to --page-size)
  WPSTGCLI_DEBUG               Enable debug output (equivalent to --debug flag)
  WPSTGCLI_QUIET               Suppress all output (equivalent to --quiet flag)
  WPSTGCLI_VERBOSE             Show detailed output (equivalent to --verbose flag)
  WPSTGCLI_ALLOW_ROOT          Allow running as root (Linux/macOS)

  Note: Command-line flags take precedence over environment variables.
  Boolean environment variables accept: 1, true, yes, on (case-insensitive).
```

<a name="command-add"></a>
# Command: add

```
Add a new WordPress site to the Docker environment.

Use --from to restore from a WP STAGING backup file after creating the site.

Usage:
  wpstaging add <site-url> [flags]

Examples:
  wpstaging add https://newsite.local
  wpstaging add newsite.local
  wpstaging add newsite.local --from=backup.wpstg
  wpstaging add newsite.local --from=https://example.com/backup.wpstg

Env Flags:
      --php string                  PHP version to use (default "8.1")
      --env-path string             Path to store docker environments (default: ~/wpstaging)
      --compose-file string         File path to docker-compose.yml (default: ~/wpstaging/sites/<hostname>/docker-compose.yml)
      --container-ip string         Container IP address (default "127.3.2.1")
      --http-port int               NGINX HTTP port (default "80")
      --https-port int              NGINX HTTPS port (default "443")
      --db-port int                 MariaDB port (default "3306")
      --db-root string              MariaDB root password (default "123456")
      --mailpit-http-port int       Mailpit HTTP port (default "8025")
      --disable-mailpit             Disable the Mailpit container (use =false to re-enable)

WordPress Flags:
      --wp string                   WordPress version to install (default "latest")
      --db-host string              WordPress database host (default "localhost")
      --db-name string              WordPress database name
      --db-user string              WordPress database user
      --db-pass string              WordPress database password
      --db-prefix string            WordPress database prefix (default "wp_")
      --db-ssl                      Enable SSL for WordPress database connection
      --admin-user string           WordPress admin username (default "admin")
      --admin-pass string           WordPress admin password (default "admin")
      --admin-email string          WordPress admin email (default "admin@dev.null")
      --secure-credentials          Use secure random credentials for database and WordPress admin
      --multisite                   Enable WordPress Multisite
      --subdomains string           Enable subdomain multisite. Optional: comma-separated hostnames

Other Flags:
      --disable-adminer             Disable the Adminer database UI (use =false to re-enable)
      --disable-adminer-autologin   Disable Adminer auto-login (use =false to re-enable)
      --disable-magic-link          Disable the magic-link auto-login (use =false to re-enable)
      --magic-link-timeout int      Default magic-link lifetime in minutes (default "15")
      --skip-warmup                 Skip warming up the site after it starts
      --fast-mode                   Windows only: speed up the webroot with a Docker volume synced to a browsable directory (on by default)
      --label string                Friendly site label (defaults to the hostname)
      --from string                 Backup file path or remote URL (http/https) to restore after site creation

```

<a name="command-list"></a>
# Command: list

```
List WordPress sites in the Docker environment.

If hostnames are provided, shows details for those specific sites.
If no hostname is provided, lists all sites with their status.

Usage:
  wpstaging list [hostname...] [flags]

Examples:
  wpstaging list                           # List all sites
  wpstaging list mysite.local              # Show details for specific site
  wpstaging list site1.local site2.local   # Show details for multiple sites

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-del"></a>
# Command: del

```
Delete WordPress sites from the Docker environment.

If hostnames are provided, deletes those specific sites.
If no hostname is provided, deletes all sites.

Usage:
  wpstaging del [hostname...] [flags]

Examples:
  wpstaging del                           # Delete all sites
  wpstaging del mysite.local              # Delete specific site
  wpstaging del site1.local site2.local   # Delete multiple sites

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-enable"></a>
# Command: enable

```
Enable a WordPress site in the Docker environment.

Usage:
  wpstaging enable <hostname> [flags]

Examples:
  wpstaging enable mysite.local

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-disable"></a>
# Command: disable

```
Disable a WordPress site in the Docker environment.

Usage:
  wpstaging disable <hostname> [flags]

Examples:
  wpstaging disable mysite.local

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-reset"></a>
# Command: reset

```
Reset a WordPress site in the Docker environment.

Use --from to restore from a WP STAGING backup file after resetting the site.
Use --wp to specify a different WordPress version to install.

Usage:
  wpstaging reset <hostname> [flags]

Examples:
  wpstaging reset mysite.local
  wpstaging reset mysite.local --wp=6.5
  wpstaging reset mysite.local --from=backup.wpstg
  wpstaging reset mysite.local --from=https://example.com/backup.wpstg

Env Flags:
      --env-path string             Path to store docker environments (default: ~/wpstaging)
      --disable-mailpit             Disable the Mailpit container (use =false to re-enable)

WordPress Flags:
      --wp string                   WordPress version to install (e.g., 6.5, latest)

Other Flags:
      --skip-warmup                 Skip warming up the site after it starts
      --from string                 Backup file path or remote URL (http/https) to restore after reset
      --disable-adminer             Disable the Adminer database UI (use =false to re-enable)
      --disable-adminer-autologin   Disable Adminer auto-login (use =false to re-enable)
      --disable-magic-link          Disable the magic-link auto-login (use =false to re-enable)
      --magic-link-timeout int      Default magic-link lifetime in minutes (default "15")

```

<a name="command-switch-php"></a>
# Command: switch-php

```
Switch the PHP version for an existing WordPress site.
Updates the configuration, regenerates Docker files, and restarts the containers.

Supported PHP versions: 7.4, 8.1, 8.2, 8.3, 8.4

Usage:
  wpstaging switch-php <hostname> <php-version> [flags]

Examples:
  wpstaging switch-php mysite.local 8.4
  wpstaging switch-php mysite.local 8.1

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-switch-wp"></a>
# Command: switch-wp

```
Switch the WordPress version for an existing site.
Replaces only the WordPress core files while preserving the database,
themes, plugins, and uploads. Requires running containers.

Supported versions: specific version (e.g. 6.5, 6.7-beta1, 6.7-RC1), latest, nightly

Usage:
  wpstaging switch-wp <hostname> <wp-version> [flags]

Examples:
  wpstaging switch-wp mysite.local 6.5
  wpstaging switch-wp mysite.local 6.7-beta1
  wpstaging switch-wp mysite.local latest
  wpstaging switch-wp mysite.local nightly

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-magic-link"></a>
# Command: magic-link

```
Issue a fresh wp-admin auto-login URL ("magic link") for a site.

The previous URL is invalidated immediately, so a leaked or shared
link stops working. Use --timeout to set a one-shot lifetime in
minutes (up to 24 hours); without the flag the new link uses the
site default from .env, or 15 minutes when the site has none. The
site default is set with --magic-link-timeout on add/reset/reconfigure.

Usage:
  wpstaging magic-link <hostname> [flags]

Examples:
  wpstaging magic-link mysite.local
  wpstaging magic-link mysite.local --timeout=60

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

Other Flags:
      --timeout int       One-shot token lifetime in minutes (default "15")

```

<a name="command-sync-status"></a>
# Command: sync-status

```
Show the file sync status for a Windows fast-mode site.

Reports whether the browsable directory is in sync with the site's webroot volume.

Usage:
  wpstaging sync-status <hostname> [flags]

Examples:
  wpstaging sync-status mysite.local

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-open"></a>
# Command: open

```
Open a site's webroot directory (sites/<hostname>/www) in the system file manager.

For a Windows fast-mode site this is the browsable mirror of the webroot volume.

Usage:
  wpstaging open <hostname> [flags]

Examples:
  wpstaging open mysite.local

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-extract"></a>
# Command: extract

```
Extract items from a WP STAGING backup file.

This command extracts files and database from a .wpstg backup file
to the specified output directory. You can filter which parts to extract
using the --only-* and --skip-* flags.

The backup file can be a local path or a remote URL (http/https).
Use --from flag or pass the backup file directly as an argument.

Usage:
  wpstaging extract [flags] <backupfile.wpstg>

Examples:
  wpstaging extract backup.wpstg
  wpstaging extract --from=backup.wpstg
  wpstaging extract --from=https://example.com/backups/backup.wpstg
  wpstaging extract --only-plugins --output-dir=/var/www backup.wpstg

Flags:
  -o, --output-dir string     Directory for extracted files (default: ./wpstaging-output)
  -n, --normalizedb           Normalize database files during extraction
      --overwrite string      Overwrite existing extraction directory (yes/no) (default "yes")
      --site-url string       Specify a new WordPress site URL
      --verify                Verify integrity of extracted files
      --db-prefix string      Specify a new WordPress database table prefix
      --download-dir string   Directory for downloaded backup files (default: ./wpstaging-download)
      --from string           Backup file path or remote URL (http/https)

Only-Filters Flags:
  These flags can only be used once. Pair with `--only-file` to match specific file names.
  -r, --only-wproot        Extract only WP root files
  -w, --only-wpcontent     Extract only wp-content
  -i, --only-plugins       Extract only plugins
  -t, --only-themes        Extract only themes
  -m, --only-muplugins     Extract only mu-plugins
  -u, --only-uploads       Extract only uploads
  -g, --only-languages     Extract only language files
  -b, --only-dbfile        Extract only database file
  -e, --only-dropins       Extract only drop-in files
  -f, --only-file string   Extract only files matching this name

Skip-Filters Flags:
  These flags can be used more than once. Pair with `--skip-file` to skip specific file names.
  -R, --skip-wproot        Skip WP root files
  -W, --skip-wpcontent     Skip wp-content
  -I, --skip-plugins       Skip plugins
  -T, --skip-themes        Skip themes
  -M, --skip-muplugins     Skip mu-plugins
  -U, --skip-uploads       Skip uploads
  -G, --skip-languages     Skip language files
  -B, --skip-dbfile        Skip database file
  -E, --skip-dropins       Skip drop-in files
  -F, --skip-file string   Skip files matching this name

```

<a name="command-restore"></a>
# Command: restore

```
Restore a WordPress site from a WP STAGING backup file.

This command extracts and restores both files and database from a .wpstg backup file
to the specified WordPress installation path. It requires a valid WordPress installation
at the target path.

The backup file can be a local path or a remote URL (http/https).
Use --from flag or pass the backup file directly as an argument.

For dockerized sites, you can specify the site hostname directly:
  wpstaging restore site.local backup.wpstg
  wpstaging restore site.local --from=backup.wpstg

The site must already exist (created with 'wpstaging add site.local').
Database credentials will be auto-detected from the site's .env file.

Usage:
  wpstaging restore [flags] [<site.local>] <backupfile.wpstg>

Examples:
  wpstaging restore --path=/var/www/html backup.wpstg
  wpstaging restore --path=/var/www/html --from=backup.wpstg
  wpstaging restore --path=/var/www/html --from=https://example.com/backups/backup.wpstg

  # Restore directly to a dockerized site:
  wpstaging restore site.local backup.wpstg
  wpstaging restore site.local --from=backup.wpstg
  wpstaging restore site.local --from=https://example.com/backups/backup.wpstg

Flags:
  -o, --output-dir string         Directory for extracted files (default: ./wpstaging-output)
  -p, --path string               WordPress installation path (required)
      --site-url string           Target WordPress site URL (use if detection fails)
      --overwrite string          Overwrite target directory (yes/no) (default "yes")
      --overwrite-db string       Overwrite database (yes/no) (default "yes")
      --overwrite-wproot string   Overwrite WP root files (yes/no) (default "no")
      --db-prefix string          Target WordPress DB table prefix (use if detection fails)
      --db-innodb-strict-mode     Enable InnoDB strict mode (off by default during restore)
      --db-file string            Use the extracted backup SQL file to resume database restoration
      --db-batch-size int         Database insert batch size (default "1000")
      --db-insert-single          Use single-row INSERT statement per query
      --db-timeout string         Database connection timeout (default "15s")
      --verify                    Verify integrity of extracted files
      --skip-extract              Skip extraction if files already exist
      --download-dir string       Directory for downloaded backup files (default: ./wpstaging-download)
      --from string               Backup file path or remote URL (http/https)

Wordpress DB-related Flags:
  This flags overrides the DB-related configuration parsed from the wp-config.php file.
      --db-host string          Database host
      --db-name string          Database name
      --db-user string          Database username
      --db-password string      Database password
      --db-socket string        Database socket path
      --db-charset string       Database charset
      --db-collate string       Database collation
      --db-ssl-ca-cert string   Database SSL CA certificate file
      --db-ssl-cert string      Database SSL client certificate file
      --db-ssl-key string       Database SSL client key file
      --db-ssl-mode string      Database SSL mode (skip-verify/preferred)

Only-Filters Flags:
  These flags can only be used once. Pair with `--only-file` to match specific file names.
  -r, --only-wproot        Extract only WP root files
  -w, --only-wpcontent     Extract only wp-content
  -i, --only-plugins       Extract only plugins
  -t, --only-themes        Extract only themes
  -m, --only-muplugins     Extract only mu-plugins
  -u, --only-uploads       Extract only uploads
  -g, --only-languages     Extract only language files
  -b, --only-dbfile        Extract only database file
  -e, --only-dropins       Extract only drop-in files
  -f, --only-file string   Extract only files matching this name

Skip-Filters Flags:
  These flags can be used more than once. Pair with `--skip-file` to skip specific file names.
  -R, --skip-wproot        Skip WP root files
  -W, --skip-wpcontent     Skip wp-content
  -I, --skip-plugins       Skip plugins
  -T, --skip-themes        Skip themes
  -M, --skip-muplugins     Skip mu-plugins
  -U, --skip-uploads       Skip uploads
  -G, --skip-languages     Skip language files
  -B, --skip-dbfile        Skip database file
  -E, --skip-dropins       Skip drop-in files
  -F, --skip-file string   Skip files matching this name

```

<a name="command-dump-header"></a>
# Command: dump-header

```
Display the header information from a WP STAGING backup file.

Usage:
  wpstaging dump-header <backupfile.wpstg> [flags]

Aliases:
  dump-header, dh

Examples:
  wpstaging dump-header backup.wpstg

Flags:
  -o, --output-dir string   Directory for extracted files (default: ./wpstaging-output)

```

<a name="command-dump-index"></a>
# Command: dump-index

```
Display the file index from a WP STAGING backup file.

Usage:
  wpstaging dump-index <backupfile.wpstg> [flags]

Aliases:
  dump-index, di

Examples:
  wpstaging dump-index backup.wpstg
  wpstaging dump-index --data backup.wpstg

Flags:
      --data                Display detailed index data
  -o, --output-dir string   Directory for extracted files (default: ./wpstaging-output)

```

<a name="command-dump-metadata"></a>
# Command: dump-metadata

```
Display the metadata information from a WP STAGING backup file.

Usage:
  wpstaging dump-metadata <backupfile.wpstg> [flags]

Aliases:
  dump-metadata, dm

Examples:
  wpstaging dump-metadata backup.wpstg

Flags:
  -o, --output-dir string   Directory for extracted files (default: ./wpstaging-output)

```

<a name="command-start"></a>
# Command: start

```
Start Docker containers for a specific site or all sites.

If hostname is provided, starts containers for that site only.
If no hostname is provided, starts containers for all sites.

Usage:
  wpstaging start [hostname] [flags]

Aliases:
  start, up

Examples:
  wpstaging start                # Start all sites
  wpstaging start mysite.local   # Start specific site

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

Other Flags:
      --skip-warmup       Skip warming up the site after it starts

```

<a name="command-stop"></a>
# Command: stop

```
Stop and remove Docker containers for a specific site or all sites.

If hostname is provided, stops containers for that site only.
If no hostname is provided, stops containers for all sites.

Usage:
  wpstaging stop [hostname] [flags]

Aliases:
  stop, down

Examples:
  wpstaging stop                 # Stop all sites
  wpstaging stop mysite.local    # Stop specific site

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-restart"></a>
# Command: restart

```
Restart Docker containers for a specific site or all sites.

If hostname is provided, restarts containers for that site only.
If no hostname is provided, restarts containers for all sites.

Usage:
  wpstaging restart [hostname] [flags]

Examples:
  wpstaging restart              # Restart all sites
  wpstaging restart mysite.local # Restart specific site

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

Other Flags:
      --skip-warmup       Skip warming up the site after it starts

```

<a name="command-status"></a>
# Command: status

```
Display the status of Docker containers.

If hostnames are provided, shows status for those specific sites.
If no hostname is provided, shows status for all sites.

Usage:
  wpstaging status [hostname...] [flags]

Examples:
  wpstaging status                           # Show all sites status
  wpstaging status mysite.local              # Show specific site status
  wpstaging status site1.local site2.local   # Show status for multiple sites

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-shell"></a>
# Command: shell

```
Open an interactive shell in the PHP container. Use 'shell <hostname> root' to open as root.

Usage:
  wpstaging shell <hostname> [root] [flags]

Examples:
  wpstaging shell mysite.local
  wpstaging shell mysite.local root
Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-remove"></a>
# Command: remove

```
Stop all containers and remove the complete Docker setup including volumes and configuration.

Usage:
  wpstaging remove [flags]

Examples:
  wpstaging remove
Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-update-subdomains"></a>
# Command: update-subdomains

```
Query WordPress for all subsites and update Nginx, SSL certificates, and /etc/hosts
with discovered hostnames. Run this after creating or mapping subsites in wp-admin.

Usage:
  wpstaging update-subdomains <hostname> [flags]

Aliases:
  update-subdomains, usub

Examples:
  wpstaging update-subdomains mysite.local

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-update-hosts-file"></a>
# Command: update-hosts-file

```
Update the host machine's hosts file with entries for local WordPress sites.

Usage:
  wpstaging update-hosts-file [flags]

Aliases:
  update-hosts-file, uhf

Examples:
  wpstaging update-hosts-file

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-generate-compose-file"></a>
# Command: generate-compose-file

```
Generate a docker-compose.yml file for the Docker environment.
If no hostname is given, regenerates compose files for all sites.

Usage:
  wpstaging generate-compose-file [hostname] [flags]

Aliases:
  generate-compose-file, gcf

Examples:
  wpstaging generate-compose-file mysite.local
  wpstaging generate-compose-file

Env Flags:
      --env-path string             Path to store docker environments (default: ~/wpstaging)
      --disable-mailpit             Disable the Mailpit container (use =false to re-enable)

Other Flags:
      --disable-adminer             Disable the Adminer database UI (use =false to re-enable)
      --disable-adminer-autologin   Disable Adminer auto-login (use =false to re-enable)
      --disable-magic-link          Disable the magic-link auto-login (use =false to re-enable)
      --magic-link-timeout int      Default magic-link lifetime in minutes (default "15")

```

<a name="command-generate-docker-file"></a>
# Command: generate-docker-file

```
Generate Docker-related configuration files.
If no hostname is given, regenerates files for all sites.

Usage:
  wpstaging generate-docker-file [hostname] [flags]

Aliases:
  generate-docker-file, gdf

Examples:
  wpstaging generate-docker-file mysite.local
  wpstaging generate-docker-file

Env Flags:
      --env-path string             Path to store docker environments (default: ~/wpstaging)
      --disable-mailpit             Disable the Mailpit container (use =false to re-enable)

Other Flags:
      --disable-adminer             Disable the Adminer database UI (use =false to re-enable)
      --disable-adminer-autologin   Disable Adminer auto-login (use =false to re-enable)
      --disable-magic-link          Disable the magic-link auto-login (use =false to re-enable)
      --magic-link-timeout int      Default magic-link lifetime in minutes (default "15")

```

<a name="command-reconfigure"></a>
# Command: reconfigure

```
Update a site's Docker setup and apply the changes without reinstalling.
Regenerates the site's configuration files (compose, nginx, PHP, SSL,
Adminer) and relaunches the site. WordPress files and the database are
preserved.

Use this to roll a site forward after a CLI upgrade, to apply new defaults,
or to refresh the SSL certificate after the hostname list changes.

You can also apply feature-toggle changes here. For example, pass
--disable-adminer=false to re-enable the Adminer UI on a site where
it was previously disabled, --disable-adminer-autologin to turn off
auto-login while keeping Adminer installed, --disable-mailpit=false
to re-enable the Mailpit container, --disable-magic-link to turn
off wp-admin auto-login, or --skip-warmup=false to turn warmup back
on for a site where it is skipped by default (Windows).

If no hostname is given, all sites are reconfigured using each
site's existing settings from its .env.

Usage:
  wpstaging reconfigure [hostname] [flags]

Aliases:
  reconfigure, rcf

Examples:
  wpstaging reconfigure mysite.local
  wpstaging reconfigure

Env Flags:
      --env-path string             Path to store docker environments (default: ~/wpstaging)
      --disable-mailpit             Disable the Mailpit container (use =false to re-enable)

Other Flags:
      --install-wp-staging-pro      Download and install WP Staging Pro on the site
      --disable-adminer             Disable the Adminer database UI (use =false to re-enable)
      --disable-adminer-autologin   Disable Adminer auto-login (use =false to re-enable)
      --disable-magic-link          Disable the magic-link auto-login (use =false to re-enable)
      --magic-link-timeout int      Default magic-link lifetime in minutes (default "15")
      --skip-warmup                 Skip warming up the site after it starts
      --site-label string           Update the friendly site label (empty resets to the hostname)

```

<a name="command-reinstall-cert"></a>
# Command: reinstall-cert

```
Delete and regenerate the WP Staging CLI SSL certificate for a site.

If no hostname is given, the certificate is regenerated for every
site. To rotate the certificate authority and re-sign every site's
leaf certificate in one pass, use `wpstaging reinstall-ca`
or pass --reinstall-ca to this command.

Usage:
  wpstaging reinstall-cert [hostname] [flags]

Examples:
  wpstaging reinstall-cert mysite.local
  wpstaging reinstall-cert
  wpstaging reinstall-cert --reinstall-ca

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

Other Flags:
      --reinstall-ca      Alias for `wpstaging reinstall-ca`
      --skip-restart      Skip restarting running sites after regenerating the certificate

```

<a name="command-reinstall-ca"></a>
# Command: reinstall-ca

```
Wipe the WP Staging CLI certificate authority, generate a fresh one,
install it into the system trust store, and re-sign every site's SSL
certificate against the new CA. Stale WP Staging CLI CA entries are
removed from the system trust store afterwards.

Requires elevated privileges to update the system trust store.

Usage:
  wpstaging reinstall-ca [flags]

Examples:
  wpstaging reinstall-ca

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

Other Flags:
      --skip-restart      Skip restarting running sites after rotating the CA
      --skip-leaf         Rotate the CA without re-signing per-site certificates

```

<a name="command-verify-cert"></a>
# Command: verify-cert

```
Inspect the WP Staging CLI certificate authority across every system
trust store and check each site's leaf certificate (chain to current CA,
expiry buffer). Reports per-store CA presence and per-site leaf state
without modifying anything.

If a hostname is given, only that site's leaf is inspected. The CA
section still covers every store. Use --live to add a live TLS handshake
per site to confirm the served leaf matches the on-disk one. Use --json
to emit a machine-readable report.

Exits 0 when everything is trusted, non-zero when any leaf or trust
store needs attention.

Usage:
  wpstaging verify-cert [hostname] [flags]

Examples:
  wpstaging verify-cert
  wpstaging verify-cert mysite.local
  wpstaging verify-cert --json
  wpstaging verify-cert --live

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

Other Flags:
      --live              Probe https://<host>:443 and compare the served leaf with the on-disk leaf

```

<a name="command-docker-start"></a>
# Command: docker-start

```
Detect the installed Docker runtime (Docker Desktop or native
Docker Engine), launch it, and poll the daemon until it responds
or --timeout is reached. Use --json to emit a machine-readable
result. Other brands (OrbStack, Rancher Desktop, Podman Desktop,
Colima) are detected but launch is refused.

Usage:
  wpstaging docker-start [flags]

Examples:
  wpstaging docker-start
  wpstaging docker-start --timeout=90 --json
  wpstaging docker-start --status --json


Other Flags:
      --status        Report the current Docker state without trying to start it
      --timeout int   Timeout in seconds to wait for the Docker daemon to come up (default "60")

```

<a name="command-docker-image"></a>
# Command: docker-image

```
Check whether the Docker images required to run a site are present
locally and pull the missing ones. Use --status to report without
pulling, --php to select one or more PHP images, and --json for
machine output.

Usage:
  wpstaging docker-image [flags]

Examples:
  wpstaging docker-image --status --json
  wpstaging docker-image --yes --json
  wpstaging docker-image --php 8.1
  wpstaging docker-image --php 8.1,8.3

Env Flags:
      --php stringSlice   PHP version(s) to check or pull, comma-separated (supported: 7.4, 8.1, 8.2, 8.3, 8.4) (default "[8.1]")

Other Flags:
      --status            Report which required images are present without pulling

```

<a name="command-diagnostics"></a>
# Command: diagnostics

```
Collect the facts support needs into one bundle: WP Staging CLI
version and build time, license registration status, operating
system and architecture, Docker status, the state of the directories,
and a secret-free view of each local site. Use --json for a structured bundle.

Usage:
  wpstaging diagnostics [flags]

Examples:
  wpstaging diagnostics
  wpstaging diagnostics --json

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-register"></a>
# Command: register

```
Register your WP STAGING Pro license by entering your license key.
The key will be validated and stored encrypted locally for future use.
Use --status to display the registered license details.

Usage:
  wpstaging register [flags]

Examples:
  wpstaging register
  wpstaging register -l=YOUR_LICENSE_KEY
  wpstaging register --license=YOUR_LICENSE_KEY
  wpstaging register --status

This will prompt you to enter your license key (or use -l/--license flag), validate it
with WP STAGING servers, and register it for this machine.

Flags:
  -l, --license string   License key to register (skips interactive prompt)
      --status           Show the registered license details

```

<a name="command-update"></a>
# Command: update

```
Check for and install updates to WP Staging CLI.

By default, downloads and replaces the current binary with the latest version.
Use --check to check for updates without installing.
Use --status to show the update and announcement status.
Use --full to update using the install script from wp-staging.com.
Use --version to target a specific version (upgrade or downgrade).

Announcements are separate from the "Update vX available" banner. The banner
clears after you install the new version. Use --acknowledge to dismiss an
announcement by id, or "all" to dismiss every visible dismissible announcement.
Critical announcements cannot be dismissed.

Usage:
  wpstaging update [flags]

Examples:
  Update:
    wpstaging update
    wpstaging update --check
    wpstaging update --status
    wpstaging update --full
    wpstaging update --version 1.5.0
    wpstaging update --version v1.5.0
    wpstaging update --version 1.5.0 --check
    wpstaging update --version 1.5.0 --full

  Acknowledge announcement:
    wpstaging update --acknowledge info-1
    wpstaging update --acknowledge all

Flags:
      --acknowledge string   Acknowledge an announcement by id (e.g., info-1)
      --check                Only check for updates, don't install
      --clear-acks           Clean up acknowledgement cache files
      --clear-cache          Clean up update cache files
      --full                 Update using install script from wp-staging.com
      --status               Show the update and announcement status
      --version string       Target a specific version (e.g., 1.5.0 or v1.5.0)

```

<a name="command-uninstall"></a>
# Command: uninstall

```
Remove WP Staging CLI from the system.

By default, deactivates the license, removes the binary, shell completion
files, and PATH entries from shell RC files.
Use --full to run the full uninstall script from wp-staging.com,
which additionally removes cache and Docker sites.

Usage:
  wpstaging uninstall [flags]

Examples:
  wpstaging uninstall
  wpstaging uninstall --full

Flags:
      --full   Uninstall using uninstall script from wp-staging.com (removes completions, cache, Docker sites, etc.)

```

<a name="command-clean"></a>
# Command: clean

```
Clean up various resources like cache files and stored license keys.

Usage:
  wpstaging clean [flags]
  wpstaging clean [command]

Available Commands:
  all         Clean up cache, WP-CLI cache, and stored license
  cache       Clean up cache files
  license     Remove stored license key
  wpcli       Clean up WP-CLI cache files

Use "wpstaging clean [command] --help" for more information and available flags for a command.

```

<a name="command-clean-all"></a>
# Command: clean all

```
Remove the general cache, WP-CLI cache, and stored license. Persistent state is preserved.

Usage:
  wpstaging clean all [flags]

Examples:
  wpstaging clean all

This removes the general cache, WP-CLI cache, and stored license. Persistent state is preserved.

Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-clean-cache"></a>
# Command: clean cache

```
Remove cache files in working directory.

Usage:
  wpstaging clean cache [flags]

Examples:
  wpstaging clean cache

```

<a name="command-clean-license"></a>
# Command: clean license

```
Delete the encrypted license key file from local storage. You will need to re-enter your license key on the next run.

Usage:
  wpstaging clean license [flags]

Examples:
  wpstaging clean license

This will remove the stored license key.

```

<a name="command-clean-wpcli"></a>
# Command: clean wpcli

```
Remove WP-CLI cached downloads (plugin, core, and WP Staging Pro) shared across all sites.

Usage:
  wpstaging clean wpcli [flags]

Examples:
  wpstaging clean wpcli

Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```


# Hidden Commands

These commands are hidden from normal help output but available for advanced usage:

<a name="hidden-command-deactivate"></a>
## Hidden Command: deactivate

```
Deactivate your WP STAGING Pro license on the server and remove the stored license key from local storage.
You will need to re-enter your license key on the next run.

Usage:
  wpstaging deactivate [flags]

Aliases:
  deactivate, unregister

Examples:
  wpstaging deactivate

This will deactivate your license on WP STAGING servers and remove the stored license key.

```

<a name="hidden-command-shell-db"></a>
## Hidden Command: shell-db

```
Open an interactive shell in the MariaDB container. Use 'shell-db <hostname> root' to open as root.

Usage:
  wpstaging shell-db <hostname> [root] [flags]

Examples:
  wpstaging shell-db mysite.local
  wpstaging shell-db mysite.local root

```

<a name="hidden-command-sweep-ca-trust"></a>
## Hidden Command: sweep-ca-trust

```
Scan the system trust stores for WP Staging CLI SSL certificate
authority entries whose fingerprint does not match the current rootCA.pem
and remove only those. Third-party CAs and CAs from other WP Staging CLI
installs are detected but never removed.

Usage:
  wpstaging sweep-ca-trust [flags]

Examples:
  wpstaging sweep-ca-trust
  wpstaging sweep-ca-trust --dry-run

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

Other Flags:
      --dry-run           List stale CA entries that would be removed without modifying any trust store
      --include-legacy    Also remove legacy mkcert-branded CAs, including third-party

```

<a name="hidden-command-compose-info"></a>
## Hidden Command: compose-info

```
Display environment variables and configuration from the docker-compose.yml file.

Usage:
  wpstaging compose-info <hostname> [flags]

Examples:
  wpstaging compose-info mysite.local

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="hidden-command-dump-all-help"></a>
## Hidden Command: dump-all-help

```
Display help for all commands and flags

Usage:
  wpstaging dump-all-help [flags]

Flags:
  -h, --help       help for dump-all-help
      --html       Output in HTML format
      --markdown   Output in Markdown format

```

<a name="hidden-command-sudo-keepalive"></a>
## Hidden Command: sudo-keepalive

```
Internal command spawned by the CLI to keep sudo credentials warm for the
duration of a terminal session. Not intended to be invoked directly.

Environment variables:
  WPSTGCLI_SUDO_KEEPALIVE_MAX_LIFETIME  Override the 12h lifetime cap (e.g. 30m, 6h).
  WPSTGCLI_DISABLE_SUDO_KEEPALIVE       Skip the daemon entirely.

Usage:
  wpstaging sudo-keepalive [flags]

Flags:
      --leader-sid int          Session leader PID to watch (default "0")
      --max-lifetime duration   Absolute cap on daemon lifetime. Exits cleanly when reached (default "12h0m0s")
      --pid-file string         PID file path written by the daemon

```


---

*Generated on 2026-07-10 19:10:53 UTC*
