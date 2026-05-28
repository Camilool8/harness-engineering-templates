---
name: init
description: Select a Harness Mobile sub-domain and write the .claude/HARNESS.toml marker so the matching skills and hooks activate.
---
You are initializing the Harness Mobile pack for this project.
1. Ask which sub-domain fits, presenting these options (one line each from their SUBDOMAIN.md adopt-if):
   - **flutter-app** — a Flutter 3.27+ / Dart app wanting pixel-perfect uniform UI across iOS + Android with heavy custom animation and Impeller's render-performance ceiling.
   - **native-android** — a Kotlin / Jetpack Compose app shipping to Google Play with maximum Android integration (Gemini Nano / AICore, foreground services, Health Connect, Photo Picker); Android-only or Android-first.
   - **native-ios** — a Swift / SwiftUI app shipping to the App Store with maximum platform integration (Foundation Models, App Intents, Live Activities, Widgets); iOS-only or iOS-first.
   - **react-native-expo** — a cross-platform Expo SDK 54+ React Native app for a JS/TS team, wanting the deepest AI-tooling MCP coverage and OTA JS updates via EAS Update.
2. Write (creating if absent) to ${CLAUDE_PROJECT_DIR}/.claude/HARNESS.toml, MERGING (never overwrite other tables):

   [mobile]
   subdomain = "<choice>"
3. Confirm the selection and name the skills/hooks now armed. Do not edit the project's CLAUDE.md.
