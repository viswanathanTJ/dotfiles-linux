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

keymap("User Ctrl+Space", {
    # Real Ctrl+Space for apps (VibeTyper dictation hotkey, code completion). Toshy's default turns
    # it into Super+Space (keyboard layout switch); this laptop has only the US layout.
    C("LC-Space"):              C("C-Space"),                   # Caps+Space
    C("Super-Space"):           C("C-Space"),                   # physical Left Ctrl+Space in apps
}, when = lambda ctx:
    cnfg.screen_has_focus and
    not ctx_app_is_remote
)

keymap("User Caps double tap", {
    # isDoubleTap sends Esc the moment the 2nd tap lands (MultiTap waited another 0.25 s
    # for a possible 3rd tap). Taps must be within tapInterval (above); a single tap does nothing.
    C("F16"): isDoubleTap(C("Esc")),
}, when = lambda ctx:
    cnfg.screen_has_focus and
    not ctx_app_is_remote
)


keymap("User app launchers", {
    # Alt+Caps+letter (Cmd+Ctrl+letter) -> Ctrl+Alt+Super+letter, which the GNOME "Run or Raise"
    # extension uses to focus or launch an app. A combo nobody types, so real Ctrl+Alt+letter
    # (Win+Caps+letter) reaches apps. Only Alt+Caps launches; Alt+Left Ctrl+letter does not.
    C("RC-LC-b"):            C("C-Alt-Super-b"),                   # Chrome
    C("RC-LC-c"):            C("C-Alt-Super-c"),                   # VS Code
    C("RC-LC-t"):            C("C-Alt-Super-t"),                   # kitty
    C("RC-LC-k"):            C("C-Alt-Super-k"),                   # kitty (second key)
    C("RC-LC-w"):            C("C-Alt-Super-w"),                   # ZapZap
    C("RC-LC-m"):            C("C-Alt-Super-m"),                   # YouTube Music
    C("RC-LC-n"):            C("C-Alt-Super-n"),                   # Telegram
    C("RC-LC-a"):            C("C-Alt-Super-a"),                   # AyuGram
    C("RC-LC-e"):            C("C-Alt-e"),                   # Teams: search (Ctrl+Alt+E)
    C("RC-LC-x"):            C("C-Alt-Super-x"),                   # Brave
    C("RC-LC-p"):            C("C-Alt-Super-p"),                   # Postman
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
    # Alt+Caps+V (or Alt+Left Ctrl+V) -> Super+V = GNOME open / close the notification list
    C("RC-LC-v"):               C("Super-v"),
    C("RC-Super-v"):            C("Super-v"),
    # Alt+Caps+D (or Alt+Left Ctrl+D) -> Ctrl+Alt+Super+D = GNOME shortcut "Clear notifications"
    # (~/.local/bin/notif-clear): closes every notification, including ones stuck on screen
    C("RC-LC-d"):               C("C-Alt-Super-d"),
    C("RC-Super-d"):            C("C-Alt-Super-d"),
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
    # Caps+[ / Caps+] = previous/next tmux window, same as Win+H / Win+L (Alt+h / Alt+l, see ~/.tmux.conf).
    # Without this, Caps+[ is Ctrl+[ = Esc, which tmux can't tell apart from Esc.
    C("LC-Left_Brace"):         C("Alt-h"),                     # previous tmux window
    C("LC-Right_Brace"):        C("Alt-l"),                     # next tmux window
    # Caps+Shift+1..9 = tmux window 1..9: sent as Alt+Shift+N, which ~/.tmux.conf binds (M-! .. M-().
    # A terminal can't send Ctrl+Shift+digit on its own (it arrives as a plain digit).
    C("Shift-LC-Key_1"):        C("Shift-Alt-Key_1"),
    C("Shift-LC-Key_2"):        C("Shift-Alt-Key_2"),
    C("Shift-LC-Key_3"):        C("Shift-Alt-Key_3"),
    C("Shift-LC-Key_4"):        C("Shift-Alt-Key_4"),
    C("Shift-LC-Key_5"):        C("Shift-Alt-Key_5"),
    C("Shift-LC-Key_6"):        C("Shift-Alt-Key_6"),
    C("Shift-LC-Key_7"):        C("Shift-Alt-Key_7"),
    C("Shift-LC-Key_8"):        C("Shift-Alt-Key_8"),
    C("Shift-LC-Key_9"):        C("Shift-Alt-Key_9"),
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
