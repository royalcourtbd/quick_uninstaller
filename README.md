# Quick Uninstaller

Quick Uninstaller is a lightweight Android app manager built with Flutter. It helps users review installed apps, search and sort app lists, open app details, launch apps, open Play Store pages, create shortcuts, and quickly uninstall selected user-installed apps.

## Core Features

- View installed user apps and system apps separately.
- Search installed apps by name.
- Sort apps by name, size, and install date.
- Select multiple user apps and start uninstall actions.
- Open app details, launch apps, and open app Play Store pages.
- View device storage availability.

## Play Release Notes

This app uses broad package visibility because its core feature is installed-app management. For Google Play, complete the `QUERY_ALL_PACKAGES` declaration and keep the store listing, screenshots, and privacy policy aligned with that purpose.

Before building a Play release, copy `android/key.properties.example` to `android/key.properties`, fill in your private upload key values, and build with:

```sh
flutter build appbundle --release
```
