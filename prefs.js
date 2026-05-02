// SPDX-FileCopyrightText: 2023 Florian Müllner <fmuellner@gnome.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import Adw from 'gi://Adw';
import Gtk from 'gi://Gtk';
import GTop from 'gi://GTop';
import {ExtensionPreferences, gettext as _} from 'resource:///org/gnome/Shell/Extensions/js/extensions/prefs.js';

export default class SystemMonitorPreferences extends ExtensionPreferences {
    fillPreferencesWindow(window) {
        const settings = this.getSettings();

        const page = new Adw.PreferencesPage({
            title: _('General'),
            icon_name: 'dialog-information-symbolic',
        });
        window.add(page);

        const displayGroup = new Adw.PreferencesGroup({
            title: _('Display Options'),
            description: _('Choose which system stats to show'),
        });
        page.add(displayGroup);

        const cpuRow = new Adw.ActionRow({
            title: _('Show CPU Usage'),
        });
        const cpuSwitch = new Gtk.Switch({
            active: settings.get_boolean('show-cpu'),
            valign: Gtk.Align.CENTER,
        });
        settings.bind('show-cpu', cpuSwitch, 'active', 0);
        cpuRow.add_suffix(cpuSwitch);
        displayGroup.add(cpuRow);

        const memRow = new Adw.ActionRow({
            title: _('Show Memory Usage'),
        });
        const memSwitch = new Gtk.Switch({
            active: settings.get_boolean('show-memory'),
            valign: Gtk.Align.CENTER,
        });
        settings.bind('show-memory', memSwitch, 'active', 0);
        memRow.add_suffix(memSwitch);
        displayGroup.add(memRow);

        const swapRow = new Adw.ActionRow({
            title: _('Show Swap Usage'),
        });
        const swapSwitch = new Gtk.Switch({
            active: settings.get_boolean('show-swap'),
            valign: Gtk.Align.CENTER,
        });
        settings.bind('show-swap', swapSwitch, 'active', 0);
        swapRow.add_suffix(swapSwitch);
        displayGroup.add(swapRow);

        const uploadRow = new Adw.ActionRow({
            title: _('Show Upload Speed'),
        });
        const uploadSwitch = new Gtk.Switch({
            active: settings.get_boolean('show-upload'),
            valign: Gtk.Align.CENTER,
        });
        settings.bind('show-upload', uploadSwitch, 'active', 0);
        uploadRow.add_suffix(uploadSwitch);
        displayGroup.add(uploadRow);

        const downloadRow = new Adw.ActionRow({
            title: _('Show Download Speed'),
        });
        const downloadSwitch = new Gtk.Switch({
            active: settings.get_boolean('show-download'),
            valign: Gtk.Align.CENTER,
        });
        settings.bind('show-download', downloadSwitch, 'active', 0);
        downloadRow.add_suffix(downloadSwitch);
        displayGroup.add(downloadRow);

        const networkGroup = new Adw.PreferencesGroup({
            title: _('Network Interface Monitoring'),
            description: _('Select which network interfaces to monitor (leave all unchecked to monitor all)'),
        });
        page.add(networkGroup);

        GTop.glibtop_init();
        const netlist = new GTop.glibtop_netlist();
        const ifnames = GTop.glibtop_get_netlist(netlist);
        const monitoredInterfaces = settings.get_strv('monitored-interfaces');

        for (const ifname of ifnames) {
            const netload = new GTop.glibtop_netload();
            GTop.glibtop_get_netload(netload, ifname);

            const FLAG_LOOPBACK = 1 << 4;
            if (netload.if_flags & FLAG_LOOPBACK)
                continue;

            let subtitle = _('Network Interface');
            if (ifname.startsWith('wl'))
                subtitle = _('Wireless Interface');
            else if (ifname.startsWith('eth') || ifname.startsWith('en'))
                subtitle = _('Ethernet Interface');
            else if (ifname.startsWith('wg'))
                subtitle = _('WireGuard VPN');
            else if (ifname.startsWith('tun') || ifname.startsWith('tap'))
                subtitle = _('VPN Interface');
            else if (ifname.startsWith('docker') || ifname.startsWith('br'))
                subtitle = _('Virtual Bridge');

            const row = new Adw.ActionRow({
                title: ifname,
                subtitle: subtitle,
            });

            const toggle = new Gtk.Switch({
                active: monitoredInterfaces.length === 0 || monitoredInterfaces.includes(ifname),
                valign: Gtk.Align.CENTER,
            });

            toggle.connect('notify::active', () => {
                let interfaces = settings.get_strv('monitored-interfaces');

                if (toggle.active) {
                    if (!interfaces.includes(ifname))
                        interfaces.push(ifname);
                } else {
                    interfaces = interfaces.filter(name => name !== ifname);
                }

                settings.set_strv('monitored-interfaces', interfaces);
            });

            row.add_suffix(toggle);
            networkGroup.add(row);
        }
    }
}
