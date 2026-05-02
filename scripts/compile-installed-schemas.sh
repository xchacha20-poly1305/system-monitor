#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 AnRong
# SPDX-License-Identifier: GPL-2.0-or-later

set -euo pipefail

schema_dir="${DESTDIR:-}$1"

if ! command -v glib-compile-schemas >/dev/null 2>&1; then
    echo "Missing required tool: glib-compile-schemas" >&2
    exit 1
fi

glib-compile-schemas "$schema_dir"
