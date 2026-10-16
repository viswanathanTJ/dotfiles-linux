# GNOME settings that live in GNOME's settings database (dconf), not in files,
# so they can't be symlinked. setup.sh sources this file and calls these functions.
# To change a setting: edit it here, then run ./setup.sh --only <part> again.
# Needs: run, say, have (from setup.sh), HERE = repo folder.

gnome_ver() { gnome-shell --version 2>/dev/null | grep -oE '[0-9]+' | head -1; }

install_extension() {   # $1 = extensions.gnome.org id, $2 = uuid
    local ver url
    ver=$(gnome_ver)
    url=$(curl -fsSL "https://extensions.gnome.org/extension-info/?pk=$1&shell_version=$ver" \
          | python3 -c 'import json,sys; print(json.load(sys.stdin)["download_url"])' 2>/dev/null || true)
    if [ -z "$url" ]; then
        echo "    No version of $2 for GNOME $ver; install it from https://extensions.gnome.org/extension/$1/"
        return
    fi
    run "curl -fsSL -o /tmp/$2.zip \"https://extensions.gnome.org$url\" && gnome-extensions install --force /tmp/$2.zip"
}

# add (+uuid) or remove (-uuid) entries in GNOME's enabled-extensions list
set_extensions() {
    run "python3 - $* <<'PY'
import subprocess, ast, sys
cur = ast.literal_eval(subprocess.run(['gsettings','get','org.gnome.shell','enabled-extensions'],capture_output=True,text=True).stdout.strip().removeprefix('@as '))
for arg in sys.argv[1:]:
    uuid = arg[1:]
    if arg[0] == '+' and uuid not in cur: cur.append(uuid)
    if arg[0] == '-' and uuid in cur: cur.remove(uuid)
subprocess.run(['gsettings','set','org.gnome.shell','enabled-extensions',str(cur)],check=True)
PY"
}

# ---------------------------------------------------------------- keyboard
gnome_keyboard() {
    say "GNOME extensions: Focused Window D-Bus + Run or Raise"
    run "gsettings set org.gnome.shell disable-user-extensions false"
    gnome-extensions info focused-window-dbus@flexagoon.com >/dev/null 2>&1 || install_extension 5592 focused-window-dbus@flexagoon.com
    gnome-extensions info run-or-raise@edvard.cz >/dev/null 2>&1 || install_extension 1336 run-or-raise@edvard.cz
    set_extensions +focused-window-dbus@flexagoon.com +run-or-raise@edvard.cz

    say "GNOME keyboard settings"
    # Caps = Ctrl when Toshy is off; both Shift keys = Caps Lock
    run "gsettings set org.gnome.desktop.input-sources xkb-options \"['ctrl:nocaps', 'shift:both_capslock']\""
    # Win tap does nothing; Activities on Shift+Ctrl+Space (Toshy sends it for Alt+Space)
    run "gsettings set org.gnome.mutter overlay-key ''"
    run "gsettings set org.gnome.shell.keybindings toggle-overview \"['<Shift><Control>space']\""
    # Alt+Tab switches apps, not windows
    run "gsettings set org.gnome.desktop.wm.keybindings switch-applications \"['<Super>Tab', '<Alt>Tab']\""
    run "gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward \"['<Shift><Super>Tab', '<Shift><Alt>Tab']\""
    run "gsettings set org.gnome.desktop.wm.keybindings switch-windows \"[]\""
    run "gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward \"[]\""
    run "gsettings set org.gnome.desktop.wm.keybindings close \"['<Alt>F4', '<Alt>q']\""
    # Ubuntu's Ctrl+Alt+T terminal shortcut off (Run or Raise uses it for kitty)
    run "gsettings set org.gnome.settings-daemon.plugins.media-keys terminal \"[]\""
    local base=org.gnome.settings-daemon.plugins.media-keys
    local kb=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings
    run "gsettings set $base custom-keybindings \"['$kb/copyq/', '$kb/screen-ocr/', '$kb/blank-screen/', '$kb/force-quit/']\""
    run "gsettings set $base.custom-keybinding:$kb/copyq/ name 'CopyQ'"
    run "gsettings set $base.custom-keybinding:$kb/copyq/ command 'copyq show'"
    run "gsettings set $base.custom-keybinding:$kb/copyq/ binding '<Shift><Control><Alt>v'"
    run "gsettings set $base.custom-keybinding:$kb/screen-ocr/ name 'Screen OCR'"
    run "gsettings set $base.custom-keybinding:$kb/screen-ocr/ command '$HOME/.local/bin/screen-ocr'"
    run "gsettings set $base.custom-keybinding:$kb/screen-ocr/ binding '<Shift><Super>t'"
    run "gsettings set $base.custom-keybinding:$kb/blank-screen/ name 'Blank screen'"
    run "gsettings set $base.custom-keybinding:$kb/blank-screen/ command '$HOME/.local/bin/blank-screen'"
    run "gsettings set $base.custom-keybinding:$kb/blank-screen/ binding '<Shift><Control><Alt>l'"
    run "gsettings set $base.custom-keybinding:$kb/force-quit/ name 'Force Quit (btop)'"
    run "gsettings set $base.custom-keybinding:$kb/force-quit/ command 'kitty --title \"Force Quit (btop)\" btop'"
    run "gsettings set $base.custom-keybinding:$kb/force-quit/ binding '<Shift><Control>Escape'"
    if gsettings list-schemas | grep -qx org.gnome.shell.extensions.dash-to-dock; then
        say "Ubuntu dock found: always auto-hide"
        run "gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false"
        run "gsettings set org.gnome.shell.extensions.dash-to-dock autohide true"
        run "gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false"
    fi

    if [ "$(cat /proc/sys/fs/inotify/max_user_watches)" -lt 524288 ]; then
        say "File-watch limit is low (VS Code + Toshy need more). Run this yourself:"
        echo "    echo 'fs.inotify.max_user_watches=524288' | sudo tee /etc/sysctl.d/60-inotify-watches.conf; sudo sysctl --system"
    fi
}

