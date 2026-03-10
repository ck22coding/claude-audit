#!/usr/bin/env bash
# Runs appropriate formatter after file writes. Silently no-ops if no formatter configured.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ] && exit 0

EXT="${FILE_PATH##*.}"

run_prettier() {
  local dir
  dir=$(dirname "$FILE_PATH")
  # Only run if project has a prettier config and prettier in node_modules
  if ([ -f "$dir/../../.prettierrc" ] || [ -f ".prettierrc" ] || \
      [ -f "prettier.config.js" ] || [ -f "prettier.config.ts" ] || \
      [ -f "prettier.config.mjs" ]) && command -v npx &>/dev/null; then
    npx --no-install prettier --write "$FILE_PATH" 2>/dev/null
  fi
}

run_black() {
  command -v black &>/dev/null && black "$FILE_PATH" 2>/dev/null
}

case "$EXT" in
  js|jsx|ts|tsx|css|scss|html|json|md|yaml|yml) run_prettier ;;
  py) run_black ;;
esac

exit 0  # Always — formatter failure must never block Claude
