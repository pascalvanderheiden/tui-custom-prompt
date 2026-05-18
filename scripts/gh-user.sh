#!/usr/bin/env bash
# Print the active GitHub account from `gh auth status`, empty if not signed in.
# Cached for 5 minutes in ~/.cache/tui-custom-prompt to avoid running gh on every prompt.
# (oh-my-posh's built-in `cache` for `command` segments shares one key across all
# command segments, so we cache ourselves instead.)
set -e
command -v gh >/dev/null 2>&1 || exit 0

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tui-custom-prompt"
CACHE_FILE="$CACHE_DIR/gh-user"
TTL=300

if [ -f "$CACHE_FILE" ]; then
  mtime=$(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
  age=$(( $(date +%s) - mtime ))
  if [ "$age" -ge 0 ] && [ "$age" -lt "$TTL" ]; then
    cat "$CACHE_FILE"
    exit 0
  fi
fi

mkdir -p "$CACHE_DIR"

# gh auth status prints, per host, lines of the form:
#   ✓ Logged in to github.com account <user> (...)
#   - Active account: true|false
# We pick the user whose subsequent "Active account: true" is present.
out=$(gh auth status 2>/dev/null | awk '
  /Logged in to github.com account/ { u = $7 }
  /Active account: true/            { if (u != "") { print u; exit } }
')
printf '%s' "$out" >"$CACHE_FILE"
printf '%s\n' "$out"
