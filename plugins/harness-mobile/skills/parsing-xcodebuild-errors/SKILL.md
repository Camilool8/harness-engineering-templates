---
name: parsing-xcodebuild-errors
description: Read structured XcodeBuildMCP error output and produce a focused fix list — failing target, file, line, error category, remediation.
---

# Parsing xcodebuild errors via XcodeBuildMCP

## Inputs

- The JSON error tree returned by XcodeBuildMCP `build_*` tools.
- The project's `Package.swift` and `project.pbxproj` (read-only).

## Process

1. Walk the JSON error tree and extract every leaf error.
2. Group errors by category: `compilation`, `linking`, `signing`, `dependency`, `provisioning`, `scheme`.
3. For each error, identify: failing target, failing file, line number, exact compiler/linker message.
4. Produce a one-line remediation per error or per error-group.
5. Surface the *first* error in each category as the highest priority — later errors are often cascades.

## Output

```
Errors (sorted by category, priority first):

[compilation] FooTarget · Sources/Foo/Bar.swift:42 — "cannot convert value of type 'Int' to expected argument type 'String'"
  → Cast or change the function signature. Likely caller-side mismatch from a recent API rename.

[signing] AppTarget · No provisioning profile matching bundle id "com.example.app"
  → Run fastlane match development; ensure team_id matches in Appfile.

...
```

Never invoke fixes from this skill — handoff to `xcode-build-resolver`.
