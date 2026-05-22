---
name: parsing-gradle-errors
description: Turn `./gradlew --console=plain` output into a structured fix list (failing module, task, line, remediation).
---

# Parsing Gradle errors

## Inputs

- The plain-text Gradle output (always invoke with `--console=plain`).
- `libs.versions.toml`, `settings.gradle.kts`, root `build.gradle.kts`.

## Process

1. Find the first `> Task :module:task FAILED` line.
2. Read backwards 20 lines to find the actual error text (Gradle prints reverse-chronological causes).
3. Categorize: `compilation`, `linking`, `dependency-resolution`, `ksp/kapt`, `compose-compiler`, `signing`, `r8/proguard`.
4. For dependency-resolution, run `./gradlew :module:dependencies --console=plain` and locate the conflicting transitives.
5. Produce one-line remediation per error.

## Output

```
[ksp/kapt] :feature:checkout · "Cannot find generated Hilt module"
  → Replace `kapt 'com.google.dagger:hilt-android-compiler'` with `ksp 'com.google.dagger:hilt-android-compiler'`. Run `./gradlew clean`.

[compose-compiler] :feature:product · "Kotlin version 2.0.20 incompatible with Compose Compiler 1.5.10"
  → Use Compose Compiler Gradle Plugin (id("org.jetbrains.kotlin.plugin.compose") version "2.1.0"). Remove `kotlinCompilerExtensionVersion`.
```
