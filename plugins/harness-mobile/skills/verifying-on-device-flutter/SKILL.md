---
name: verifying-on-device-flutter
description: Flutter-specific simulator/emulator verification loop with flutter drive and screenshot capture for both platforms.
---

# Verifying a Flutter UI change on device

## Process

1. Boot simulator: `xcrun simctl boot 'iPhone 16 Pro'` (or via XcodeBuildMCP `boot_simulator`).
2. Boot emulator: `emulator -avd Pixel_8 -no-snapshot-load &`.
3. Build for both: `flutter build ios --debug --simulator` and `flutter build apk --debug`.
4. Install + run: `flutter run -d "iPhone 16 Pro"` and (in parallel terminal) `flutter run -d emulator-5554`.
5. Drive UI: either Patrol from the test suite, or `flutter drive --target=integration_test/<flow>.dart`.
6. Capture screenshots: `xcrun simctl io booted screenshot ios.png` and `adb exec-out screencap -p > android.png`.
7. Diff against baseline if `baselines/` exists; if no baseline, save the current screenshot as the new baseline (one file per platform).

## Output

- `ios.png` + `android.png` saved to `.claude/screenshots/<feature>/<timestamp>/`.
- A one-line verdict: "iOS PASS / Android PASS" or specific deltas.
