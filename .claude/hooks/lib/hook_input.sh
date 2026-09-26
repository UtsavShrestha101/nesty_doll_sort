# shellcheck shell=bash
# Sourced by the hooks in .claude/hooks/ — not a hook itself (so not executable).
#
# Reads the hook's JSON payload from stdin exactly once and exposes small
# accessors. jq is preferred; python3 is the fallback so the hooks still work on
# a machine without jq. If neither exists every accessor returns "" and the
# hooks fail OPEN (exit 0) — the permissions deny-list in settings.json is the
# backstop for the protected paths.

HOOK_INPUT="$(cat)"

# hook_get <field>
#   file_path         .tool_input.file_path (Write / Edit / MultiEdit)
#   content           everything the tool is about to write: .content,
#                     .new_string and every .edits[].new_string, newline-joined
#   stop_hook_active  "true" when Claude is already continuing because a Stop
#                     hook blocked it (used to avoid block loops)
hook_get() {
  local field="$1"
  if command -v jq >/dev/null 2>&1; then
    case "$field" in
      file_path)
        printf '%s' "$HOOK_INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null ;;
      content)
        printf '%s' "$HOOK_INPUT" | jq -r '
          [ .tool_input.content, .tool_input.new_string,
            ((.tool_input.edits // []) | .[] | .new_string) ]
          | map(select(type == "string")) | join("\n")' 2>/dev/null ;;
      stop_hook_active)
        printf '%s' "$HOOK_INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null ;;
    esac
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$HOOK_INPUT" | python3 -c '
import json, sys
field = sys.argv[1]
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
ti = data.get("tool_input") or {}
if field == "file_path":
    print(ti.get("file_path") or "")
elif field == "content":
    parts = [ti.get("content"), ti.get("new_string")]
    parts += [e.get("new_string") for e in (ti.get("edits") or []) if isinstance(e, dict)]
    print("\n".join(p for p in parts if isinstance(p, str)))
elif field == "stop_hook_active":
    print("true" if data.get("stop_hook_active") else "false")
' "$field" 2>/dev/null
  fi
}

# nesty_root — the repository root. Claude Code exports CLAUDE_PROJECT_DIR to
# hooks; the fallback is two levels up from this file (.claude/hooks/lib/..).
nesty_root() {
  if [[ -n "${CLAUDE_PROJECT_DIR:-}" ]]; then
    printf '%s' "$CLAUDE_PROJECT_DIR"
  else
    (cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)
  fi
}

# package_dir_of <file> — nearest ancestor directory that holds a pubspec.yaml
# (a workspace member such as apps/game), or "" when there is none.
package_dir_of() {
  local dir
  dir="$(dirname "$1")"
  while [[ "$dir" != "/" && "$dir" != "." && -n "$dir" ]]; do
    if [[ -f "$dir/pubspec.yaml" ]]; then
      printf '%s' "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 0
}
