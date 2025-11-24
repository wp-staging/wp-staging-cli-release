## v1.4.0-beta.1
<!-- IMPORTANT: Write changelog entries in user-friendly language for non-technical users. -->
<!-- Use only these prefixes: New: Enh: Fix: Dev: -->
<!-- Avoid technical jargon, focus on benefits, and explain what users can do with features. -->
<!-- Example: Instead of "Multi-row INSERT optimization" use "Faster database restoration for large sites" -->
<!-- This comment will be automatically removed during release by .github/workflows/deploy.yml -->

**New:** Local development environment for WordPress staging sites with isolated Docker containers.  
**New:** Run multiple WordPress sites simultaneously - each site gets its own containers with unique IPs and ports.  
**New:** Automatic port and IP address management - no manual configuration needed when running multiple sites.  
**New:** Per-site configuration files - each site remembers its settings between restarts.  
**New:** Filter site list by hostname to quickly find specific sites: `wpstaging list mysite.local`  
**New:** `reset` command to reinstall WordPress without losing container configuration.  
**New:** One-click installation with automated installers for Windows, macOS, and Linux.  
**New:** Unregister command to deactivate your license when switching machines.  
**New:** License information display showing plan details, expiration date, and remaining activations.  
**New:** External database support - connect sites to remote MySQL/MariaDB servers with `--external-db` flag.  
**New:** Secure random password generation with `--secure-credentials` flag.  
**New:** Protection against switching from external to internal database without proper reconfiguration.  
**Enh:** Simplified site creation - use `add <site-url>` to create and configure sites in one step.  
**Enh:** Better organization - each site stored in `~/wpstaging/sites/` with independent configurations.  
**Enh:** Automatic secure password generation for database and WordPress admin accounts.  
**Enh:** Site list command now shows real-time container status (Running/Stopped) and totals.  
**Enh:** Edit port settings in site's `.env` file and apply changes with `restart <hostname>` command.  
**Enh:** Linux and Windows users get automatic IP address assignment.  
**Enh:** macOS users receive clear instructions for manual IP configuration when needed.  
**Enh:** Cleaner output during database operations - technical details hidden unless using `--debug` flag.  
**Enh:** Better progress display for large files during extraction.  
**Enh:** Improved command help organization with hidden advanced flags (use `--show-all` to view).  
**Enh:** Installer now supports both formatted and minified JSON manifests for better reliability.  
**Enh:** Enhanced installer colors for better readability in terminal.  
**Enh:** Smarter installer with automatic platform detection and helpful error messages.  
**Enh:** Windows CMD installer now detects if run on Linux/macOS and provides correct installation command.  
**Enh:** Faster container management when working with many sites - now processes in batches.  
**Enh:** More efficient memory usage when managing large numbers of containers.  
**Enh:** Simplified command descriptions throughout the tool for clarity.  
**Enh:** Additional command aliases for convenience (`--env-path`, `--ip`).  
**Enh:** All dump commands now support `--outputdir` flag for consistent behavior.  
**Enh:** Docker Compose compatibility - works with both newer V2 plugin and older standalone V1.  
**Enh:** More helpful debug information when using `--debug` flag to troubleshoot configuration issues.  
**Enh:** Register command now displays your license information after activation.  
**Enh:** Simpler site reset - automatically uses existing credentials without prompting.  
**Enh:** Restart command now applies manual changes made to `.env` file.  
**Enh:** Database name respects your custom `--db-name` value.  
**Enh:** Command aliases for faster typing: `up`, `down`, `dh`, `di`, `dm`, `license`, `unlicense`.  
**Enh:** Better IP conflict handling - adjusts ports instead of switching IPs when you specify `--container-ip`.  
**Enh:** Command reference documentation now features modern two-column HTML layout with table of contents sidebar.  
**Enh:** Improved markdown formatting for command documentation with proper code blocks.  
**Enh:** Generation timestamp added to all command documentation formats for tracking updates.  
**Fix:** Configuration file now loads correctly from default location on all operating systems.  
**Fix:** Settings saved in config file (like `--workingdir`) now apply properly at startup.  
**Fix:** Site list command now finds all your sites reliably without missing any.  
**Fix:** Port change detection now only prompts for URL updates when ports actually change.  
**Fix:** Database connection issues when adding sites with custom ports resolved.  
**Fix:** Site installation now works correctly with port auto-adjustment.  
**Fix:** Database credentials remain consistent throughout installation process.  
**Fix:** Command options now load properly from configuration file.  
**Fix:** Installer checksum parsing now handles formatted JSON with multiple fields correctly.  
**Fix:** Container restart now properly applies port changes from `.env` file.  
**Fix:** URL updates only triggered when HTTPS port actually changes, preventing false prompts.  
**Fix:** Site deletion returns proper success status.  
**Fix:** SSL certificate verification works with external databases.  
**Fix:** WordPress installation handles empty databases gracefully.  
**Fix:** Auto-generated completion command now properly disabled instead of just hidden.  
**Dev:** Removed deprecated `--confirm-timeout` flag (use `--prompt-timeout` instead).  
**Dev:** Comprehensive installer testing suite with 21 automated tests integrated with Docker infrastructure.  
**Dev:** New Make targets for installer testing: `docker-test-installer`, `docker-test-installer-setup` (use `DEBUG=1` for debug mode).  
**Dev:** Installer test documentation with step-by-step guides and troubleshooting for all testing scenarios.  
**Dev:** Test helper functions for manifest parsing, checksum verification, and binary validation.  
**Dev:** Complete test coverage for manifest download, binary execution, platform detection, and error handling.  
**Dev:** Updated documentation with OS-specific config file paths and working directory resolution details.  
**Dev:** Enhanced debugging documentation showing how to trace configuration and path issues.  
**Dev:** Comprehensive test suite with 9 integration tests for site lifecycle.  
**Dev:** Updated documentation with license management and external database guides.  
**Dev:** Code refactoring to eliminate duplicate WP-CLI environment variables across multiple functions.  
**Dev:** Test coverage for external database switch protection with comprehensive integration tests.  

