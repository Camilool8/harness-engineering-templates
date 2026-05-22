#!/usr/bin/env bash
# block-static-store-creds.sh — PreToolUse hook on Bash.
# Refuses to proceed if static store/build credentials are present in env
# when an OAuth alternative exists. Codifies the post-ShinyHunters (April
# 2026) credential-posture default for the mobile domain: agent hosts do
# not hold long-lived App Store Connect / Play / Expo / Sentry tokens.
#
# Exit 2 = block (reason on stderr). Exit 0 = allow.
set -uo pipefail

event="$(cat)"
tool="$(printf '%s' "$event" | jq -r '.tool_name // empty' 2>/dev/null)"
[ "$tool" = "Bash" ] || exit 0

cmd="$(printf '%s' "$event" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# Only police mobile build/distribution CLIs. Other Bash is fine.
printf '%s' "$cmd" | grep -Eq '\b(xcodebuild|fastlane|eas|expo|gradle|gradlew|adb|flutter|pod)\b' || exit 0

issues=()
[ -n "${APP_STORE_CONNECT_API_KEY_BASE64:-}" ]         && issues+=("APP_STORE_CONNECT_API_KEY_BASE64 set — use App Store Connect API short-lived JWT via fastlane spaceship.")
[ -n "${ASC_API_KEY_ID:-}${ASC_API_KEY_ISSUER_ID:-}" ] && issues+=("ASC_API_KEY_* set — store .p8 outside repo; use fastlane app_store_connect_api_key with key_filepath, not env paste.")
[ -n "${GOOGLE_PLAY_SERVICE_ACCOUNT_JSON:-}" ]         && issues+=("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON set — use GCP Workload Identity Federation to fastlane supply.")
[ -n "${EXPO_TOKEN:-}" ]                               && issues+=("EXPO_TOKEN set — use Expo MCP OAuth (mcp.expo.dev) instead.")
[ -n "${SENTRY_AUTH_TOKEN:-}" ]                        && issues+=("SENTRY_AUTH_TOKEN set — use Sentry MCP OAuth (mcp.sentry.dev) instead.")
[ -n "${FIREBASE_TOKEN:-}" ]                           && issues+=("FIREBASE_TOKEN set — use Firebase CLI interactive OAuth or ADC instead.")
[ -n "${FASTLANE_PASSWORD:-}" ]                        && issues+=("FASTLANE_PASSWORD set — use App Store Connect API key, not Apple ID password.")
[ -n "${MATCH_PASSWORD:-}" ]                           && issues+=("MATCH_PASSWORD set inline — store in Keychain or use match storage_mode=git_basic_authorization with PAT scoped to one repo.")

if [ "${#issues[@]}" -gt 0 ]; then
  echo "BLOCKED: static store/build credentials present in env (post-ShinyHunters 2026 posture)." >&2
  for i in "${issues[@]}"; do echo "  - $i" >&2; done
  echo "Remove the static cred from env; use the OAuth / Managed-MCP path." >&2
  exit 2
fi

exit 0