# Toshy rules: copy keyboard/toshy_user_apps.py into Toshy's config (its user_apps section)
toshy_rules() {
    local cfg="$HOME/.config/toshy/toshy_config.py"
    if [ ! -f "$cfg" ]; then
        echo "    Toshy is not installed yet. Install it (README.md, 'Keyboard'), log out and in,"
        echo "    then run ./setup.sh --only keyboard again to add the custom rules."
        return
    fi
    say "Toshy: your rules (keyboard/toshy_user_apps.py) and preferences"
    run "cp -a \"$cfg\" \"$cfg.bak-$(date +%Y%m%d-%H%M%S)\""
    run "python3 - \"$cfg\" \"$HERE/keyboard/toshy_user_apps.py\" <<'PY'
import re, sys
cfg, new = sys.argv[1], open(sys.argv[2]).read().rstrip('\n')
t = open(cfg).read()
pat = r'###  SLICE_MARK_START: user_apps .*?###  SLICE_MARK_END: user_apps [^\n]*'
if not re.search(pat, t, re.S): sys.exit('user_apps section not found in ' + cfg)
open(cfg, 'w').write(re.sub(pat, lambda m: new, t, count=1, flags=re.S))
PY"
    run "python3 - <<'PY'
import sqlite3, os
c = sqlite3.connect(os.path.expanduser('~/.config/toshy/toshy_user_preferences.sqlite'))
for k, v in [('capslock_mode','caps_is_esc_and_lctrl'),('l_cmd_is_sup_and_cmd','False'),('l_opt_is_sup_and_opt','False')]:
    c.execute('update config_preferences set value=? where name=?', (v, k))
c.commit()
PY"
    if have fish; then run "fish -c reload-shortcuts || true"; fi
}

# ---------------------------------------------------------------- desktops
gnome_desktops() {
    say "4 fixed desktops; Super+Alt+1..4 switches (Toshy sends it for Alt+Caps+1..4)"
    run "gsettings set org.gnome.mutter dynamic-workspaces false"
    run "gsettings set org.gnome.desktop.wm.preferences num-workspaces 4"
    for i in 1 2 3 4; do
        run "gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i \"['<Super><Alt>$i']\""
    done
    run "gsettings set org.gnome.shell disable-user-extensions false"
    # desktop-rules@local (app -> desktop rules) stays OFF: with it on, GNOME 46 crashed and logged out.
    # Turn it on by hand to try it: gnome-extensions enable desktop-rules@local
    set_extensions -desktop-rules@local -auto-move-windows@gnome-shell-extensions.gcampax.github.com

    say "Touchpad (Wayland): 3-finger left/right = window switcher, 4-finger left/right = desktops"
    local tgc=touchpad-gesture-customization@coooolapps.com
    gnome-extensions info $tgc >/dev/null 2>&1 || install_extension 7850 $tgc
    set_extensions +$tgc
    local tp=/org/gnome/shell/extensions/touchpad-gesture-customization
    run "dconf write $tp/horizontal-swipe-3-fingers-gesture \"'WINDOW_SWITCHING'\""
    run "dconf write $tp/horizontal-swipe-4-fingers-gesture \"'WORKSPACE_SWITCHING'\""
    run "dconf write $tp/vertical-swipe-3-fingers-gesture \"'OVERVIEW_NAVIGATION'\""
    # pinch off: its defaults close a tab / window (too easy to hit), and show-desktop pinch isn't
    # detected on GNOME 46 here (use Alt+F3)
    run "dconf write $tp/pinch-3-finger-gesture \"'NONE'\""
    run "dconf write $tp/pinch-4-finger-gesture \"'NONE'\""
}

