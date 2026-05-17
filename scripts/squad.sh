#!/usr/bin/env bash
# Print "squad" if a .squad marker exists at or above $PWD, else nothing.
set -e
d="$PWD"
while [ -n "$d" ] && [ "$d" != "/" ]; do
  if [ -e "$d/.squad" ]; then
    echo "squad"
    exit 0
  fi
  d="$(dirname "$d")"
done
