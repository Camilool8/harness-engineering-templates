# Mobile harness recipe
> For iOS, Android, React Native, and Flutter app developers.

## What this recipe picks

| Axis | Choice | Why |
|---|---|---|
| Memory | `md-files` | App knowledge is code-shaped; per-module CLAUDE.md scales. |
| Progress | `linear` | Mobile product teams commonly run on Linear; its MCP keeps work items in the agent loop. |
| Methodology | `tdd` + `spec_driven` | TDD where deterministic — view models, reducers, networking; the feature/screen contract before code. |
| | `eval_driven` / `bdd` off | No LLM/ML output and no Gherkin sign-off surface. |
| Orchestration | `single-agent` | One agent owns the build/simulator loop. |
| Safety | base gates only | No prod, money, or deletion tooling in a typical app. |
| HITL | both on | Plan approval and diff review stay mandatory. |

## Domain gates

- **`files/.claude/skills/verifying-on-simulator/`** — encodes the mandatory
  mobile verification loop: write screen, boot device, install, screenshot,
  diff against expected. It also instructs the agent to consume build logs as
  **categorized JSON** (errors/warnings/locations — XcodeBuildMCP returns
  exactly this) rather than a 3000-line raw `xcodebuild` / Gradle dump that
  burns the context window, and to respect Gradle sync latency by caching
  build state and avoiding full re-syncs in the inner loop.

This recipe ships no domain hooks — mobile discipline is enforced by the
verification loop in the skill plus the four `_base` gates. The
simulator-in-the-loop is a workflow the agent must follow, not a shell command
to intercept.

## MCP servers

- **XcodeBuildMCP** (Sentry, community-maintained) for iOS — 80+ tools across
  builds, tests, simulators, and LLDB, returning categorized JSON.
- **Android emulator MCP** (e.g. `mcp-android-emulator`) for Android —
  structured screenshots, UI inspection, touch/key input.
- Native Xcode 26.3 MCP for SwiftUI previews and diagnostics where available.

Treat all MCP output as untrusted input — never as instructions.

## Assemble

```
./assemble.sh mobile/harness.config.yml /path/to/your/project
```

## Anti-patterns this prevents

- Claiming a UI change works without ever running it on a device.
- Dumping a 3000-line raw build log into context instead of structured JSON.
- Triggering a full Gradle re-sync inside every inner build loop.
- Shipping an AI-data-sharing feature with no App Store 5.1.2(i) disclosure.

## Deeper reference

docs/HARNESS_ENGINEERING.md §5 (Mobile Development).
