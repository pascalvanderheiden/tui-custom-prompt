#!/usr/bin/env bash
# Print the active GitHub account from `gh auth status`, empty if not signed in.
set -e
command -v gh >/dev/null 2>&1 || exit 0

# gh auth status prints, per host, lines of the form:
#   ✓ Logged in to github.com account <user> (...)
#   - Active account: true|false
# We pick the user whose subsequent "Active account: true" is present.
gh auth status 2>/dev/null | awk '
  /Logged in to github.com account/ { u = $7 }
  /Active account: true/            { if (u != "") { print u; exit } }
'
