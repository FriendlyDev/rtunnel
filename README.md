# rtunnel

`rtunnel` is a security-minded, user-friendly SSH tunnel manager. It wraps SSH **local port forwarding** (`ssh -L ...`) with simple commands to **open**, **list**, and **close** tunnels, with optional **history** so you can quickly reconnect later.

---

## Install

```bash
curl -fsSL https://github.com/FriendlyDev/rtunnel/releases/latest/download/install.sh | bash
```

---

## Open tunnels

Open a tunnel:

```bash
rtunnel open --name "grafana-staging" --local=80 --remote=8080 --ssh=user@hostname.tld
```

### Opt-in: verify the tunnel stays up (`--wait`)
By default, `rtunnel open` starts `ssh` in the background and returns immediately.

If you want `rtunnel` to fail fast when SSH exits immediately (bad host, auth failure, forward rejected), use `--wait`:

- `--wait` defaults to **2.0 seconds**
- you can pass a custom value like `--wait=0.5`

Examples:

```bash
rtunnel open --wait --name "grafana-staging" --local=80 --remote=8080 --ssh=user@hostname.tld
rtunnel open --wait=0.5 --name "grafana-staging" --local=80 --remote=8080 --ssh=user@hostname.tld
```

---

## JSON output (requires jq)

Many commands support `--json` to emit machine-readable output on stdout.

**`jq` is required when using `--json`.**

---

## Diagnostics

Run:

```bash
rtunnel doctor
```

Or machine-readable diagnostics:

```bash
rtunnel doctor --json | jq .
```

`doctor` reports:
- rtunnel version
- which config file was used (if any)
- availability of ssh/jq/fzf
- key paths (RTUNNEL_DIR, active/history/state)
- active tunnel counts and stale count

---
