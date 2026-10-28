#!/usr/bin/env bash
# Puts this laptop back close to how IT handed it over: removes personal apps, the Toshy keyboard
# setup, shortcuts, GNOME tweaks, logins and caches. Company software is never removed.
# Run ./reset-to-stock.sh with no arguments for the help.
set -uo pipefail
shopt -s nullglob

SELF="$(readlink -f "$0")"
HERE="$(dirname "$SELF")"
LOGDIR="$HERE/logs"
STAMP="$(date +%Y-%m-%dT%H%M%S)"
DRY=0 YES=0 BG=0 DELETE=0 WORKER=0 ALL_YES=0 FAILS=0
TUSER="$(id -un)"
MODS=()
DEL_QUEUE=()
CUR=""          # the part a log line belongs to
RM_JOBS=4       # rm workers per big folder
JOBDIR=""       # per-run temp folder: part logs, apt queue, failure list
# deletes a folder's entries with several rm workers, then the folder itself ($1 = folder, $2 = workers)
FASTRM='find "$1" -mindepth 1 -maxdepth 1 -print0 | xargs -0 -r -P "$2" -n 8 rm -rf --; rm -rf -- "$1"'

# machine-only settings, not in git (template: examples/reset-local.conf.example):
#   KEEP_NOTE              what the help lists as never touched
#   EXTRA_REMOVE_<part>    more paths that part deletes, written as "~/..."
#   EXTRA_DELETE           more folders --delete asks about
KEEP_NOTE="Anything your company or IT installed (VPN, security agent, device management, domain join).
  Only the packages and paths listed in each part are removed."
EXTRA_DELETE=()
[ -f "$HERE/local.conf" ] && . "$HERE/local.conf"

# the order matters: login shell back to bash before fish is removed, logins after the apps
ORDER=(autostart toshy shortcuts extensions launchers gnome configs shell tailscale rustdesk wine apps system logins appdata caches)
ROOT_MODS=" toshy configs shell tailscale rustdesk wine apps system "

# personal packages (checked with apt-get -s: removing them takes nothing else with it)
APPS_PKGS=(zapzap copyq kitty tmux btop eza fd-find ripgrep jq gh stow ydotool dpscreenocr tesseract-ocr tesseract-ocr-eng
    7zip p7zip-full adb filezilla flatpak fonts-taml gnome-nettool input-utils libinput-tools ruby sshfs v4l-utils
    wl-clipboard wmctrl x11vnc xclip xpdf xprintidle cheese gedit onboard printer-driver-cups-pdf)
# build libraries pulled in for Toshy and other tools: marked "automatic", so apt autoremove deletes the
# ones nothing else needs
APPS_AUTO=(libcairo2-dev libcjson-dev libconfig-dev libdbus-1-dev libgirepository-2.0-dev libgirepository1.0-dev
    libjpeg-dev libsystemd-dev libwayland-dev libxi-dev libxinerama-dev libxkbcommon-dev libxrandr-dev libxt-dev
    wayland-protocols python3-dev gir1.2-ayatanaappindicator3-0.1 libnotify-bin libsecret-tools libfuse2t64
    libqt5webkit5 python3-tk python3-netifaces libprotobuf23)
WINE_PKGS=(wine wine32:i386 wine64 wine-common libwine:amd64 libwine:i386 fonts-wine)

describe() {
    case "$1" in
        autostart)  echo "ALL your startup items and user services/timers (tmux-restore, VibeTyper, CopyQ, Remmina, ydotoold, podman socket, remote desktop); system startup items you had hidden come back" ;;
        toshy)      echo "Toshy Mac-style keys: services, tray, configs + backups, udev rule, uinput module, 'input' group, downloaded installers" ;;
        shortcuts)  echo "GNOME keyboard shortcuts, custom shortcuts (OCR, CopyQ, blank screen, force quit), Caps/Shift keyboard options" ;;
        extensions) echo "Your GNOME extensions (Run or Raise, gestures, net speed, VibeTyper, desktop rules, focused-window) + their settings" ;;
        launchers)  echo "Menu-entry overrides (Wayland flags), Chrome web apps, default-app choices" ;;
        gnome)      echo "Every other GNOME setting back to Ubuntu defaults (dconf reset; a backup is saved in logs/)" ;;
        configs)    echo "Lock screen asks for the password again (after blank + suspend), autologin off, idle/power defaults, every leftover config linked from ~/dotfiles" ;;
        shell)      echo "Login shell back to bash (sssd override), fish/starship/tmux/kitty/nvim/btop configs, fresh .bashrc/.profile" ;;
        tailscale)  echo "Sign out of Tailscale, remove it and its apt repo" ;;
        rustdesk)   echo "Remove RustDesk and its config" ;;
        wine)       echo "Wine (64 + 32-bit), its menu entries, the Wine prefixes (~/.wine*), and the i386 architecture if nothing else uses it" ;;
        apps)       echo "Every personal package: ZapZap, Telegram, VibeTyper, CopyQ, kitty, tmux, fish, btop, eza, ripgrep, fd, jq, gh, glow, uv, stow, ydotool, OCR, FileZilla, Flatpak, x11vnc, sshfs, Ruby, gedit, Cheese, … + Neovim, starship, FiraCode, PPAs, Toshy build libraries (apt autoremove)" ;;
        system)     echo "System tweaks: inotify watch limit (sysctl), touchpad speed (hwdb)" ;;
        logins)     echo "Sign out + wipe: SSH keys and config, git identity, GitHub (gh), Claude, browser profiles, keyrings, GPG, OneDrive sign-out, app logins" ;;
        appdata)    echo "Personal app data: messages, VS Code/Obsidian/Postman/Compass settings, Wine prefixes, shell history, recent files" ;;
        caches)     echo "Caches and junk: ~/.cache, npm, gradle, Trash, core dumps" ;;
    esac
}

