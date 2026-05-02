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

Using Meson:

```bash
cd /path/to/system-monitor
meson setup build
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
