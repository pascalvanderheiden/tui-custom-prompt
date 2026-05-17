#!/usr/bin/env bash
# Print Copilot CLI / AI Engineering Fluency 30-day token total, empty if N/A.
set -e
command -v ai-engineering-fluency >/dev/null 2>&1 || exit 0
ai-engineering-fluency usage 2>/dev/null | awk '
  /Last 30 Days/    { in30 = 1; next }
  in30 && /Total tokens:/ { print $NF; exit }
'
