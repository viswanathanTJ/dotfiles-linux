# Keyboard and shortcuts: full setup and rebuild guide

Mac-style keys on Ubuntu 24.04 (GNOME 46, Wayland) with **Toshy**, GNOME settings and the **Run or Raise** extension. Every config below is copied verbatim from the live machine on **2026-10-15**, so this file alone is enough to rebuild the setup on a new machine.

Interactive version with a filterable cheatsheet: `~/claude/keyboard-wiki.html` (also published as a private page).

Commands are for the **fish** shell.

## Your keys

Toshy maps keys by **position**, like a Mac keyboard (`Control · Option · Command · space`). This PC keyboard's bottom-left row is `Ctrl · Win · Alt · space`:

| Physical key | Acts as | Notes |
|---|---|---|
| **Caps Lock** | Hold = **real Ctrl**, **double tap = Esc**, single tap = nothing | Toshy CapsLock Mode "caps_is_caps" (Toshy leaves the key alone) + custom "User Caps tap F16 / hold Ctrl" and "User Caps double tap" |
| **Left Ctrl** | Mac **Control** | Real Ctrl in terminals; Mac-style in apps (Ctrl+A / E = line start / end) |
| **Win** | **Option** | Word jumps. Win+1…9 = dock apps (like Windows). Tapping it does nothing |
| **Left Alt** | **Cmd** | Copy, paste, tabs, quit, app switching |
| **Both Shift keys** | Real **Caps Lock** | GNOME option `shift:both_capslock` |

Toshy's internal names in its config: `RC` = Cmd (Toshy turns Alt into Right Ctrl), `LC` = a real Ctrl (Caps held), `Super` = Mac Control (Left Ctrl in apps), `Alt` = Option (Win).

## Cheatsheet

| Press | Does | Implemented by |
|---|---|---|
| Alt+C / V / X | Copy / paste / cut (terminals too) | Toshy |
| Alt+Z / Alt+Shift+Z | Undo / redo | Toshy |
| Alt+A / S / F | Select all / save / find | Toshy |
| Alt+T / W / N | New tab / close tab / new window | Toshy |
| Alt+Q | Quit / close window (Alt+F4) | Toshy (GNOME `close` also has `<Alt>q`) |
| **Alt+1…9** | Tab 1–9 in Chrome, VS Code and kitty (Cmd+number, like a Mac) | Toshy default → Ctrl+number; kitty `map ctrl+N goto_tab N` |
| **Left Ctrl+1…4**, Caps+1…4 | Go to desktop 1–4 (Mac Control+number), in every app | Toshy "User desktop numbers" → Super+Alt+N → GNOME |
| **Left Ctrl+← / →** | Desktop to the left / right (apps only; in terminals Ctrl+arrows jump words) | Toshy "User desktop arrows" → Super+Page Up/Down |
| Caps+Tab, Left Ctrl+Tab | Next tab (add Shift for previous) | Toshy custom "User tab switching" (apps) and "User terminal tab switching" (terminals) |
| Alt+Shift+[ / ] | Previous / next tab | Toshy |
| **Alt+Space** | **Activities / Launchpad** | Toshy → Shift+Ctrl+Space → GNOME `toggle-overview` |
| **Alt+Tab** | Switch **apps** (one icon per app) | Toshy → Alt+Tab → GNOME `switch-applications` |
| Alt+` | Switch windows of the same app | Toshy → GNOME `switch-group` |
| **Win+1…9** | Open or switch to dock app 1–9 (like Windows) | Toshy "User dock apps" → Super+1…9 → GNOME dock |
| Alt+H / Alt+Ctrl+F / Alt+F3 | Hide / maximise / show desktop | Toshy |
| **Alt+Caps+Enter** | Maximise / restore the window (Alt+Left Ctrl+Enter too) | Toshy → Alt+F10 → GNOME |
| **Alt+Shift+H / L** | Switch to the desktop (workspace) on the left / right. In VS Code this replaces Alt+Shift+L "select all occurrences" (use Ctrl+F2) | Toshy → Super+Page Up/Down → GNOME |
| **Alt+Win+H / L** | Move the window to the previous / next desktop (you go with it; a new desktop is made past the last one) | Toshy → Super+Shift+Page Up/Down → GNOME |
| **Alt+Caps+1…4** | Go to desktop 1–4 (4 fixed desktops) | Toshy → Super+Alt+1…4 → GNOME `switch-to-workspace-N` |
| **Caps+Shift+Esc**, Left Ctrl+Shift+Esc | **Force Quit**: opens btop in kitty (f filter, e tree, t terminate, k kill, q quit) | GNOME custom "Force Quit (btop)" on Ctrl+Shift+Esc (`kitty --title "Force Quit (btop)" btop`); Toshy rule `Shift-Super-Esc` for Left Ctrl in apps |
| **Alt+Caps+L** | **Blank the screen**, no password to wake (while `autolock off`) | Toshy → Ctrl+Alt+Shift+L → GNOME custom "Blank screen" (`~/.local/bin/blank-screen`) |
| **Alt+Caps+Q** | **Lock the screen**, like macOS ⌃⌘Q (Alt + Left Ctrl + Q works too) | Toshy → Super+L → GNOME `media-keys screensaver` |
| **Alt+Caps+B** or **X** | Focus or launch **Chrome** | Toshy → Ctrl+Alt+B → Run or Raise |
| **Alt+Caps+C** | Focus or launch **VS Code** | Toshy → Ctrl+Alt+C → Run or Raise |
| **Alt+Caps+T** or **K** | Focus or launch **kitty** | Toshy → Ctrl+Alt+T / K → Run or Raise |
| **Alt+Caps+W** | Focus or launch **ZapZap** | Toshy → Ctrl+Alt+W → Run or Raise |
| **Alt+Caps+M** | Focus or launch **Teams for Linux** | Toshy → Ctrl+Alt+M → Run or Raise |
| **Alt+Caps+E** | Teams: search box (Teams shows Ctrl+Alt+E) | Toshy → Ctrl+Alt+E → Teams |
| **Alt+Shift+2** | **Screen OCR**: select an area, its text is copied | Toshy → Super+Shift+T → GNOME custom "Screen OCR" |
| Alt+Shift+3 / 4 / 5 | Screenshot: screen / window / tool | Toshy → Shift+Print / Alt+Print / Print |
| **Alt+Shift+V** | Open **CopyQ** | Toshy → Ctrl+Alt+Shift+V → GNOME custom "CopyQ" |
| Alt+← / → , Alt+↑ / ↓ | Line start / end, document start / end | Toshy |
| Win+← / → | Previous / next word | Toshy |
| Win+Backspace / Alt+Backspace | Delete word / delete to line start | Toshy |
| Caps+W, Left Ctrl+W (apps, Chrome too) | Delete word left, like Ctrl+W on a Mac. Close a tab with Alt+W (Cmd+W) | Toshy custom "User Caps word erase" |
| **Caps+L (Chrome)** | Edit the address bar (same as Alt+L / Ctrl+L) | Toshy custom "User Chrome Caps" |
| **Caps+H / J / K / L** | ← ↓ ↑ → arrows, vim style (add Shift to select). Apps only; in terminals they stay real Ctrl | Toshy "User Caps vim arrows" |
| Left Ctrl+J (VS Code) | Join lines (Mac Control+J); Alt+J (Cmd+J) toggles the panel | Toshy → Super+J → VS Code `meta+j` |
| Caps+C or Left Ctrl+C (terminal) | Stop the running program | Toshy |
| Alt+. (terminal) | Stop the running program | Toshy |
| Bottom screen edge | Show the dock (always auto-hides) | GNOME dash-to-dock `intellihide=false` |

## How it works

```
Keyboard ──► Toshy ──────────────────► GNOME ──────────────────► Extension / app
Alt+Caps+B   Alt=Cmd (RC),              Ctrl+Alt+B is a          Run or Raise: Chrome open?
             Caps held=Ctrl (LC),       Run or Raise shortcut    yes → focus it
             rule RC-LC-b → Ctrl+Alt+B                           no  → gtk-launch google-chrome
