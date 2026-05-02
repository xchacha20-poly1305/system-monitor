# Repository Guidelines

## Project Structure & Module Organization

This repository contains a GNOME Shell extension for system monitoring. Core runtime code lives in `extension.js`; the preferences UI is in `prefs.js`; panel styling is in `stylesheet.css`. Extension metadata is split between `metadata.json` and `metadata.json.in`. GSettings schemas are under `schemas/`, symbolic icons are under `icons/`, and gettext translations are under `po/` with local overrides in `po/overrides/`. Helper scripts for local installation, schema compilation, and translation syncing live in `scripts/`.

## Build, Test, and Development Commands

- `scripts/install-local.sh`: installs the extension into the user's GNOME extension directory, compiles schemas, and builds translation `.mo` files.
- `meson setup --prefix="$HOME/.local" build`: configures a local Meson build directory.
- `meson compile -C build`: runs the Meson build.
- `meson install -C build`: installs files to the configured prefix.
- `gnome-extensions enable system-monitor@org.codeberg.anrong`: enables the extension after GNOME Shell is restarted or the user logs back in.
- `gnome-extensions prefs system-monitor@org.codeberg.anrong`: opens the preferences window for manual verification.
- `scripts/sync-translations.sh [UPSTREAM_PATH]`: refreshes `po/` from an upstream `gnome-shell-extensions` checkout.

## Coding Style & Naming Conventions

JavaScript follows GNOME Shell extension conventions: ES modules, `import ... from 'gi://...'`, 4-space indentation, braces on the same line, and private fields prefixed with `#` where appropriate. Use camelCase for variables and methods, PascalCase for classes, and underscore-prefixed methods for internal helpers. Keep user-facing strings wrapped in `_()` for extraction. Preserve SPDX headers.

## Testing Guidelines

There is no automated test suite in this repo. Validate changes by installing locally with `scripts/install-local.sh`, restarting GNOME Shell or logging back in, enabling the extension, and checking both the panel indicator and preferences window. For schema changes, confirm `glib-compile-schemas` succeeds. For translation changes, run `msgfmt --check` against affected `.po` files.

## Commit & Pull Request Guidelines

Recent commits use short imperative summaries such as `Fix select interface` and `Add i18n`. Keep the first line concise and action-oriented; add body text only when the change needs context. Pull requests should describe the user-visible behavior, list manual verification steps, mention schema or translation impacts, and include screenshots or screen recordings for UI changes.

## Security & Configuration Tips

Do not commit generated local build output from `build/` or user-specific GNOME settings. Treat shell scripts as install paths: keep quoting strict, prefer `set -euo pipefail`, and validate required external tools before using them.
