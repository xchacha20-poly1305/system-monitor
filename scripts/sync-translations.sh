#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 AnRong
# SPDX-License-Identifier: GPL-2.0-or-later

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
root_dir=$(cd -- "$script_dir/.." && pwd)
upstream_dir=${1:-"$root_dir/../gnome-shell-extensions"}
upstream_po_dir="$upstream_dir/po"
po_dir="$root_dir/po"
domain="org.codeberg.anrong.gnome.system-monitor"
pot_file="$po_dir/$domain.pot"
schema_file="schemas/org.codeberg.anrong.gnome.system-monitor.gschema.xml"
schema_its="/usr/share/gettext/its/gschema.its"

require_tool() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Missing required tool: $1" >&2
        exit 1
    fi
}

require_tool xgettext
require_tool msgcat
require_tool msgmerge
require_tool msgattrib
require_tool find
require_tool sed
require_tool sort

if [ ! -d "$upstream_po_dir" ]; then
    echo "Upstream po directory not found: $upstream_po_dir" >&2
    echo "Usage: $0 [path-to-gnome-shell-extensions]" >&2
    exit 1
fi

if [ ! -f "$schema_its" ]; then
    echo "GSettings gettext ITS file not found: $schema_its" >&2
    exit 1
fi

tmpdir=$(mktemp -d)
cleanup() {
    rm -rf "$tmpdir"
}
trap cleanup EXIT

cd "$root_dir"
mkdir -p "$po_dir"

xgettext \
    --from-code=UTF-8 \
    --language=JavaScript \
    --keyword=_ \
    --package-name=system-monitor \
    --msgid-bugs-address=https://codeberg.org/xchacha20-poly1305/system-monitor/issues \
    --output="$tmpdir/js.pot" \
    extension.js prefs.js

xgettext \
    --from-code=UTF-8 \
    --its="$schema_its" \
    --package-name=system-monitor \
    --msgid-bugs-address=https://codeberg.org/xchacha20-poly1305/system-monitor/issues \
    --output="$tmpdir/schema.pot" \
    "$schema_file"

metadata_name=$(sed -n 's/^[[:space:]]*"name"[[:space:]]*:[[:space:]]*"\(.*\)",[[:space:]]*$/\1/p' metadata.json)
metadata_description=$(sed -n 's/^[[:space:]]*"description"[[:space:]]*:[[:space:]]*"\(.*\)",[[:space:]]*$/\1/p' metadata.json)

cat > "$tmpdir/metadata.pot" <<POT
#. Extension metadata name
#: metadata.json:2
msgid "$metadata_name"
msgstr ""

#. Extension metadata description
#: metadata.json:3
msgid "$metadata_description"
msgstr ""
POT

msgcat \
    --use-first \
    --output-file="$pot_file" \
    "$tmpdir/js.pot" "$tmpdir/schema.pot" "$tmpdir/metadata.pot"

find "$upstream_po_dir" -maxdepth 1 -name '*.po' -printf '%f\n' |
    sed 's/\.po$//' |
    sort > "$po_dir/LINGUAS"

while IFS= read -r lang; do
    upstream_po="$upstream_po_dir/$lang.po"
    out_po="$po_dir/$lang.po"

    msgmerge \
        --quiet \
        --previous \
        --output-file="$tmpdir/$lang.merged.po" \
        "$upstream_po" "$pot_file"

    msgattrib \
        --no-obsolete \
        --output-file="$out_po" \
        "$tmpdir/$lang.merged.po"

    override_po="$po_dir/overrides/$lang.po"
    if [ -f "$override_po" ]; then
        msgcat \
            --use-first \
            --output-file="$tmpdir/$lang.with-overrides.po" \
            "$override_po" "$out_po"

        msgmerge \
            --quiet \
            --previous \
            --output-file="$tmpdir/$lang.final.po" \
            "$tmpdir/$lang.with-overrides.po" "$pot_file"

        msgattrib \
            --no-obsolete \
            --output-file="$out_po" \
            "$tmpdir/$lang.final.po"
    fi
done < "$po_dir/LINGUAS"

echo "Updated translations from: $upstream_po_dir"
echo "Template: $pot_file"
echo "Languages: $(wc -l < "$po_dir/LINGUAS")"
