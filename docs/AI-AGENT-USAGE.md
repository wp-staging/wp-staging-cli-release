# AI Agent Usage

## Overview

How an AI coding assistant, a script, or any other program drives a local site created by WP Staging CLI when there is no person at the keyboard. This guide assumes an installed `wpstaging` binary.

Three things make the CLI usable this way. `wpstaging wp` runs a single WP-CLI command in a site and keeps standard output clean, so its result can be captured straight into a variable. `--json` turns every other command into machine-readable envelopes, including the prompts a program has to answer. Exit codes separate success from failure.

Most work needs no terminal at all. Reading a site and running WP-CLI commands never ask for anything. Site management is the exception: `add`, `start`, `del` and their neighbours write the machine's hosts file, install a security certificate into the system trust store, and on macOS bind a loopback address. Each of those needs root, so each can prompt. This document names every one of them, says what a program sees in each mode, and gives the flags that skip the step and the prompt with it.

Nothing here is a full command reference. See [COMMANDS.md](./COMMANDS.md) for the complete list of commands and flags.

---

## Table of Contents

- [Start here](#start-here)
- [Reading JSON output](#reading-json-output)
- [Run a WP-CLI command](#run-a-wp-cli-command)
- [Sites without WordPress](#sites-without-wordpress)
- [Read the site details](#read-the-site-details)
- [Export a static copy](#export-a-static-copy)
- [Commands that ask for a password](#commands-that-ask-for-a-password)
- [Calling Docker directly](#calling-docker-directly)
- [Things to know](#things-to-know)

---

## Start here

Two commands cover almost every task:

```bash
wpstaging list --json                          # find the sites and their details
wpstaging wp <hostname> <wp-cli arguments...>  # run one WP-CLI command in a site
```

A whole task usually looks like this. Read the site, start it if it is stopped, then work in it:

```bash
wpstaging list mysite.local --json          # read "running" from the response
wpstaging start mysite.local                # only when running is false
wpstaging wp mysite.local plugin list --format=json
```

A license is needed for the site commands. Supply it without a person present by setting the environment variable once:

```bash
export WPSTGPRO_LICENSE=<key>
```

`--license=<key>` does the same thing for a single command.

## Reading JSON output

Add `--json` to any command except `wp`. Every response uses the same envelope:

| Field | Meaning |
|---|---|
| `success` | Whether the command worked |
| `command` | Which response this is, for example `list`, `message`, `prompt` or `error` |
| `data` | The payload, whose shape depends on `command` |
| `error` | Present on failure, carrying `message`, a stable `code`, and sometimes `hint` |

**Responses are pretty-printed and span several lines.** Do not read the output line by line and parse each line as JSON. Feed the stream to a JSON decoder and read one complete object at a time.

One run emits several objects. Notices arrive as their own `message` responses before the one you asked for, so match on the `command` field rather than counting objects:

```json
{
  "success": true,
  "command": "message",
  "data": {
    "type": "config_loaded",
    "message": "Loaded 1 options from /home/user/.config/wpstaging/wpstaging.conf"
  }
}
{
  "success": true,
  "command": "list",
  "data": {
    "sites": [
      {
        "name": "mysite.local",
        "running": false,
        "url": "https://mysite.local"
      }
    ]
  }
}
```

A failure keeps the same envelope, with `success` false and `command` set to `error`:

```json
{
  "success": false,
  "command": "error",
  "error": {
    "message": "Error: WordPress site 'nope.local' not available. Use `wpstaging add nope.local` to create one.",
    "code": "error"
  }
}
```

Most failures carry the plain code `error`, so branch on `success` first. Some cases carry a specific code worth matching, such as `docker_not_running`, `docker_not_installed`, `unsupported_php_version`, `unsupported_db_version` and `site_has_no_wordpress`. See [Sites without WordPress](#sites-without-wordpress) for the last one. A few errors also carry `hint`, an array of suggested next steps.

Treat `0` as success and any non-zero code as failure. In practice the failure code is `1`. `wpstaging wp` is the exception and returns whatever WP-CLI returned.

## Run a WP-CLI command

`wpstaging wp` runs a single WP-CLI command inside the site's PHP container and exits. Everything after the hostname reaches WP-CLI unchanged.

```bash
wpstaging wp mysite.local plugin list --format=json
wpstaging wp mysite.local option get siteurl
wpstaging wp mysite.local db query "SELECT COUNT(*) FROM wp_posts"
wpstaging wp mysite.local core version
```

### Output contract

| Stream | Carries |
|---|---|
| Standard output | WP-CLI output only, byte for byte |
| Standard error | WP-CLI errors, plus any message from WP Staging CLI |
| Exit code | The code WP-CLI returned |

Nothing from WP Staging CLI is written to standard output, so this is safe:

```bash
plugins=$(wpstaging wp mysite.local plugin list --format=json)
```

This holds in every mode, including `--json` and a terminal session. Messages that other commands print to standard output, such as the config-file notice or a Docker warning, move to standard error for this command.

There is no time limit, so a long `db export` or `search-replace` runs to completion.

### Quoting

There is one shell layer, so quote as you normally would:

```bash
wpstaging wp mysite.local db query "SELECT COUNT(*) FROM wp_posts"
```

### Flags

Flags placed **before** the hostname belong to WP Staging CLI. Flags placed **after** the hostname belong to WP-CLI. This holds even when both tools use the same flag name:

```bash
wpstaging wp --env-path /custom/path mysite.local plugin list   # --env-path is ours
wpstaging wp mysite.local plugin list --quiet                   # --quiet is WP-CLI's
```

Position is the only rule, so a flag that only WP Staging CLI accepts, such as `--env-path`, reaches WP-CLI when written after the hostname and does not apply here. The command prints a warning to standard error when it sees this.

### The site must be running

`wpstaging wp` never starts a site by itself, because starting containers is a side effect the caller did not ask for. A stopped site fails with exit code 1 and this message on standard error:

```
Error: WordPress site 'mysite.local' is not running. Use `wpstaging start mysite.local` to start it.
```

Start it first when that happens:

```bash
wpstaging start mysite.local
```

That command can ask for a password. See "Commands that ask for a password" below.

### Multisite

Pass WP-CLI's own `--url` to target a subsite:

```bash
wpstaging wp mysite.local --url=sub.mysite.local plugin list
```

## Sites without WordPress

A site created with `wpstaging add <hostname> --skip-wordpress` is a plain PHP site. `list --json` reports it with `site_type` set to `php`. Check this field before you call `wpstaging wp`.

On such a site, `wp`, `switch-wp`, `magic-link`, and `update-subdomains` stop with the error code `site_has_no_wordpress`. `restore` stops the same way when `--path` points into the site directory. `start`, `stop`, `restart`, `switch-php`, `reconfigure`, `reset`, and `del` work as usual.

To work in the site, write files to the directory in `path`. PHP code reads the database settings with `getenv()`: `DB_HOST`, `DB_NAME`, `DB_USER`, and `DB_PASSWORD`. To run a command in the container, use `docker exec <container_php> <command>`.

## Read the site details

`wpstaging list --json` answers with a `list` response whose `data.sites` is an array, one entry per site. Read the objects as described in [Reading JSON output](#reading-json-output) and pick the one whose `command` field is `list`.

```bash
wpstaging list --json
```

Pass one or more hostnames to limit the output to those sites: `wpstaging list mysite.local other.local --json`. An unknown hostname is not an error. It returns an empty `sites` array and exit code `0`, so check the array rather than the exit code. When no sites exist at all, `list --json` returns an error response with the code `no_sites` and exit code `1`.

Each entry in `data.sites` carries more than 30 fields. These are the ones a program usually needs:

| Field | Meaning |
|---|---|
| `name` | Hostname. Pass this to every other command |
| `running` | Whether the site's containers are up |
| `path` | WordPress directory on the host |
| `url` | Site URL |
| `site_type` | `single`, `multisite`, `multisite-subdomain`, or `php`. A `php` site has no WordPress |
| `container_php` | Name of the PHP container |
| `container_db` | Name of the database container |
| `docroot` | WordPress path inside the container |

To read one group of sites instead of all of them, add `--filter=<term>`. A plain term is searched in the name, label, address, status, PHP version, site type, and subsites. A term written as `field:value` searches one field only, such as `status:stopped` or `adminer:off`. Repeat the flag to narrow further. The `summary` and `pagination` blocks then describe the sites returned.

```bash
wpstaging list --json --filter=shop --filter=running:true
```

## Export a static copy

`export-static` saves a running site as a static website: plain HTML, CSS, JavaScript, and media files that need no PHP or database.

```bash
wpstaging export-static mysite.local --json
```

Like `wp`, it needs a running site and never starts one. A stopped site fails with an error that names the `start` command. It needs no root and no password.

While the export runs, `message` responses with `"type": "progress"` arrive about once per second. The last response has `command` set to `export_static`:

| Field | Meaning |
|---|---|
| `output_dir` | Absolute path of the export. The default is `~/wpstaging/sites/<hostname>/static` |
| `pages` | Saved HTML pages |
| `files` | Saved files of every other type |
| `failed` | URLs that could not be saved, each with `url` and `reason`. Always an array |
| `truncated` | `true` when the export stopped adding URLs at its limit |

**Check `failed`, not only the exit code.** Broken links on the site do not change the exit code, which stays `0`. The exit code is `1` only when the export stops, for example because the site is stopped, the home page fails, an option or the output directory is refused, or a question is declined.

`--output-dir` writes the export to another directory. When that directory already exists, the command first sends a `prompt` with `"type": "confirm"`. Pass `--yes` to answer it in advance. A directory that holds files an earlier export did not write is refused without a question, so the export never replaces unrelated files.

## Commands that ask for a password

`wp`, `list`, and `export-static` never need root, so the workflow above runs without a password prompt. Site management is different. `add`, `start`, `del`, `remove` and the other site commands update the machine's hosts file. On macOS they also bind a loopback address, and on Linux they may start the Docker service. Each of those steps needs root.

The hosts file is written only when its content changes, so the prompt is intermittent. One quiet run is not proof that the next one is quiet.

What a program sees depends on the mode:

| Mode | Behavior |
|---|---|
| Plain output, no terminal | `sudo` has nowhere to read the password from and fails |
| `--json` on macOS and Linux | A `prompt` response with `"type": "sudo"` on standard output. Write `<password>\n` to standard input to answer it |
| `--json` on Windows | No prompt response. Windows uses its own dialog, see below |

The JSON prompt has no timeout. It waits on standard input until it gets an answer. `--prompt-timeout` applies only to prompts in plain output mode.

### Answering a prompt in JSON mode

A prompt arrives as an ordinary response with `command` set to `prompt`. The `data.type` field says which kind it is, so match on that rather than on the message text.

A password request carries `"type": "sudo"`. Answer it by writing the password and a newline to standard input.

A yes/no question carries `"type": "confirm"` and lists what it accepts:

```json
{
  "success": true,
  "command": "prompt",
  "data": {
    "message": "The next action will install a security certificate to your system.\nThis allows your browser to trust the SSL certificates created by this tool.\nContinue to install?",
    "type": "confirm",
    "accept": ["y", "n"]
  }
}
```

The `message` is written for a person to read and its wording can change, so match on `type` instead. This one gains a further line, "Sudo permission is required." or "Administrator permission is required.", when the command is not already running with those rights.

Answer by writing `y` or `n` and a newline to standard input. Anything else is rejected and the question is asked again, up to ten times.

Answer `n` only when the refusal is meant to last. See [Leaving the security certificate alone](#leaving-the-security-certificate-alone) for what a `n` to that particular question does.

### macOS and Linux

A person runs this once, in a terminal:

```bash
wpstaging sudo-rules
```

It asks for the password once, then writes a sudo configuration file that allows only the exact commands listed above, and only for that user. Those commands then run without a prompt, and no `sudo` prompt envelope is emitted at all.

An agent can check the state at any time. This never asks for a password:

```bash
wpstaging sudo-rules --status --json
```

Read the `installed` field of the `sudo_rules` response. `--dry-run` prints the rules that would be written without writing them, and `--remove` undoes the install.

### Windows

Windows has no sudo configuration file, so there is no `sudo-rules` command there. The hosts file update asks for confirmation through a User Account Control dialog, which a program cannot answer.

When that happens the elevated work continues in a separate console window and the original command exits with code `0`. The exit code and the output therefore say nothing about whether the hosts file was updated. Read `C:\Windows\System32\drivers\etc\hosts` to confirm.

For unattended use on Windows, run the agent from a console that is already elevated, or leave the hosts file alone.

### Leaving the hosts file alone

Every site command accepts `--skip-update-hosts-file`, which skips the step and the prompt with it. The flag is not listed in `--help`.

```bash
wpstaging start mysite.local --skip-update-hosts-file
```

This is safe when the hostname already resolves, which is the normal case for a site that was added earlier. A new site created this way does not resolve until the entry exists, so an agent that creates sites still needs one of the options above.

On macOS the flag does not cover the loopback address, which is bound separately. `add`, `reconfigure`, `update-subdomains`, and `update-hosts-file` accept `--skip-macos-auto-ip` to avoid that prompt as well. Sites then separate by port instead of by address. `start` and `restart` do not accept this flag. They ask for the password only when the site's address is not bound yet, for example after a reboot.

### Leaving the security certificate alone

The hosts file is not the only step that asks for a password. On Linux and macOS the local certificate authority is installed into the system trust store, which needs sudo too, and `wpstaging sudo-rules` does not cover that step. Windows is not affected, because the certificate goes into the current user's store.

Every site command accepts `--skip-install-ca`, which skips the prompt and the trust install. The flag is not listed in `--help`.

```bash
wpstaging add mysite.local --skip-install-ca
```

The site still gets its certificate and still serves HTTPS. Only the trust install is skipped, so a browser shows a warning until the certificate authority is installed later. The skip applies to the current run alone, so the next command asks again.

Answering `n` at the prompt is different. That answer is remembered, and no later run asks again until `wpstaging reinstall-ca` is run. A run with no terminal, where the prompt gets no answer at all, is treated as a skip and leaves nothing behind.

## Calling Docker directly

Prefer `wpstaging wp`. It handles the container name, the WordPress path, and the WP-CLI environment for you.

If a task genuinely needs raw Docker, take the container name and docroot from `list --json` instead of building them by hand. Note that `wp` is not on the container's default `PATH`, so give the full path to the phar:

```bash
docker exec <container_php> php /wp-cli/wp-cli.phar --path=<docroot> plugin list
```

## Things to know

- `wpstaging shell <hostname>` is for interactive use. Use `wpstaging wp` for a single command instead.
- `wpstaging wp` places no restriction on which WP-CLI commands may run. It has the same reach as an interactive shell on the site, so a destructive command such as `db drop` will do exactly what it says.
- Site commands need a valid WP Staging Pro license, the same as interactive use.

---

**Last Updated:** 2026-10-21 09:07:17 UTC
