#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 AnRong
# SPDX-License-Identifier: GPL-2.0-or-later

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
root_dir=$(cd -- "$script_dir/.." && pwd)

require_tool() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Missing required tool: $1" >&2
        exit 1
    fi
}

require_tool python3
require_tool glib-compile-schemas
require_tool msgfmt

metadata_value="$script_dir/metadata-value.py"
uuid=$("$metadata_value" uuid)
domain=$("$metadata_value" gettext-domain)
schema=$("$metadata_value" settings-schema)
extension_dir="${XDG_DATA_HOME:-$HOME/.local/share}/gnome-shell/extensions/$uuid"

cd "$root_dir"

install -d "$extension_dir"
install -m 0644 extension.js prefs.js stylesheet.css metadata.json "$extension_dir/"

rm -rf "$extension_dir/icons" "$extension_dir/schemas" "$extension_dir/locale"
cp -R icons "$extension_dir/icons"
install -d "$extension_dir/schemas"
install -m 0644 "schemas/$schema.gschema.xml" "$extension_dir/schemas/"
glib-compile-schemas "$extension_dir/schemas"

while IFS= read -r lang; do
    case "$lang" in
        ''|\#*)
            continue
            ;;
    esac

    po_file="po/$lang.po"
    mo_dir="$extension_dir/locale/$lang/LC_MESSAGES"
    install -d "$mo_dir"
    msgfmt --check --output-file="$mo_dir/$domain.mo" "$po_file"
done < po/LINGUAS

echo "Installed $uuid to $extension_dir"
echo "Restart GNOME Shell or log out and back in, then enable the extension:"
echo "  gnome-extensions enable $uuid"
