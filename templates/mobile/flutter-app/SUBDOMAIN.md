# Sub-domain: mobile/flutter-app

Curated harness for Flutter 3.27+ / Dart 3.x apps targeting iOS + Android in 2026.

## Adopt if

- Pixel-perfect uniform UI across iOS + Android with heavy custom animation.
- Dart expertise (or willingness to build it).
- Want Impeller's render performance ceiling.

## Skip if

- You need OTA JS updates — pick `react-native-expo`.
- You need first-class Apple Intelligence Foundation Models or Gemini Nano APIs — pick native.
- You need maximum AI-tooling MCP integration — `react-native-expo` has deeper coverage in 2026.

## Addons that pair well

- `xcodebuild-mcp` (default) · iOS build/sim loop.
- `firebase-mcp` (default) · Auth/Firestore/FCM/Crashlytics — Flutter's de-facto BaaS.
- `sentry-mcp` (default) · OAuth-hosted crash triage.
- `patrol-flutter` (default) · `integration_test` with native automation via UIAutomator/XCUITest.
- `privacy-manifest-ios` (default) · `PrivacyInfo.xcprivacy` + Required Reason API helpers.
- `play-data-safety` (default) · Play Console "Data safety" walker.
- `fastlane` (opt-in) · If shipping outside EAS.

## Agent team

- `flutter-architect` — project shape, package layout, Dart linter config.
- `flutter-screen-implementer` — Material 3 + Cupertino widget composition.
- `flutter-test-implementer` — `flutter_test` + Patrol.
- `riverpod-state-modeler` — Provider/Notifier/AsyncNotifier discipline.

Shared agents inherited. Shared skill `verifying-on-simulator` inherited.
