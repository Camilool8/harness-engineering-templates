## Mobile rules

<!-- Fill the stack lockdown for YOUR platform: native Swift/SwiftUI,
     Kotlin/Compose, React Native + Expo, or Flutter. -->

### Stack lockdown

- State the platform, language, minimum OS version, and UI framework here, and
  hold to them — do not mix paradigms (e.g. SwiftUI views with UIKit
  view-controller patterns) unless the screen genuinely requires it.

### Verification

- **Simulator/emulator-in-the-loop is mandatory.** After any screen change,
  run the `verifying-on-simulator` skill: boot device, install, screenshot,
  diff. A UI change is not verified until it has run on a device.
- TDD applies to deterministic code — view models, reducers, networking,
  formatting. UI verification is the simulator loop, not a unit test.
- Consume build logs as structured/categorized JSON (XcodeBuildMCP on iOS),
  never a 3000-line raw log.

### Android

- Gradle sync is slow (10–30s). Cache build state; avoid full re-syncs inside
  the inner edit-build loop.

### App Store compliance

- Apple Guideline **5.1.2(i)** requires the app to explicitly disclose when
  personal data is shared with a third-party AI, and to name the AI provider.
  Any feature sending user data to an AI service must surface that disclosure.

### Never do

- Never claim a UI change works without running it on a simulator/emulator.
- Never ship an AI-data-sharing feature without the 5.1.2(i) disclosure.