```

| Layer | What it is | Notes |
|---|---|---|
| **Toshy** | Keymapper service (`toshy-config.service`). Grabs the keyboard and re-sends keys through a virtual keyboard (`XWayKeyz`) | Knows the focused app through the **Focused Window D-Bus** extension, so terminals and apps get different rules. Your rules live between `SLICE_MARK` lines, which Toshy upgrades keep |
| **GNOME settings** | dconf, changed with `gsettings`; apply instantly | GNOME sees keys **after** Toshy. A GNOME keyboard option is invisible to Toshy's rules |
| **Run or Raise** | GNOME Shell extension | On Wayland only extensions can focus other apps' windows. Listens for Ctrl+Alt+letter |
| **GNOME custom shortcuts** | Run a command for a key | CopyQ (`copyq show`), Screen OCR (`~/.local/bin/screen-ocr`) |

## Rebuild on a new machine

### 1. Allow user extensions

```fish
gsettings set org.gnome.shell disable-user-extensions false
```

A master switch that, when `true`, silently disables every extension you install.

### 2. Install the GNOME extensions (GNOME 46 versions)

```fish
curl -fL -o /tmp/focused-window-dbus.zip "https://extensions.gnome.org/download-extension/focused-window-dbus@flexagoon.com.shell-extension.zip?version_tag=62865"
gnome-extensions install --force /tmp/focused-window-dbus.zip
curl -fL -o /tmp/run-or-raise.zip "https://extensions.gnome.org/download-extension/run-or-raise@edvard.cz.shell-extension.zip?version_tag=75680"
gnome-extensions install --force /tmp/run-or-raise.zip
```

Create `~/.config/run-or-raise/shortcuts.conf` (step 6) **before** enabling Run or Raise, otherwise it copies in its own example shortcuts. Then **log out and back in** (Wayland loads new extensions only at login) and enable both:

```fish
gnome-extensions enable focused-window-dbus@flexagoon.com
gnome-extensions enable run-or-raise@edvard.cz
```

Other GNOME versions: look up the right download at `https://extensions.gnome.org/extension-info/?pk=5592&shell_version=NN` (Focused Window D-Bus) and `pk=1336` (Run or Raise); `gnome-shell --version` shows NN.

### 3. Install Toshy

Run as your normal user (not with sudo); the installer asks for the sudo password itself. Log out and back in afterwards.

```fish
curl -fL -o /tmp/toshy.zip https://github.com/RedBearAK/toshy/archive/refs/heads/main.zip
unzip -o /tmp/toshy.zip -d ~/Downloads/
cd ~/Downloads/Toshy-main; ./setup_toshy.py install
```

### 4. Toshy preferences

In the tray icon → Preferences (or `toshy-gui`): CapsLock Mode **caps_is_caps** (leave Caps alone; your rules handle it); Super Tap Passthru **both off**. Or directly:

```fish
python3 -c 'import sqlite3,os
c=sqlite3.connect(os.path.expanduser("~/.config/toshy/toshy_user_preferences.sqlite"))
for k,v in [("capslock_mode","caps_is_caps"),("l_cmd_is_sup_and_cmd","False"),("l_opt_is_sup_and_opt","False")]:
    c.execute("update config_preferences set value=? where name=?",(v,k))
c.commit()'
```

All preferences on this machine (`~/.config/toshy/toshy_user_preferences.sqlite`, table `config_preferences`):

```
autoload_tray_icon = True
gui_dark_theme = True
gui_theme_mode = auto
override_kbtype = Auto-Adapt
overlay_mask = 255
optspec_layout = Disabled
forced_numpad = True
altgr_on_menu_key = True
media_arrows_fix = False
multi_lang = False
capslock_mode = caps_is_caps
Enter2Ent_Cmd = False
l_cmd_is_sup_and_cmd = False
l_opt_is_sup_and_opt = False
ST3_in_VSCode = False
swap_spotlight_and_input = False
```

### 5. Toshy custom rules

In `~/.config/toshy/toshy_config.py`, replace the `user_apps` section (from its `SLICE_MARK_START` line to its `SLICE_MARK_END` line) with this. The other user sections (`user_custom_modmaps`, `user_custom_functions`) stay empty.

