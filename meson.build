# SPDX-FileCopyrightText: 2023 Florian Müllner <fmuellner@gnome.org>
# SPDX-License-Identifier: GPL-2.0-or-later

project('system-monitor',
  version: '1.0',
  meson_version: '>= 0.58.0'
)

gnome = import('gnome')
i18n = import('i18n')

uuid = 'system-monitor@org.codeberg.anrong'
gettext_domain = 'org.codeberg.anrong.gnome.system-monitor'
extensiondir = get_option('prefix') / get_option('datadir') / 'gnome-shell' / 'extensions' / uuid

install_data('extension.js', 'prefs.js', 'stylesheet.css',
  install_dir: extensiondir
)

install_data('metadata.json',
  install_dir: extensiondir
)

install_subdir('icons',
  install_dir: extensiondir
)

install_data('schemas/org.codeberg.anrong.gnome.system-monitor.gschema.xml',
  install_dir: extensiondir / 'schemas'
)

gnome.compile_schemas(
  depend_files: 'schemas/org.codeberg.anrong.gnome.system-monitor.gschema.xml'
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
