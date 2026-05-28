---
name: foreground-service-type-author
description: Declare correct foregroundServiceType per Android 14/15/16 rules; pair with Play Console "App content" entry.
---

# Declaring foregroundServiceType correctly

## Why

Android 14+ throws `MissingForegroundServiceTypeException` if a `<service>` running as foreground does not declare `android:foregroundServiceType`. Android 15 added time bounds to `dataSync` / `mediaProcessing`. Android 16 applies runtime quotas to jobs from FGS in non-active buckets.

## Inputs

- The use case: "what is the foreground service doing?"
- The current `AndroidManifest.xml`.

## Process

1. Pick the most specific type from: `dataSync`, `mediaProcessing`, `mediaPlayback`, `phoneCall`, `connectedDevice`, `location`, `health`, `shortService`, `specialUse`, `remoteMessaging`, `systemExempted`.
2. Declare in manifest:

```xml
<service
    android:name=".MyForegroundService"
    android:foregroundServiceType="dataSync"
    android:exported="false" />
```

3. Add the corresponding permission to the manifest: `FOREGROUND_SERVICE_DATA_SYNC` for `dataSync`, etc.
4. Document the matching Play Console "App content" entry in `play-console-checklist.md` (missing this breaks store review).

## Output

The manifest edit, the permission addition, and the checklist update.