```python
###  SLICE_MARK_START: user_apps  ###  EDITS OUTSIDE THESE MARKS WILL BE LOST ON UPGRADE


# Caps: hold = real Ctrl, single tap = nothing, quick double tap = Esc.
# Needs Toshy's CapsLock mode "caps_is_caps" (Toshy leaves the key alone, so this is the only Caps rule).
# Tap sends F16, an unused key that the keymap below always swallows; real Caps Lock = both Shift keys.
multipurpose_modmap("User Caps tap F16 / hold Ctrl", {
    Key.CAPSLOCK:               [Key.F16, Key.LEFT_CTRL]
}, when = lambda ctx:
    cnfg.screen_has_focus and
    not ctx_app_is_remote
)

# Double-tap window for isDoubleTap (Toshy's default 0.24 s, doubled). Set here, inside the
# user_apps section, so it survives Toshy upgrades.
tapInterval = 0.48

keymap("User Caps double tap", {
    # isDoubleTap sends Esc the moment the 2nd tap lands (MultiTap waited another 0.25 s
    # for a possible 3rd tap). Taps must be within tapInterval (above); a single tap does nothing.
    C("F16"): isDoubleTap(C("Esc")),
}, when = lambda ctx:
    cnfg.screen_has_focus and
    not ctx_app_is_remote
)


keymap("User app launchers", {
    # Cmd+Ctrl+B (physical Alt + Caps, or Alt + Left Ctrl) -> Ctrl+Alt+B,
    # which the GNOME "Run or Raise" extension uses to focus or launch Chrome.
    C("RC-LC-b"):               C("C-Alt-b"),                   # Caps held = literal Ctrl (Caps mode esc_and_lctrl)
    C("RC-Super-b"):            C("C-Alt-b"),                   # physical Left Ctrl in GUI apps (Mac Control = Super)
    C("RC-LC-c"):            C("C-Alt-c"),                   # VS Code
    C("RC-Super-c"):         C("C-Alt-c"),
    C("RC-LC-t"):            C("C-Alt-t"),                   # kitty
    C("RC-Super-t"):         C("C-Alt-t"),
    C("RC-LC-k"):            C("C-Alt-k"),                   # kitty (second key)
    C("RC-Super-k"):         C("C-Alt-k"),
    C("RC-LC-w"):            C("C-Alt-w"),                   # ZapZap
    C("RC-Super-w"):         C("C-Alt-w"),
    C("RC-LC-m"):            C("C-Alt-m"),                   # Teams for Linux
    C("RC-Super-m"):         C("C-Alt-m"),
    C("RC-LC-e"):            C("C-Alt-e"),                   # Teams: search (Ctrl+Alt+E)
    C("RC-Super-e"):         C("C-Alt-e"),
    C("RC-LC-x"):            C("C-Alt-x"),                   # Chrome (second key)
    C("RC-Super-x"):         C("C-Alt-x"),
    # Alt+Caps+L (or Alt+Left Ctrl+L) -> Ctrl+Alt+Shift+L = GNOME shortcut "Blank screen"
    # (~/.local/bin/blank-screen; no password while `autolock off`)
    C("RC-LC-l"):            C("C-Alt-Shift-l"),
    C("RC-Super-l"):         C("C-Alt-Shift-l"),
    # Cmd+Ctrl+Q (Alt+Caps+Q or Alt+Left Ctrl+Q), the macOS lock shortcut -> Super+L = GNOME lock screen
    C("RC-LC-q"):            C("Super-l"),
    C("RC-Super-q"):         C("Super-l"),
    # Left Ctrl+Shift+Esc -> Ctrl+Shift+Esc = GNOME shortcut "Force Quit (btop)". In apps Toshy sends
    # physical Left Ctrl as Super, so it needs this rule; Caps (real Ctrl) and terminals pass through.
    C("Shift-Super-Esc"):       C("C-Shift-Esc"),
    # Alt+Caps+Enter (or Alt+Left Ctrl+Enter) -> Alt+F10 = GNOME maximize / restore the window
    C("RC-LC-Enter"):           C("Alt-F10"),
    C("RC-Super-Enter"):        C("Alt-F10"),
    # Alt+Shift+H / L -> Super+Page Up / Down = GNOME switch to the desktop (workspace) on the left / right
    C("Shift-RC-h"):            C("Super-Page_Up"),
    C("Shift-RC-l"):            C("Super-Page_Down"),
    # Alt+Win+H / L (Cmd+Option) -> Super+Shift+Page Up / Down = GNOME move the window to the previous / next desktop
    C("RC-Alt-h"):              C("Shift-Super-Page_Up"),
    C("RC-Alt-l"):              C("Shift-Super-Page_Down"),
    # Alt+Caps+1..4 (or Alt+Left Ctrl+1..4) -> Super+Alt+1..4 = GNOME switch to desktop 1..4
    C("RC-LC-Key_1"):           C("Super-Alt-Key_1"),
    C("RC-LC-Key_2"):           C("Super-Alt-Key_2"),
    C("RC-LC-Key_3"):           C("Super-Alt-Key_3"),
    C("RC-LC-Key_4"):           C("Super-Alt-Key_4"),
    C("RC-Super-Key_1"):        C("Super-Alt-Key_1"),
    C("RC-Super-Key_2"):        C("Super-Alt-Key_2"),
    C("RC-Super-Key_3"):        C("Super-Alt-Key_3"),
    C("RC-Super-Key_4"):        C("Super-Alt-Key_4"),
    # Cmd+Shift+V (Alt+Shift+V) -> Ctrl+Alt+Shift+V = GNOME shortcut that opens CopyQ.
    # Plain Cmd+V stays paste (Ctrl+V in apps, Ctrl+Shift+V in terminals).
    C("Shift-RC-v"):            C("C-Alt-Shift-v"),
    # Cmd+Shift+2 (Alt+Shift+2) -> Super+Shift+T = GNOME shortcut "Screen OCR"
    # (select an area, its text is copied). Next to macOS screenshot keys Cmd+Shift+3/4/5.
    C("Shift-RC-Key_2"):        C("Super-Shift-t"),
}, when = lambda ctx:
    cnfg.screen_has_focus and
    not ctx_app_is_remote
)

keymap("User tab switching", {
    # Caps held = literal Ctrl (Caps mode esc_and_lctrl). Make Caps+Tab switch tabs
    # in GUI apps like Ctrl+Tab, same as physical Left Ctrl+Tab (Mac Control+Tab).
    C("LC-Tab"):                [bind,C("C-Tab")],              # next tab
    C("Shift-LC-Tab"):          [bind,C("Shift-C-Tab")],        # previous tab
}, when = lambda ctx:
    cnfg.screen_has_focus and
    not ctx_app_is_terminal and not ctx_app_is_remote
)

keymap("User terminal tab switching", {
    # Ctrl+Tab / Ctrl+Shift+Tab = next/previous tab in kitty (Toshy's "General Terminals" rule sends Ctrl+PageDown/PageUp,
    # which kitty ignores), with `bind` so Ctrl stays held. Without bind, Caps (tap Esc / hold Ctrl)
    # + Tab left Ctrl stuck in kitty, and later keys arrived as Ctrl+key.
    C("LC-Tab"):                [bind,C("C-Tab")],              # next tab (kitty: ctrl+tab)
    C("Shift-LC-Tab"):          [bind,C("Shift-C-Tab")],        # previous tab (kitty: ctrl+shift+tab)
}, when = lambda ctx:
    cnfg.screen_has_focus and
    ctx_app_is_terminal
)

keymap("User Chrome Caps", {
    # Chrome only, checked before the Caps word-erase and vim-arrow rules below.
    # Caps+L = address bar (like Alt+L / Ctrl+L). Caps+W erases a word, as in other apps;
    # close the tab with Alt+W (Cmd+W).
    C("LC-l"):                  C("C-l"),                       # focus and select the address bar
}, when = lambda ctx:
    cnfg.screen_has_focus and
    hmp_is_chrome_browser(ctx) )

keymap("User Caps word erase", {
    # Caps held = literal Linux Ctrl (Caps mode esc_and_lctrl), so in apps Caps+W was
    # Ctrl+W = close tab. On a Mac, Ctrl+W never closes; Cmd+W (Alt+W) does.
    # Make Caps+W erase the previous word, like Ctrl+W in a terminal.
    C("LC-w"):                  C("C-Backspace"),               # erase previous word (Caps+W)
    C("Super-w"):               C("C-Backspace"),               # same for physical Left Ctrl+W (Mac Control)
}, when = lambda ctx:
    cnfg.screen_has_focus and
    not ctx_app_is_terminal and not ctx_app_is_remote
)

keymap("User desktop numbers", {
    # Mac Control+1..4 = desktop 1..4: physical Left Ctrl (Super in apps, Ctrl in terminals) or Caps (Ctrl)
    # -> Super+Alt+1..4 = GNOME switch-to-workspace-1..4. Tabs by number are on Alt (Cmd) + 1..9.
    C("Super-Key_1"):           C("Super-Alt-Key_1"),
    C("Super-Key_2"):           C("Super-Alt-Key_2"),
    C("Super-Key_3"):           C("Super-Alt-Key_3"),
    C("Super-Key_4"):           C("Super-Alt-Key_4"),
    C("LC-Key_1"):              C("Super-Alt-Key_1"),
    C("LC-Key_2"):              C("Super-Alt-Key_2"),
    C("LC-Key_3"):              C("Super-Alt-Key_3"),
    C("LC-Key_4"):              C("Super-Alt-Key_4"),
}, when = lambda ctx:
    cnfg.screen_has_focus and
    not ctx_app_is_remote
)

keymap("User desktop arrows", {
    # Mac Control+Left/Right = desktop left/right (apps only; in terminals Ctrl+Left/Right jumps words)
    C("Super-Left"):            C("Super-Page_Up"),
    C("Super-Right"):           C("Super-Page_Down"),
}, when = lambda ctx:
    cnfg.screen_has_focus and
    not ctx_app_is_terminal and not ctx_app_is_remote
)

keymap("User dock apps", {
    # Win (Option) + 1..9 -> Super+1..9 = open or switch to dock app 1..9 (like Windows).
    # Alt (Cmd) + 1..9 is left to Toshy's default, Ctrl+1..9 = tab 1..9 in Chrome, VS Code, kitty (like a Mac).
    C("Alt-Key_1"):             C("Super-Key_1"),
    C("Alt-Key_2"):             C("Super-Key_2"),
    C("Alt-Key_3"):             C("Super-Key_3"),
    C("Alt-Key_4"):             C("Super-Key_4"),
    C("Alt-Key_5"):             C("Super-Key_5"),
    C("Alt-Key_6"):             C("Super-Key_6"),
    C("Alt-Key_7"):             C("Super-Key_7"),
    C("Alt-Key_8"):             C("Super-Key_8"),
    C("Alt-Key_9"):             C("Super-Key_9"),
}, when = lambda ctx:
    cnfg.screen_has_focus and
    not ctx_app_is_remote
)

keymap("User Caps vim arrows", {
    # Caps (held = real Ctrl) + H/J/K/L = arrow keys, like a vim-style Mac setup.
    # Apps only: in terminals Ctrl+H/J/K/L stay real Ctrl (backspace, newline, Neovim window moves).
    # The Ctrl+H/J/K/L app shortcuts stay reachable with Alt (Cmd) + H/J/K/L.
    C("LC-h"):                  C("Left"),
    C("LC-j"):                  C("Down"),
    C("LC-k"):                  C("Up"),
    C("LC-l"):                  C("Right"),
    C("Shift-LC-h"):            C("Shift-Left"),                # select
    C("Shift-LC-j"):            C("Shift-Down"),
    C("Shift-LC-k"):            C("Shift-Up"),
    C("Shift-LC-l"):            C("Shift-Right"),
    # Caps+A / Caps+F = start / end of line (add Shift to select). Find stays on Alt+F, select all on Alt+A.
    C("LC-a"):                  C("Home"),
    C("LC-f"):                  C("End"),
    C("Shift-LC-a"):            C("Shift-Home"),
    C("Shift-LC-f"):            C("Shift-End"),
}, when = lambda ctx:
    cnfg.screen_has_focus and
    not ctx_app_is_terminal and not ctx_app_is_remote
)

keymap("User hardware keys", {
    # PUT UNIVERSAL REMAPS FOR HARDWARE KEYS HERE
    # KEYMAP WILL BE ACTIVE IN ALL DESKTOP ENVIRONMENTS/DISTROS


}, when = lambda ctx:
    cnfg.screen_has_focus and
    not ctx_app_is_remote
)

###  SLICE_MARK_END: user_apps  ###  EDITS OUTSIDE THESE MARKS WILL BE LOST ON UPGRADE
```

