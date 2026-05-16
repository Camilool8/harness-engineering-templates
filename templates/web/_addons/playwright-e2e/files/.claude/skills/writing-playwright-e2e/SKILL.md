---
name: writing-playwright-e2e
description: Writes Playwright E2E tests using the page-object pattern and accessibility-tree assertions. Use whenever creating or editing E2E test files in a Playwright project.
---

# Writing Playwright E2E Tests

Playwright enables cross-browser end-to-end testing with built-in auto-wait,
web-first assertions, and the accessibility tree as a first-class assertion target.

## Project setup

```bash
npm init playwright@latest
# Choose: TypeScript, tests/ folder, add GitHub Actions workflow
```

`playwright.config.ts` — annotate the dev server so tests start it automatically:

```ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox',  use: { ...devices['Desktop Firefox'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
})
```

## Page-object model

Create one Page Object (PO) class per page or major region. POs encapsulate
locators and actions — tests call methods, not raw Playwright APIs.

```ts
// e2e/pages/LoginPage.ts
import type { Page, Locator } from '@playwright/test'

export class LoginPage {
  readonly page: Page
  readonly emailInput: Locator
  readonly passwordInput: Locator
  readonly submitButton: Locator

  constructor(page: Page) {
    this.page = page
    this.emailInput    = page.getByLabel('Email')
    this.passwordInput = page.getByLabel('Password')
    this.submitButton  = page.getByRole('button', { name: 'Sign in' })
  }

  async goto() {
    await this.page.goto('/login')
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email)
    await this.passwordInput.fill(password)
    await this.submitButton.click()
  }
}
```

```ts
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test'
import { LoginPage } from './pages/LoginPage'

test('user can sign in', async ({ page }) => {
  const loginPage = new LoginPage(page)
  await loginPage.goto()
  await loginPage.login('alice@example.com', 'correct-password')
  await expect(page).toHaveURL('/dashboard')
})
```

## Locator strategy (priority order)

1. `getByRole('button', { name: 'Submit' })` — role + accessible name (preferred).
2. `getByLabel('Email')` — form label association.
3. `getByText('Confirm deletion')` — visible text.
4. `getByTestId('submit-btn')` — `data-testid` attribute (use when no semantic alternative).
5. CSS selectors — last resort; fragile to DOM changes.

**Never** use `page.$('#some-div > div:nth-child(3)')` — it breaks on any layout change.

## Accessibility-tree assertions

Assert the semantic structure of a page with `toMatchAriaSnapshot`. This catches
heading changes, missing labels, and structural regressions:

```ts
test('home page structure', async ({ page }) => {
  await page.goto('/')
  await expect(page.locator('body')).toMatchAriaSnapshot(`
    - banner:
      - heading "Acme Dashboard" [level=1]
      - navigation:
        - link "Dashboard"
        - link "Settings"
    - main:
      - heading "Recent activity" [level=2]
  `)
})
```

Update the snapshot intentionally with `npx playwright test --update-snapshots`.

## Element assertions

```ts
// Visible / enabled / hidden
await expect(page.getByRole('button', { name: 'Save' })).toBeVisible()
await expect(page.getByRole('button', { name: 'Delete' })).toBeEnabled()
await expect(page.getByTestId('spinner')).toBeHidden()

// Text content
await expect(page.getByRole('heading')).toHaveText('Welcome back, Alice')

// URL navigation
await expect(page).toHaveURL('/dashboard')
await expect(page).toHaveURL(/\/posts\/\d+/)

// Role + state
await expect(page.getByRole('checkbox', { name: 'Agree' })).toBeChecked()
```

## Test isolation and authentication

Tests must be fully independent. Use `storageState` to authenticate once per
worker, not per test:

```ts
// e2e/auth.setup.ts
import { test as setup } from '@playwright/test'

setup('authenticate', async ({ page }) => {
  await page.goto('/login')
  await page.getByLabel('Email').fill(process.env.TEST_USER_EMAIL!)
  await page.getByLabel('Password').fill(process.env.TEST_USER_PASSWORD!)
  await page.getByRole('button', { name: 'Sign in' }).click()
  await page.waitForURL('/dashboard')
  await page.context().storageState({ path: 'e2e/.auth/user.json' })
})
```

```ts
// playwright.config.ts — reference the saved state
projects: [
  { name: 'setup', testMatch: /auth\.setup\.ts/ },
  {
    name: 'authenticated',
    use: { storageState: 'e2e/.auth/user.json' },
    dependencies: ['setup'],
  },
]
```

## Hard rules

- Use `toMatchAriaSnapshot()` for structural regression, not `toHaveScreenshot()`
  as the primary assertion. Screenshots are for confirmed visual bugs only.
- Tests must not share state. No globals mutated between tests; use `beforeEach`
  for fresh fixtures.
- All tests must pass in CI (`forbidOnly: true` prevents `.only` in CI).
- Keep `e2e/.auth/` in `.gitignore` — it contains session tokens.
- Locators must use roles, labels, or text — not nth-child CSS selectors.
