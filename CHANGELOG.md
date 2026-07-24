## v1.13.2 (2026-07-24)

- **Enh:** After a hosts file update, the output now lists every local domain that was written. This makes it easy to see when a multisite subsite domain is missing (#427).

## v1.13.1 (2026-07-20)

- **Enh:** The update notice now also shows a one-line install command as another way to update (#418).
- **Fix:** On Windows, `update` no longer installs older versions with a broken self-update (#417).
- **Fix:** On Windows, `update --full` now completes instead of failing while verifying the download (#417).
- **Fix:** Restoring a multisite network backup now migrates the hostname of every subsite, not just the primary site (#421).
- **Fix:** Database restore no longer treats the database file size as zero when calculating restore progress (#421).
- **Fix:** `add` no longer lets two different site names share the same Docker files and database (#422).

## v1.13.0 (2026-07-12)

- **New:** Add an `open <site>` command that opens a site's files in your system file manager (#394).
- **New:** Windows sites now default to a fast Docker volume, still editable from Explorer. Use `--fast-mode=false` to opt out (#394).
- **New:** Add a `docker-image` command to check which Docker images are installed and pull any that are not (#414).
- **Enh:** Show the version number in the help header, the about screen, and the command reference title.
- **Enh:** `stop`, `stop-all`, and `disable` now pause Windows fast-mode file sync. `start`, `start-all`, `enable`, and `restart` resume it (#394).
- **Fix:** `uninstall` and `uninstall --full` now remove the binary and finish reliably on Windows (#401).
- **Fix:** `update` now actually replaces the binary on Windows instead of reporting success without doing so (#403).
- **Fix:** `del`, `remove`, and `restore` no longer hang or fail to remove site files with certain names on Windows (#408).
- **Fix:** `del` no longer fails to remove Windows fast-mode site files still in use by the background file sync (#394).
- **Fix:** Restoring a backup no longer corrupts saved code or text when a backslash appears before certain letters (#407).
- **Fix:** Manually added hosts file entries no longer conflict with a site's managed entry and cause certificate errors (#405).
- **Fix:** Creating a site on Linux with Docker Desktop no longer fails when Docker Desktop is already running (#396).
- **Dev:** `list --json` now reports a per-site `fast_mode` flag, and `sync-status --json` returns structured sync state (#394).

## v1.12.0 (2026-07-03)

- **Enh:** Add a `diagnostics` command that gathers a secret-free bundle to share with support (#386).
- **Enh:** Allow the first-party desktop client to restore from a local backup file (#381).
- **Enh:** Shorten the first-party desktop client token lifetime to one day for tighter security (#382).
- **Enh:** Terminal announcements now show the command to dismiss them and appear at most once a day instead of after every command (#388).

## v1.11.3 (2026-06-13)

- **Enh:** Add `reconfigure --install-wp-staging-pro` to install the WP Staging Pro plugin on an existing site without reinstalling WordPress (#360).
- **Enh:** `list --json` now reports a per-site `magic_link_supported` flag so the desktop app can tell which sites support auto-login (#366).
- **Enh:** License checks now require a signed reply from wp-staging.com and reject any unsigned, fake, or changed reply (#378).
- **Enh:** Warm up each site after it starts so the first page load is fast instead of slow. Use `--skip-warmup` to skip (#379).
- **Enh:** Tune OPcache (more cache, fewer file checks) so sites respond faster after they start (#379).
- **Fix:** Site deletion now clears leftover WP Staging Pro license files so they no longer build up over time (#362).
- **Fix:** `del` and `update-subdomains` now reliably show their completion message and finish cleanup before updating the hosts file (#363).
- **Fix:** Repair auto-login on sites created before the feature existed. Clicking the auto-login link no longer returns a 403 error after running `reconfigure` (#366).
- **Fix:** Turning auto-login off with `reconfigure --disable-magic-link` no longer fails on macOS when leftover login files cannot be removed (#366).
- **Fix:** `start` and `restart` now recreate missing auto-login and Adminer files instead of failing with a Docker bind mount error on pre-existing sites (#368).
- **Fix:** Subdomain multisite subsites are now created with `https://` instead of `http://`, matching the main site (#369).
- **Fix:** Cached license checks now re-verify the stored signature for the current machine, so only a genuine signed activation is accepted (#376).
- **Fix:** Release builds now always download updates from the official WP Staging source and cannot be redirected to another server (#375).

## v1.11.2 (2026-06-02)

- **New:** Add `reinstall-ca --skip-leaf` to rotate the CA without re-signing per-site certificates (#351).
- **New:** Add `update --clear-acks` to clean up the announcement acknowledgement cache (#351).
- **New:** Add `update --status` to show the update and announcement status (#355).
- **Enh:** Replace external mkcert binary with built-in SSL trust setup. First `add` no longer fetches an external tool (#302).
- **Enh:** Show announcements from wp-staging.com on `update` and the daily update check (#334).
- **Enh:** Add `update --acknowledge <id>` to silence a dismissible announcement (#334).
- **Enh:** Add `update --clear-cache` flag to refresh the daily update check and announcement cache (#334).
- **Enh:** `update --check` now always refetches the latest version and announcement, bypassing the 24h cache (#334).
- **Enh:** `update --check` runs the latest-version and announcement fetches in parallel for a faster response (#334).
- **Enh:** Automatic update check now caches network errors and missing files to avoid refetching on every command (#334).
- **Enh:** Background sudo refresh now exits after 12 hours so cached sudo credentials cannot stay warm indefinitely (#339).
- **Enh:** Add `--label` (add) and `--site-label` (reconfigure) for a friendly site label, shown by `list` (#347).
- **Enh:** Site label validation now reports a precise error when the value is too long or contains an unsupported character (#347).
- **Enh:** Rename `--no-restart` to `--skip-restart` on `reinstall-cert` and `reinstall-ca` (#351).
- **Enh:** Previously dismissed announcements stay hidden after `clean cache` and across upgrades (#353).
- **Fix:** Remote backup download via `--from=<url>` now removes partial files on terminate and rejects corrupt resumes (#349).
- **Fix:** Remote backup download via `--from=<url>` cancels promptly even when the server has stopped responding (#349).
- **Fix:** Remote backup download via `--from=<url>` now stops within one chunk of Ctrl+C instead of continuing for tens of MB (#345).
- **Fix:** Daily update check no longer claims a new version is available after the user has updated to the cached latest (#338).
- **Fix:** Windows `add` no longer prompts twice for the security certificate or leaves browsers showing "not secure" (#302).
- **Fix:** `reconfigure <site> --disable-mailpit=false` now re-enables Mailpit on a site where it had been disabled (#343).
- **Fix:** `reinstall-ca` now skips unrecognized site directories. The CA is still reinstalled even when no eligible sites remain (#351).
- **Fix:** `verify-cert` now skips unrecognized site directories, matching what `list` shows (#351).
- **Fix:** `verify-cert` now reports an unknown trust status when no browser trust stores are present to audit the CA (#351).
- **Fix:** macOS no longer kills `wpstaging` with "Killed: 9" after reinstalling or upgrading with the install script (#358).
- **Fix:** On macOS Docker Desktop, adding a site right after removing one with the same name no longer fails to start the mail container (#356).
- **Dev:** New CAs land in `stack/localcert/`. Existing `stack/mkcert/` installs remain untouched until `reset` / `reinstall-ca` / `reinstall-cert --reinstall-ca` (#302).
- **Dev:** Collapse duplicated wrappers in the env package by routing Set/Get/Enable through shared helpers (#334).

## v1.11.1 (2026-05-13)

- **Enh:** Install scripts now confirm when a reinstall recovers from the v1.10.0/v1.11.0 stuck-updater bug (#329).
- **Enh:** `update` (default, `--check`, `--version`) and install scripts refuse v1.10.0 and v1.11.0; they cannot self-update (#329).
- **Fix:** `update` now recognises real release builds and no longer skips the check as a development version (#328).
- **Fix:** `update` on macOS now updates the real binary when launched via a symlink, leaving the symlink intact (#331).
- **Fix:** Install scripts now resolve the latest stable from main's manifest when GitHub's tags API is unreachable (#333).
- **Dev:** CI smoke test guards against the v-prefixed release dev-skip regression (#329).

## v1.11.0 (2026-05-12)

- **New:** Add `register --status` to display the registered license details, including customer email and plan name (#276).
- **New:** All install and uninstall scripts add `--print-version` / `-V` to print the build stamp and exit (#297).
- **New:** Add `sweep-ca-trust` command to remove stale SSL certificate authorities left by previous `--reinstall-ca` cycles (#290).
- **New:** Add `reinstall-ca` command to rotate the certificate authority and re-sign every site's certificate in one pass (#300).
- **New:** Add `verify-cert` command to audit SSL certificate trust state across system trust stores and per-site leaves (#301).
- **New:** Add `docker-start` command to start Docker when it is not already running (#282).
- **New:** Add `--download-dir` flag; downloaded backup files now land in a `wpstaging-download` subfolder by default (#318).
- **New:** Add magic-link to sign into wp-admin without a password; URL refreshes on `list` (#285).
- **New:** Add `magic-link` command to issue a fresh URL on demand, with optional `--timeout` (#285).
- **Enh:** Add `clean wpcli` subcommand to remove cached WP-CLI downloads; also covered by `clean all` (#139).
- **Enh:** `--version --json` now emits the standard JSON envelope with `name`, `version`, and `build_time` (#313).
- **Enh:** Site SSL certificates now show WP Staging CLI in browser certificate viewers instead of the upstream mkcert default (#290).
- **Enh:** `reinstall-cert` with no hostname now regenerates the SSL certificate for every site in one go (#300).
- **Enh:** `reinstall-cert` now restarts any running sites automatically after regenerating the certificate (#300).
- **Enh:** `reinstall-ca` and `reinstall-cert` now confirm completion after restarting running sites (#290).
- **Enh:** `start` and `stop` now show a progress spinner; pass `--debug` to see verbose Docker output instead (#290).
- **Enh:** `sweep-ca-trust` confirmation prompt is now shorter and easier to read, especially with `--include-legacy` (#290).
- **Enh:** When Docker is not running, JSON output now shows which Docker app is installed and how to start it (#282).
- **Enh:** `list` and `add` JSON output now include each site's `created_at` ISO-8601 UTC timestamp (#274).
- **Enh:** Rename `--outputdir` to `--output-dir` on extract and restore; the old name still works as a hidden alias (#318).
- **Enh:** Rename `--workingdir` to `--working-dir`; the old name still works as a hidden alias (#318).
- **Enh:** Adminer login page now blocks cross-origin requests so its credentials cannot leak to malicious tabs (#324).
- **Enh:** Adminer is now reachable only at `adminer.<site>`; the `/adminer/` subpath on the main site is no longer routed (#324).
- **Enh:** Sites restored from a backup now identify themselves as local so plugins suppress telemetry and updates (#323).
- **Enh:** `add` now rolls back containers and the half-created site directory on Ctrl-C or SIGINT/SIGTERM (#283).
- **Enh:** Cancel output is now clean with no leftover spinner frame or duplicate "Process cancelled" line (#283).
- **Enh:** Sudo password is remembered for the rest of the terminal session, so you only enter it once per session (#229).
- **Enh:** `add --json` now emits a typed `rollback` event around cancel-rollback so callers can detect start and finish (#325).
- **Fix:** `--disable-mailpit=false` now re-enables the Mailpit container on sites where it was previously disabled (#319).
- **Fix:** macOS: SSL certificate now reliably trusted by Chrome and Safari for sites running under Docker (#273).
- **Fix:** `reinstall-cert --reinstall-ca` now removes the previous CA from the system trust store after regenerating (#290).
- **Fix:** `reinstall-cert <hostname> --reinstall-ca` no longer leaves other sites with untrusted certificates after rotating the CA (#300).
- **Fix:** `remove` now cleans up wpstaging certificate authority entries from the system trust store instead of leaving them as orphans (#290).
- **Fix:** Windows: `sweep-ca-trust` now removes stale CA entries silently instead of prompting a confirmation dialog per certificate (#290).
- **Fix:** Windows: spinner no longer leaves a stale frame on the previous line after `reinstall-ca` finishes (#290).
- **Fix:** `--json` license output now emits `valid_through` as ISO-8601 (`YYYY-MM-DD`) so locale-aware GUI clients can parse it reliably (#276).
- **Fix:** `start` and `restart` now create the missing Adminer directory on sites created before the bundled Adminer feature (#299).
- **Fix:** Default output directory falls back to a writable location when the working directory is not writable (#289).
- **Fix:** Installer and uninstaller scripts now work with any POSIX shell, not only bash or dash (#294).
- **Fix:** Uninstaller now only removes `wpstg` or `wp-staging` files that are confirmed WP Staging CLI aliases (#296).
- **Fix:** Windows uninstaller now times out the `--version` check after 5 seconds, preventing a hang on an unresponsive binary (#295).
- **Fix:** Re-running `add` after a canceled attempt no longer fails with a Docker mount-namespace error (#283).
- **Fix:** `--output-dir` now appends a `wpstaging-output` subfolder, matching the default output layout (#321).
- **Fix:** `reconfigure` without a hostname now applies `--disable-*` flags to every site and saves them to each site's `.env` (#315).
- **Fix:** Saving a disable flag to a site's `.env` no longer leaves a blank line gap or strips the trailing newline (#316).
- **Dev:** CHANGELOG release PR now stages only `CHANGELOG.md` so its title matches its diff (#298).
- **Dev:** Stop tracking `manifest.json` and `target_repo` in the source repo; both are regenerated by the deploy workflow each release (#298).
- **Dev:** Consolidate `--disable-*` toggle plumbing into shared helpers across the single-site commands (#288).
- **Dev:** Consolidate duplicated sites-directory path-building into shared helpers used across site commands (#304).
- **Dev:** macOS unit test now tolerates `$TMPDIR` with a trailing slash so `make tests-go-unit` passes (#326).

## v1.10.0 (2026-04-27)

- **New:** Bundled Adminer database UI at `<site>/adminer/` and `adminer.<site>`. Opt out with `--disable-adminer` (#69).
- **New:** Add `reconfigure` command to update a site's Docker setup without reinstalling or losing data (#286).
- **New:** Add `uninstall` command to remove the CLI, shell completions, and PATH entries. Use `--full` to also remove cache, license, and Docker sites (#256).
- **Enh:** Shell completion: pressing TAB on commands like `add` or `start` now shows usage examples (#262).
- **Enh:** On macOS, suggest enabling VirtioFS in Docker Desktop during `add`, `reset`, `extract`, and `restore` for faster file sharing (#211).
- **Enh:** Installer and uninstaller scripts no longer require bash; they now run with any POSIX shell (#251).
- **Enh:** Uninstall scripts now verify the binary is WP Staging CLI before removing it (#257).
- **Enh:** Adminer now auto-logs in on first visit. Opt out with `--disable-adminer-autologin` to keep the DB password out of the generated HTML (#69).
- **Enh:** `--disable-adminer=false` and `--disable-adminer-autologin=false` re-enable the feature on a site that was previously disabled, without editing `.env` by hand (#69).
- **Enh:** `list` shows whether Adminer is enabled (and if auto-login is on) or disabled for each site (#69).
- **Fix:** Development and other non-semver builds no longer show a bogus "Update vX.Y.Z available (current: vdev)" notice at startup; any version that is not a valid semver string now skips the update check (#287).
- **Fix:** Shell completion: `--subdomains` flag forced a mandatory argument in zsh instead of being optional (#262).
- **Fix:** Shell completion: `switch-wp` version argument restricted to `latest`/`nightly` in zsh instead of allowing free-form versions like `6.5` (#262).
- **Fix:** Shell completion: `update-subdomains` was grouped with no-argument commands instead of requiring a hostname positional in both Bash and Zsh (#262).
- **Fix:** Shell completion: `add`, `del`, `enable`, and other commands with a required first positional argument in Bash did not expect that positional first (#262).
- **Fix:** Shell completion: `compose-info` was grouped with no-argument commands instead of requiring a hostname positional (#262).
- **Fix:** Shell completion: `generate-compose-file` and `generate-docker-file` did not offer an optional hostname positional (#262).
- **Fix:** Shell completion: `remove` was grouped with hostname commands but takes no positional argument (#262).
- **Fix:** Shell completion: `shell` and `shell-db` did not offer `root` as a second positional argument (#262).
- **Fix:** Shell completion: `--wp` flag suggested stale versions instead of `latest` and `nightly` (#262).
- **Fix:** Shell completion: `reinstall-cert` in Bash did not expect a hostname positional, unlike Zsh (#262).
- **Fix:** Shell completion offered invalid flags for site-management commands (#266).
- **Fix:** `del`, `enable`, `disable`, and `reset` created an empty site folder when run against a non-existent hostname (#278).
- **Fix:** `remove` ended with a misleading hosts-file error after deleting the sites directory (#279).
- **Fix:** macOS: VirtioFS tip now works with current Docker Desktop and reappears if you turn off VirtioFS later (#211).
- **Dev:** Add unit tests for shell completion scripts (Bash and Zsh) with bash/zsh parity check (#265).
- **Dev:** Fix changelog-format.sh on macOS where the sed block was incompatible with BSD sed and silently aborted (#275).
- **Dev:** changelog-format.sh now inserts the missing blank line between the "ADD NEW ENTRIES" comment and the first entry (#275).
- **Dev:** Port installer test coverage to tests-installer-local.sh and remove old tests-installer.sh (#268).
- **Dev:** Add CI tests for the exact install and uninstall commands documented in README-RELEASES.md (#271).

## v1.9.0 (2026-04-08)

- **New:** Add `--version` flag to the `update` command to update or downgrade to a specific version, e.g., `wpstaging update --version 1.5.0` (#245).
- **New:** `switch-wp` command to change WordPress version for existing sites without reinstalling (#222).
- **New:** Subdomain multisite support with `--subdomains` flag. Wildcard SSL, nginx, and `/etc/hosts` are configured automatically (#212).
- **New:** `update-subdomains` command to sync subsite hostnames from WordPress into nginx, SSL, and hosts file (#212).
- **New:** Auto-detect subdomain multisite from backup during restore and configure nginx, SSL, and hosts automatically (#212).
- **Enh:** `list` command now shows WordPress version. Actual version stored in `.env` instead of symbolic values like "latest" (#222).
- **Enh:** `list` command now shows multisite type (subdomain/subdirectory) and subsite hostnames (#212).
- **Fix:** `update --full` did not replace the current binary when the install directory was not yet in the shell PATH (#252).
- **Fix:** `update --full` removed the installed binary from the install directory, leaving symlinks dangling (#253).
- **Fix:** macOS: Docker Desktop misreported as "not installed" when PATH is broken by a removed third-party Docker provider (#238).
- **Fix:** JSON mode now emits spinner-type progress for `switch-wp`, `switch-php`, and Docker shell scripts (#222).
- **Fix:** Custom domain subsites now show the correct URL in the WordPress "My Sites" menu and login works correctly across all subsite domains (#212).
- **Fix:** Installer scripts reject valid versions without the `v` prefix, e.g., `install.sh -v 1.7.0` fails while `install.sh -v v1.7.0` works (#250).
- **Dev:** Fix `findInstalledBinary` unit tests failing on macOS due to `/var` symlink resolution (#259).
- **Dev:** Add `-trimpath` to build flags for reproducible builds and to avoid leaking local file paths in binaries (#212).
- **Dev:** Add docker integration tests for subdomain multisite (#212).
- **Dev:** Deploy workflow now blocks stable release tags from non-master branches (#246).

## v1.8.2 (2026-03-31)

- **Enh:** Search-replace now matches protocol-relative, JSON-escaped, URL-encoded, and bare hostname URL variants, matching the PHP plugin's coverage (#243).
- **Fix:** Search-replace now replaces bare hostnames stored without a scheme prefix, such as Cloudflare image IDs (#243).
- **Fix:** ACF taxonomy settings and other serialised data no longer corrupted after restore (#243).
- **Fix:** Backups with latin1 database tables now restore correctly by converting to utf8mb4 (#243).

## v1.8.1 (2026-03-29)

- **New:** `--json` output mode with `--page`/`--page-size` pagination (default: 100 items per page) for GUI wrappers and automation (#224).
- **Enh:** JSON mode now sends extraction progress as structured data so GUI wrappers can show a progress bar (#224).
- **Enh:** JSON mode now sends restore progress as structured data, including file section status and database query progress (#224).
- **Enh:** JSON mode now sends remote backup information and download progress as structured data (#224).
- **Enh:** JSON mode now sends license registration and deactivation results as structured data (#224).
- **Enh:** JSON mode now sends sudo password prompts as structured JSON so GUI wrappers can show a password dialog (#224).
- **Enh:** JSON mode now outputs structured data for dump-header, dump-metadata, and dump-index commands (#224).
- **Enh:** JSON mode now outputs structured progress during binary update downloads (#224).
- **Enh:** JSON mode now includes actionable hints in Docker-related error responses to help resolve problems (#224).
- **Enh:** Faster database restoration and normalisation by pre-compiling regular expressions used in search-replace operations (#240).
- **Fix:** Site URL not replaced when the backup metadata stores HTTPS but the database uses HTTP, or vice versa. The search-replace now matches both scheme variants (#240).
- **Fix:** Search-replace now processes serialised data containing PHP object instances (e.g. ACF taxonomy fields) instead of skipping them. This prevents broken serialisation after restore (#240).
- **Fix:** All CLI output is now properly structured when using `--json` mode. Status messages from update, clean, and Docker commands no longer break the JSON stream (#224).
- **Fix:** Fix crash when running Docker commands with JSON pagination environment variables set (#224).
- **Fix:** CHANGELOG formatting script now properly preserves blank lines between sections instead of removing them (#236).
- **Dev:** Use Go constants for all JSON command types, sub-types, and progress scopes (#224).

## v1.8.0 (2026-03-09)

- **New:** `switch-php` command to change the PHP version for an existing site without reinstalling WordPress (#216).
- **New:** Auto-detect OrbStack Docker context and switch to Docker Desktop or Docker Engine. OrbStack networking does not support loopback IP aliases used by the CLI (#223).
- **New:** macOS loopback IP aliases now persist across reboots via LaunchDaemon. Only creates aliases for existing sites (#223).
- **New:** The `start` and `restart` commands auto-create missing macOS loopback aliases (#223).
- **Enh:** Extract command now shows a progress bar with file count and percentage (#205).
- **Enh:** Large files now show byte-level extraction progress (e.g., "3.00 MB of 4.50 MB") (#205).
- **Enh:** The CLI now checks Windows version at startup and shows a clear error on Windows older than Windows 10 / Server 2016 (#205).
- **Enh:** `list` command now shows the PHP version for each site (#216).
- **Enh:** Limit PHP extension config bind mounts to 25 files per site to prevent excessive Docker mounts (#217).
- **Enh:** LaunchDaemon auto-updates when `--env-path` changes, so loopback aliases always use the correct sites directory (#223).
- **Enh:** Rename LaunchDaemon plist to `com.wp-staging.cli-loopback` to follow Apple reverse-DNS naming convention (#223).
- **Enh:** Use modern `launchctl bootstrap`/`bootout` API with fallback to legacy `load`/`unload` for older macOS (#223).
- **Enh:** WordPress downloads now support resume for `latest` and `nightly` versions. Interrupted downloads continue from where they left off instead of starting over (#198).
- **Fix:** The `register` command now accepts the `-l` short flag for `--license` (#231).
- **Fix:** Site setup no longer fails with "is a directory" error when Docker creates bind mount paths as directories (#217).
- **Fix:** Spinner and database restore progress no longer output ANSI escape codes when stdout is piped or redirected (#205).
- **Fix:** The `remove` command now shows the Docker start prompt instead of exiting silently when Docker is not running (#223).
- **Fix:** Show error message when Docker check fails in `initWorkingEnvironment` instead of exiting silently (#223).
- **Fix:** Harden LaunchDaemon plist against shell injection by escaping the sites directory path (#223).
- **Fix:** Validate IP addresses from site `.env` files before using them in shell commands (#223).
- **Fix:** Fix typo in method name `genereateContainerConfig` → `generateContainerConfig` (#223).
- **Dev:** Consolidate macOS platform detection into exported `IsDarwinOrTest()`, removing inline duplications across `cmd` package (#223).
- **Dev:** Remove unused `commandsSkipDocker` variable and simplify Docker check condition (#223).

## v1.7.0 (2026-03-03)

- **New:** `update` command to update WP Staging CLI to the latest version directly from the terminal (#67).
- **New:** Automatic update check notifies when a new version is available (once per day) (#67).
- **New:** Cross-site communication - Dockerized sites can now send HTTPS requests to each other using a shared Docker network (#196).
- **New:** Combined CA bundle - PHP and shell tools inside containers now trust both local mkcert certificates and public certificates (#196).
- **New:** Installer `--bin-dir` (`-d`) flag to install the binary to a custom directory instead of the auto-detected location (#189).
- **New:** Installer `--extract` (`-e`) flag to download all installable files to a directory without running the full installation (#189).
- **New:** Installer `--cli-args` (`-a`) flag to pass extra arguments to every wpstaging binary call during installation (#189).
- **Enh:** Auto-detect multisite from backup in `add --from` and `reset --from` commands (#206).
- **Enh:** Persist multisite setting in `.env` file so `reset` preserves multisite (#206).
- **Enh:** Show backup type in restore confirmation and multisite status in `list` command (#206).
- **Enh:** Show notice when restoring a multisite backup to a single-site target (#206).
- **Enh:** `generate-docker-file` and `generate-compose-file` commands now support regenerating all sites at once when no hostname is given (#196).
- **Enh:** Shell prompt now shows the site hostname instead of the container ID (#196).
- **Enh:** All containers now auto-restart when Docker daemon restarts, and stay stopped when explicitly stopped with `stop` command (#196).
- **Fix:** Prevent restoring full multisite network backup to single-site WordPress (#206).
- **Fix:** Multisite detection now only requires `MULTISITE` constant, matching WordPress core behavior (#206).
- **Fix:** MariaDB no longer shows "unhealthy" on Docker Desktop during first site setup by using longer healthcheck timings (#196).
- **Fix:** Release workflow now produces correctly formatted CHANGELOG with proper blank line spacing between version sections (#213).
- **Fix:** CHANGELOG formatting script now works on macOS by replacing GNU sed-only features with portable alternatives (#213).
- **Fix:** `stop` and `restart` without hostname no longer fail on some Docker versions due to stale network endpoint references (#67).
- **Dev:** Add tests for multisite backup validation and multisite auto-detection (#206).
- **Dev:** Docker development environment now auto-detects `HOST_UID` and `HOST_GID` from the current user when running `make` commands (#179).
- **Dev:** Docker development environment now works on macOS with Docker Desktop (#179).
- **Dev:** Uses nginx TCP proxy and network aliases to handle macOS container networking limitations (#179).
- **Dev:** Docker integration tests now use the correct binary architecture on macOS and skip tests that require Linux-only network access (#179).
- **Dev:** Fix `sed -i` cross-platform compatibility in Docker integration tests (#179).

## v1.6.2 (2026-02-10)

- **New:** Zsh shell completion support - Tab completion now works in both Bash and Zsh shells (#150).
- **Enh:** Binary download shows progress and automatically resumes interrupted downloads (#67).
- **Enh:** Update command works natively on Windows using a helper script for binary replacement (#67).
- **Enh:** `update --full` now also updates the current binary location when running from outside PATH (#67).
- **Enh:** Uninstaller now deactivates license and removes all working directories across platforms (#150).
- **Enh:** Added `.dev` as a supported TLD for dockerize site URLs (#194).
- **Enh:** Register command now shows a message when the license key is read from the `WPSTGPRO_LICENSE` environment variable (#188).
- **Fix:** License registration no longer fails with "Failed to read license key EOF" when installing via `curl | bash` with the `-l` flag (#188).
- **Fix:** Uninstaller now deactivates the license before removing the binary, ensuring deactivation actually succeeds (#150).
- **Fix:** Port conflicts from other Docker containers (including port ranges) are now detected and resolved automatically (#190).
- **Fix:** MariaDB data directory clearing no longer fails on Docker Desktop due to permission issues (#190).
- **Dev:** License tests use built-in mock server instead of requiring Docker (#67).

## v1.6.1 (2026-02-03)

- **Enh:** Expired licenses now display licensee name and expiration date instead of being silently deleted (#171).
- **Enh:** Installer tests auto-start and stop the local test server, no longer requiring a separate terminal (#170).
- **Fix:** Manifest generator and installer tests now work on macOS default bash 3.2 (#170).
- **Fix:** Version verification test now correctly handles pre-release suffixes like beta and RC (#170).
- **Dev:** Port availability test no longer fails on macOS due to hardcoded port assumption (#174).
- **Dev:** Optimized dockerize test suite with per-file cleanup, reducing cleanup operations by 87% (#170).
- **Dev:** Consolidated installer/uninstaller tests into `devtools/tests/installer/` with standardized `tests-*` naming (#170).

## v1.6.0 (2026-01-29)

- **Enh:** Docker Compose warning "No services to build" no longer clutters the terminal output (#160).
- **Enh:** `reset` command now supports `--from` flag to restore from a backup (#158).
- **Enh:** `reset` command now supports `--wp` flag to specify WordPress version (#162).
- **Enh:** Restore directly to dockerized sites using hostname: `wpstaging restore site.local backup.wpstg` (#148).
- **Enh:** Database credentials are auto-detected when restoring to a dockerized site (#148).
- **Fix:** Stored license is now preserved when validation fails due to network timeout (#165).
- **Fix:** `reset` command now fails correctly when the site doesn't exist instead of creating a new site (#164).
- **Fix:** `WP_VERSION` in `.env` file now defaults to "latest" when `--wp` flag is not specified (#162).

## v1.5.2 (2026-01-24)

- **Fix:** MariaDB now starts correctly on Docker Desktop for Mac by disabling native AIO and using fsync flush method (#156).

## v1.5.1 (2026-01-23)

- **Fix:** User capabilities are now properly restored after database restore (#152).
- **Dev:** Release PRs now include changelog entries in the description and validate tag format (#154).

## v1.5.0 (2026-01-23)

- **New:** `add --from` creates a new site and restores from a backup in one step (#68).
- **Enh:** After restoring with `add --from`, login credentials and important paths are now displayed for easy reference (#147).
- **Fix:** License validation no longer fails due to API response format inconsistencies (#145).
- **Fix:** File-only backups (without database) now restore gracefully instead of showing "is a directory" error (#124).
- **Dev:** Added tests for license API response parsing and `make gotest-run` target for running single tests (#145).
- **Dev:** Added bashunit tests for file-only backup restore functionality (#140).
- **Dev:** Added tests-backup.yml CI workflow for backup operations tests (#140).
- **Dev:** Renamed CI workflow files for consistency: tests-docker-integration.yml, tests-go-unit.yml (#140).

## v1.4.6 (2026-01-12)

- **Enh:** WP Staging Pro plugin downloads are now cached by version - skips re-downloading when the same version is already available.
- **Fix:** Sites created with older versions no longer fail to start after upgrade due to missing MariaDB configuration directory.
- **Fix:** Sudo password explanation now displays correctly on macOS when updating the hosts file.
- **Dev:** Release workflow now removes all HTML comments from CHANGELOG and auto-formats blank lines after version headers.

## v1.4.5 (2026-01-12)

- **Fix:** macOS SSL certificate now trusted by browsers on first run instead of requiring a second attempt.

## v1.4.4 (2026-01-10)

- **Fix:** Show explanation when sudo password is required for updating the hosts file during site setup.
- **Fix:** Installer now correctly reports version after upgrade and updates existing installation in place.
- **Fix:** Backup restore confirmation no longer auto-cancels - waits indefinitely for user input to prevent accidental cancellation.

## v1.4.3 (2026-01-09)

- **New:** Remote backup URL support - Extract and restore backups directly from URLs with chunked downloads, resume support, and preflight validation.
- **New:** `--from` flag for `extract` and `restore` commands - Specify backup file path or remote URL as an alternative to positional argument.
- **New:** Automatic WP Staging Pro license activation - When creating a new site with `add`, the plugin license is automatically activated in WordPress.
- **New:** External service conflict detection - CLI detects when other services (Apache, nginx, MySQL) are using the wpstaging IP range or wildcard bindings.
- **New:** Automatic Docker startup prompt - CLI offers to start Docker when it's not running on Windows, macOS, and Linux.

## v1.4.2 (2025-11-30)

- **Enh:** Use temporary redirect (302) for HTTP-to-HTTPS in local development - prevents browser caching issues.
- **Enh:** Smarter IP and port conflict handling - automatically rotates to next available IP, shows OS-specific diagnostic commands, and continues starting other sites when some have conflicts.
- **Enh:** Changed MariaDB image from `latest` to `11.8` for better stability and consistent behavior.
- **Enh:** Renamed `uninstall` command to `remove` for clarity - no longer requires license validation or image downloads.
- **Enh:** PHP Docker images now support Apple Silicon (ARM64) - no more platform mismatch warnings on macOS M1/M2/M3.
- **Enh:** Cleaner output - removed "Dockerize:" prefix, improved error messages, and human-readable timeout display.
- **Enh:** Faster setup - Docker images pulled in parallel, downloads support resume and caching across installations.
- **Enh:** Per-site locking prevents conflicts when running multiple commands on the same site simultaneously.
- **Enh:** Commands `del`, `list`, and `status` now accept multiple hostnames and no longer require license validation.
- **Enh:** The `del` and `remove` commands now automatically deactivate WP Staging Pro licenses with spinner animation.
- **Enh:** External database setup checks if user credentials work before using root password.
- **Fix:** Docker Desktop MariaDB issues - fixed root password initialization, database connection timing, and "Host not allowed to connect" errors.
- **Fix:** Windows improvements - fixed installer parsing error, elevated console now shows privilege status, progress spinner, and results properly.
- **Fix:** macOS fixes - license key cache loading, confirmation prompt countdown, and clear loopback IP instructions.
- **Fix:** `list`, `status`, `start`, `stop`, and `restart` commands now show accurate messages and properly prompt to start Docker.
- **Fix:** Stop all command now properly removes orphaned Docker networks in addition to containers and volumes.
- **Fix:** Site availability check now correctly validates directory existence instead of file existence.
- **Fix:** Corrupted downloads no longer cause "broken signature" errors - downloads now use atomic temp file pattern to prevent partial/corrupt files.
- **Dev:** Test install scripts on all major OS by using CI GitHub actions.
- **Dev:** Multi-arch build support for PHP images (amd64 + arm64) with Docker Build Cloud option.

## v1.4.1 (2025-11-27)

- **Fix:** Windows 32-bit installer now downloads from the correct directory path.
- **Fix:** Installer alias commands now reference the correct binary name (wpstaging.exe).
- **Enh:** Installers now use the binary path from manifest.json for more reliable downloads.

## v1.4.0 (2025-11-27)

- **New:** Local development environment for WordPress staging sites with isolated Docker containers.
- **New:** Run multiple WordPress sites simultaneously - each site gets its own containers with unique IPs and ports.
- **New:** Automatic port and IP address management - no manual configuration needed when running multiple sites.
- **New:** Per-site configuration files - each site remembers its settings between restarts.
- **New:** Filter site list by hostname to quickly find specific sites: `wpstaging list mysite.local`.
- **New:** `reset` command to reinstall WordPress without losing container configuration.
- **New:** One-click installation with automated installers for Windows, macOS, and Linux.
- **New:** Unregister command to deactivate your license when switching machines.
- **New:** License information display showing plan details, expiration date, and remaining activations.
- **New:** External database support - connect sites to remote MySQL/MariaDB servers with `--external-db` flag.
- **New:** Secure random password generation with `--secure-credentials` flag.
- **New:** Protection against switching from external to internal database without proper reconfiguration.
- **New:** `reinstall-cert` command to regenerate SSL certificates for a site.
- **New:** Port conflict detection now checks stopped sites to prevent conflicts when starting.
- **New:** IP allocation now scans all site configurations to prevent conflicts with stopped sites.
- **Enh:** Better error messages when using `--container-ip` with an IP already in use - shows which site has the IP and suggests the next available one.
- **New:** Restore command validates `--site-url` hostname matches the dockerize site's configured URL to prevent misconfiguration.
- **New:** Register command now accepts `--license` flag for non-interactive license registration in scripts.
- **Enh:** Simplified site creation - use `add <site-url>` to create and configure sites in one step.
- **Enh:** Better organization - each site stored in `~/wpstaging/sites/` with independent configurations.
- **Enh:** Automatic secure password generation for database and WordPress admin accounts.
- **Enh:** Site list command now shows real-time container status (Running/Stopped) and totals.
- **Enh:** Edit port settings in site's `.env` file and apply changes with `restart <hostname>` command.
- **Enh:** Linux and Windows users get automatic IP address assignment.
- **Enh:** macOS users receive clear instructions for manual IP configuration when needed.
- **Enh:** Cleaner output during database operations - technical details hidden unless using `--debug` flag.
- **Enh:** Better progress display for large files during extraction.
- **Enh:** Improved command help organization with hidden advanced flags (use `--show-all` to view).
- **Enh:** Installer now supports both formatted and minified JSON manifests for better reliability.
- **Enh:** Enhanced installer colors for better readability in terminal.
- **Enh:** Smarter installer with automatic platform detection and helpful error messages.
- **Enh:** Windows CMD installer now detects if run on Linux/macOS and provides correct installation command.
- **Enh:** Faster container management when working with many sites - now processes in batches.
- **Enh:** More efficient memory usage when managing large numbers of containers.
- **Enh:** Simplified command descriptions throughout the tool for clarity.
- **Enh:** Additional command aliases for convenience (`--env-path`, `--ip`).
- **Enh:** All dump commands now support `--outputdir` flag for consistent behavior.
- **Enh:** Docker Compose compatibility - works with both newer V2 plugin and older standalone V1.
- **Enh:** More helpful debug information when using `--debug` flag to troubleshoot configuration issues.
- **Enh:** Register command now displays your license information after activation.
- **Enh:** Simpler site reset - automatically uses existing credentials without prompting.
- **Enh:** Restart command now applies manual changes made to `.env` file.
- **Enh:** Database name respects your custom `--db-name` value.
- **Enh:** Command aliases for faster typing: `up`, `down`, `dh`, `di`, `dm`, `license`, `unlicense`.
- **Enh:** Better IP conflict handling - adjusts ports instead of switching IPs when you specify `--container-ip`.
- **Enh:** Command reference documentation now features modern two-column HTML layout with table of contents sidebar.
- **Enh:** Improved markdown formatting for command documentation with proper code blocks.
- **Enh:** Generation timestamp added to all command documentation formats for tracking updates.
- **Enh:** Windows users now see proper spinners and progress indicators with automatic ANSI escape code support.
- **Enh:** Better hostname validation with clearer error messages for invalid site URLs.
- **Enh:** Nginx configuration automatically regenerates when HTTPS port changes.
- **Enh:** Installer supports beta, RC, and alpha version downloads for testing pre-release versions.
- **Enh:** `wpstg` and `wp-staging` command aliases added for quicker access.
- **Fix:** Configuration file now loads correctly from default location on all operating systems.
- **Fix:** Settings saved in config file (like `--workingdir`) now apply properly at startup.
- **Fix:** Site list command now finds all your sites reliably without missing any.
- **Fix:** Port change detection now only prompts for URL updates when ports actually change.
- **Fix:** Database connection issues when adding sites with custom ports resolved.
- **Fix:** Site installation now works correctly with port auto-adjustment.
- **Fix:** Database credentials remain consistent throughout installation process.
- **Fix:** Command options now load properly from configuration file.
- **Fix:** Installer checksum parsing now handles formatted JSON with multiple fields correctly.
- **Fix:** Container restart now properly applies port changes from `.env` file.
- **Fix:** URL updates only triggered when HTTPS port actually changes, preventing false prompts.
- **Fix:** Site deletion returns proper success status.
- **Fix:** SSL certificate verification works with external databases.
- **Fix:** WordPress installation handles empty databases gracefully.
- **Fix:** Auto-generated completion command now properly disabled instead of just hidden.
- **Fix:** Confirmation prompt countdown no longer interferes with user keyboard input.
- **Fix:** Status command now correctly displays disabled sites with their port information.
- **Fix:** Windows installer now uses correct binary name and passes version arguments properly.
- **Fix:** Shell scripts no longer show false error messages during successful operations.
- **Dev:** Removed deprecated `--confirm-timeout` flag (use `--prompt-timeout` instead).
- **Dev:** Comprehensive installer testing suite with 21 automated tests integrated with Docker infrastructure.
- **Dev:** New Make targets for installer testing: `docker-test-installer`, `docker-test-installer-setup` (use `DEBUG=1` for debug mode).
- **Dev:** Installer test documentation with step-by-step guides and troubleshooting for all testing scenarios.
- **Dev:** Test helper functions for manifest parsing, checksum verification, and binary validation.
- **Dev:** Complete test coverage for manifest download, binary execution, platform detection, and error handling.
- **Dev:** Updated documentation with OS-specific config file paths and working directory resolution details.
- **Dev:** Enhanced debugging documentation showing how to trace configuration and path issues.
- **Dev:** Comprehensive test suite with 9 integration tests for site lifecycle.
- **Dev:** Updated documentation with license management and external database guides.
- **Dev:** Code refactoring to eliminate duplicate WP-CLI environment variables across multiple functions.
- **Dev:** Test coverage for external database switch protection with comprehensive integration tests.
- **Dev:** DockerizeExecutor refactored into focused modules: operations, port validation, site management, and status display.
- **Dev:** Shell scripts now use shared library (`docker-lib`) for common functions.
- **Dev:** Manifest generator test suite validates JSON formatting and version support.
- **Dev:** Requires Docker Compose 2.19.0 or later for container management.

## v1.3.1 (2025-08-20)

- **New:** Development script for easier testing and running the tool.
- **Enh:** Better documentation with clearer examples.
- **Enh:** Updated testing framework for improved reliability.
- **Fix:** Commands now work correctly when using special characters or spaces.
- **Fix:** You can now use multiple filter options together (like `--only-wproot --only-database`).
- **Fix:** Windows users no longer experience file locking issues.

## v1.3.0 (2025-06-26)

- **New:** Faster database restoration for large WordPress sites.
- **Enh:** Better progress display when restoring your database.
- **Fix:** Database restore now completes successfully for all table sizes.

## v1.2.3 (2025-05-15)

- **New:** Save your favorite settings in a config file so you don't have to type them every time.
- **New:** Use `--skip-config` to ignore your saved settings when needed.
- **New:** Support for Developer Plan (30 Active Sites) license.
- **Enh:** Better error messages when something goes wrong with your database.
- **Enh:** Older license keys continue to work.
- **Fix:** Database views are now restored correctly.
- **Fix:** Backup with corrupted entries no longer stop the restoration process.
- **Fix:** Configuration settings are now saved and loaded properly.

## v1.2.2 (2025-02-19)

- **New:** Support for MySQL socket connections (automatically detects from wp-config.php).
- **New:** Control how long confirmation prompts wait before timing out (`--confirm-timeout`).
- **New:** Adjust database import speed with `--db-insert-batch-size` option.
- **New:** Bash command completion for faster typing in terminal.
- **Enh:** Tool now prevents running as root user for better security.
- **Enh:** Better handling of special characters in your database content.
- **Fix:** Restoring database-only backups now works correctly.
- **Fix:** Compatible with various MySQL and MariaDB server configurations.

## v1.2.1 (2024-12-18)

- **Fix:** Internal release addressing various bug fixes.

## v1.2.0 (2024-12-18)

- **New:** WordPress Multisite support - extract and restore network sites, main sites, and subsites.
- **New:** Verify file integrity with `--verify` flag to ensure your backup extracted correctly.
- **Enh:** Faster extraction of compressed backups.
- **Enh:** Better URL replacement for multisite installations.
- **Enh:** Automatic cleanup of empty output folders.
- **Fix:** WordPress serialized data is now handled correctly.
- **Fix:** Compressed backup files extract more reliably.
- **Fix:** Skipping database extraction works as expected.
- **Fix:** Media files restore to the correct location on multisite subsites.
- **Fix:** WordPress core tables are preserved during database restoration.

## v1.1.0 (2024-10-09)

- **New:** Restore command - rebuild your entire WordPress site from a backup file.
- **New:** Exclude specific files or folders during extraction with `--exclude` flags.
- **New:** Overwrite existing WordPress files with `--overwrite` option.
- **New:** Clean up database tables that aren't in your backup with `--remove-tables`.
- **New:** View detailed backup contents with `--data` flag.
- **New:** Secure SSL/TLS database connections for remote servers.
- **Enh:** Much faster and more reliable extraction of large compressed backups.
- **Enh:** Better progress tracking so you know how long operations will take.
- **Enh:** Improved documentation with more examples.
- **Fix:** Large compressed backups no longer fail during extraction.
- **Fix:** Database operations complete successfully without interruption.

## v1.0.3 (2024-08-09)

- **Enh:** Tool renamed to "WP Staging CLI" for clarity.
- **Enh:** Support for Agency and Developer license plans.

## v1.0.2 (2024-08-05)

- **Fix:** Progress bars now display correctly on Windows 10 and newer versions.

## v1.0.1 (2024-07-31)

- **Fix:** Tool now works on all Linux systems without needing extra software installed.

## v1.0.0 (2024-07-28)

- **Enh:** Various fixes and enhancements.

## v0.0.0

- **New:** Initial release for internal use.