### 6. Run or Raise config

`~/.config/run-or-raise/shortcuts.conf`. Format: `shortcut,command,[window-class regex],[title]`. `gtk-launch` uses the app's menu entry, so launcher flags (like the Wayland flag) are kept.

```
# Run or raise: shortcut,command,[wm_class],[title]
# Focus an existing window whose wm_class matches, otherwise run the command.
# To reload after editing: gnome-extensions disable run-or-raise@edvard.cz && gnome-extensions enable run-or-raise@edvard.cz

# Ctrl+Alt+B (Alt+Caps+B): Chrome. Exact wm_class, so Chrome web apps (Outlook, Teams) aren't matched.
<Control><Alt>b,gtk-launch google-chrome,/^[Gg]oogle-chrome$/,
<Control><Alt>x,gtk-launch google-chrome,/^[Gg]oogle-chrome$/,

# Ctrl+Alt+C (Alt+Caps+C): VS Code
<Control><Alt>c,gtk-launch com.microsoft.VSCode,/^(code|Code|com\.microsoft\.VSCode)$/,
# Ctrl+Alt+T (Alt+Caps+T): kitty
<Control><Alt>t,gtk-launch kitty,/^kitty$/,
<Control><Alt>k,gtk-launch kitty,/^kitty$/,
# Ctrl+Alt+W (Alt+Caps+W): ZapZap (WhatsApp)
<Control><Alt>w,gtk-launch com.rtosta.zapzap,/^(zapzap|ZapZap|com\.rtosta\.zapzap)$/,
# Ctrl+Alt+M (Alt+Caps+M): Teams for Linux
<Control><Alt>m,gtk-launch teams-for-linux,/^teams-for-linux$/,
```

