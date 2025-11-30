# Table of Contents

- [wpstaging](#root-command)
- [add](#command-add)
- [list](#command-list)
- [del](#command-del)
- [enable](#command-enable)
- [disable](#command-disable)
- [reset](#command-reset)
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
- [uninstall](#command-uninstall)
- [update-hosts-file](#command-update-hosts-file)
- [generate-compose-file](#command-generate-compose-file)
- [generate-docker-file](#command-generate-docker-file)
- [register](#command-register)
- [clean](#command-clean)
- [clean all](#command-clean-all)
- [clean cache](#command-clean-cache)
- [clean license](#command-clean-license)

**Hidden Commands:**
- [deactivate](#hidden-command-deactivate)
- [compose-info](#hidden-command-compose-info)
- [dump-all-help](#hidden-command-dump-all-help)
- [reinstall-cert](#hidden-command-reinstall-cert)

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
  list                  List all sites or show details for a specific site
  del                   Delete a WordPress site
  enable                Enable a WordPress site
  disable               Disable a WordPress site
  reset                 Reset a WordPress site

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
  status                Display container status for a site or all sites
  shell                 Open an interactive shell in the PHP container
  uninstall             Stop containers and remove all Docker data
  update-hosts-file     Update the local hosts file with site entries
  generate-compose-file Generate a docker-compose.yml file
  generate-docker-file  Generate Docker configuration files

Other Commands:
  register              Activate your WP Staging Pro license
  clean                 Clean up cached data, license info, and temporary files
  help                  Help about any command

Global Flags:
  -l, --license string       Provide WP Staging Pro license key for this command
      --workingdir string    Working directory for config files
      --skip-config          Skip loading the default config file
      --config string        Load settings from a custom config file
      --prompt-timeout int   Timeout for user input in seconds (default "180")
      --yes                  Automatically confirm all prompts
  -d, --debug                Show debug messages
  -q, --quiet                Suppress all output
  -v, --version              Display application version
      --about                Display license and support notice

Use "wpstaging [command] --help" for more information and available flags for a command.

Note:
  WP STAGING CLI is an independent project and is not affiliated with or
  endorsed by Docker, Inc. "Docker" is a trademark of Docker, Inc.

```

<a name="command-add"></a>
# Command: add

```
Add a new WordPress site to the Docker environment.

Usage:
  wpstaging add <site-url> [flags]

Examples:
  wpstaging add https://newsite.local
  wpstaging add newsite.local

Env Flags:
      --php string              PHP version to use (default "8.1")
      --env-path string         Path to store docker environments (default: ~/wpstaging)
      --compose-file string     File path to docker-compose.yml (default: ~/wpstaging/sites/<hostname>/docker-compose.yml)
      --container-ip string     Container IP address (default "127.3.2.1")
      --http-port int           NGINX HTTP port (default "80")
      --https-port int          NGINX HTTPS port (default "443")
      --db-port int             MariaDB port (default "3306")
      --db-root string          MariaDB root password (default "123456")
      --mailpit-http-port int   Mailpit HTTP port (default "8025")
      --disable-mailpit         Disable the Mailpit container

WordPress Flags:
      --wp string               WordPress version to install (default "latest")
      --db-host string          WordPress database host (default "localhost")
      --db-name string          WordPress database name
      --db-user string          WordPress database user
      --db-pass string          WordPress database password
      --db-prefix string        WordPress database prefix (default "wp_")
      --db-ssl                  Enable SSL for WordPress database connection
      --admin-user string       WordPress admin username (default "admin")
      --admin-pass string       WordPress admin password (default "admin")
      --admin-email string      WordPress admin email (default "admin@dev.null")
      --secure-credentials      Use secure random credentials for database and WordPress admin
      --multisite               Enable WordPress Multisite

```

<a name="command-list"></a>
# Command: list

```
List all WordPress sites in the Docker environment, or show details for a specific site.

If hostname is provided, shows detailed information for that site.
If no hostname is provided, lists all sites with their status.

Usage:
  wpstaging list [hostname] [flags]

Examples:
  wpstaging list                 # List all sites
  wpstaging list mysite.local    # Show details for specific site

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-del"></a>
# Command: del

```
Delete a WordPress site from the Docker environment.

Usage:
  wpstaging del <hostname> [flags]

Examples:
  wpstaging del mysite.local

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

Usage:
  wpstaging reset <hostname> [flags]

Examples:
  wpstaging reset mysite.local

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

Usage:
  wpstaging extract [flags] <backupfile.wpstg>

Examples:
  wpstaging extract backup.wpstg
  wpstaging extract --only-plugins --outputdir=/var/www backup.wpstg
  wpstaging extract --skip-uploads backup.wpstg

Flags:
  -o, --outputdir string   Directory for extracted files (default: ./wpstaging-output)
  -n, --normalizedb        Normalize database files during extraction
      --overwrite string   Overwrite existing extraction directory (yes/no) (default "yes")
      --site-url string    Specify a new WordPress site URL
      --verify             Verify integrity of extracted files
      --db-prefix string   Specify a new WordPress database table prefix

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

Usage:
  wpstaging restore [flags] <backupfile.wpstg>

Examples:
  wpstaging restore --path=/var/www/html backup.wpstg
  wpstaging restore --skip-extract --path=/var/www/html backup.wpstg

Flags:
  -o, --outputdir string          Directory for extracted files (default: ./wpstaging-output)
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
  -o, --outputdir string   Directory for extracted files (default: ./wpstaging-output)

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
      --data               Display detailed index data
  -o, --outputdir string   Directory for extracted files (default: ./wpstaging-output)

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
  -o, --outputdir string   Directory for extracted files (default: ./wpstaging-output)

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

```

<a name="command-status"></a>
# Command: status

```
Display the status of Docker containers for a specific site or all sites.

If hostname is provided, shows status for that site only.
If no hostname is provided, shows status for all sites.

Usage:
  wpstaging status [hostname] [flags]

Examples:
  wpstaging status               # Show all sites status
  wpstaging status mysite.local  # Show specific site status

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

<a name="command-uninstall"></a>
# Command: uninstall

```
Stop all containers and remove the complete Docker setup including volumes and configuration.

Usage:
  wpstaging uninstall [flags]

Examples:
  wpstaging uninstall
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

Usage:
  wpstaging generate-compose-file <hostname> [flags]

Aliases:
  generate-compose-file, gcf

Examples:
  wpstaging generate-compose-file mysite.local

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-generate-docker-file"></a>
# Command: generate-docker-file

```
Generate Docker-related configuration files.

Usage:
  wpstaging generate-docker-file <hostname> [flags]

Aliases:
  generate-docker-file, gdf

Examples:
  wpstaging generate-docker-file mysite.local

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

```

<a name="command-register"></a>
# Command: register

```
Register your WP STAGING Pro license by entering your license key.
The key will be validated and stored encrypted locally for future use.

Usage:
  wpstaging register [flags]

Examples:
  wpstaging register
  wpstaging register --license=YOUR_LICENSE_KEY

This will prompt you to enter your license key (or use --license flag), validate it
with WP STAGING servers, and register it for this machine.

Flags:
      --license string   License key to register (skips interactive prompt)

```

<a name="command-clean"></a>
# Command: clean

```
Clean up various resources like cache files and stored license keys.

Usage:
  wpstaging clean [flags]
  wpstaging clean [command]

Available Commands:
  all         Clean up all stored resources
  cache       Clean up cache files
  license     Remove stored license key

Use "wpstaging clean [command] --help" for more information and available flags for a command.

```

<a name="command-clean-all"></a>
# Command: clean all

```
Remove all stored resources and data used by the CLI tool.

Usage:
  wpstaging clean all [flags]

Examples:
  wpstaging clean all

This will clean up all stored resources in the working directory.

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

<a name="hidden-command-reinstall-cert"></a>
## Hidden Command: reinstall-cert

```
Delete and regenerate the mkcert SSL certificate for a site.

Usage:
  wpstaging reinstall-cert <hostname> [flags]

Examples:
  wpstaging reinstall-cert mysite.local
  wpstaging reinstall-cert mysite.local --reinstall-ca

Env Flags:
      --env-path string   Path to store docker environments (default: ~/wpstaging)

Other Flags:
      --reinstall-ca      Also reinstall mkcert CA to system trust store (requires elevated privileges)

```


---

*Generated on 2025-11-28 18:05:35 UTC*
