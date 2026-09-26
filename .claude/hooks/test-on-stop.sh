#!/usr/bin/env bash
# Stop hook. Keeps nesty_core green before Claude hands control back.
#
# Why only nesty_core: CLAUDE.md says its tests "must always pass", every game
# rule lives there (rule 2), and it is pure Dart, so `dart test` takes seconds.
# Flutter test suites (nesty_render, apps/*) are too slow for a Stop hook — they
# run in CI (.github/workflows/ci.yaml) and at every milestone close-out.
#
# Change detection uses mtimes against a stamp in .dart_tool/ (gitignored), so
# it needs no git repository and ignores edits outside nesty_core. Directory
# mtimes are included because deleting or renaming a file only touches its
# parent directory.
#
#   dependencies not resolved yet        -> exit 0 (run `flutter pub get` first)
#   core unchanged since last green run  -> exit 0, nothing runs
#   tests pass                           -> refresh stamp, exit 0
#   tests fail, first stop               -> exit 2: Claude is told to keep working
#   tests fail, stop_hook_active == true -> exit 1: warn the user, never loop
#
# Escape hatch: NESTY_SKIP_STOP_TESTS=1 skips the hook entirely.
set -uo pipefail

# shellcheck source=lib/hook_input.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/hook_input.sh"

[[ "${NESTY_SKIP_STOP_TESTS:-0}" == "1" ]] && exit 0
command -v dart >/dev/null 2>&1 || exit 0

ROOT="$(nesty_root)"
CORE="$ROOT/packages/nesty_core"
[[ -d "$CORE/test" ]] || exit 0
# A fresh clone before `flutter pub get`: `dart test` would fail for a reason
# that has nothing to do with the code, so don't block Claude on it.
[[ -f "$ROOT/.dart_tool/package_config.json" ]] || exit 0

STATE_DIR="$ROOT/.dart_tool/claude-hooks"
STAMP="$STATE_DIR/nesty_core-tests.stamp"
mkdir -p "$STATE_DIR" 2>/dev/null || exit 0

if [[ -f "$STAMP" ]]; then
  CHANGED="$(find "$CORE/lib" "$CORE/test" "$CORE/pubspec.yaml" "$CORE/analysis_options.yaml" \
    -newer "$STAMP" \( -type d -o \( -type f \( -name '*.dart' -o -name '*.json' -o -name '*.yaml' \) \) \) \
    -print 2>/dev/null | head -n 1)"
  [[ -z "$CHANGED" ]] && exit 0
fi

# Mark the start of the run, so edits made while the tests run are still seen as
# "changed" next time.
RUN_MARK="$STATE_DIR/nesty_core-tests.running"
touch "$RUN_MARK"

OUT="$(cd "$CORE" && dart test --reporter failures-only 2>&1)"
CODE=$?

# 79 = "no tests found" (an empty test/ dir) — nothing is failing.
if [[ $CODE -eq 0 || $CODE -eq 79 ]]; then
  mv -f "$RUN_MARK" "$STAMP"
  exit 0
fi
rm -f "$RUN_MARK"

{
  echo "nesty_core tests are failing (cd packages/nesty_core && dart test, exit $CODE)."
  echo "CLAUDE.md: core rules/solver tests must always pass. Last lines of output:"
  printf '%s\n' "$OUT" | tail -n 40
} >&2

if [[ "$(hook_get stop_hook_active)" == "true" ]]; then
  exit 1
fi
exit 2
