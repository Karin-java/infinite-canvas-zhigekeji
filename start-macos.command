#!/bin/sh
set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
WEB_DIR="$SCRIPT_DIR/web"

fail() {
    printf '\nERROR: %s\n' "$1"
    printf 'Press Return to close...'
    IFS= read -r _
    exit 1
}

[ -f "$WEB_DIR/package.json" ] || fail "The web project was not found next to this launcher."
cd "$WEB_DIR" || fail "The web project could not be opened."

if [ "${1:-}" = "--check" ]; then
    printf 'macOS launcher check passed.\n'
    exit 0
fi

BUN_BIN=$(command -v bun 2>/dev/null || true)
[ -n "$BUN_BIN" ] || BUN_BIN="$HOME/.bun/bin/bun"

if [ ! -x "$BUN_BIN" ]; then
    printf 'Bun is not installed. Installing it for the current user...\n'
    curl -fsSL https://bun.com/install | bash || fail "Bun installation failed. Check the network and try again."
    BUN_BIN="$HOME/.bun/bin/bun"
    [ -x "$BUN_BIN" ] || fail "Bun was installed but its executable could not be found."
fi

if [ ! -f "node_modules/vite/package.json" ]; then
    printf 'Installing project dependencies...\n'
    "$BUN_BIN" install --frozen-lockfile || fail "Project dependencies could not be installed."
fi

printf 'Starting Infinite Canvas at http://localhost:3000 ...\n'
"$BUN_BIN" run launch || fail "Infinite Canvas could not start. Port 3000 may already be in use."
