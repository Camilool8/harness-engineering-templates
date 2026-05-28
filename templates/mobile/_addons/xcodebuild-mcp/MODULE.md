# Module: mobile/addon/xcodebuild-mcp

> Config: `domain.addons` · Depends on: macOS host with Xcode 26+ installed; Node + npm.

**What it does.** Wires `getsentry/XcodeBuildMCP` and `ios-simulator-mcp` into `.mcp.json` so the agent can build, boot simulator, install, launch, screenshot, log, and run tests on iOS / macOS / tvOS / watchOS / visionOS targets. Contributes the `xcode-simulator-driver` agent.

## Adopt if
- iOS work is in scope (native-ios, react-native-expo iOS targets, flutter-app iOS targets).

## Skip if
- Project targets Android-only.

## Dependencies
- macOS with Xcode 26+ installed.
- `npx` on PATH.

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.
2. Add the `XcodeBuildMCP` + `ios-simulator-mcp` blocks to `.mcp.json`.
3. Copy `xcode-simulator-driver.md` into `.claude/agents/`.

## Install (assemble.sh)
Add `xcodebuild-mcp` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove the `## XcodeBuildMCP` section from `CLAUDE.md`.
- Remove the `XcodeBuildMCP` + `ios-simulator-mcp` entries from `.mcp.json`.
- Delete `.claude/agents/xcode-simulator-driver.md`.

## Files
- `MODULE.md`
- `claude-md.md`
- `files/.mcp.json.fragment`
- `files/.claude/agents/xcode-simulator-driver.md`
