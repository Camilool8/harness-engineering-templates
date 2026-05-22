## XcodeBuildMCP

The agent has access to:

- **XcodeBuildMCP** (`getsentry/XcodeBuildMCP`): build, scheme management, sim boot/install/launch, screenshot, log streaming, test execution, UI automation. Around 59 tools, headless (no Xcode UI required).
- **ios-simulator-mcp** (`joshuayoes/ios-simulator-mcp`): accessibility-tree driven UI automation (tap, swipe, type) — resolves elements by accessibility label, robust to layout changes.

### Telemetry posture
XcodeBuildMCP ships opt-out Sentry telemetry to its new maintainer. Set `XCODEBUILDMCP_SENTRY_DISABLED=true` in the MCP env block to disable.

### Credentials
Local Xcode keychain only. No remote tokens. No App Store Connect API key in the env.
