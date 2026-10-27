// Desktop rules: put each new app window on a fixed desktop (workspace).
// Listed apps go to their desktop; every other normal window goes to desktop 4.
// Dialogs, pop-ups and windows shown on all desktops are left alone.
//
// Safety (version 3, follow fixed; version 2 safety): the first version moved windows inside GNOME's own "first frame" signal and
// switched desktops from there, and GNOME 46 crashed. Now every move happens later, from a timer,
// only after checking the window still exists, and the desktop switch goes through Main.activateWindow
// (the same path the dock and Alt+Tab use).
import GLib from 'gi://GLib';
import Meta from 'gi://Meta';
import Shell from 'gi://Shell';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

// Desktop numbers count from 1. Matched against the app id, then the window class.
const RULES = [
    {desktop: 1, ids: ['teams-for-linux.desktop'], classes: ['teams-for-linux']},
    {desktop: 2, ids: ['google-chrome.desktop'], classes: ['google-chrome']},
    {desktop: 2, ids: ['brave-browser.desktop', 'com.brave.Browser.desktop'], classes: ['brave-browser']},
    {desktop: 3, ids: ['kitty.desktop'], classes: ['kitty']},
    {desktop: 3, ids: ['com.microsoft.VSCode.desktop', 'code.desktop'], classes: ['code']},
];
const OTHERS_DESKTOP = 4;

// Never moved: tray/helper windows and the Force Quit (btop) kitty window.
// wl-copy / wl-paste open a hidden window "wl-clipboard" for every copy (GNOME has no
// clipboard protocol without one); moving it pulled you to desktop 4 on each copy.
const SKIP_CLASSES = ['copyq', 'gnome-shell', 'org.gnome.shell.extensions', 'io.github.bugaevc.wl-clipboard'];
const SKIP_TITLES = ['Force Quit (btop)', 'wl-clipboard'];

// Shown on every desktop, so the shortcut never switches desktops.
const STICKY_CLASSES = ['vibe-typer'];

const PLACE_DELAY_MS = 400;     // wait this long after a window appears before moving it
const STARTUP_DELAY_MS = 5000;  // sort windows that are already open this long after enabling
const QUIET_SECONDS = 20;       // after login: move windows, but don't switch desktops

export default class DesktopRules extends Extension {
    enable() {
        this._tracker = Shell.WindowTracker.get_default();
        this._pending = new Map();  // window -> {timer, unmanagedId}
        this._quietUntil = GLib.get_monotonic_time() + QUIET_SECONDS * GLib.USEC_PER_SEC;
        this._createdId = global.display.connect('window-created',
            (_display, win) => this._schedule(win, true));
        this._startupId = GLib.timeout_add(GLib.PRIORITY_DEFAULT_IDLE, STARTUP_DELAY_MS, () => {
            this._startupId = 0;
            for (const actor of global.get_window_actors())
                this._schedule(actor.meta_window, false);
            return GLib.SOURCE_REMOVE;
        });
    }

    disable() {
        if (this._createdId)
            global.display.disconnect(this._createdId);
        if (this._startupId)
            GLib.source_remove(this._startupId);
        for (const win of [...this._pending.keys()])
            this._cancel(win);
        this._createdId = 0;
        this._startupId = 0;
        this._pending = null;
        this._tracker = null;
    }

    _schedule(win, isNew) {
        if (!win || this._pending.has(win))
            return;
        const entry = {timer: 0, unmanagedId: 0};
        // a window that closes before the timer fires is simply forgotten
        entry.unmanagedId = win.connect('unmanaged', () => this._cancel(win));
        entry.timer = GLib.timeout_add(GLib.PRIORITY_DEFAULT_IDLE, PLACE_DELAY_MS, () => {
            entry.timer = 0;
            this._cancel(win);
            const follow = isNew && GLib.get_monotonic_time() > this._quietUntil;
            try {
                this._place(win, follow);
            } catch (e) {
                console.warn(`desktop-rules: skipped a window: ${e}`);
            }
            return GLib.SOURCE_REMOVE;
        });
        this._pending.set(win, entry);
    }

    _cancel(win) {
        const entry = this._pending?.get(win);
        if (!entry)
            return;
        if (entry.timer)
            GLib.source_remove(entry.timer);
        if (entry.unmanagedId)
            win.disconnect(entry.unmanagedId);
        this._pending.delete(win);
    }

    _targetDesktop(win) {
        const cls = (win.get_wm_class() || '').toLowerCase();
        const title = win.get_title() || '';
        if (SKIP_CLASSES.includes(cls) || SKIP_TITLES.includes(title))
            return 0;
        const app = this._tracker?.get_window_app(win);
        const appId = app ? app.get_id() : '';
        for (const rule of RULES) {
            if (rule.ids.includes(appId) || rule.classes.includes(cls))
                return rule.desktop;
        }
        return OTHERS_DESKTOP;
    }

    _place(win, follow) {
        // only real, finished, normal app windows on a single desktop
        if (!win.get_compositor_private() || win.is_override_redirect())
            return;
        if (win.get_window_type() !== Meta.WindowType.NORMAL)
            return;
        if (STICKY_CLASSES.includes((win.get_wm_class() || '').toLowerCase())) {
            if (!win.is_on_all_workspaces())
                win.stick();
            return;
        }
        if (win.get_transient_for() || win.skip_taskbar || win.is_on_all_workspaces())
            return;
        const current = win.get_workspace();
        if (!current)
            return;
        const desktop = this._targetDesktop(win);
        const wm = global.workspace_manager;
        if (!desktop || desktop > wm.get_n_workspaces())
            return;
        const index = desktop - 1;
        const from = current.index();
        if (from !== index)
            win.change_workspace_by_index(index, false);
        // a window you just opened: go to its desktop with it. Only for an app's first window,
        // so an app that keeps opening windows (Genymotion's player) doesn't pull you there.
        // Timers have no event time (global.get_current_time() is 0) and GNOME ignores a
        // switch without one, so ask the display server for a real timestamp.
        let followed = false;
        if (follow && wm.get_active_workspace_index() !== index && !this._appHasOtherWindows(win)) {
            const time = global.display.get_current_time_roundtrip();
            wm.get_workspace_by_index(index).activate_with_focus(win, time);
            Main.overview.hide();
            followed = true;
        }
        this._log(`${win.get_wm_class()}: desktop ${from + 1} -> ${desktop}` +
            `${follow ? (followed ? ', followed' : ', already there') : ', no follow'}` +
            `, now on ${wm.get_active_workspace_index() + 1}`);
    }

    // small log for checking behaviour: ~/.cache/desktop-rules.log (last 200 lines kept)
    _log(line) {
        try {
            const path = GLib.build_filenamev([GLib.get_user_cache_dir(), 'desktop-rules.log']);
            let text = '';
            try {
                const [, bytes] = GLib.file_get_contents(path);
                text = new TextDecoder().decode(bytes);
            } catch (_e) {}
            const stamp = GLib.DateTime.new_now_local().format('%H:%M:%S');
            const lines = (text + `${stamp} ${line}\n`).split('\n').slice(-201);
            GLib.file_set_contents(path, lines.join('\n'));
        } catch (_e) {}
    }

    _appHasOtherWindows(win) {
        const pid = win.get_pid();
        const cls = win.get_wm_class();
        return global.get_window_actors().some(actor => {
            const other = actor.meta_window;
            return other !== win &&
                ((pid > 0 && other.get_pid() === pid) || (cls && other.get_wm_class() === cls));
        });
    }
}
