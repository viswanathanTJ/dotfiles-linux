// Desktop rules: put each new app window on a fixed desktop (workspace).
// Listed apps go to their desktop; every other normal window goes to desktop 4.
// Dialogs, pop-ups and windows shown on all desktops are left alone.
import GLib from 'gi://GLib';
import Meta from 'gi://Meta';
import Shell from 'gi://Shell';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

// Desktop numbers count from 1. Matched against the app id, then the window class.
const RULES = [
    {desktop: 1, ids: ['teams-for-linux.desktop'], classes: ['teams-for-linux']},
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

export default class DesktopRules extends Extension {
    enable() {
        this._tracker = Shell.WindowTracker.get_default();
        // Apps that start with the session shouldn't make the screen jump between desktops
        this._quietUntil = GLib.get_monotonic_time() + 15 * GLib.USEC_PER_SEC;
        this._createdId = global.display.connect('window-created',
            (_display, win) => this._onCreated(win));
        // Sort the windows that are already open, once (without switching desktop)
        this._startupId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1500, () => {
            this._startupId = 0;
            for (const actor of global.get_window_actors())
                this._place(actor.meta_window, false);
            return GLib.SOURCE_REMOVE;
        });
    }

    disable() {
        if (this._createdId)
            global.display.disconnect(this._createdId);
        if (this._startupId)
            GLib.source_remove(this._startupId);
        this._createdId = 0;
        this._startupId = 0;
        this._tracker = null;
    }

    _onCreated(win) {
        // The app id and title are only reliable once the window has drawn its first frame
        const actor = win.get_compositor_private();
        if (!actor)
            return;
        const id = actor.connect('first-frame', () => {
            actor.disconnect(id);
            // Move it after the signal returns, not inside it (moving a window from within
            // first-frame is the likely cause of the GNOME 46 crash)
            const follow = GLib.get_monotonic_time() > this._quietUntil;
            GLib.idle_add(GLib.PRIORITY_DEFAULT_IDLE, () => {
                if (this._tracker && win.get_compositor_private())
                    this._place(win, follow);
                return GLib.SOURCE_REMOVE;
            });
        });
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
        if (!win || win.get_window_type() !== Meta.WindowType.NORMAL)
            return;
        if (win.get_transient_for() || win.skip_taskbar || win.is_on_all_workspaces())
            return;
        const desktop = this._targetDesktop(win);
        const wm = global.workspace_manager;
        if (!desktop || desktop > wm.get_n_workspaces())
            return;
        const index = desktop - 1;
        if (win.get_workspace()?.index() !== index)
            win.change_workspace_by_index(index, false);
        // An app you just opened: go to its desktop with it. Only for its first window, so an
        // app that keeps opening windows (Genymotion's player) doesn't pull you to its desktop.
        if (follow && wm.get_active_workspace_index() !== index && !this._appHasOtherWindows(win))
            wm.get_workspace_by_index(index).activate_with_focus(win, global.get_current_time());
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