# ---------------------------------------------------------------- lock
gnome_lock() {
    say "No password after screen blank or suspend (undo: autolock on). Alt+Caps+Q still locks."
    run "gsettings set org.gnome.desktop.screensaver lock-enabled false"
    run "gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false 2>/dev/null || true"
    echo "    Login without a password is separate and needs sudo: run 'autologin on' in fish if you want it."
}

# ---------------------------------------------------------------- teams
teams_settings() {
    local cfg="$HOME/.config/teams-for-linux/config.json"
    say "Teams for Linux: \"menubar\": \"hidden\" in $cfg (restart Teams to apply)"
    run "mkdir -p \"$(dirname "$cfg")\" && { [ -f \"$cfg\" ] && cp -a \"$cfg\" \"$cfg.bak\" || true; }"
    run "python3 - \"$cfg\" <<'PY'
import json, os, sys
p = sys.argv[1]
c = json.load(open(p)) if os.path.exists(p) and os.path.getsize(p) else {}
c['menubar'] = 'hidden'
json.dump(c, open(p, 'w'), indent=2)
PY"
}

# ---------------------------------------------------------------- reset to defaults
reset_keyboard_settings() {
    say "GNOME keyboard settings back to defaults"
    local k
    for k in "org.gnome.desktop.input-sources xkb-options" "org.gnome.mutter overlay-key" \
             "org.gnome.shell.keybindings toggle-overview" \
             "org.gnome.desktop.wm.keybindings switch-applications" "org.gnome.desktop.wm.keybindings switch-applications-backward" \
             "org.gnome.desktop.wm.keybindings switch-windows" "org.gnome.desktop.wm.keybindings switch-windows-backward" \
             "org.gnome.desktop.wm.keybindings close" "org.gnome.settings-daemon.plugins.media-keys terminal" \
             "org.gnome.settings-daemon.plugins.media-keys custom-keybindings"; do
        run "gsettings reset $k"
    done
    if gsettings list-schemas | grep -qx org.gnome.shell.extensions.dash-to-dock; then
        for k in dock-fixed autohide intellihide; do run "gsettings reset org.gnome.shell.extensions.dash-to-dock $k"; done
    fi
    set_extensions -run-or-raise@edvard.cz -focused-window-dbus@flexagoon.com
    local cfg="$HOME/.config/toshy/toshy_config.py"
    if [ -f "$cfg" ]; then
        say "Toshy: your rules removed (Toshy's built-in Mac keys stay; stop Toshy with toshy-services-stop)"
        run "cp -a \"$cfg\" \"$cfg.bak-$(date +%Y%m%d-%H%M%S)\""
        run "python3 - \"$cfg\" <<'PY'
import re, sys
cfg = sys.argv[1]
empty = '''###  SLICE_MARK_START: user_apps  ###  EDITS OUTSIDE THESE MARKS WILL BE LOST ON UPGRADE


keymap(\"User hardware keys\", {
    # PUT UNIVERSAL REMAPS FOR HARDWARE KEYS HERE
    # KEYMAP WILL BE ACTIVE IN ALL DESKTOP ENVIRONMENTS/DISTROS


}, when = lambda ctx:
    cnfg.screen_has_focus and
    not ctx_app_is_remote
)

###  SLICE_MARK_END: user_apps  ###  EDITS OUTSIDE THESE MARKS WILL BE LOST ON UPGRADE'''
t = open(cfg).read()
pat = r'###  SLICE_MARK_START: user_apps .*?###  SLICE_MARK_END: user_apps [^\n]*'
open(cfg, 'w').write(re.sub(pat, lambda m: empty, t, count=1, flags=re.S))
PY"
        if have toshy-services-restart; then run "toshy-services-restart >/dev/null 2>&1 || true"; fi
    fi
}

reset_desktops_settings() {
    say "Desktops back to GNOME defaults (dynamic desktops), app rules off"
    run "gsettings reset org.gnome.mutter dynamic-workspaces"
    run "gsettings reset org.gnome.desktop.wm.preferences num-workspaces"
    local i
    for i in 1 2 3 4; do run "gsettings reset org.gnome.desktop.wm.keybindings switch-to-workspace-$i"; done
    set_extensions -desktop-rules@local -touchpad-gesture-customization@coooolapps.com
    run "dconf reset -f /org/gnome/shell/extensions/touchpad-gesture-customization/"
}

reset_lock_settings() {
    say "Screen lock back to defaults (password after blank and suspend)"
    run "gsettings reset org.gnome.desktop.screensaver lock-enabled"
    run "gsettings reset org.gnome.desktop.screensaver ubuntu-lock-on-suspend 2>/dev/null || true"
}

reset_teams_settings() {
    local cfg="$HOME/.config/teams-for-linux/config.json"
    [ -f "$cfg" ] || return 0
    say "Teams for Linux: menubar setting removed (back to default)"
    run "python3 - \"$cfg\" <<'PY'
import json, sys
p = sys.argv[1]
c = json.load(open(p)); c.pop('menubar', None)
json.dump(c, open(p, 'w'), indent=2)
PY"
}
