# Module: web/addon/playwright-e2e

> Config: `domain.addons` · Depends on: none (pairs with `frontend-app`, `fullstack-app`, `design-system`)

**What it does.** Installs the `writing-playwright-e2e` skill that teaches the
agent to write Playwright E2E tests using the page-object model, assert on the
accessibility tree rather than pixels, and integrate with `toMatchAriaSnapshot`
for structural regression detection.

## Adopt if
- You need E2E coverage for user flows spanning multiple pages or requiring a
  real browser (auth redirects, file uploads, complex JS interactions).
- You want to catch regressions in accessibility tree structure alongside
  functional behavior.
- Your app's critical paths (checkout, onboarding, login) must be verified
  end-to-end before release.

## Skip if
- Your test strategy stops at component/unit tests — Playwright adds infrastructure
  overhead; add it when E2E value is clear.
- Your app is a pure API service with no browser-facing UI.

## Dependencies
- `@playwright/test` (`npm init playwright@latest` to scaffold config and install browsers).
- A running dev or staging server (Playwright can start it via `webServer` config).

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.

## Install (assemble.sh)
Add `playwright-e2e` to `domain.addons` in `harness.config.yml` and run
`./assemble.sh`.

## Remove
- Delete `.claude/skills/writing-playwright-e2e/`.
- Remove the `## Addon — Playwright E2E` section from `CLAUDE.md`.

## Files
- `files/.claude/skills/writing-playwright-e2e/SKILL.md` — page-object pattern,
  a11y-tree assertions, `toMatchAriaSnapshot` usage, test isolation rules, and
  the no-pixel-assertion convention.
