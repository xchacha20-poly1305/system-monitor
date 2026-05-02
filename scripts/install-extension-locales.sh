#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 AnRong
# SPDX-License-Identifier: GPL-2.0-or-later

set -euo pipefail

source_root=$1
extension_dir=$2
domain=$3
target_root="${DESTDIR:-}$extension_dir"

if ! command -v msgfmt >/dev/null 2>&1; then
    echo "Missing required tool: msgfmt" >&2
    exit 1
fi

while IFS= read -r lang; do
    case "$lang" in
        ''|\#*)
            continue
            ;;
    esac

    po_file="$source_root/po/$lang.po"
    mo_dir="$target_root/locale/$lang/LC_MESSAGES"
    install -d "$mo_dir"
    msgfmt --check --output-file="$mo_dir/$domain.mo" "$po_file"
done < "$source_root/po/LINGUAS"
