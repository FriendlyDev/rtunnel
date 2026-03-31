#!/bin/sh
# install.sh - install rtunnel into a prefix (default: ~/.local/bin)
# Usage:
#   ./install.sh
#   PREFIX=$HOME/.local ./install.sh
#   BINDIR=$HOME/bin ./install.sh
set -eu

info() { printf '%s\n' "$*"; }
warn() { printf 'install: %s\n' "$*" >&2; }
die()  { warn "$*"; exit 1; }

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SRC="$ROOT_DIR/rtunnel"

[ -f "$SRC" ] || die "rtunnel not found next to install.sh"

PREFIX="${PREFIX:-$HOME/.local}"
BINDIR="${BINDIR:-$PREFIX/bin}"

mkdir -p "$BINDIR"

DEST="$BINDIR/rtunnel"
cp "$SRC" "$DEST"
chmod +x "$DEST"

info "Installed: $DEST"
info ""
info "Next:"
info "  1) Ensure $BINDIR is in your PATH"
info "  2) (Optional) copy example config:"
info "     mkdir -p \"\${XDG_CONFIG_HOME:-$HOME/.config}/rtunnel\""
info "     cp config/rtunnel.env.example \"\${XDG_CONFIG_HOME:-$HOME/.config}/rtunnel/rtunnel.env\""
info ""
info "Shell completions:"
info "  bash: source completions/rtunnel.bash"
info "  zsh : put completions/_rtunnel in your \$fpath and run compinit"