#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# install.sh - install rtunnel from GitHub Releases.
#
# Examples:
#   curl -fsSL https://github.com/FriendlyDev/rtunnel/releases/latest/download/install.sh | bash
#   curl -fsSL https://github.com/FriendlyDev/rtunnel/releases/latest/download/install.sh | bash -s -- --version v0.2.0
#   ... | bash -s -- --bindir "$HOME/.local/bin"
#
# Flags:
#   --version vX.Y.Z   Install specific release tag (default: latest)
#   --prefix PATH      Install into PATH/bin (default: ~/.local)
#   --bindir PATH      Install into PATH (overrides --prefix)
#   --no-verify        Skip SHA256 verification (not recommended)

OWNER="${RTUNNEL_OWNER:-FriendlyDev}"
REPO="${RTUNNEL_REPO:-rtunnel}"

PREFIX="${PREFIX:-$HOME/.local}"
BINDIR=""
VERSION_TAG="latest"
VERIFY=1

info() { printf '%s\n' "$*"; }
warn() { printf 'install: %s\n' "$*" >&2; }
die()  { warn "$*"; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

sha256_verify() {
  local file="$1"
  local expected="$2"

  if have shasum; then
    local actual
    actual="$(shasum -a 256 "$file" | awk '{print $1}')"
    [[ "$actual" == "$expected" ]]
    return
  fi

  if have sha256sum; then
    local actual
    actual="$(sha256sum "$file" | awk '{print $1}')"
    [[ "$actual" == "$expected" ]]
    return
  fi

  die "Neither 'shasum' nor 'sha256sum' found; cannot verify SHA256. Install one or use --no-verify."
}

usage() {
  cat <<EOF
Install rtunnel from GitHub Releases.

Usage:
  install.sh [--version vX.Y.Z] [--prefix PATH] [--bindir PATH] [--no-verify]

Defaults:
  --version latest
  --prefix  $HOME/.local
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      shift
      [[ $# -gt 0 ]] || die "missing value for --version"
      VERSION_TAG="$1"
      ;;
    --version=*)
      VERSION_TAG="${1#--version=}"
      ;;
    --prefix)
      shift
      [[ $# -gt 0 ]] || die "missing value for --prefix"
      PREFIX="$1"
      ;;
    --prefix=*)
      PREFIX="${1#--prefix=}"
      ;;
    --bindir)
      shift
      [[ $# -gt 0 ]] || die "missing value for --bindir"
      BINDIR="$1"
      ;;
    --bindir=*)
      BINDIR="${1#--bindir=}"
      ;;
    --no-verify)
      VERIFY=0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
  shift
done

if [[ -z "$BINDIR" ]]; then
  BINDIR="${BINDIR:-$PREFIX/bin}"
fi

mkdir -p "$BINDIR"

TMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

BASE_URL="https://github.com/${OWNER}/${REPO}/releases/${VERSION_TAG}/download"
if [[ "$VERSION_TAG" == "latest" ]]; then
  BASE_URL="https://github.com/${OWNER}/${REPO}/releases/latest/download"
fi

RTUNNEL_URL="${BASE_URL}/rtunnel"
SHA_URL="${BASE_URL}/SHA256SUMS"

info "Downloading rtunnel from: $RTUNNEL_URL"
curl -fsSL "$RTUNNEL_URL" -o "$TMP_DIR/rtunnel"

if [[ "$VERIFY" -eq 1 ]]; then
  info "Downloading checksums from: $SHA_URL"
  curl -fsSL "$SHA_URL" -o "$TMP_DIR/SHA256SUMS"

  expected="$(awk '$2=="rtunnel"{print $1}' "$TMP_DIR/SHA256SUMS")"
  [[ -n "$expected" ]] || die "Could not find checksum for 'rtunnel' in SHA256SUMS"

  info "Verifying SHA256..."
  sha256_verify "$TMP_DIR/rtunnel" "$expected" || die "SHA256 verification failed for rtunnel"
else
  warn "Skipping SHA256 verification (--no-verify)."
fi

DEST="$BINDIR/rtunnel"
install -m 0755 "$TMP_DIR/rtunnel" "$DEST"

info "Installed: $DEST"
info ""
info "Next:"
info "  rtunnel --help"
