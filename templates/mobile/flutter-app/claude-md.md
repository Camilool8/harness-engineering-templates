## flutter-app rules

### Stack lockdown
- Flutter 3.27+ stable channel; Dart 3.x.
- Impeller renderer (the only iOS option since 2024; default on Android API 29+).
- Riverpod 2.5+ for state management in new code; BLoC retained only for regulated enterprise codebases that already standardize on it.
- Material 3 + Cupertino widget composition; use `Theme.adaptive` patterns where rules differ per platform.
- `flutter_test` + Patrol for integration tests; no `flutter_driver` in new code.

### Build loop
- iOS: drive via XcodeBuildMCP (Flutter's `ios/` is a real Xcode project).
- Android: `flutter build apk --debug` then drive with `adb`.
- Use `flutter --enable-impeller --verbose` to capture renderer traces when investigating jank.

### Cupertino / Material parity
- Do not force a single design language on both platforms unless the brand demands it. Use `Platform.isIOS` switches sparingly; prefer `CupertinoApp`+`MaterialApp` composition through `AdaptiveApp` pattern.

### Never do
- Never check in `google-services.json` or `GoogleService-Info.plist` with production keys.
- Never disable Impeller on iOS without a documented bug.
- Never claim a UI change works without simulator+emulator screenshots.
