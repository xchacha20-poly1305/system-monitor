# SPDX-FileCopyrightText: 2023 Florian Müllner <fmuellner@gnome.org>
# SPDX-License-Identifier: GPL-2.0-or-later

project('system-monitor',
  version: '1.0',
  meson_version: '>= 0.58.0'
)

gnome = import('gnome')
i18n = import('i18n')

# metadata.json is the single source of the extension's identifiers.
python = import('python').find_installation()
metadata_value = files('scripts/metadata-value.py')
uuid = run_command(python, metadata_value, 'uuid', check: true).stdout().strip()
gettext_domain = run_command(python, metadata_value, 'gettext-domain', check: true).stdout().strip()
schema_file = 'schemas' / run_command(python, metadata_value, 'settings-schema', check: true).stdout().strip() + '.gschema.xml'
extensiondir = get_option('prefix') / get_option('datadir') / 'gnome-shell' / 'extensions' / uuid

install_data('extension.js', 'prefs.js', 'stylesheet.css',
  install_dir: extensiondir
)

# Copying (rather than install_data) makes Meson reconfigure when
# metadata.json changes, so the identifiers above stay current.
configure_file(
  input: 'metadata.json',
  output: 'metadata.json',
  copy: true,
  install_dir: extensiondir
)

install_subdir('icons',
  install_dir: extensiondir
)

install_data(schema_file,
  install_dir: extensiondir / 'schemas'
)

gnome.compile_schemas(
  depend_files: schema_file
)

meson.add_install_script(
  'scripts/compile-installed-schemas.sh',
  extensiondir / 'schemas',
)

subdir('po')

meson.add_install_script(
  'scripts/install-extension-locales.sh',
  meson.project_source_root(),
  extensiondir,
  gettext_domain,
)
