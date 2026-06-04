# Platform — Android Build Notes

## Purpose

Documents Android Gradle configuration quirks and the **compileSdk floor** enforced for transitive plugins.

## Entry points

| File | Role |
|------|------|
| [`android/build.gradle.kts`](../../../android/build.gradle.kts) | Subproject compileSdk guard |
| [`android/app/build.gradle.kts`](../../../android/app/build.gradle.kts) | App module config |

## compileSdk compatibility guard

Some pub plugins ship with `compileSdkVersion 30` while depending on AndroidX resources requiring API 31+ (`android:attr/lStar`, etc.).

**Fix** in root `android/build.gradle.kts`:

```kotlin
subprojects {
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.library")) {
            extensions.configure<com.android.build.gradle.LibraryExtension> {
                if ((compileSdk ?: 0) < 34) {
                    compileSdk = 34
                }
            }
        }
    }
}
```

This applies to **all Android library subprojects** including transitive pub plugins.

## Symptom

Release build failure:

```text
AAPT: error: resource android:attr/lStar not found.
```

Inspect `build/.../values.xml` for missing `android:attr/*` and verify library module compile SDK values.

## Regression check

```bash
flutter build apk --release
```

## Related docs

- `.cursor/rules/android-plugin-compile-sdk-compat.mdc`
- [android-sms-listener.md](android-sms-listener.md)

## How to extend

When upgrading Flutter or major plugins, re-run release build. If new resource errors appear, raise the floor compileSdk to match the app's `compileSdk` (keep them aligned).
