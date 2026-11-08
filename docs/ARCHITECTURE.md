# Architecture

## What this is

greenguide. The repository is a Flutter application.

## Layout

- `android/`
- `assets/`
- `ios/`
- `lib/` — `app_drawer.dart`, `auth`, `firebase_options.dart`, `main.dart`, `screens`, `services`
- `linux/`
- `macos/`
- `test/`
- `web/`
- `windows/`
- Tooling: `.vscode`, `.gitignore`, `.metadata`
- Root files: `analysis_options.yaml`, `devtools_options.yaml`, `firebase.json`, `pubspec.lock`, `pubspec.yaml`, `README.md`

## How the pieces fit

Flutter app: `pubspec.yaml` plus `lib/` (app_drawer.dart, auth, firebase_options.dart, main.dart, screens, services). Platform folders: `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`. Entrypoint file `lib/main.dart` is present. Pub dependencies include `http`, `get`, `shared_preferences`.

## How to run

This repository does not document a run procedure.

## External services named in the repo

- Firebase — `firebase_auth` in `pubspec.yaml`
