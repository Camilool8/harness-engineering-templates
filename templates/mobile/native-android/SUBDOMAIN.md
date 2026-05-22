# Sub-domain: mobile/native-android

Curated harness for Kotlin / Jetpack Compose Android apps targeting Google Play in 2026.

## Adopt if

- You're shipping a Kotlin app to Google Play with maximum Android integration: Gemini Nano / AICore, foreground services, Health Connect, Photo Picker.
- Your team is Android-only or Android-first.
- You want first-class Gradle + Android Studio Otter+ Gemini Agent Mode integration.

## Skip if

- You need cross-platform iOS coverage from the same codebase — pick `react-native-expo` or `flutter-app`.

## Addons that pair well

- `firebase-mcp` (default) · Auth, Firestore, FCM, Crashlytics (Experimental), Remote Config.
- `sentry-mcp` (default) · Crash + release triage via OAuth-hosted MCP.
- `fastlane` (default) · `supply` for Play upload, `screengrab` for screenshots.
- `play-data-safety` (default) · Walks the Play Console "Data safety" form.
- `maestro-e2e` (opt-in) · Cross-platform E2E.

## Agent team

- `android-architect` — module layout, Gradle config (KSP + Compose compiler), target/min SDK, Hilt graph.
- `compose-implementer` — Compose UI with Strong Skipping in mind.
- `android-test-implementer` — Compose UI Test + Espresso + Roborazzi snapshots.
- `gradle-build-resolver` — parse `gradle --console=plain` output, fix dependency conflicts.

Shared agents inherited: `app-store-compliance-auditor`, `mobile-release-coordinator`, `mobile-ux-screenshot-critic`.

Shared skill inherited: `verifying-on-simulator` (interpreted as "emulator" for Android).
