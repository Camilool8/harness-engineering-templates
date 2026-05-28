---
name: patrol-flow-author
description: Author Patrol integration tests for Flutter — UI + native automation interleaved.
---

# Authoring a Patrol integration test

## Pattern

```dart
import 'package:patrol/patrol.dart';
import 'package:my_app/main.dart' as app;

void main() {
  patrolTest(
    'user signs in and allows notifications',
    ($) async {
      app.main();
      await $.pumpAndSettle();

      await $(#emailField).enterText('user@example.com');
      await $(#passwordField).enterText('correct-horse-battery-staple');
      await $(#continueButton).tap();

      // Native permission dialog
      await $.native.grantPermissionWhenInUse();

      expect($('Welcome back'), findsOneWidget);
    },
  );
}
```

## Constraints
- Use `$` (PatrolTester) finder API, not raw `find.byKey()`.
- Use `Key('emailField')` and reference as `$(#emailField)` for hardiness.
- Always `pumpAndSettle()` after navigation.

Reference: <https://patrol.leancode.co/>.