### 7. GNOME settings

Safe to re-run.

```fish
# Keyboard options: Caps = Ctrl (when Toshy is off), both Shift keys = Caps Lock
gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps', 'shift:both_capslock']"
# Win tap does nothing (Toshy default); Activities on Shift+Ctrl+Space = Alt+Space via Toshy
gsettings set org.gnome.mutter overlay-key ''
gsettings set org.gnome.shell.keybindings toggle-overview "['<Shift><Control>space']"
# Alt+Tab switches apps, not windows
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab', '<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab', '<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "[]"
# Alt+Q closes the window also without Toshy
gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>F4', '<Alt>q']"
# Ubuntu's Ctrl+Alt+T terminal shortcut off (Run or Raise uses Ctrl+Alt+T for kitty)
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "[]"
# Custom shortcuts: CopyQ and Screen OCR
set base org.gnome.settings-daemon.plugins.media-keys
set kb /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings
gsettings set $base custom-keybindings "['$kb/copyq/', '$kb/screen-ocr/', '$kb/blank-screen/', '$kb/force-quit/']"
gsettings set $base.custom-keybinding:$kb/copyq/ name 'CopyQ'
gsettings set $base.custom-keybinding:$kb/copyq/ command 'copyq show'
gsettings set $base.custom-keybinding:$kb/copyq/ binding '<Shift><Control><Alt>v'
gsettings set $base.custom-keybinding:$kb/screen-ocr/ name 'Screen OCR'
gsettings set $base.custom-keybinding:$kb/screen-ocr/ command "$HOME/.local/bin/screen-ocr"
gsettings set $base.custom-keybinding:$kb/screen-ocr/ binding '<Shift><Super>t'
gsettings set $base.custom-keybinding:$kb/blank-screen/ name 'Blank screen'
gsettings set $base.custom-keybinding:$kb/blank-screen/ command "$HOME/.local/bin/blank-screen"
gsettings set $base.custom-keybinding:$kb/blank-screen/ binding '<Shift><Control><Alt>l'
gsettings set $base.custom-keybinding:$kb/force-quit/ name 'Force Quit (btop)'
gsettings set $base.custom-keybinding:$kb/force-quit/ command 'kitty --title "Force Quit (btop)" btop'
gsettings set $base.custom-keybinding:$kb/force-quit/ binding '<Shift><Control>Escape'
# Dock always auto-hides
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false
# 4 fixed desktops; Super+Alt+1..4 switches to them (Toshy sends it for Alt+Caps+1..4)
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 4
for i in 1 2 3 4; gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super><Alt>$i']"; end
```

Current values on this machine (`dconf dump`; includes a few settings not made by this setup, such as edge tiling):

```ini
# /org/gnome/desktop/input-sources/
[/]
sources=[('xkb', 'us')]
xkb-options=['ctrl:nocaps', 'shift:both_capslock']

# /org/gnome/mutter/
[/]
edge-tiling=false
experimental-features=['x11-randr-fractional-scaling', 'scale-monitor-framebuffer']
overlay-key=''

[keybindings]
toggle-tiled-left=@as []
toggle-tiled-right=@as []

# /org/gnome/shell/keybindings/
[/]
toggle-overview=['<Shift><Control>space']

# /org/gnome/desktop/wm/keybindings/
[/]
close=['<Alt>F4', '<Alt>q']
switch-applications=['<Super>Tab', '<Alt>Tab']
switch-applications-backward=['<Shift><Super>Tab', '<Shift><Alt>Tab']
switch-windows=@as []
switch-windows-backward=@as []

# /org/gnome/settings-daemon/plugins/media-keys/
[/]
custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/copyq/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/screen-ocr/']
terminal=@as []

[custom-keybindings/copyq]
binding='<Shift><Control><Alt>v'
command='copyq show'
name='CopyQ'

[custom-keybindings/screen-ocr]
binding='<Shift><Super>t'
command='$HOME/.local/bin/screen-ocr'
name='Screen OCR'

# /org/gnome/shell/extensions/dash-to-dock/
[/]
dash-max-icon-size=48
dock-fixed=false
dock-position='BOTTOM'
extend-height=false
intellihide=false
show-trash=false

# enabled extensions
['ding@rastersoft.com', 'tiling-assistant@ubuntu.com', 'focused-window-dbus@flexagoon.com', 'ubuntu-dock@ubuntu.com', 'run-or-raise@edvard.cz']
```

### 8. CopyQ

```fish
sudo apt install copyq
```

Start it once and turn on Preferences → Autostart. Then edit the `Exec` line of `~/.config/autostart/copyq.desktop` so CopyQ runs through XWayland and can see clipboard changes on Wayland:

```
Exec=env QT_QPA_PLATFORM=xcb /usr/bin/copyq
```

### 9. Screen OCR

```fish
sudo apt install tesseract-ocr tesseract-ocr-eng wl-clipboard libnotify-bin
sudo apt-mark manual tesseract-ocr
```

Save as `~/.local/bin/screen-ocr`, then `chmod +x ~/.local/bin/screen-ocr`:

