---
name: mobile-addon-xcodebuild-mcp
description: XcodeBuildMCP + ios-simulator-mcp for headless iOS/macOS/tvOS/watchOS/visionOS build, scheme management, simulator boot/install/launch, screenshot, log streaming, test execution, and accessibility-tree UI automation. Use when wiring or driving these MCPs for an iOS build/sim loop, with XCODEBUILDMCP_SENTRY_DISABLED set and local-keychain-only credentials.
---

## XcodeBuildMCP

The agent has access to:

- **XcodeBuildMCP** (`getsentry/XcodeBuildMCP`): build, scheme management, sim boot/install/launch, screenshot, log streaming, test execution, UI automation. Around 59 tools, headless (no Xcode UI required).
- **ios-simulator-mcp** (`joshuayoes/ios-simulator-mcp`): accessibility-tree driven UI automation (tap, swipe, type) — resolves elements by accessibility label, robust to layout changes.

### Telemetry posture
XcodeBuildMCP ships opt-out Sentry telemetry to its new maintainer. Set `XCODEBUILDMCP_SENTRY_DISABLED=true` in the MCP env block to disable.

### Credentials
Local Xcode keychain only. No remote tokens. No App Store Connect API key in the env.
