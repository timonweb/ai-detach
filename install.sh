#!/usr/bin/env bash
set -euo pipefail

REPO="timonweb/ai-detach"
INSTALL_DIR="${AI_DETACH_INSTALL_DIR:-/usr/local/bin}"
BIN_NAME="ai-detach"
RAW_URL="https://raw.githubusercontent.com/${REPO}/main/${BIN_NAME}"

# Colors
if [ -t 1 ]; then
    GREEN='\033[0;32m' RED='\033[0;31m' BOLD='\033[1m' RESET='\033[0m'
else
    GREEN='' RED='' BOLD='' RESET=''
fi

info()    { printf "${BOLD}=>${RESET} %s\n" "$*"; }
success() { printf "${GREEN}=>${RESET} %s\n" "$*"; }
die()     { printf "${RED}error:${RESET} %s\n" "$*" >&2; exit 1; }

# Check for curl or wget
if command -v curl >/dev/null 2>&1; then
    fetch() { curl -fsSL "$1"; }
elif command -v wget >/dev/null 2>&1; then
    fetch() { wget -qO- "$1"; }
else
    die "curl or wget is required"
fi

info "Downloading ${BIN_NAME}..."
tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT
fetch "$RAW_URL" > "$tmpfile"

# Verify we got a script, not a 404 page
head -1 "$tmpfile" | grep -q '^#!/' || die "Download failed — got unexpected content"

chmod +x "$tmpfile"

# Install
if [ -w "$INSTALL_DIR" ]; then
    mv "$tmpfile" "${INSTALL_DIR}/${BIN_NAME}"
else
    info "Writing to ${INSTALL_DIR} requires sudo"
    sudo mv "$tmpfile" "${INSTALL_DIR}/${BIN_NAME}"
fi

success "Installed ${BIN_NAME} to ${INSTALL_DIR}/${BIN_NAME}"
printf "  Run ${BOLD}ai-detach --help${RESET} to get started\n"
