---
name: mobile-addon-patrol-flutter
description: Patrol E2E conventions for Flutter — extends integration_test with native automation (UIAutomator + XCUITest) to tap permission dialogs, toggle system settings, handle notifications, and follow deep links. Use when authoring or running Patrol integration journeys for a Flutter app, using patrolTest over testWidgets for native-automation flows.
---

## Patrol (Flutter E2E)

Patrol extends Flutter's `integration_test` with native automation via UIAutomator (Android) + XCUITest (iOS):

- Tap native permission dialogs (`grantNotificationPermission`, `grantLocationPermission`).
- Toggle Settings (Wi-Fi, Bluetooth, Airplane Mode).
- Pull down notifications and tap them.
- Interact with other apps (deep links from email, share extensions).

### Running
- `patrol test --target integration_test/login_test.dart`.
- `patrol develop` for incremental dev loop.

### Conventions
- One file per integration journey under `integration_test/`.
- Use `patrolTest` (not `testWidgets`) for any flow needing native automation.
- Pump UI with `await $.pumpAndSettle()` consistently.
