#!/usr/bin/env bash
# PostToolUse hook (Write|Edit|MultiEdit). Runs `dart format` on the Dart file that
# was just written, from inside its workspace member so the member's
# analysis_options.yaml (formatter page width) and language version apply.
#
# A formatter failure almost always means the file no longer parses, so it is
# reported back to Claude (exit 2 on PostToolUse shows stderr; the write already
# happened). A missing `dart` binary is not an error — the hook just skips.
set -uo pipefail

# shellcheck source=lib/hook_input.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/hook_input.sh"

FILE="$(hook_get file_path)"
[[ "$FILE" == *.dart ]] || exit 0
[[ -f "$FILE" ]] || exit 0
command -v dart >/dev/null 2>&1 || exit 0

PKG="$(package_dir_of "$FILE")"
[[ -z "$PKG" ]] && PKG="$(nesty_root)"

if ! OUT="$(cd "$PKG" && dart format "$FILE" 2>&1)"; then
  echo "dart format failed for $FILE — the file probably does not parse:" >&2
  printf '%s\n' "$OUT" | head -n 20 >&2
  exit 2
fi
exit 0
