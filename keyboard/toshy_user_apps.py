###  SLICE_MARK_START: user_apps  ###  EDITS OUTSIDE THESE MARKS WILL BE LOST ON UPGRADE


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
    # Caps+L = address bar (like Alt+L / Ctrl+L), Caps+W = close tab (like Alt+W).
    C("LC-l"):                  C("C-l"),                       # focus and select the address bar
    C("LC-w"):                  C("C-w"),                       # close tab
}, when = lambda ctx:
    cnfg.screen_has_focus and
    hmp_is_chrome_browser(ctx) )

keymap("User Caps word erase", {
    # Caps held = literal Linux Ctrl (Caps mode esc_and_lctrl), so in apps Caps+W was
    # Ctrl+W = close tab. On a Mac, Ctrl+W never closes; Cmd+W (Alt+W) does.
    # Make Caps+W erase the previous word, like Ctrl+W in a terminal.
    C("LC-w"):                  C("C-Backspace"),               # erase previous word
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
