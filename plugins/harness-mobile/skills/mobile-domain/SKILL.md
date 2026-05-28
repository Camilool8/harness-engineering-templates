---
name: mobile-domain
description: Shared rules for any mobile engineering work — single-stack lockdown, simulator/emulator-in-the-loop verification (a UI change is not done until it has run on a device), structured build-log consumption, App Store 5.1.2(i) + Play AI-content compliance gates, an OAuth-first credential posture, and live docs via Context7. Auto-loads for any iOS, Android, React Native, or Flutter task.
---

# Mobile rules

### Stack lockdown
- Pick one sub-domain (native-ios, native-android, react-native-expo, flutter-app) and hold to it. Do not mix paradigms (e.g. SwiftUI screens with UIKit view-controller patterns) unless the screen genuinely requires it.

### Verification (simulator/emulator-in-the-loop)
- After any screen change, run the `verifying-on-simulator` skill: boot device, install, screenshot, diff. A UI change is not verified until it has run on a device.
- TDD applies to deterministic code — view models, reducers, networking, formatting. UI verification is the simulator/emulator loop, not a unit test.

### Build logs
- Consume build logs as structured/categorized output, never a 3000-line raw log. iOS: XcodeBuildMCP parses `xcodebuild` to JSON. Android: parse `gradle --console=plain` or use Gemini Agent Mode's structured Logcat readback.

### Store compliance
- Apple Guideline 5.1.2(i) (Nov 13, 2025) requires explicit user consent before personal data is sent to any third-party AI. A privacy-policy link is not enough — implement a pre-action consent UI.
- Google Play AI-Generated Content policy requires in-app reporting/flagging of generative output and labeling of AI-generated content.

### Credentials posture
- Prefer OAuth MCPs (Expo, Firebase, Sentry, GitHub) over PAT/API-key MCPs (Bitrise, MobSF). After the April 2026 Anodot/ShinyHunters breach, long-lived broker-held tokens are the new weakest link.

### Never do
- Never claim a UI change works without running it on a simulator/emulator.
- Never ship an AI-data-sharing feature without the 5.1.2(i) consent UI.
- Never paste App Store Connect API keys, Play service account JSON, EXPO_TOKEN, SENTRY_AUTH_TOKEN, or FIREBASE_TOKEN inline.
