# rtunnel

`rtunnel` is a security-minded, user-friendly SSH tunnel manager. It wraps SSH **local port forwarding** (`ssh -L ...`) with simple commands to **open**, **list**, and **close** tunnels, with optional **history** so you can quickly reconnect later.

It’s designed for macOS and Linux, and implemented as a small **bash** script with:

- safe defaults (binds to loopback by default)
- no `eval`
- optional history (enabled by default)
- release-based install with SHA256 integrity verification

---

## What this simplifies

Instead of typing:

```bash
ssh -N -L 80:127.0.0.1:8080 user@hostname.tld
```

You can run:

```bash
rtunnel open --local=80 --remote=8080 --ssh=user@hostname.tld
```

---

## Install (recommended: latest release)

### Install latest release

This installs the latest published release and verifies it with SHA256:

```bash
curl -fsSL https://github.com/FriendlyDev/rtunnel/releases/latest/download/install.sh | bash
```

By default it installs to:

- `~/.local/bin/rtunnel`

Ensure `~/.local/bin` is in your `PATH`.

### Install a specific version

```bash
curl -fsSL https://github.com/FriendlyDev/rtunnel/releases/latest/download/install.sh | bash -s -- --version v0.4.0
```

---

## Quick start

### Open a tunnel

```bash
rtunnel open --name "grafana-staging" --local=80 --remote=8080 --ssh=user@hostname.tld
```

Pass additional SSH flags after `--`:

```bash
rtunnel open --name "grafana-staging" --local=80 --remote=8080 --ssh=user@hostname.tld -- -i ~/.ssh/id_ed25519 -J jumpbox
```

Mark it as a favorite at creation time:

```bash
rtunnel open --favorite --name "grafana-staging" --local=80 --remote=8080 --ssh=user@hostname.tld
```

#### Replace by name (restart a tunnel)
Replace any currently-active tunnel with the same name:

```bash
rtunnel open --replace --name "grafana-staging" --local=80 --remote=8080 --ssh=user@hostname.tld
```

Notes:
- `--replace` replaces **by active name only**.
- `--replace` requires an explicit `--name`.

### Private tunnels (no history)

If you open a tunnel with `--private`, `rtunnel` will **not** save it to history and will **not** update “last opened” state. This means:

- `rtunnel reopen` **cannot** reopen private tunnels.

By default, `rtunnel open --private ...` prints a warning explaining this. To silence warnings:

- set `RTUNNEL_NO_WARN=1`, or
- pass `--no-warn` to `open`.

---

## JSON output (requires jq)

Many commands support `--json` to emit machine-readable output on stdout.

**`jq` is required when using `--json`.** If `jq` is not installed and you pass `--json`, `rtunnel` will exit with an error.

Output contract:
- Single-target commands output a **single JSON object** (`open --json`, `close 80 --json`)
- Multi-target commands output a **JSON array** (`ls --json`, `history --json`, `favorites --json`, `close --all --json`)

Examples:

```bash
rtunnel ls --json | jq .
rtunnel history --favorites --json | jq .
rtunnel open --name test --local 9999 --remote 9999 --ssh user@host --json | jq .
rtunnel close test --json | jq .
rtunnel close --all --json | jq .
```

---

## List open tunnels

```bash
rtunnel ls
```

---

## Close tunnels

Close by local port:

```bash
rtunnel close 80
```

Close by active name:

```bash
rtunnel close grafana-staging
```

Close all tunnels (best-effort; exits non-zero if any close fails):

```bash
rtunnel close --all
```

Force close all tunnels (SIGKILL if SIGTERM doesn’t stop a tunnel):

```bash
rtunnel close --all --force
```

Remove stale entries (dead PIDs) without killing anything:

```bash
rtunnel close --stale
```

---

## History

Show history:

```bash
rtunnel history
```

Filter history by name:

```bash
rtunnel history --name "grafana-staging"
```

Show favorites only:

```bash
rtunnel history --favorites
```

Limit results:

```bash
rtunnel history --limit 20
```

Reopen a tunnel from history (interactive; uses `fzf` if installed and enabled):

```bash
rtunnel reopen
```

Reopen by history id (the numeric ID shown in `rtunnel history`):

```bash
rtunnel reopen 42
```

Reopen the most recently opened (non-private) tunnel:

```bash
rtunnel reopen --last
```

To make `rtunnel reopen` default to reopening the most recent tunnel, set:

```bash
RTUNNEL_REOPEN_DEFAULT=last
```

---

## "Did you mean?" suggestions

When you type a name that doesn’t exist, `rtunnel` will suggest close matches (printed to stderr):

- `rtunnel close <name>` suggests from **active** tunnel names
- `rtunnel reopen <name>`, `rtunnel fav <name>`, `rtunnel unfav <name>` suggest from **history** names

To disable suggestions:

- set `RTUNNEL_NO_SUGGEST=1`, or
- pass `--no-suggest` to the command.

---

## Favorites

```bash
rtunnel fav 42
rtunnel unfav 42
rtunnel favorites
```

You can also favorite by most-recent name match:

```bash
rtunnel fav grafana-staging
```

---

## Configuration

`rtunnel` loads an optional `.env` style config file.

Search order:

1. `$RTUNNEL_ENV_FILE` (if set)
2. `$XDG_CONFIG_HOME/rtunnel/rtunnel.env`
3. `$HOME/.config/rtunnel/rtunnel.env`

---

## License

MIT. See `LICENSE`.
