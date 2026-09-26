#!/usr/bin/env bash
# PreToolUse hook (Write|Edit|MultiEdit). Refuses two things:
#
#   1. Files that hold secrets or owner-only credentials, by path: env files,
#      signing material (keystores, key.properties, .p12/.pem/.p8, provisioning
#      profiles), anything under a secrets/ folder, service-account JSON, and
#      the Firebase app config that only `flutterfire configure` writes
#      (google-services.json, GoogleService-Info.plist; block-generated.sh
#      refuses those too).
#   2. Content that looks like a secret, in any file.
#
# Why: CLAUDE.md hard rule 5 — never commit real ad unit IDs or any secret. Real
# AdMob IDs arrive at build time through --dart-define; debug builds use
# Google's official test IDs (publisher 3940256099942544), which are allowed.
# Nesty has no env files at all (configuration is --dart-define), so every
# .env* path is refused, .env.example included.
#
# Exit 2 blocks the tool call and shows stderr to Claude. Anything else lets it run.
set -uo pipefail

# shellcheck source=lib/hook_input.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/hook_input.sh"

block_path() {
  echo "Blocked by .claude/hooks/block-secrets.sh: $1" >&2
  echo "Claude never writes credential files. Ask the user to create or change it outside Claude; the repo's .gitignore keeps it out of git." >&2
  exit 2
}

FILE="$(hook_get file_path)"
if [[ -n "$FILE" ]]; then
  BASE="$(basename "$FILE")"
  case "$BASE" in
    .env|.env.*)
      block_path "$BASE is an env file. Nesty takes configuration from --dart-define at build time (CLAUDE.md rule 5), not env files." ;;
    key.properties|*.jks|*.keystore|*.p12|*.pem|*.p8|*.mobileprovision|*.provisionprofile)
      block_path "$BASE is signing material (Android keystore / key.properties, Apple certificate, key or provisioning profile)." ;;
    google-services.json|GoogleService-Info.plist)
      block_path "$BASE is Firebase app config produced by \`flutterfire configure\`, which only the owner runs (CLAUDE.md)." ;;
    *service-account*.json|*service_account*.json|*firebase-adminsdk*.json)
      block_path "$BASE looks like a Google service-account key. Point GOOGLE_APPLICATION_CREDENTIALS at a file outside the repo instead (tools/README.md)." ;;
  esac
  case "/$FILE" in
    */secrets/*)
      block_path "$FILE is inside a secrets/ folder." ;;
  esac
fi

CONTENT="$(hook_get content)"
[[ -z "$CONTENT" ]] && exit 0

block() {
  echo "Blocked by .claude/hooks/block-secrets.sh: $1" >&2
  echo "Secrets never go in source. Use --dart-define at build time (CLAUDE.md rule 5), Remote Config for tunables, or ask the user. If this is a deliberately fake test fixture, build the string at runtime so it does not look like a real credential." >&2
  exit 2
}

# Generic credentials. Patterns are anchored on well-known prefixes so ordinary
# code does not trip them.
SECRET_RE='AKIA[0-9A-Z]{16}'                                   # AWS access key id
# The sk- keys need a left boundary, otherwise "task-<long-identifier>" matches.
SECRET_RE+='|(^|[^A-Za-z0-9])sk-ant-[A-Za-z0-9_-]{20,}'        # Anthropic API key
SECRET_RE+='|(^|[^A-Za-z0-9])sk-(proj-)?[A-Za-z0-9_-]{40,}'    # OpenAI API key
SECRET_RE+='|sk_live_[0-9A-Za-z]{20,}'                         # Stripe live key
SECRET_RE+='|gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{60,}'  # GitHub tokens
SECRET_RE+='|xox[baprs]-[A-Za-z0-9-]{10,}'                     # Slack tokens
SECRET_RE+='|AIza[0-9A-Za-z_-]{35}'                            # Google / Firebase API key
SECRET_RE+='|-----BEGIN ([A-Z]+ )?PRIVATE KEY-----'            # PEM / service-account key
SECRET_RE+='|eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'  # JWT
SECRET_RE+='|https://[0-9a-f]{32}@[a-z0-9.-]*ingest[a-z0-9.-]*sentry\.io'       # Sentry DSN

if MATCH="$(printf '%s' "$CONTENT" | grep -oE -m1 "$SECRET_RE" | head -n1)" && [[ -n "$MATCH" ]]; then
  block "secret-like string detected (starts with '${MATCH:0:8}...')."
fi

# AdMob: any app/unit ID that is not Google's public test publisher is a real ID.
ADMOB_IDS="$(printf '%s' "$CONTENT" | grep -oE 'ca-app-pub-[0-9]{16}[~/][0-9]{10}' || true)"
if [[ -n "$ADMOB_IDS" ]] && printf '%s\n' "$ADMOB_IDS" | grep -vq '^ca-app-pub-3940256099942544'; then
  block "real AdMob ID detected. Debug builds use Google's test IDs (ca-app-pub-3940256099942544/...); release IDs come from --dart-define (spec §9.1, M6/M8)."
fi

exit 0
