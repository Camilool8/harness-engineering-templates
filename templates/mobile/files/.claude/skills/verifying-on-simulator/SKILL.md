---
name: verifying-on-simulator
description: Verifies a mobile UI change by running it on a simulator/emulator. Use after editing any screen, view, or layout — boot a device, install the build, screenshot, and diff against the expected result. Consume build logs as structured JSON, not raw text.
---

# Verifying on a simulator

A mobile UI change is not verified until it has run on a device. The
simulator/emulator-in-the-loop pattern is the mobile analog of the web's
headless-browser screenshot loop, and it is mandatory.

## The loop

Run this after every screen- or layout-affecting edit:

1. **Write the screen.** Make the code change.
2. **Boot the device.** Start the target simulator (iOS) or emulator (Android)
   if it is not already running. Keep one warm for the session.
3. **Install the build.** Build and install onto the booted device.
4. **Screenshot.** Capture the running screen.
5. **Diff against expected.** Compare to the intended layout / a baseline.
   A mismatch is a failure to fix, not a note to file.

## Build logs are structured data, not a wall of text

- Consume build output as **categorized JSON** — errors, warnings, and their
  file/line locations — not a 3000-line raw `xcodebuild` / Gradle dump. On iOS,
  XcodeBuildMCP returns exactly this categorized form; use it.
- A raw log dump burns the context window and buries the one error that
  matters. Always prefer the structured surface.

## Android: respect Gradle sync latency

- Gradle sync is the latency villain — 10–30 seconds per full sync. **Cache
  build state** and avoid triggering a full re-sync inside the inner
  edit-build-screenshot loop. Incremental builds only, unless dependencies or
  the build config actually changed.

## Rules

- Never mark a UI task complete without naming the device you ran it on and the
  screenshot/diff result you observed.
- A build error or a visual diff blocks "done" — treat it like a failing test.
