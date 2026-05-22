# Mobile domain pack

Curated harness content for mobile teams: native iOS, native Android,
React Native + Expo, and Flutter.

> **Status: curated three-layer pack** (fourth after `web/`, `devops/`, `data/`).
> Specialised via per-MCP, per-tester, per-build/distribution, and per-compliance
> addons.

## Sub-domain decision guide

Pick by team composition and platform targets, not by framework popularity.

| Sub-domain | Adopt if… |
|---|---|
| [`native-ios`](native-ios/) | Swift/SwiftUI app to the App Store with maximum platform integration (Foundation Models, App Intents); iOS-only or iOS-first team. |
| [`native-android`](native-android/) | Kotlin/Compose app to Google Play with maximum Android integration (Gemini Nano / AICore, foreground services); Android-only or Android-first team. |
| [`react-native-expo`](react-native-expo/) | Cross-platform to iOS + Android with a JS/TS team; deepest AI-tooling MCP coverage; OTA JS updates via EAS Update. |
| [`flutter-app`](flutter-app/) | Pixel-perfect uniform cross-platform UI with heavy custom animation; Dart team or willingness to build one. |

Each sub-domain ships a `SUBDOMAIN.md` with deeper adopt-if / skip-if guidance and the curated agent team.

## Addons

Composable extras declared in `domain.addons`. Each sub-domain config ships sensible defaults; override as needed.

| Addon | Pairs with | Purpose |
|---|---|---|
| `xcodebuild-mcp` | `native-ios`, `react-native-expo`, `flutter-app` | `getsentry/XcodeBuildMCP` + `ios-simulator-mcp`; build, sim, screenshot, log, test. |
| `expo-mcp` | `react-native-expo` | `mcp.expo.dev` hosted OAuth MCP; EAS Build/Submit/Workflow inspection. |
| `firebase-mcp` | `native-android`, `flutter-app`, `react-native-expo` | `firebase-tools mcp`; Auth, Firestore, FCM, Crashlytics (Experimental), Remote Config. |
| `sentry-mcp` | all four | `mcp.sentry.dev` hosted OAuth MCP; issues, breadcrumbs, releases, replays. |
| `maestro-e2e` | `react-native-expo`, `native-ios`, `native-android` | Maestro CLI + flow author skill; cross-platform E2E. |
| `patrol-flutter` | `flutter-app` | LeanCode Patrol; Flutter `integration_test` with native automation. |
| `eas-build` | `react-native-expo` | EAS Build/Submit/Update profiles + release coordinator agent. |
| `fastlane` | `native-ios`, `native-android`, `flutter-app` | Fastfile / Appfile / Matchfile templates; lane author skill. |
| `privacy-manifest-ios` | `native-ios`, `react-native-expo`, `flutter-app` | `PrivacyInfo.xcprivacy` + Required Reason API helpers. |
| `play-data-safety` | `native-android`, `react-native-expo`, `flutter-app` | Google Play "Data safety" form walker agent. |

Each addon ships a `MODULE.md` with adopt-if / skip-if guidance. Browse [`_addons/`](_addons/).

## What we deliberately do not curate (yet)

- **Kotlin Multiplatform / Compose Multiplatform** — reshapes project structure too deeply for v1; reachable from `native-android` + `native-ios` with manual setup. Graduation target.
- **Bitrise MCP** — PAT-only as of May 2026 (post-Anodot posture gap). EAS / Fastlane / GitHub Actions cover the same need with OAuth-first MCPs.
- **MobSF MCP, AppSweep, DexGuard, Detekt, SwiftLint** — invoked via Bash; no OAuth MCP path yet.
- **App Store Connect / Play Console first-party MCP** — no first-party server exists; reach via EAS Submit, fastlane `deliver` / `supply`.
- **Wearables, TV, CarPlay, VisionOS** — out of scope; pick `native-ios` or `native-android` and document the secondary target in `references.md`.

## Assemble

The sub-domain config is the assemble unit. Pass it directly to `assemble.sh`:

```bash
./assemble.sh mobile/native-ios/harness.config.yml ./my-ios-app
./assemble.sh mobile/native-android/harness.config.yml ./my-android-app
./assemble.sh mobile/react-native-expo/harness.config.yml ./my-rn-app
./assemble.sh mobile/flutter-app/harness.config.yml ./my-flutter-app
```

## See also

- [`docs/how-to/pick-a-recipe.md`](../../docs/how-to/pick-a-recipe.md) — decision flow including the mobile sub-domain choice.
- [`docs/reference/domains.md`](../../docs/reference/domains.md) — full domain and addon catalog.
- [`docs/HARNESS_ENGINEERING.md`](../../docs/HARNESS_ENGINEERING.md) §2 — engineering guide for the mobile domain.
- [`references.md`](references.md) — curated mobile-platform dossier (refresh quarterly).
