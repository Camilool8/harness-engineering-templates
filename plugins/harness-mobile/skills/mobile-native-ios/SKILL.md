---
name: mobile-native-ios
description: Conventions for a Swift / SwiftUI iOS app targeting App Store Connect. Use when .claude/HARNESS.toml selects mobile/native-ios, or when building iOS UI with Swift 6.2 Approachable Concurrency, @Observable view models, SwiftData persistence, Swift Testing + XCUITest, an XcodeBuildMCP-driven build loop, Foundation Models on-device AI, and simulator screenshot verification.
---

# native-ios rules

### Stack lockdown
- Swift 6.2 with Approachable Concurrency on (`SWIFT_DEFAULT_ACTOR_ISOLATION=MainActor`, `Approachable Concurrency = Yes`).
- SwiftUI as the primary UI framework. Use `@Observable` macros and `@State` for ownership; do not write new `@StateObject` / `@ObservedObject` code.
- SwiftData for persistence in new projects; Core Data only if the schema is >5 years old or migrations require it (justify in PR).
- Swift Testing for unit tests; XCUITest for UI tests; both can coexist in one target.
- Build SDK: Xcode 26+ (mandatory for App Store Connect after Apr 28, 2026).

### Build loop
- Drive `xcodebuild` exclusively through XcodeBuildMCP; read structured errors, never raw 3000-line logs.
- Boot the simulator with `xcrun simctl` or XcodeBuildMCP `boot_simulator`; screenshot after every UI change.

### Apple Intelligence
- Use the Foundation Models framework for on-device summarization / extraction / classification / rewriting.
- Do not call Foundation Models on devices ineligible for Apple Intelligence; ship a fallback path (hosted LLM with 5.1.2(i) consent UI, or graceful degradation).

### Never do
- Never paste an App Store Connect API key, `.p8` private key, or `MATCH_PASSWORD` into a tool call.
- Never disable Approachable Concurrency on a per-file basis without a documented reason.
- Never claim a UI change works without a simulator screenshot.
