#!/usr/bin/env bash
# Blocks Claude from writing to sensitive dirs without user confirmation.
# Exit 2 = block + send message to Claude.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE_PATH" ] && exit 0  # MultiEdit or no path — let through

SHARP_PATTERNS=("migrations/" "auth/" "infra/" ".env")

for pattern in "${SHARP_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "BLOCKED: '$FILE_PATH' is in a protected zone ('$pattern'). Ask the user to confirm before editing this file. Check for existing tests or migration guards first." >&2
    exit 2
  fi
done

exit 0
