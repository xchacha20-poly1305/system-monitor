#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 AnRong
# SPDX-License-Identifier: GPL-2.0-or-later

"""Print one top-level value from metadata.json.

metadata.json is the single source of the extension's identifiers
(uuid, gettext-domain, settings-schema); the build and helper scripts
read them from here instead of repeating them.
"""

import json
import sys
from pathlib import Path

metadata_file = Path(__file__).resolve().parent.parent / 'metadata.json'

if len(sys.argv) != 2:
    sys.exit(f'Usage: {sys.argv[0]} KEY')

metadata = json.loads(metadata_file.read_text(encoding='utf-8'))
try:
    print(metadata[sys.argv[1]])
except KeyError:
    sys.exit(f'Key not found in {metadata_file}: {sys.argv[1]}')
