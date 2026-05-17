#!/usr/bin/env bash
# Print spec-kit status (tasks done/total, plan, spec, or active) for the
# nearest enclosing spec-kit project, else nothing.
set -e
d="$PWD"
root=""
while [ -n "$d" ] && [ "$d" != "/" ]; do
  if [ -d "$d/.specify" ]; then
    root="$d"
    break
  fi
  if compgen -G "$d/specs/*/spec.md" >/dev/null 2>&1 \
     || compgen -G "$d/specs/*/plan.md" >/dev/null 2>&1 \
     || compgen -G "$d/specs/*/tasks.md" >/dev/null 2>&1; then
    root="$d"
    break
  fi
  d="$(dirname "$d")"
done
[ -z "$root" ] && exit 0

latest="$(ls -td "$root"/specs/*/ 2>/dev/null | head -1 || true)"
if [ -n "$latest" ] && [ -f "$latest/tasks.md" ]; then
  total=$(grep -cE '^[[:space:]]*- \[[ xX]\]' "$latest/tasks.md" 2>/dev/null || echo 0)
  done_n=$(grep -cE '^[[:space:]]*- \[[xX]\]'  "$latest/tasks.md" 2>/dev/null || echo 0)
  if [ "${total:-0}" -gt 0 ]; then
    echo "$done_n/$total"
    exit 0
  fi
fi
if [ -n "$latest" ] && [ -f "$latest/plan.md" ]; then echo "plan"; exit 0; fi
if [ -n "$latest" ] && [ -f "$latest/spec.md" ]; then echo "spec"; exit 0; fi

echo "active"
