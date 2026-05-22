# Sub-domain: mobile/native-ios

Curated harness for Swift / SwiftUI iOS apps targeting App Store Connect in 2026.

## Adopt if

- You're shipping a Swift app to the App Store with maximum platform integration: Foundation Models, App Intents, Live Activities, Widgets.
- Your team is iOS-only or iOS-first.
- You want first-class Xcode + XcodeBuildMCP integration for AI-assisted dev.

## Skip if

- You need cross-platform Android coverage from the same codebase — pick `react-native-expo` or `flutter-app`.
- You're shipping a web app inside a shell — Capacitor lives outside this pack.

## Addons that pair well

- `xcodebuild-mcp` (default) · XcodeBuildMCP + ios-simulator-mcp for build/sim/screenshot loops.
- `sentry-mcp` (default) · Crash + release triage via OAuth-hosted MCP.
- `privacy-manifest-ios` (default) · `PrivacyInfo.xcprivacy` + Required Reason API helpers.
- `fastlane` (default) · `match` for signing, `deliver` for App Store upload, `snapshot` for screenshots.
- `maestro-e2e` (opt-in) · Cross-platform E2E if you also target other stacks.

## Agent team

- `ios-architect` — module layout, dependency tree, iOS minimum target.
- `swiftui-implementer` — SwiftUI views + `@Observable` view models.
- `swift-test-implementer` — Swift Testing suites + XCUITest flows.
- `xcode-build-resolver` — parse XcodeBuildMCP errors; fix dependency / signing / scheme drift.

Shared agents inherited: `app-store-compliance-auditor`, `mobile-release-coordinator`, `mobile-ux-screenshot-critic`.

Shared skill inherited: `verifying-on-simulator`.
