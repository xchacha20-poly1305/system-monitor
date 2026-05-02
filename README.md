# System Monitor - GNOME Shell Extension

A customizable system monitoring extension for GNOME Shell with network interface filtering capabilities.

## Forked feature

- Allow select network interface.

## Installation

### Prerequisites

- GNOME Shell 45 or later
- Meson build system (optional, for building)
- GLib development tools

### Build and Install

For a per-user local install:

```bash
cd /path/to/system-monitor
scripts/install-local.sh
```

Using Meson:

```bash
cd /path/to/system-monitor
meson setup --prefix="$HOME/.local" build
meson compile -C build
meson install -C build
```

Or manually:

```bash
# Create extension directory
mkdir -p ~/.local/share/gnome-shell/extensions/system-monitor@org.codeberg.anrong

# Copy files
cp extension.js prefs.js stylesheet.css metadata.json \
  ~/.local/share/gnome-shell/extensions/system-monitor@org.codeberg.anrong/
cp -r icons schemas \
  ~/.local/share/gnome-shell/extensions/system-monitor@org.codeberg.anrong/

# Compile GSettings schema
glib-compile-schemas \
  ~/.local/share/gnome-shell/extensions/system-monitor@org.codeberg.anrong/schemas/

# Compile and install translations
while read -r lang; do
  [ -z "$lang" ] || [ "${lang#\#}" != "$lang" ] && continue
  install -d \
    "$HOME/.local/share/gnome-shell/extensions/system-monitor@org.codeberg.anrong/locale/$lang/LC_MESSAGES"
  msgfmt --check \
    --output-file="$HOME/.local/share/gnome-shell/extensions/system-monitor@org.codeberg.anrong/locale/$lang/LC_MESSAGES/org.codeberg.anrong.gnome.system-monitor.mo" \
    po/$lang.po
done < po/LINGUAS
```

### Enable the Extension

After installation, restart GNOME Shell:

**X11:**
- Press `Alt+F2`
- Type `r`
- Press Enter

**Wayland:**
- Log out and log back in

Then enable the extension:

```bash
gnome-extensions enable system-monitor@org.codeberg.anrong
```

Verify installation:

```bash
gnome-extensions list | grep system-monitor
gnome-extensions info system-monitor@org.codeberg.anrong
```

## Configuration

### Graphical Interface (Recommended)

Open the preferences dialog:

```bash
gnome-extensions prefs system-monitor@org.codeberg.anrong
```

In the settings window, you can:
- **Display Options** - Choose which metrics to show (CPU, Memory, Swap, Upload, Download)
- **Network Interface Monitoring** - Select which network interfaces to monitor

### Command Line Configuration

View current configuration:

```bash
gsettings get org.codeberg.anrong.gnome.system-monitor monitored-interfaces
```

Monitor all interfaces (default):

```bash
gsettings set org.codeberg.anrong.gnome.system-monitor monitored-interfaces "[]"
```

Monitor specific interfaces:

```bash
# Monitor only wlan0
gsettings set org.codeberg.anrong.gnome.system-monitor monitored-interfaces "['wlan0']"

# Monitor wlan0 and wg0
gsettings set org.codeberg.anrong.gnome.system-monitor monitored-interfaces "['wlan0', 'wg0']"
```

Reset to default:

```bash
gsettings reset org.codeberg.anrong.gnome.system-monitor monitored-interfaces
```

### View Available Network Interfaces

```bash
ip link show | grep -E "^[0-9]+:" | awk '{print $2}' | sed 's/:$//' | sed 's/@.*//'
```

## Behavior

### Default Behavior

When `monitored-interfaces` is an empty array `[]`, the extension monitors all non-loopback network interfaces (same as the original behavior).

### Selecting Specific Interfaces

- Check the desired interfaces in the settings window, or
- Use the command line to set a specific interface list
- Changes take effect immediately without restarting the extension

## Troubleshooting

### Extension Not Appearing in List

- Confirm GNOME Shell has been restarted
- Check logs: `journalctl -f -o cat /usr/bin/gnome-shell`

### Configuration Not Taking Effect

- Verify the correct schema ID: `org.codeberg.anrong.gnome.system-monitor`
- Recompile schema:
  ```bash
  glib-compile-schemas ~/.local/share/gnome-shell/extensions/system-monitor@org.codeberg.anrong/schemas/
  ```

### Settings Window Won't Open

Ensure `prefs.js` exists and has correct permissions:

```bash
ls -l ~/.local/share/gnome-shell/extensions/system-monitor@org.codeberg.anrong/prefs.js
```

### Extension Fails to Load

Check the GNOME Shell logs:

```bash
journalctl -f -o cat /usr/bin/gnome-shell
```

## Uninstallation

To remove the extension:

```bash
gnome-extensions disable system-monitor@org.codeberg.anrong
rm -rf ~/.local/share/gnome-shell/extensions/system-monitor@org.codeberg.anrong
```

Then restart GNOME Shell.

## Translation Guide

Translations are maintained under `po/`. Most strings are copied from the
upstream GNOME Shell Extensions translation catalog, then merged with strings
added by this fork.

### Sync From Upstream

The sync script expects the upstream repository at `../gnome-shell-extensions`
by default:

```bash
scripts/sync-translations.sh
```

If the upstream checkout is somewhere else, pass its path:

```bash
scripts/sync-translations.sh /path/to/gnome-shell-extensions
```

The script will:

- extract translatable strings from `extension.js`, `prefs.js`, `metadata.json`,
  and the GSettings schema
- copy all languages listed in the upstream `po/` directory
- merge upstream translations into this extension's template
- apply local translation overrides from `po/overrides/`
- regenerate `po/LINGUAS` and `po/org.codeberg.anrong.gnome.system-monitor.pot`

### Local Translation Overrides

Fork-specific translations should be added to override files instead of editing
generated language files directly. For Chinese translations, update:

- `po/overrides/zh_CN.po`
- `po/overrides/zh_TW.po`
- `po/overrides/zh_HK.po`

Then rerun:

```bash
scripts/sync-translations.sh
```

This keeps local strings such as the preferences UI and metadata translated
while still allowing upstream translations to be refreshed.

### Add New Translatable Strings

For JavaScript strings, wrap user-visible text with `_()`:

```js
title: _('Display Options')
```

For preferences code, import gettext from the preferences extension API:

```js
import {ExtensionPreferences, gettext as _} from 'resource:///org/gnome/Shell/Extensions/js/extensions/prefs.js';
```

After adding or changing strings, run the sync script and add Chinese
translations to the override files when needed.

### Verify Translations

Check the script syntax:

```bash
bash -n scripts/sync-translations.sh
```

Check a PO file:

```bash
msgfmt --check --output-file=/tmp/zh_CN.mo po/zh_CN.po
```

Build all translations with Meson:

```bash
meson setup build
meson compile -C build
```

## Technical Details

- **Configuration Key**: `monitored-interfaces`
- **Data Type**: String array (`as`)
- **Default Value**: `[]` (empty array)
- **Storage**: dconf database
- **Update Frequency**: Configuration read once per second

## File Locations

- **Extension Directory**: `~/.local/share/gnome-shell/extensions/system-monitor@org.codeberg.anrong/`
- **Schema Files**: `~/.local/share/gnome-shell/extensions/system-monitor@org.codeberg.anrong/schemas/`
- **Source Code**: Project repository

## License

SPDX-License-Identifier: [GPL-2.0-or-later](./LICENSE)

## Credits

Based on [GNOME Shell Extensions project](https://gitlab.gnome.org/GNOME/gnome-shell-extensions).
