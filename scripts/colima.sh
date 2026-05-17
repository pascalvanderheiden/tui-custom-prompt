#!/usr/bin/env bash
# Print "running/total" Colima VMs, empty if colima not installed or no VMs.
set -e
command -v colima >/dev/null 2>&1 || exit 0
out="$(colima list -j 2>/dev/null || true)"
total=$(printf '%s\n' "$out" | grep -c '^{' || true)
[ "${total:-0}" -gt 0 ] || exit 0
running=$(printf '%s\n' "$out" | grep -c '"status":"Running"' || true)
echo "${running:-0}/$total"
