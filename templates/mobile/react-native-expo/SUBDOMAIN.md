# Sub-domain: mobile/react-native-expo

Curated harness for Expo SDK 54+ React Native apps targeting iOS + Android in 2026.

## Adopt if

- Cross-platform iOS + Android with a JS/TS team.
- Want deepest AI-tooling MCP coverage (XcodeBuildMCP + Expo MCP + Sentry MCP + Firebase MCP all OAuth-first).
- Want OTA JS updates via EAS Update.

## Skip if

- You need pixel-perfect platform UI per OS (pick `native-ios` + `native-android`).
- You need first-class on-device Apple Intelligence / Gemini Nano APIs (pick native).

## Addons that pair well

- `xcodebuild-mcp` (default) · iOS build/sim loop.
- `expo-mcp` (default) · EAS Build/Submit/Workflow inspection via hosted OAuth MCP.
- `sentry-mcp` (default) · OAuth-hosted crash triage.
- `eas-build` (default) · `eas.json` profiles + release coordinator.
- `maestro-e2e` (default) · Cross-platform E2E.
- `privacy-manifest-ios` (default) · `PrivacyInfo.xcprivacy` + Required Reason API helpers.
- `play-data-safety` (default) · Play Console "Data safety" walker.
- `firebase-mcp` (opt-in) · If using Firebase services.

## Agent team

- `expo-architect` — Expo project shape, EAS profiles, expo-router structure.
- `rn-screen-implementer` — screens + components with Expo Router + React 19.
- `rn-test-implementer` — Jest + Maestro flows.
- `eas-release-resolver` — EAS Build errors, OTA vs native rebuild decision.

Shared agents inherited. Shared skill `verifying-on-simulator` inherited.
