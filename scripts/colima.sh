#!/usr/bin/env bash
# Print "running/total" Colima VMs, empty if colima not installed or no VMs.
# Cached for 30s (see gh-user.sh for the rationale).
set -e
command -v colima >/dev/null 2>&1 || exit 0

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tui-custom-prompt"
CACHE_FILE="$CACHE_DIR/colima"
TTL=30

if [ -f "$CACHE_FILE" ]; then
  mtime=$(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
  age=$(( $(date +%s) - mtime ))
  if [ "$age" -ge 0 ] && [ "$age" -lt "$TTL" ]; then
    cat "$CACHE_FILE"
    exit 0
  fi
fi

mkdir -p "$CACHE_DIR"

out="$(colima list -j 2>/dev/null || true)"
total=$(printf '%s\n' "$out" | grep -c '^{' || true)
[ "${total:-0}" -gt 0 ] || { : >"$CACHE_FILE"; exit 0; }
running=$(printf '%s\n' "$out" | grep -c '"status":"Running"' || true)
result="${running:-0}/$total"
printf '%s' "$result" >"$CACHE_FILE"
echo "$result"