## v1.3.1 (2025-08-20)

**New:** Development script for easier testing and running the tool.  
**Enh:** Better documentation with clearer examples.  
**Enh:** Updated testing framework for improved reliability.  
**Fix:** Commands now work correctly when using special characters or spaces.  
**Fix:** You can now use multiple filter options together (like `--only-wproot --only-database`).  
**Fix:** Windows users no longer experience file locking issues.  

## v1.3.0 (2025-06-26)

**New:** Faster database restoration for large WordPress sites.  
**Enh:** Better progress display when restoring your database.  
**Fix:** Database restore now completes successfully for all table sizes.  

## v1.2.3 (2025-05-15)

**New:** Save your favorite settings in a config file so you don't have to type them every time.  
**New:** Use `--skip-config` to ignore your saved settings when needed.  
**New:** Support for Developer Plan (30 Active Sites) license.  
**Enh:** Better error messages when something goes wrong with your database.  
**Enh:** Older license keys continue to work.  
**Fix:** Database views are now restored correctly.  
**Fix:** Backup with corrupted entries no longer stop the restoration process.  
**Fix:** Configuration settings are now saved and loaded properly.  

## v1.2.2 (2025-02-19)

**New:** Support for MySQL socket connections (automatically detects from wp-config.php).  
**New:** Control how long confirmation prompts wait before timing out (`--confirm-timeout`).  
**New:** Adjust database import speed with `--db-insert-batch-size` option.  
**New:** Bash command completion for faster typing in terminal.  
**Enh:** Tool now prevents running as root user for better security.  
**Enh:** Better handling of special characters in your database content.  
**Fix:** Restoring database-only backups now works correctly.  
**Fix:** Compatible with various MySQL and MariaDB server configurations.  

## v1.2.1 (2024-12-18)

**Fix:** Internal release addressing various bug fixes.  

## v1.2.0 (2024-12-18)

**New:** WordPress Multisite support - extract and restore network sites, main sites, and subsites.  
**New:** Verify file integrity with `--verify` flag to ensure your backup extracted correctly.  
**Enh:** Faster extraction of compressed backups.  
**Enh:** Better URL replacement for multisite installations.  
**Enh:** Automatic cleanup of empty output folders.  
**Fix:** WordPress serialized data is now handled correctly.  
**Fix:** Compressed backup files extract more reliably.  
**Fix:** Skipping database extraction works as expected.  
**Fix:** Media files restore to the correct location on multisite subsites.  
**Fix:** WordPress core tables are preserved during database restoration.  

## v1.1.0 (2024-10-09)

**New:** Restore command - rebuild your entire WordPress site from a backup file.  
**New:** Exclude specific files or folders during extraction with `--exclude` flags.  
**New:** Overwrite existing WordPress files with `--overwrite` option.  
**New:** Clean up database tables that aren't in your backup with `--remove-tables`.  
**New:** View detailed backup contents with `--data` flag.  
**New:** Secure SSL/TLS database connections for remote servers.  
**Enh:** Much faster and more reliable extraction of large compressed backups.  
**Enh:** Better progress tracking so you know how long operations will take.  
**Enh:** Improved documentation with more examples.  
**Fix:** Large compressed backups no longer fail during extraction.  
**Fix:** Database operations complete successfully without interruption.  

## v1.0.3 (2024-08-09)

**Enh:** Tool renamed to "WP Staging CLI" for clarity.  
**Enh:** Support for Agency and Developer license plans.  

## v1.0.2 (2024-08-05)

**Fix:** Progress bars now display correctly on Windows 10 and newer versions.  

## v1.0.1 (2024-07-31)

**Fix:** Tool now works on all Linux systems without needing extra software installed.  

## v1.0.0 (2024-07-28)

**Enh:** Various fixes and enhancements.  

## v0.0.0

**New:** Initial release for internal use.  
