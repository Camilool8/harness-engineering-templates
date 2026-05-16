## Addon — Playwright E2E

Playwright is the E2E testing layer. Tests live in `e2e/` or `tests/e2e/` and
run against a live (dev or staging) server.

**Page-object model (required):**
- Every page or significant UI region gets a Page Object class in `e2e/pages/`.
- Page Objects encapsulate locators and actions; tests call methods, not raw
  Playwright APIs. This keeps tests readable when the DOM changes — update the
  PO, not every test.

**Assert on the accessibility tree, not pixels:**
- Use `toMatchAriaSnapshot()` to assert on the semantic structure of a page.
  This catches heading changes, missing labels, and structure regressions without
  screenshot brittleness.
- Use `expect(locator).toHaveText()`, `.toBeVisible()`, `.toBeEnabled()`, and
  `.toHaveRole()` for element-level assertions.
- Use `expect(page).toHaveURL()` for navigation assertions.
- Do **not** use `toHaveScreenshot()` as the primary assertion — screenshots are
  flaky across CI environments and do not capture accessibility. Use them only
  to record a confirmed visual bug.

**Test isolation:**
- Each test must be fully independent. No shared state between tests; use
  `test.beforeEach` to set up fresh fixtures.
- Use the Playwright `storageState` fixture for authenticated tests — sign in
  once per worker, not per test.