```python
#!/usr/bin/python3 -I
"""Select a screen area, OCR it with Tesseract and copy the text (works on GNOME Wayland).

Uses the xdg-desktop-portal Screenshot API, which opens GNOME's own screenshot
tool, so it works where X11 screen grabbing (dpScreenOCR) does not.
Language: OCR_LANG env var, default "eng" (e.g. OCR_LANG=eng+tam).
"""
import os
import subprocess
import urllib.parse

import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib

LANG = os.environ.get("OCR_LANG", "eng")
PORTAL = "org.freedesktop.portal.Desktop"


def notify(title, body=""):
    subprocess.run(["notify-send", "-a", "Screen OCR", "-i", "edit-copy", title, body[:200]])


bus = Gio.bus_get_sync(Gio.BusType.SESSION)
loop = GLib.MainLoop()
result = {}
token = f"screenocr{os.getpid()}"
sender = bus.get_unique_name()[1:].replace(".", "_")
request_path = f"/org/freedesktop/portal/desktop/request/{sender}/{token}"


def on_response(conn, snd, path, iface, signal, params):
    code, results = params.unpack()
    result["code"] = code
    result["uri"] = results.get("uri")
    loop.quit()


bus.signal_subscribe(PORTAL, "org.freedesktop.portal.Request", "Response", request_path,
                     None, Gio.DBusSignalFlags.NONE, on_response)
bus.call_sync(PORTAL, "/org/freedesktop/portal/desktop", "org.freedesktop.portal.Screenshot",
              "Screenshot",
              GLib.Variant("(sa{sv})", ("", {"handle_token": GLib.Variant("s", token),
                                             "interactive": GLib.Variant("b", True)})),
              None, Gio.DBusCallFlags.NONE, -1, None)
GLib.timeout_add_seconds(120, loop.quit)
loop.run()

if result.get("code") != 0 or not result.get("uri"):
    raise SystemExit(0)  # cancelled

image = urllib.parse.unquote(urllib.parse.urlparse(result["uri"]).path)
try:
    ocr = subprocess.run(["tesseract", image, "-", "-l", LANG],
                         capture_output=True, text=True)
finally:
    os.remove(image)  # the portal saves a copy in ~/Pictures/Screenshots

text = ocr.stdout.strip()
if not text:
    notify("No text found", ocr.stderr.strip())
    raise SystemExit(1)

subprocess.run(["wl-copy"], input=text, text=True)
notify("Text copied", text)
```

### 10. reload-shortcuts

Save as `~/.config/fish/functions/reload-shortcuts.fish`. Run `reload-shortcuts` after editing the Toshy or Run or Raise config. It checks the Toshy config for typos first, so a mistake can't leave the keyboard unmapped.

```fish
function reload-shortcuts --description 'Reload Run or Raise and Toshy after editing their configs'
    # Check the Toshy config first: a typo would stop Toshy and leave the keyboard unmapped
    set -l cfg ~/.config/toshy/toshy_config.py
    if not ~/.config/toshy/.venv/bin/python -I -m py_compile $cfg
        echo "Toshy config has an error (see above); nothing reloaded."
        return 1
    end
    rm -f ~/.config/toshy/__pycache__/toshy_config.*.pyc

    # Every Ctrl+Alt+<letter> in Run or Raise needs a Toshy rule RC-LC-<letter> (Alt+Caps+<letter>),
    # otherwise Toshy sends Alt+Caps+<letter> as Ctrl+<letter> and Run or Raise never sees it
    for key in (string match -rg '^<Control><Alt>([a-z0-9])' < ~/.config/run-or-raise/shortcuts.conf)
        if not string match -q "*C(\"RC-LC-$key\")*" < $cfg
            echo "Warning: Run or Raise has Ctrl+Alt+$key but Toshy has no rule for Alt+Caps+$key."
            echo "  Add to keymap \"User app launchers\" in $cfg:"
            echo "    C(\"RC-LC-$key\"):            C(\"C-Alt-$key\"),"
            echo "    C(\"RC-Super-$key\"):         C(\"C-Alt-$key\"),"
        end
    end

    # Run or Raise reads ~/.config/run-or-raise/shortcuts.conf only when it starts
    gnome-extensions disable run-or-raise@edvard.cz
    sleep 1
    gnome-extensions enable run-or-raise@edvard.cz
    # never leave it switched off (Alt+Caps+letter would stop opening apps)
    if not gnome-extensions info run-or-raise@edvard.cz | string match -q '*Enabled: Yes*'
        sleep 1
        gnome-extensions enable run-or-raise@edvard.cz
    end
    if not gnome-extensions info run-or-raise@edvard.cz | string match -q '*Enabled: Yes*'
        echo "Run or Raise is still off. Run: gnome-extensions enable run-or-raise@edvard.cz"
        return 1
    end

    toshy-services-restart >/dev/null 2>&1
    sleep 5
    if systemctl --user is-active --quiet toshy-config
        echo "Shortcuts reloaded (Run or Raise + Toshy)."
    else
        echo "Toshy did not start. Check: toshy-services-status"
        return 1
    end
end
```

### 11. Reload and test

```fish
reload-shortcuts
```

Test every row of the cheatsheet. If keys freeze: `toshy-services-stop`.

## Desktops and app rules

4 fixed desktops (`dynamic-workspaces false`, `num-workspaces 4`).

| Keys / gesture | Does |
|---|---|
| Alt+Caps+1…4 | Go to desktop 1–4 |
| Alt+Shift+H / L | Desktop to the left / right |
| Alt+Win+H / L | Move the window to the previous / next desktop |
| 3-finger swipe left / right (Wayland only) | App switcher, like Alt+Tab (Touchpad Gesture Customization extension) |
| 4-finger swipe left / right (Wayland only) | Desktop to the left / right |
| 3-finger swipe up, up again (Wayland only) | Overview (all desktops), then the app grid |

GNOME's touchpad gestures only work in a **Wayland** session. On the login screen, choose **Ubuntu** with the gear icon, not "Ubuntu on Xorg". Pinch gestures are off: they aren't detected reliably on GNOME 46 (show desktop: Alt+F3).

**App rules** (currently **off**: with it on, GNOME 46 crashed and logged out; turn on by hand with `gnome-extensions enable desktop-rules@local`) come from a small local extension, `~/.local/share/gnome-shell/extensions/desktop-rules@local/extension.js`:

| Desktop | Apps |
|---|---|
| 1 | Teams for Linux |
| 2 | Chrome |
| 3 | kitty, VS Code |
| 4 | Every other app (Chrome web apps such as Outlook too) |

- A window you open goes to its desktop and you go with it. For 15 seconds after login, windows still move but the screen doesn't jump.
- Dialogs, pop-ups, windows on all desktops, tray windows, CopyQ and the "Force Quit (btop)" window are left alone.
- To change the rules, edit `RULES` at the top of `extension.js`, then log out and in. (Wayland loads extension changes only at login.)
- Check: `gnome-extensions info desktop-rules@local | rg State` should say ACTIVE. Turn off: `gnome-extensions disable desktop-rules@local`.
- GNOME's own Auto Move Windows extension was tried first, but it can't do "everything else on desktop 4", so it's disabled.