# other names people type for a part
canon() {
    case "$1" in
        keys|keyboard|keymap) echo toshy ;;
        keybindings|hotkeys)  echo shortcuts ;;
        ext|extension)        echo extensions ;;
        fish|bash|tmux|kitty|nvim|starship) echo shell ;;
        ssh|git|gh|github|claude|browsers|secrets|login) echo logins ;;
        lock|lockscreen|screensaver|autolock|autologin|config|dotfiles) echo configs ;;
        cache) echo caches ;;
        *) echo "$1" ;;
    esac
}

usage() {
    local m
    cat <<EOF
Reset to stock: removes your personal setup so the laptop is close to how IT handed it over.

USAGE
  ./reset-to-stock.sh <part> [<part>...]   reset these parts now, e.g. ./reset-to-stock.sh toshy shortcuts
  ./reset-to-stock.sh --all                reset every part, in the background (asks your sudo password first)
  ./reset-to-stock.sh --delete             delete your own files (WorkSpace, GitHub repos, ~/claude, Documents,
                                           Downloads, …), asking before each folder. Never runs in the background.
  ./reset-to-stock.sh --list               list the parts
  ./reset-to-stock.sh help                 this help

OPTIONS
  -n, --dry-run      show what would happen, change nothing (start with this)
  -y, --yes          don't ask "Type yes to continue" (--delete still asks before each folder)
  --bg               run the chosen parts in the background (--all does this already)
  Parts can also be given comma-separated: ./reset-to-stock.sh toshy,shortcuts
  --all --delete     deletes your files first (asking), then resets everything in the background

PARTS (run in this order)
EOF
    for m in "${ORDER[@]}"; do
        printf '  %-11s %s%s\n' "$m" "$(describe "$m")" "$([[ $ROOT_MODS == *" $m "* ]] && echo ' [sudo]')"
    done
    cat <<'EOF'

  Other names work too: keyboard = toshy, fish/tmux/kitty = shell, ssh/git/gh/github = logins.

EOF
    printf 'NEVER TOUCHED: %s\n' "$KEEP_NOTE"
    cat <<'EOF'

LOGS
  logs/reset-<date-time>.log (logs/latest.log points to the newest). Follow a background run:
  tail -f logs/latest.log
EOF
}

say() { printf '%s\n' "$*"; }
log() { printf '[%s] %s%s\n' "$(date +%T)" "${CUR:+[$CUR] }" "$*"; }

as_user() {
    if [ "$EUID" -eq 0 ]; then
        runuser -u "$TUSER" -- env HOME="$THOME" XDG_RUNTIME_DIR="/run/user/$TUID" \
            DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$TUID/bus" "$@"
    else
        "$@"
    fi
}
as_root() { if [ "$EUID" -eq 0 ]; then "$@"; else sudo "$@"; fi; }

# runl <user|root> <label> <command...>: logs the label and runs the command (dry-run only logs it)
runl() {
    local who=$1 label=$2 rc; shift 2
    if ((DRY)); then log "  would run ($who): $label"; return 0; fi
    log "  run ($who): $label"
    if [ "$who" = root ]; then as_root "$@"; else as_user "$@"; fi
    rc=$?
    if ((rc)); then
        log "  ! failed (exit $rc): $label"
        [ -n "$JOBDIR" ] && echo "$label" >>"$JOBDIR/fails"
    fi
    return $rc
}
run() { runl "$1" "${*:2}" "${@:2}"; }

# remove <user|root> <path...>: deletes the paths that exist, all at once (folders with several rm
# workers); returns 1 if there was nothing to delete
remove() {
    local who=$1 p did=1 cmd; shift
    for p in "$@"; do
        case "$p" in "" | / | "$THOME" | "$THOME/") log "  ! refusing to delete '$p'"; continue ;; esac
        [ -e "$p" ] || [ -L "$p" ] || continue
        did=0
        if [ -d "$p" ] && [ ! -L "$p" ]; then
            cmd=(runl "$who" "rm -rf -- $p  (parallel)" bash -c "$FASTRM" _ "$p" "$RM_JOBS")
        else
            cmd=(run "$who" rm -rf -- "$p")
        fi
        if ((DRY)); then "${cmd[@]}"; else "${cmd[@]}" & fi
    done
    wait
    return $did
}

