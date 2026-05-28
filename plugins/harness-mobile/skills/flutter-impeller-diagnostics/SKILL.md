---
name: flutter-impeller-diagnostics
description: Read Impeller renderer traces; identify shader stutters; decide when to fall back to Skia (Android only).
---

# Impeller diagnostics

## Inputs

- Output of `flutter run --enable-impeller --verbose`.
- A jank report (`Jank` lines in the log) or DevTools timeline.

## Process

1. Look for `Impeller` lines in the verbose log; Impeller is the iOS-only renderer (cannot be disabled there since 2024).
2. On Android: Impeller is default on API 29+. If you see shader-compilation stutters in the first frames, that's the classic Impeller-Android pattern.
3. Capture the shader hot path with DevTools' performance timeline.
4. Mitigations:
   - Add `@pragma('vm:prefer-inline')` to hot paths; precompile shaders with `flutter run --cache-sksl` (Skia only — for Android-Skia fallback) or `--impeller-precompile-shaders`.
   - Reduce shader variants: avoid runtime gradient math; bake into constants.
5. Android fallback to Skia (`--no-enable-impeller`) is allowed *only* for an emergency: document the bug ID and link the Flutter issue.

## Output

The renderer choice, the shader hot path, the mitigation applied, and a regression test if applicable.
