---
name: maestro-flow-author
description: Author Maestro YAML flows — selectors, gestures, assertions, app launch/state setup.
---

# Authoring a Maestro flow

## Inputs

- The user journey ("user logs in with email", "user adds item to cart").
- The app's identifier (`bundleId` iOS, `appId` Android).

## Pattern

```yaml
appId: com.example.myapp
---
- launchApp:
    clearState: true
- tapOn: "Sign in"
- inputText: "user@example.com"
- tapOn:
    id: "password-input"
- inputText: "correct-horse-battery-staple"
- tapOn: "Continue"
- assertVisible: "Welcome back, user@example.com"
```

## Constraints
- Always start with `clearState: true` for deterministic runs.
- Always use `id:` or `text:` selectors; never coordinates.
- Use `extendedWaitUntil` for network-bound flows.
- For each Maestro command, see <https://maestro.mobile.dev/api-reference/commands>.

## Output
A working `.maestro/<journey>.yaml` plus a one-line description of the flow.
