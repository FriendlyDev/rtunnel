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
curl -fsSL https://github.com/FriendlyDev/rtunnel/releases/latest/download/install.sh | bash -s -- --version v0.2.0
```

### Install location options

```bash
# Install into PREFIX/bin (default PREFIX is ~/.local)
curl -fsSL https://github.com/FriendlyDev/rtunnel/releases/latest/download/install.sh | bash -s -- --prefix "$HOME/.local"

# Or specify an explicit bin directory
curl -fsSL https://github.com/FriendlyDev/rtunnel/releases/latest/download/install.sh | bash -s -- --bindir "$HOME/bin"
```

### (Not recommended) Skip checksum verification

```bash
curl -fsSL https://github.com/FriendlyDev/rtunnel/releases/latest/download/install.sh | bash -s -- --no-verify
```

---

## Quick start

### Open a tunnel

Named args (any order):

```bash
rtunnel open --local=80 --remote=8080 --ssh=user@hostname.tld
```

Positional args:

```bash
rtunnel open 80 8080 user@hostname.tld
```

Pass additional SSH flags after `--`:

```bash
rtunnel open --local=80 --remote=8080 --ssh=user@hostname.tld -- -i ~/.ssh/id_ed25519 -J jumpbox
```

Name it (recommended):

```bash
rtunnel open --name "grafana-staging" --local=80 --remote=8080 --ssh=user@hostname.tld
```

Mark it as a favorite at creation time:

```bash
rtunnel open --favorite --name "grafana-staging" --local=80 --remote=8080 --ssh=user@hostname.tld
```

### Private tunnels (no history)

If you open a tunnel with `--private`, `rtunnel` will **not** save it to history and will **not** update “last opened” state. This means:

- `rtunnel reopen` **cannot** reopen private tunnels.

By default, `rtunnel open --private ...` prints a warning explaining this. To silence warnings:

- set `RTUNNEL_NO_WARN=1`, or
- pass `--no-warn` to `open`.

Examples:

```bash
rtunnel open --private --name "one-off" --local=3306 --remote=3306 --ssh=user@db-host
rtunnel open --private --no-warn --name "one-off" --local=3306 --remote=3306 --ssh=user@db-host
```

### List open tunnels

```bash
rtunnel ls
```

### Close a tunnel

Close by local port:

```bash
rtunnel close 80
```

Close by active name:

```bash
rtunnel close grafana-staging
```

---

## History

History is **enabled by default**, and is controlled by `RTUNNEL_HISTORY_ENABLED`.

Show history:

```bash
rtunnel history
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

Forget an entry:

```bash
rtunnel forget 42
```

Rename an entry:

```bash
rtunnel name 42 "new name"
```

---

## Favorites

Favorites are stored in history metadata:

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

## Security model / defaults

`rtunnel` aims to be safe-by-default:

- Uses SSH `-N` (no remote command execution).
- Uses remote bind host `127.0.0.1` by default (loopback on the remote side).
- Avoids `eval`.
- Tracks tunnels by PID and cleans up stale entries when listing.
- Release installer verifies SHA256 checksums (unless you opt out).

**Important:** Port forwarding can expose services unintentionally. Always understand what you’re binding to and who can reach your forwarded port.

---

## Configuration

`rtunnel` loads an optional `.env` style config file.

Search order:

1. `$RTUNNEL_ENV_FILE` (if set)
2. `$XDG_CONFIG_HOME/rtunnel/rtunnel.env`
3. `$HOME/.config/rtunnel/rtunnel.env`

Start by copying the example config from the latest release:

```bash
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/rtunnel"
curl -fsSL https://github.com/FriendlyDev/rtunnel/releases/latest/download/rtunnel.env.example \
  -o "${XDG_CONFIG_HOME:-$HOME/.config}/rtunnel/rtunnel.env"
```

Example settings you may want:

```bash
RTUNNEL_HISTORY_ENABLED=1
RTUNNEL_FZF=1
RTUNNEL_DEFAULT_BIND=127.0.0.1
RTUNNEL_SSH_BIN=ssh

# reopen defaults
RTUNNEL_REOPEN_DEFAULT=prompt

# warning control
RTUNNEL_NO_WARN=0
```

---

## Interactive selection (fzf)

If `fzf` is installed and `RTUNNEL_FZF=1`, interactive commands like `rtunnel reopen` will use it. Otherwise `rtunnel` falls back to a simple numbered prompt.

Install fzf:

- macOS (Homebrew): `brew install fzf`
- Linux: use your distro’s package manager

---

## Shell completion

### Bash completion

Source the completion script from your `.bashrc`:

```bash
# Example path if you cloned the repo
source /path/to/rtunnel/completions/rtunnel.bash
```

### Zsh completion

Add the completion directory to your `$fpath` and enable `compinit`:

```zsh
fpath=(/path/to/rtunnel/completions $fpath)
autoload -Uz compinit && compinit
```

---

## Release automation (for maintainers)

This repository can publish releases automatically on push to `master`:

- Reads version from `./rtunnel --version`
- If tag `vX.Y.Z` does not exist, it creates:
  - an **annotated git tag**
  - a GitHub Release
  - release assets: `rtunnel`, `install.sh`, `rtunnel.env.example`, `SHA256SUMS`

This makes “bump version → push → release” the only manual steps.

---

## License

MIT. See `LICENSE`.
