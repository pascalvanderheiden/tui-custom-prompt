#!/usr/bin/env bash
# Print Copilot CLI / AI Engineering Fluency 30-day token total, empty if N/A.
# Cached for 5 minutes (see gh-user.sh for the rationale).
set -e
command -v ai-engineering-fluency >/dev/null 2>&1 || exit 0

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tui-custom-prompt"
CACHE_FILE="$CACHE_DIR/tokens"
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

out=$(ai-engineering-fluency usage 2>/dev/null | awk '
  /Last 30 Days/    { in30 = 1; next }
  in30 && /Total tokens:/ { print $NF; exit }
')
printf '%s' "$out" >"$CACHE_FILE"
printf '%s\n' "$out"