installed() { dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q 'ok installed'; }

# purge <package...>: queues the installed ones; apt_queue_run removes them all in one apt run at the
# end (apt can only run once at a time, and one run is faster than several)
purge() {
    local p ps=()
    for p in "$@"; do installed "$p" && ps+=("$p"); done
    if ((${#ps[@]} == 0)); then log "  (not installed: $*)"; return 0; fi
    log "  queued for apt purge: ${ps[*]}"
    printf '%s\n' "${ps[@]}" >>"$JOBDIR/apt-queue"
}

apt_queue_run() {
    local q=() p keep=()
    mapfile -t q < <(sort -u "$JOBDIR/apt-queue")
    ((${#q[@]})) || return 0
    CUR=apt
    if [[ " ${q[*]} " == *" fish "* && "$(login_shell)" == *fish* ]] && ! ((DRY)); then
        log "  ! keeping fish: it is still your login shell (the 'shell' part didn't switch it back)"
        for p in "${q[@]}"; do [ "$p" = fish ] || keep+=("$p"); done
        q=("${keep[@]}")
    fi
    if ((${#q[@]})); then
        log "== apt: removing ${#q[@]} packages in one run"
        run root env DEBIAN_FRONTEND=noninteractive apt-get purge -y "${q[@]}"
    fi
    mapfile -t q < <(sort -u "$JOBDIR/apt-auto")
    if ((${#q[@]})); then
        run root apt-mark auto "${q[@]}"
        run root env DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge -y
    fi
    # Wine added the 32-bit (i386) architecture; drop it when no i386 package is left
    if [ -s "$JOBDIR/drop-arch" ] && dpkg --print-foreign-architectures | grep -qx i386; then
        if ((DRY)) || ! dpkg-query -W -f='${Architecture}\n' 2>/dev/null | grep -qx i386; then
            run root dpkg --remove-architecture i386
        else
            log "  i386 architecture kept: some 32-bit packages are still installed"
        fi
    fi
    CUR=""
}

# user_units_off <unit...>: stop and disable user systemd units that exist
user_units_off() {
    local u
    for u in "$@"; do
        as_user systemctl --user cat "$u" >/dev/null 2>&1 && run user systemctl --user disable --now "$u"
    done
    return 0
}

dconf_reset() { local d; for d in "$@"; do run user dconf reset -f "$d"; done; }

# extra_remove <part>: deletes the EXTRA_REMOVE_<part> paths from local.conf ("~/x" = your home)
extra_remove() {
    declare -p "EXTRA_REMOVE_$1" &>/dev/null || return 0
    local -n extra="EXTRA_REMOVE_$1"
    local p paths=()
    for p in "${extra[@]}"; do paths+=("${p/#\~/$THOME}"); done
    remove user "${paths[@]}"
    return 0
}

login_shell() { getent passwd "$TUSER" | cut -d: -f7; }

# ---------------------------------------------------------------- parts

mod_autostart() {
    local a="$THOME/.config/autostart" s="$THOME/.config/systemd/user" w u f units=() files=()
    # everything enabled in your user systemd (the 'toshy' part handles Toshy's own units)
    for w in "$s"/*.wants/*; do
        u=$(basename "$w")
        [[ $u == toshy-* ]] || units+=("$u")
    done
    for f in "$s"/*; do
        [ -f "$f" ] && [[ $(basename "$f") != toshy-* ]] && units+=("$(basename "$f")") && files+=("$f")
    done
    ((${#units[@]})) && user_units_off $(printf '%s\n' "${units[@]}" | sort -u)
    remove user "${files[@]}"
    # every startup item. A file here with the same name as one in /etc/xdg/autostart hides or changes
    # that system item; deleting it brings the system item back
    files=()
    for f in "$a"/*; do
        [[ $(basename "$f") == Toshy_* ]] && continue
        files+=("$f")
        if [ -e "/etc/xdg/autostart/$(basename "$f")" ]; then
            log "  system startup item comes back: $(sed -n 's/^Name=//p' "/etc/xdg/autostart/$(basename "$f")" | head -1) ($(basename "$f"))"
        fi
    done
    remove user "${files[@]}"
    run user systemctl --user daemon-reload
}

mod_toshy() {
    local s="$THOME/.config/systemd/user"
    user_units_off toshy-config.service toshy-session-monitor.service toshy-kwin-dbus.service \
        toshy-cosmic-dbus.service toshy-wlroots-dbus.service
    as_user pgrep -f toshy_tray >/dev/null && run user pkill -f toshy_tray
    remove user "$s"/toshy-*.service "$THOME/.config/toshy" "$THOME/.config/toshy_config_backups" \
        "$THOME"/.local/bin/toshy-* "$THOME"/.config/autostart/Toshy_*.desktop \
        "$THOME/.local/share/applications/Toshy_Tray.desktop" "$THOME/.local/share/applications/app.toshy.preferences.desktop" \
        "$THOME"/Downloads/Toshy-* "$THOME/Downloads/toshy-src"
    run user systemctl --user daemon-reload
    remove root /etc/udev/rules.d/70-toshy-keymapper-input.rules /etc/modules-load.d/uinput.conf \
        && run root udevadm control --reload-rules
    if id -nG "$TUSER" | tr ' ' '\n' | grep -qx input; then run root gpasswd -d "$TUSER" input; fi
}

mod_shortcuts() {
    dconf_reset /org/gnome/desktop/wm/keybindings/ /org/gnome/shell/keybindings/ /org/gnome/mutter/keybindings/ \
        /org/gnome/mutter/wayland/keybindings/ /org/gnome/settings-daemon/plugins/media-keys/ \
        /org/gnome/desktop/input-sources/ /org/gnome/terminal/legacy/keybindings/
}

mod_extensions() {
    local d
    for d in "$THOME"/.local/share/gnome-shell/extensions/*/; do
        run user gnome-extensions disable "$(basename "$d")"
        remove user "${d%/}"
    done
    run user dconf reset /org/gnome/shell/enabled-extensions
    run user dconf reset /org/gnome/shell/disabled-extensions
    dconf_reset /org/gnome/shell/extensions/
    remove user "$THOME/.config/run-or-raise"
}

mod_launchers() {
    local a="$THOME/.local/share/applications"
    # postman.desktop stays: Postman (kept) has no other menu entry
    remove user "$a"/com.microsoft.VSCode*.desktop "$a/md.obsidian.Obsidian.desktop" "$a/google-chrome.desktop" \
        "$a/teams-for-linux.desktop" "$a"/chrome-*-Default.desktop "$a/mimeapps.list" \
        "$a/defaults.list" "$THOME/.local/share/applications.bak-genymotion" "$THOME/.config/mimeapps.list"
    [ -d "$a" ] && run user update-desktop-database "$a"
}

mod_gnome() {
    local b="$LOGDIR/gnome-settings-$STAMP.ini"
    if ((DRY)); then
        log "  would save a backup of all GNOME settings to $b"
    else
        as_user dconf dump / >"$b" && log "  backup of GNOME settings: $b (restore: dconf load / < file)"
    fi
    run user dconf reset -f /
}

mod_configs() {
    local k l links=()
    # lock screen: password after the screen blanks and after suspend; idle and power back to defaults
    for k in "org.gnome.desktop.screensaver lock-enabled" "org.gnome.desktop.screensaver lock-delay" \
        "org.gnome.desktop.screensaver ubuntu-lock-on-suspend" "org.gnome.desktop.notifications show-in-lock-screen" \
        "org.gnome.desktop.session idle-delay"; do
        as_user gsettings get $k &>/dev/null && run user gsettings reset $k
    done
    dconf_reset /org/gnome/settings-daemon/plugins/power/ /org/gnome/desktop/lockdown/
    # login without a password (GDM autologin), if it was turned on
    if grep -Eqs '^\s*(AutomaticLoginEnable|TimedLoginEnable)\s*=\s*[Tt]rue' /etc/gdm3/custom.conf; then
        run root sed -i -E 's/^\s*(AutomaticLoginEnable|TimedLoginEnable)\s*=.*/\1 = false/' /etc/gdm3/custom.conf
    else
        log "  autologin is already off"
    fi
    # any config still linked into the dotfiles repo
    while IFS= read -r l; do links+=("$l"); done < <(find "$THOME" -maxdepth 6 \
        \( -path "$THOME/dotfiles" -o -path "$THOME/WorkSpace" -o -path "$THOME/snap" -o -path "$THOME/.cache" \
        -o -path "$THOME/.wine*" -o -path "$THOME/.npm" -o -path "$THOME/.nvm" -o -path "$THOME/OneDrive" \
        -o -path "$THOME/.local/share/containers" \) -prune -o -type l -lname '*dotfiles/*' -print 2>/dev/null)
    log "  ${#links[@]} config link(s) into ~/dotfiles"
    remove user "${links[@]}"
}

mod_shell() {
    # fish was made the login shell with an sssd override (the shell itself comes from AD)
    if [[ "$(login_shell)" == *fish* ]]; then
        run root sss_override user-del "$TUSER" && run root systemctl restart sssd && run root sss_cache -E
    fi
    remove user "$THOME/.config/fish" "$THOME/.config/starship.toml" "$THOME/.tmux.conf" "$THOME/.tmux" \
        "$THOME/.local/share/tmux" "$THOME/.local/state/tmux-assistant-resurrect" "$THOME/.config/kitty" "$THOME/.config/nvim" "$THOME/.local/share/nvim" \
        "$THOME/.config/btop" "$THOME/.zshrc" "$THOME"/.local/bin/{tmux-restore,blank-screen,screen-ocr,json_key_swap} \
        "$THOME/.dotfiles-backup"
    local f
    for f in .bashrc .profile .bash_logout; do
        run user cp --remove-destination "/etc/skel/$f" "$THOME/$f"
    done
}

mod_tailscale() {
    installed tailscale && run root tailscale logout
    purge tailscale tailscale-archive-keyring
    remove root /etc/apt/sources.list.d/tailscale.list /usr/share/keyrings/tailscale-archive-keyring.gpg /var/lib/tailscale
}

mod_rustdesk() {
    purge rustdesk
    remove user "$THOME/.config/rustdesk" "$THOME/.local/share/rustdesk"
    remove root /root/.config/rustdesk
}

mod_wine() {
    local h="$THOME"
    as_user pgrep -f 'wineserver|\.exe' >/dev/null && run user pkill -f 'wineserver|\.exe'
    purge "${WINE_PKGS[@]}"
    echo i386 >"$JOBDIR/drop-arch"
    remove user "$h/.wine" "$h/.wine-test" "$h/.local/share/wine" "$h/.local/share/applications/wine" \
        "$h"/.config/menus/applications-merged/wine-* "$h"/.local/share/desktop-directories/wine-* \
        "$h"/.local/share/mime/packages/x-wine-* "$h"/.local/share/applications/wine-extension-*.desktop
}

mod_apps() {
    local p pk=("${APPS_PKGS[@]}")
    # fish only goes if it stops being the login shell ('shell' runs alongside; apt runs after both)
    if [[ "$(login_shell)" != *fish* || " ${MODS[*]} " == *" shell "* ]]; then
        pk+=(fish)
    else
        log "  ! keeping fish: it is still your login shell (add the 'shell' part)"
    fi
    for p in copyq zapzap Telegram; do as_user pgrep -x "$p" >/dev/null && run user pkill -x "$p"; done
    purge "${pk[@]}"
    for p in "${APPS_AUTO[@]}"; do installed "$p" && echo "$p" >>"$JOBDIR/apt-auto"; done
    log "  queued for apt autoremove (only if nothing else needs them): $(wc -l <"$JOBDIR/apt-auto") build libraries"
    remove user "$THOME/.local/share/flatpak" "$THOME/.var"
    # glow (Markdown viewer, Snap) and uv (Python tool installer)
    snap list glow &>/dev/null && run root snap remove --purge glow
    remove user "$THOME"/.local/bin/{uv,uvx,env,env.fish} "$THOME/.local/share/uv" "$THOME/.config/uv" "$THOME/.cache/uv"
    remove root /opt/nvim
    remove root /etc/apt/sources.list.d/fish-shell-ubuntu-release-4-*.sources* \
        /etc/apt/sources.list.d/daniel_p-ubuntu-dpscreenocr-*.sources* \
        /usr/local/bin/starship /usr/local/bin/nvim /opt/nvim-linux-x86_64
    remove user "$THOME/.local/opt/Telegram" "$THOME/.local/bin/telegram" \
        "$THOME"/.local/share/applications/org.telegram.desktop*.desktop "$THOME/Downloads/VibeTyper.AppImage" \
        "$THOME"/.local/share/applications/com.vibetyper.app.desktop* "$THOME/.config/copyq" "$THOME/.local/share/copyq" \
        "$THOME/.config/dpscreenocr" "$THOME"/.local/share/fonts/FiraCode* \
        && run user fc-cache -f
}

mod_system() {
    remove root /etc/sysctl.d/60-inotify-watches.conf && run root sysctl --system
    remove root /etc/udev/hwdb.d/61-touchpad-speed.hwdb && run root systemd-hwdb update
    return 0
}

mod_logins() {
    local h="$THOME"
    # OneDrive: sign out first; the synced files in ~/OneDrive stay unless you use --delete
    if [ -d "$h/.config/onedrive" ] && command -v onedrive >/dev/null; then
        user_units_off onedrive.service
        run user onedrive --logout
        remove user "$h"/.config/onedrive/items.sqlite3*
    fi
    remove user "$h/.ssh" "$h/.gitconfig" "$h/.git-credentials" "$h/.config/git" "$h/.config/gh" \
        "$h/.claude" "$h"/.claude-* "$h"/.claude.json* "$h/.config/claude-multiprofile" "$h/.config/chrome-claude" \
        "$h/.local/share/claude" "$h/.local/state/claude" "$h/.local/bin/claude" "$h/.config/ccstatusline" "$h/.config/Claude" \
        "$h/.local/share/applications/claude-code-url-handler.desktop" "$h/.cache/claude" "$h/.cache/claude-cli-nodejs" \
        "$h/.cache/chrome-claude" "$h/.cache/google-chrome" "$h/.cache/google-chrome-headless" "$h/.cache/microsoft-edge" \
        "$h/.gnome/apps" "$h/.local/share/desktop-directories/chrome-apps.directory" \
        "$h/.config/google-chrome" "$h/.config/google-chrome-headless" "$h/.config/chromium" "$h/.config/BraveSoftware" \
        "$h/.config/vivaldi" "$h/.config/opera" "$h/.config/microsoft-edge" "$h/.mozilla" "$h/snap/firefox" "$h/.pki" \
        "$h/.local/share/keyrings" "$h/.gnupg" "$h/.config/goa-1.0" "$h/.config/teams-for-linux" \
        "$h/.config/filezilla" "$h/.putty" "$h/.config/remmina" "$h/.local/share/remmina" "$h/.config/freerdp" \
        "$h/.config/teamviewer" "$h/.local/share/teamviewer15" "$h/.copilot" "$h/.cursor" "$h/.pi" \
        "$h/.npmrc" "$h/.docker" "$h/.Genymobile" \
        "$h/.config/Genymobile" "$h/.android" "$h/.redhat" "$h/.config/configstore"
}

mod_appdata() {
    local h="$THOME"
    remove user "$h/.local/share/TelegramDesktop" "$h/.local/share/ZapZap" "$h/.config/ZapZap" \
        "$h/.local/share/com.vibetyper.app" "$h/.config/vibe-typer" "$h/.config/Code" "$h/.vscode" "$h/.vscode-shared" \
        "$h/.config/obsidian" "$h/.config/Postman" "$h/.config/MongoDB Compass" "$h/.mongodb" \
        "$h/.config/evolution" "$h/.local/share/evolution" \
        "$h/.local/share/onedriver" "$h/.local/bin/codebase-memory-mcp" \
        "$h/.bash_history" "$h/.zsh_history" "$h/.local/share/fish" "$h/.lesshst" "$h/.wget-hsts" \
        "$h/.python_history" "$h/.node_repl_history" "$h/.local/share/recently-used.xbel"
}

mod_caches() {
    remove user "$THOME/.cache" "$THOME/.npm" "$THOME/.gradle" "$THOME/.local/share/Trash" "$THOME"/core.* "$THOME/out.log"
}

# ---------------------------------------------------------------- --delete

# git repos under a path that have work not on the remote yet
unsaved_repos() {
    local g r d u
    while IFS= read -r g; do
        r=$(dirname "$g")
        d=$(git -C "$r" status --porcelain 2>/dev/null | wc -l)
        u=$(git -C "$r" log --branches --not --remotes --oneline 2>/dev/null | wc -l)
        if ((d || u)); then printf '      %s: %s uncommitted file(s), %s unpushed commit(s)\n' "${r/#$THOME/\~}" "$d" "$u"; fi
    done < <(find "$1" -maxdepth 4 -name .git -prune 2>/dev/null)
}

# deleting ~/OneDrive while the client is signed in would delete the files in the cloud on its next sync
onedrive_unlink() {
    command -v onedrive >/dev/null || return 0
    user_units_off onedrive.service
    as_user pgrep -x onedrive >/dev/null && run user pkill -x onedrive
    run user onedrive --logout
    remove user "$THOME"/.config/onedrive/items.sqlite3*
}

# wipe <path>: delete it; folders that hold this script keep the script's folder
wipe() {
    local p=$1 c kids=()
    if [[ "$HERE" == "$p"/* ]]; then
        for c in "$p"/* "$p"/.[!.]*; do [ "$c" = "$HERE" ] || kids+=("$c"); done
        remove user "${kids[@]}"
    else
        remove user "$p"
    fi
    case "$(basename "$p")" in
        Desktop | Documents | Downloads | Pictures | Videos | Music | Templates | Public)
            [ "$(dirname "$p")" = "$THOME" ] && run user mkdir -p "$p" ;;
    esac
    return 0
}

# deletes everything you said yes to, all at once
delete_queue_run() {
    local p n=${#DEL_QUEUE[@]} t0=$SECONDS
    ((n)) || { log "  nothing chosen to delete"; return 0; }
    for p in "${DEL_QUEUE[@]}"; do [ "$p" = "$THOME/OneDrive" ] && onedrive_unlink; done
    log "== deleting $n item(s) in parallel"
    for p in "${DEL_QUEUE[@]}"; do
        if ((DRY)); then wipe "$p"; else wipe "$p" & fi
    done
    wait
    ((DRY)) || log "== deleted $n item(s) in $((SECONDS - t0))s"
}

# ask_delete <path>: asks before deleting one file or folder; returns 1 when you choose quit
ask_delete() {
    local p=$1 short=${1/#$THOME/\~} size warn ans c
    [ "$p" = "$HERE" ] && return 0
    size=$(du -sh -- "$p" 2>/dev/null | cut -f1)
    warn=$([ -d "$p" ] && unsaved_repos "$p")
    if ((DRY)); then
        log "  would ask: delete $short ($size)"
        [ -n "$warn" ] && printf '    ! not pushed yet:\n%s\n' "$warn"
        return 0
    fi
    printf '\n%s (%s)\n' "$short" "$size"
    [ -n "$warn" ] && printf '    ! WORK NOT PUSHED YET, lost if you delete:\n%s\n' "$warn"
    if ((ALL_YES)) && [ -z "$warn" ]; then
        ans=y
    else
        while :; do
            read -r -p "  Delete? [y]es [n]o $([ -d "$p" ] && echo '[i]tem-by-item [l]ist ')[a]ll remaining [q]uit: " ans </dev/tty || ans=q
            case $ans in
                l) [ -d "$p" ] && ls -lA -- "$p" | head -40; continue ;;
                i)
                    [ -d "$p" ] || continue
                    for c in "$p"/* "$p"/.[!.]*; do ask_delete "$c" || return 1; done
                    return 0 ;;
                a) ALL_YES=1; ans=y ;;
                y | n | q) ;;
                *) continue ;;
            esac
            break
        done
    fi
    case $ans in
        q) return 1 ;;
        n) log "  kept $short"; return 0 ;;
    esac
    if [ -n "$warn" ]; then
        read -r -p "  This has unpushed work. Type DELETE to delete it anyway: " c </dev/tty
        [ "$c" = DELETE ] || { log "  kept $short"; return 0; }
    fi
    DEL_QUEUE+=("$p")
    log "  will delete $short"
}

delete_files() {
    local p items=() c
    for p in "$THOME/WorkSpace" "$THOME/claude" "$THOME/dotfiles" "$THOME/Files" "$THOME/c" "$THOME/fedora" \
        "$THOME/Android" "$THOME/go" "$THOME/Postman" "$THOME/OneDrive" "$THOME"/{Desktop,Documents,Downloads,Pictures,Videos,Music,Templates,Public} \
        "${EXTRA_DELETE[@]/#\~/$THOME}"; do
        [ -e "$p" ] || continue
        c=$(find "$p" -mindepth 1 -maxdepth 1 ! -path "$HERE" -print -quit 2>/dev/null)
        [ -n "$c" ] && items+=("$p")
    done
    say ""
    say "  !!! --delete PERMANENTLY deletes your files: no Trash, no undo !!!"
    say "  It asks before each folder ([i] goes inside a folder and asks per file)."
    say "  ${HERE/#$THOME/\~} (this script + logs) is kept; delete it yourself at the very end."
    say "  Copy anything you want to keep (USB drive, OneDrive web, git push) BEFORE you go on."
    say ""
    for p in "${items[@]}"; do say "    ${p/#$THOME/\~}"; done
    say ""
    if ((DRY)); then
        for p in "${items[@]}"; do ask_delete "$p"; done
        return 0
    fi
    [ -t 0 ] || { say "--delete needs a terminal to ask you questions."; return 1; }
    read -r -p "  Type DELETE to start: " c </dev/tty
    [ "$c" = DELETE ] || { say "  Nothing deleted."; return 1; }
    say "  (Nothing is deleted until you have answered every question.)"
    for p in "${items[@]}"; do ask_delete "$p" || { log "  stopped asking (quit)"; break; }; done
    if ((${#DEL_QUEUE[@]})); then
        say ""
        say "  About to delete:"
        for p in "${DEL_QUEUE[@]}"; do say "    ${p/#$THOME/\~}"; done
        read -r -p "  Type DELETE to delete these now: " c </dev/tty
        [ "$c" = DELETE ] || { say "  Nothing deleted."; DEL_QUEUE=(); return 1; }
    fi
    delete_queue_run
}

# ---------------------------------------------------------------- main

# every part runs at the same time; each writes its own log, and the logs are joined in order at
# the end. Package removals are queued and done in one apt run once all parts have finished.
run_mods() {
    local m pid id t0=$SECONDS
    declare -A part=()
    log "== starting ${#MODS[@]} parts in parallel: ${MODS[*]}"
    for m in "${MODS[@]}"; do
        (
            CUR=$m
            s=$SECONDS
            log "== $(describe "$m")"
            "mod_$m"
            extra_remove "$m"
            log "== finished in $((SECONDS - s))s"
        ) >"$JOBDIR/part-$m.log" 2>&1 &
        part[$!]=$m
    done
    while ((${#part[@]})); do
        wait -n -p id
        log "  done: ${part[$id]} ($((SECONDS - t0))s)"
        unset "part[$id]"
    done
    say ""
    for m in "${MODS[@]}"; do cat "$JOBDIR/part-$m.log"; say ""; done
    apt_queue_run
}

finish() {
    FAILS=$(cat "$JOBDIR/fails" 2>/dev/null | wc -l)
    log "== done in $((SECONDS / 60))m $((SECONDS % 60))s$( ((DRY)) && echo ' (dry run, nothing changed)'). Failed steps: $FAILS"
    ((DRY)) || log "   Log out and back in (or restart) so GNOME, the keyboard and the shell pick up the defaults."
    if ((WORKER)) && ! ((DRY)); then
        as_user notify-send "Reset to stock finished" "Failed steps: $FAILS. Log: $LOG" 2>/dev/null
        [ "$EUID" -eq 0 ] && chown -R "$TUSER:" "$LOGDIR"
    fi
}

while (($#)); do
    case "$1" in
        -h | --help | help) usage; exit 0 ;;
        -n | --dry-run) DRY=1 ;;
        -y | --yes) YES=1 ;;
        --all) MODS+=("${ORDER[@]}"); BG=1 ;;
        --bg | --background) BG=1 ;;
        --delete) DELETE=1 ;;
        --list) for m in "${ORDER[@]}"; do printf '%-11s %s\n' "$m" "$(describe "$m")"; done; exit 0 ;;
        --worker) WORKER=1 ;;
        --user) TUSER=$2; shift ;;
        -*) say "Unknown option: $1 (see ./reset-to-stock.sh help)"; exit 2 ;;
        *)
            IFS=, read -ra parts <<<"$1"
            for p in "${parts[@]}"; do
                p=$(canon "$p")
                [ -n "$(describe "$p")" ] || { say "Unknown part: $p (see ./reset-to-stock.sh --list)"; exit 2; }
                MODS+=("$p")
            done ;;
    esac
    shift
done

THOME="$(getent passwd "$TUSER" | cut -d: -f6)"
TUID="$(id -u "$TUSER")"
[ -n "$THOME" ] && [ -d "$THOME" ] || { say "Can't find the home folder of $TUSER"; exit 1; }
if [ "$EUID" -eq 0 ] && ! ((WORKER)); then
    say "Run this as your normal user, not with sudo. It asks for your sudo password when it needs it."
    exit 1
fi

# keep the canonical order, drop duplicates
sel=" ${MODS[*]-} "
MODS=()
for m in "${ORDER[@]}"; do [[ "$sel" == *" $m "* ]] && MODS+=("$m"); done
((${#MODS[@]} || DELETE)) || { usage; exit 0; }

mkdir -p "$LOGDIR"
JOBDIR="$(mktemp -d)"
trap 'rm -rf "$JOBDIR"' EXIT
: >"$JOBDIR/apt-queue"
: >"$JOBDIR/apt-auto"
: >"$JOBDIR/fails"
if ((WORKER)); then
    LOG="${RESET_LOG:-$LOGDIR/latest.log}"
    log "== background reset as $TUSER: ${MODS[*]}"
    run_mods
    finish
    exit 0
fi

LOG="$LOGDIR/reset-$STAMP.log"
: >"$LOG"
ln -sfn "$(basename "$LOG")" "$LOGDIR/latest.log"
exec > >(tee -a "$LOG") 2>&1
log "== reset-to-stock $( ((DRY)) && echo '(dry run) ')as $TUSER. Log: $LOG"

if ((DELETE)); then
    delete_files || { ((${#MODS[@]})) && say "Stopping here; the reset parts were not run."; exit 1; }
fi
((${#MODS[@]})) || { finish; exit 0; }

say ""
say "Parts to reset:"
for m in "${MODS[@]}"; do printf '  %-11s %s\n' "$m" "$(describe "$m")"; done
needs_root=0
for m in "${MODS[@]}"; do [[ $ROOT_MODS == *" $m "* ]] && needs_root=1; done

if ((DRY)); then
    say ""
    run_mods
    finish
    exit 0
fi

if ! ((YES)); then
    [[ " ${MODS[*]} " == *" logins "* ]] && say "  'logins' deletes your SSH keys, git/GitHub/Claude logins and browser profiles. Push your repos first."
    read -r -p "Type yes to continue: " ans </dev/tty
    [ "$ans" = yes ] || { say "Nothing changed."; exit 1; }
fi
((needs_root)) && { sudo -v || { say "sudo failed; nothing changed."; exit 1; }; }

if ((BG)); then
    starter=()
    ((needs_root)) && starter=(sudo)
    "${starter[@]}" env RESET_LOG="$LOG" setsid -f bash "$SELF" --worker --user "$TUSER" "${MODS[@]}" >>"$LOG" 2>&1 </dev/null
    say ""
    say "Running in the background. You can close this terminal; you get a notification when it is done."
    say "Follow it:  tail -f $LOGDIR/latest.log"
    exit 0
fi

run_mods
finish
