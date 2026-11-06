// Network speed (Mbps): upload on the top line, download on the bottom line,
// on the left of the top bar. Reads /proc/net/dev once a second.
// Counts real network cards only: loopback, Docker/VM bridges and VPN tunnels
// (Tailscale, WireGuard) are skipped so the same traffic isn't counted twice.
import GLib from 'gi://GLib';
import St from 'gi://St';
import Clutter from 'gi://Clutter';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

const SKIP = /^(lo|veth|docker|br-|virbr|vnet|vboxnet|tailscale|tun|tap|wg)/;
const decoder = new TextDecoder();

function readBytes() {
    let rx = 0, tx = 0;
    try {
        const [ok, data] = GLib.file_get_contents('/proc/net/dev');
        if (!ok)
            return null;
        for (const line of decoder.decode(data).split('\n').slice(2)) {
            const [name, rest] = line.split(':');
            if (!rest || SKIP.test(name.trim()))
                continue;
            const f = rest.trim().split(/\s+/);
            rx += Number(f[0]);
            tx += Number(f[8]);
        }
    } catch (e) {
        return null;
    }
    return {rx, tx, t: GLib.get_monotonic_time()};
}

function mbps(bytes, micros) {
    const v = (bytes * 8) / micros; // bits per microsecond = Mbps
    return v < 10 ? v.toFixed(1) : v.toFixed(0);
}

export default class NetSpeedMbps extends Extension {
    enable() {
        this._button = new PanelMenu.Button(0.0, this.metadata.name, true);
        const box = new St.BoxLayout({
            style_class: 'netspeed-mbps-box',
            orientation: Clutter.Orientation.VERTICAL,
            y_align: Clutter.ActorAlign.CENTER,
        });
        this._up = new St.Label({style_class: 'netspeed-mbps-label', text: '↑ 0.0 Mbps'});
        this._down = new St.Label({style_class: 'netspeed-mbps-label', text: '↓ 0.0 Mbps'});
        box.add_child(this._up);
        box.add_child(this._down);
        this._button.add_child(box);
        Main.panel.addToStatusArea(this.uuid, this._button, 1, 'left');

        this._last = readBytes();
        this._timer = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, () => {
            const now = readBytes();
            if (now && this._last) {
                const dt = Math.max(now.t - this._last.t, 1);
                this._up.text = `↑ ${mbps(Math.max(now.tx - this._last.tx, 0), dt)} Mbps`;
                this._down.text = `↓ ${mbps(Math.max(now.rx - this._last.rx, 0), dt)} Mbps`;
            }
            this._last = now;
            return GLib.SOURCE_CONTINUE;
        });
    }

    disable() {
        if (this._timer) {
            GLib.source_remove(this._timer);
            this._timer = null;
        }
        this._button?.destroy();
        this._button = null;
        this._up = this._down = null;
        this._last = null;
    }
}