## tmux at login

`~/.config/autostart/tmux-restore.desktop` runs `~/.local/bin/tmux-restore` at login. That starts the tmux server in the background (only if it isn't running), and tmux-continuum then restores the last save (taken every 5 minutes). Open kitty and run `tmux attach`.

Claude Code panes are resumed with their own conversations by the `tmux-assistant-resurrect` plugin. On tmux 3.4 its hooks never ran: it stores the path as `"$HOME"/…` and tmux hands that back as `"\$HOME"`. So `~/.tmux.conf` re-sets both hooks with a `~/…` path after tpm loads. Logs are in `~/.local/share/tmux/resurrect/assistant-save.log` and `assistant-restore.log`.

## Screen lock and login: `autolock`, `autologin`

Idle (5 min) and **Alt+Caps+L** only blank the screen while auto-lock is off; **Alt+Caps+Q** always locks with a password.

| Command | Does |
|---|---|
| `autolock off` | Idle blank, Alt+Caps+L and waking from **suspend** (lid close) need **no** password (`org.gnome.desktop.screensaver lock-enabled false` and `ubuntu-lock-on-suspend false`) |
| `autolock on` | Back to asking for the password after blank and suspend |
| `autolock status` | Shows both settings |

### Login screen: `autologin` (needs sudo)

| Command | Does |
|---|---|
| `autologin on` | Logs you in at boot with no password. Adds `AutomaticLoginEnable=true` and `AutomaticLogin=<you>` under `[daemon]` in `/etc/gdm3/custom.conf` (first run saves `custom.conf.bak`) |
| `autologin off` | Removes those two lines: the login screen asks again |
| `autologin status` | Shows whether it's on |

Things to know:
- The disk is encrypted (LUKS), so the **disk password at boot is still asked**. Auto-login only skips the second, GDM password.
- With auto-login, your password is never typed, so the **GNOME keyring stays locked**. Apps that store passwords there may ask for your password once after login.
- Anyone who opens the lid gets into your session, so only use it on a machine nobody else can reach.

`~/.local/bin/blank-screen` (GNOME custom shortcut "Blank screen", `<Shift><Control><Alt>l`):

```sh
#!/bin/sh
exec gdbus call --session --dest org.gnome.ScreenSaver --object-path /org/gnome/ScreenSaver \
     --method org.gnome.ScreenSaver.SetActive true >/dev/null
```

## Adding a new app shortcut

1. Find the app's menu entry and window class: `ls /usr/share/applications ~/.local/share/applications`, then `rg StartupWMClass <file>.desktop`.
2. Add to `shortcuts.conf`: `<Control><Alt>x,gtk-launch app-id,/^window-class$/,`
3. Add to the "User app launchers" keymap: `C("RC-LC-x"): C("C-Alt-x"),` and `C("RC-Super-x"): C("C-Alt-x"),`
4. Check the letter isn't a GNOME shortcut: `gsettings list-recursively org.gnome.settings-daemon.plugins.media-keys | rg -i "<Alt>x'"` (also `org.gnome.desktop.wm.keybindings`, `org.gnome.shell.keybindings`).
5. Run `reload-shortcuts`. It warns if a Ctrl+Alt+letter in `shortcuts.conf` has no matching Toshy rule.

## Editors (related key settings)

- **VS Code** (`~/.config/Code/User/settings.json`): `vscode-neovim.ctrlKeysForNormalMode` and `ctrlKeysForInsertMode` = `[]` (VS Code keeps every Ctrl shortcut); `vscode-neovim.compositeKeys` `jj` = Escape; `extensions.experimental.affinity` `asvetliakov.vscode-neovim: 1`; `editor.lineNumbers: relative`; `workbench.editorAssociations` `*.md` → `vscode.markdown.preview.editor`; `files.watcherExclude` with 32 dependency, cache and build folders (`**/node_modules`, `**/__pycache__`, `**/vendor`, `**/target`, `**/.gradle`, `**/dist`, `**/build`…).
- **VS Code** (`keybindings.json`): the Neovim extension's 18 `ctrl+w <key>` window chords removed (lines `{ "key": "ctrl+w q", "command": "-workbench.action.closeActiveEditor" }` and so on), so Ctrl+W closes Markdown previews.
- **VS Code** (`keybindings.json`): `{ "key": "meta+j", "command": "editor.action.joinLines", "when": "editorTextFocus && !editorReadonly" }`, so Left Ctrl+J (Mac Control, sent by Toshy as Super+J) joins lines. Caps+J is now the Down arrow.
- **Neovim**: `jj` = Escape, `Space zq` = close buffer, `softtabstop = 0`, autopairs `map_bs = false`, no `clipboard = unnamedplus`, plugins skipped inside VS Code (`if not vim.g.vscode`). Backup: `~/Documents/nvim-config.zip`.
- **kitty**: `copy_on_select yes`, `hide_window_decorations yes`, `map ctrl+shift+t new_tab_with_cwd`, `map ctrl+shift+enter new_window_with_cwd`, `map ctrl+shift+f5 load_config_file`.

## Decisions and pitfalls

| Choice | Why |
|---|---|
| Caps → Ctrl done **inside Toshy** | Toshy reads keys before GNOME's options. With only `ctrl:nocaps`, Toshy doesn't know Caps is Ctrl, so Alt+Caps+B wouldn't match. `ctrl:nocaps` stays set so Caps is Ctrl when Toshy is stopped |
| Toshy's **built-in** Caps mode | Hand-written Caps modmaps broke Enter, Backspace and Caps Lock |
| Caps+Tab in terminals: own rule with `bind` | Toshy's built-in terminal rule `C("LC-Tab"): C("C-PAGE_DOWN")` has no `bind` (with the Caps tap/hold key it left Ctrl stuck in kitty), and kitty doesn't use Ctrl+PageDown for tabs. The user rule sends kitty's Ctrl+Tab / Ctrl+Shift+Tab with `[bind, …]` |
| Caps+W erases a word in apps | Caps sends a real Linux Ctrl, so Caps+W was Ctrl+W = close tab. On a Mac, Ctrl+W never closes (Cmd+W does). The rule sends Ctrl+Backspace. Chrome is the exception: "User Chrome Caps" (checked first) keeps Caps+W = close tab and Caps+L = address bar instead of → |
| Win+Backspace (Option) didn't delete a word in Teams for Linux | Toshy sends a short Alt tap before Ctrl+Backspace; Electron apps with a hidden menu bar move focus to that menu on an Alt tap. Fixed with `"menubar": "hidden"` in `~/.config/teams-for-linux/config.json` ([teams-for-linux-setup.md](teams-for-linux-setup.md)) |
| VS Code `files.watcherExclude` | VS Code watched every folder of ~/WorkSpace/<project> (61,800, 96% in node_modules) and used up Linux's 65,536 inotify limit; Toshy then failed to start (`inotify watch limit reached`, found with `xwaykeyz --check -c toshy_config.py`). Plain folder patterns like `**/node_modules` cut it to about 2,000. Also raised the limit (applied on this machine, 2026-10-15): `echo fs.inotify.max_user_watches=524288 \| sudo tee /etc/sysctl.d/60-inotify-watches.conf; sudo sysctl --system` |
| Caps+H/J/K/L = arrows in apps only | In terminals, Ctrl+H/J/K/L are backspace, newline, kill-line and clear, and your Neovim window moves, so the rule skips terminals. In apps the Ctrl+H/J/K/L shortcuts stay reachable with Alt (Cmd). Replaced the earlier Caps+J = Join Lines rule (now Left Ctrl+J). Snapshot before the change: milestone `before-vim-arrows` |
| Avoid "Caps is LCtrl role swap" | It turns Left Ctrl into Caps Lock, and the Caps key then can't turn Caps Lock off |
| Win tap doesn't open Activities | Toshy sends Left Ctrl as Super; remapped Left Ctrl combos look like a Super tap and open Activities by mistake. `overlay-key = ''`, Activities on Alt+Space |
| No "tap Alt" for Activities | "L_Cmd is Super & Cmd" with the Caps tap/hold mode froze the keyboard |
| CopyQ off Ctrl+Shift+V | In terminals Toshy turns Cmd+V into Ctrl+Shift+V (paste) |
| Ctrl+Alt+T terminal shortcut off | Otherwise Alt+Caps+T opens a new terminal as well as focusing kitty |
| Run or Raise | GNOME custom shortcuts can only launch; the dock's Super+N follows dock order |
| Exact Chrome window class | `/^[Gg]oogle-chrome$/` skips Chrome web apps (Outlook, Teams) |

**Stuck keys after a crash:** if Toshy freezes and is stopped mid-press, GNOME can keep a key (often Super) "held". Symptoms: tapping Alt opens Activities, Alt+T does nothing. Press and release Win, Ctrl, Alt and Shift once each; if that doesn't help, log out and back in.

**Don't press shortcuts while `reload-shortcuts` runs.** A key pressed while Toshy restarts can get stuck, and once the session ended mid-reload, which left Run or Raise disabled (Alt+Caps+letter stopped opening apps). Fix: `gnome-extensions enable run-or-raise@edvard.cz`.

**When a logout is needed:** after installing a GNOME extension, and after a freeze. Not after Toshy rule or preference changes or `gsettings` changes.

## Recover and undo

| Situation | Command |
|---|---|
| Need a normal keyboard now | `toshy-services-stop` |
| Start again / reload after edits | `toshy-services-start` · `reload-shortcuts` |
| Don't start Toshy at login | `toshy-services-disable` (undo: `toshy-services-enable`) |
| Win opens Activities again (Toshy off) | `gsettings reset org.gnome.mutter overlay-key` |
| Remove Toshy | `cd ~/Downloads/Toshy-main; ./setup_toshy.py uninstall`, then `rm -rf ~/.config/toshy` |
| Undo Caps / both-Shifts | `gsettings reset org.gnome.desktop.input-sources xkb-options` |
| Undo Alt+Tab = apps | `gsettings reset org.gnome.desktop.wm.keybindings switch-applications` (and `switch-applications-backward`, `switch-windows`, `switch-windows-backward`) |
| Remove Run or Raise | `gnome-extensions uninstall run-or-raise@edvard.cz; rm -rf ~/.config/run-or-raise` |

## References

| Topic | Official doc |
|---|---|
| Toshy (install, uninstall, wiki) | [RedBearAK/toshy](https://github.com/RedBearAK/toshy), [Toshy wiki](https://github.com/RedBearAK/toshy/wiki) |
| Focused Window D-Bus extension | [extensions.gnome.org/extension/5592](https://extensions.gnome.org/extension/5592/focused-window-dbus/) |
| Run or Raise extension | [extensions.gnome.org/extension/1336](https://extensions.gnome.org/extension/1336/run-or-raise/), [CZ-NIC/run-or-raise](https://github.com/CZ-NIC/run-or-raise) |
| Keyboard options (`ctrl:nocaps`, `shift:both_capslock`) | [xkeyboard-config(7)](https://manpages.ubuntu.com/manpages/noble/man7/xkeyboard-config.7.html) |
| GNOME custom shortcuts | [GNOME Help: set keyboard shortcuts](https://help.gnome.org/users/gnome-help/stable/keyboard-shortcuts-set.html) |
| Screenshot portal (Screen OCR) | [XDG Desktop Portal: Screenshot](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.Screenshot.html) |
| Tesseract OCR | [tessdoc](https://tesseract-ocr.github.io/tessdoc/) |
| CopyQ on Wayland | [CopyQ known issues](https://copyq.readthedocs.io/en/latest/known-issues.html) |
| fish shell | [fish docs](https://fishshell.com/docs/current/index.html) |

## Milestones (snapshots)

Two fish commands snapshot and restore this whole setup:

| Command | Does |
|---|---|
| `save-milestone NAME` | Zips the current configs to `~/claude/milestones/NAME.zip`: Toshy config and preferences, Run or Raise, fish functions, `screen-ocr`, CopyQ and touchpad autostart, VS Code settings and keybindings, kitty, Neovim, launcher overrides in `~/.local/share/applications`, and the GNOME settings (input sources, mutter, shell and window keybindings, custom shortcuts, dock, touchpad, enabled extensions, favourites) |
| `restore-milestone NAME` | First saves the current state as `before-NAME-<date>`, then puts every file back, resets and reloads those GNOME settings, and runs `reload-shortcuts` |

Milestone **m1** was saved on 2026-10-15 (this setup: Toshy with Caps = Esc/Ctrl, Run or Raise launchers, Caps+W/Tab/J rules). Restore with `restore-milestone m1`. Restart VS Code and kitty afterwards; log out and in if extensions changed.

Not included: installed packages and GNOME extensions themselves (only the list), sign-ins, and app data.
