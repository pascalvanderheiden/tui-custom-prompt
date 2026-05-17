#!/usr/bin/env bash
# Print openspec status if an openspec/.openspec dir exists at or above $PWD.
set -e
d="$PWD"
root=""
while [ -n "$d" ] && [ "$d" != "/" ]; do
  if [ -e "$d/openspec" ] || [ -e "$d/.openspec" ]; then
    root="$d"
    break
  fi
  d="$(dirname "$d")"
done
[ -z "$root" ] && exit 0

if command -v openspec >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  out="$(cd "$root" && openspec list --json 2>/dev/null || true)"
  summary="$(printf '%s' "$out" | jq -r '
    def pct($d; $t):
      if ($t // 0) <= 0 then "0%"
      else (((($d // 0) * 100 / $t) | floor | tostring) + "%")
      end;
    def short:
      tostring | if length > 16 then .[0:13] + "..." else . end;
    (.changes // [])
    | map(select((.status // "") != "archived"))
    | if length == 0 then "0 changes"
      else (.[:3] | map((.name // .id // "change" | short) + " " + pct(.completedTasks; .totalTasks)) | join(", "))
           + (if length > 3 then " +" + ((length - 3) | tostring) else "" end)
      end
  ' 2>/dev/null || true)"
  if [ -n "$summary" ]; then
    echo "$summary"
    exit 0
  fi
fi

echo "enabled"
