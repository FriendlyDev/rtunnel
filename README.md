# rtunnel

`rtunnel` is a small POSIX-shell CLI to open/list/close SSH local port forwards (“tunnels”) and optionally keep a history of tunnels you’ve opened.

It’s designed to be:
- simple
- portable
- easy to install (`~/.local/bin`)
- configurable via a `.env` style file

## What it does

This command:

```sh
ssh -N -L 80:127.0.0.1:8080 user@hostname.tld
```

becomes:

```sh
rtunnel open --local=80 --remote=8080 --ssh=user@hostname.tld
```

## Install

### Option A: clone + install script

```sh
git clone https://github.com/FriendlyDev/rtunnel
cd rtunnel
./install.sh
```

By default it installs to `~/.local/bin/rtunnel`. You can override:

```sh
PREFIX=$HOME/.local ./install.sh
# or
BINDIR=$HOME/bin ./install.sh
```

### Option B: run without installing

From the repo directory:

```sh
./rtunnel --help
./rtunnel ls
```

## Usage

### Open a tunnel

Named args (any order):

```sh
rtunnel open --local=80 --remote=8080 --ssh=user@hostname.tld
```

Positional args:

```sh
rtunnel open 80 8080 user@hostname.tld
```

Pass extra SSH args after `--`:

```sh
rtunnel open --local=80 --remote=8080 --ssh=user@hostname.tld -- -i ~/.ssh/id_ed25519 -J jumpbox
```

Name it:

```sh
rtunnel open --name "grafana staging" --local=80 --remote=8080 --ssh=user@hostname.tld
```

Private (don’t save in history):

```sh
rtunnel open --private --local=80 --remote=8080 --ssh=user@hostname.tld
```

### List open tunnels

```sh
rtunnel ls
```

### Close a tunnel by local port

```sh
rtunnel close 80
```

## History (optional, enabled by default)

Show history:

```sh
rtunnel history
```

Reopen from history (interactive if `fzf` installed):

```sh
rtunnel reopen
```

Forget a history entry:

```sh
rtunnel forget
```

Rename a history entry:

```sh
rtunnel name
```

If you disable history in config, these subcommands are hidden from `rtunnel --help` and will print a warning if called.

## Configuration

`rtunnel` loads a `.env` style config file if present:

1. `$RTUNNEL_ENV_FILE` (if set)
2. `$XDG_CONFIG_HOME/rtunnel/rtunnel.env`
3. `$HOME/.config/rtunnel/rtunnel.env`

Start by copying the example:

```sh
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/rtunnel"
cp config/rtunnel.env.example "${XDG_CONFIG_HOME:-$HOME/.config}/rtunnel/rtunnel.env"
```

## Shell completion

### Bash

Source `completions/rtunnel.bash` from your `.bashrc`:

```sh
source /path/to/rtunnel/completions/rtunnel.bash
```

### Zsh

Add `completions/` to your `$fpath` and enable `compinit`:

```zsh
fpath=(/path/to/rtunnel/completions $fpath)
autoload -Uz compinit && compinit
```

Then restart your shell.

## Notes / limitations

- `rtunnel` tracks tunnels by local port and stores a PID. If the SSH process dies, `rtunnel ls` will clean up stale entries.
- Extra SSH arguments passed after `--` are stored as a single string in history; complex quoting may not round-trip perfectly. (It’s good enough for typical `-i`, `-J`, `-o` use.)

## License

MIT (suggested). See `LICENSE`.