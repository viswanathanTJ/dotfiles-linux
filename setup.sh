#!/usr/bin/env bash
# Dotfiles setup with GNU Stow: the files in stow/<app>/ are linked into your home folder,
# so editing a file in this repo changes the real config (and the other way round).
# Run ./setup.sh with no arguments for the help.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
STOW="$HERE/stow"
DRY=0
ACTION=""
NAMES=()
PARTS=(packages shell git tmux nvim kitty vscode copyq tools podman keyboard desktops lock teams)

describe() {
    case "$1" in
        packages) echo "Lists missing programs (fish tmux kitty stow ripgrep eza btop CopyQ Neovim starship …), shows the sudo commands, asks before installing" ;;
        shell)    echo "fish config (conf.d/ aliases, key bindings, functions/), starship prompt, .bashrc, .profile" ;;
        git)      echo "~/.gitconfig from examples/gitconfig.example, asks your name + email (kept if you have one)" ;;
        tmux)     echo "tmux config, plugins, sessions restored at login, Claude Code panes resumed" ;;
        nvim)     echo "Neovim config (plugins download on first start)" ;;
        kitty)    echo "kitty terminal (splits, fonts, shortcuts)" ;;
        vscode)   echo "VS Code settings.json + keybindings.json" ;;
        copyq)    echo "CopyQ: start at login through XWayland so it sees the clipboard on Wayland" ;;
        tools)    echo "Screen OCR and blank-screen scripts; btop sorted by memory" ;;
        podman)   echo "docker -> podman fish wrapper" ;;
        keyboard) echo "Mac-style keys: Toshy rules + preferences, GNOME shortcuts, Run or Raise (checks its prerequisites first: extensions running, Toshy installed)" ;;
        desktops) echo "4 fixed desktops, Alt+Caps+1..4, touchpad: 3-finger app switcher, 4-finger desktops (Wayland)" ;;
        lock)     echo "No password after screen blank or suspend; autolock / autologin commands" ;;
        teams)    echo "Teams for Linux: menu bar hidden (fixes Win+Backspace word delete)" ;;
    esac
}

# other names people type for a part
canon() {
    case "$1" in
        code|vs-code|vsc) echo vscode ;;
        toshy|keys|keymap|shortcuts) echo keyboard ;;
        vim|neovim) echo nvim ;;
        fish|bash|starship|zsh) echo shell ;;
        btop|ocr|bin) echo tools ;;
        docker) echo podman ;;
        workspaces|desktop|apps) echo desktops ;;
        screensaver|autolock) echo lock ;;
        teams-for-linux) echo teams ;;
        *) echo "$1" ;;
    esac
}

usage() {
    local p n
    cat <<EOF
Dotfiles setup (GNU Stow). Repo: $HERE

Each app's config lives in stow/<app>/ laid out like your home folder. "Apply" turns the real
file into a link to the repo file, so an edit in either place is the same edit. A real file that
is in the way is moved to ~/.dotfiles-backup/<date-time>/ first, so nothing is lost.

USAGE
  ./setup.sh <app> [<app>...]        apply these apps (repo version wins), e.g. ./setup.sh kitty tmux code toshy
  ./setup.sh all                     apply every app
  ./setup.sh -i                      interactive: asks y/n for each app, shows the plan, then applies
  ./setup.sh --adopt <app>...        keep THIS machine's version: copy the real files into the repo, then link
  ./setup.sh --reset <app>...        back to the app's own defaults: remove the config (backed up) and undo settings
  ./setup.sh --unlink <app>...       stop linking: links become plain copies of the repo files
  ./setup.sh --status [<app>...]     show each file: linked, plain file (same/differs), or missing
  ./setup.sh help                    this help
  Add --dry-run to any command to see what it would do without changing anything.
  Apps can also be given comma-separated: ./setup.sh kitty,tmux

APPS
EOF
    for p in "${PARTS[@]}"; do
        n=$( [ -d "$STOW/$p" ] && part_files "$p" | wc -l || echo 0)
        printf '  %-9s %-9s %s\n' "$p" "$( [ "$n" -gt 0 ] && echo "${n} file$([ "$n" -gt 1 ] && echo s)" || echo "settings")" "$(describe "$p")"
    done
    cat <<'EOF'

  Other names work too: code = vscode, toshy = keyboard, vim = nvim, fish = shell, btop = tools,
  docker = podman, workspaces = desktops.

  Settings that live in GNOME's database, not in files (keyboard, desktops, lock), are set by
  gnome/settings.sh; Toshy rules come from keyboard/toshy_user_apps.py (reload-shortcuts keeps
  that file and Toshy's own config in sync: whichever was edited last wins).

EXAMPLES
  ./setup.sh kitty                   link kitty.conf (an existing kitty.conf is backed up)
  ./setup.sh --dry-run all           preview a full setup
  ./setup.sh --adopt vscode          VS Code settings changed outside the repo? take them in
  ./setup.sh --reset kitty           kitty back to its defaults (your file stays in the repo)
  ./setup.sh --reset toshy           remove your Toshy rules and GNOME keyboard changes
  ./setup.sh --status                is everything still linked?

AFTER CHANGING THINGS
  cd ~/dotfiles; git status; git diff; git commit -am "what changed"
EOF
}

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
run() { if [ "$DRY" = 1 ]; then echo "    [dry-run] $*"; else eval "$@"; fi; }
have() { command -v "$1" >/dev/null 2>&1; }
pkg_mgr() { if have apt-get; then echo apt; elif have dnf; then echo dnf; else echo unknown; fi; }

# files of a stow part, relative to $HOME
part_files() { if [ -d "$STOW/$1" ]; then (cd "$STOW/$1" && find . \( -type f -o -type l \) | sed 's|^\./||' | sort); fi; }
is_our_link() {   # $1 = path relative to $HOME, $2 = part
    [ -L "$HOME/$1" ] && [ "$(readlink -f "$HOME/$1")" = "$(readlink -f "$STOW/$2/$1")" ]
}

# ---------------------------------------------------------------- arguments
for a in "$@"; do
    case "$a" in
        --dry-run|-n) DRY=1 ;;
        -i|--interactive) ACTION=interactive ;;
        --adopt) ACTION=adopt ;;
        --reset) ACTION=reset ;;
        --unlink) ACTION=unlink ;;
        --status) ACTION=status ;;
        -h|--help|help) usage; exit 0 ;;
        --list) for p in "${PARTS[@]}"; do printf '  %-9s %s\n' "$p" "$(describe "$p")"; done; exit 0 ;;
        all|--all) for p in "${PARTS[@]}"; do NAMES+=("$p"); done ;;
        -*) echo "Unknown option: $a (run ./setup.sh help)"; exit 1 ;;
        *) IFS=',' read -ra bits <<< "$a"; for b in "${bits[@]}"; do [ -n "$b" ] && NAMES+=("$(canon "$b")"); done ;;
    esac
done
[ -z "$ACTION" ] && [ ${#NAMES[@]} -gt 0 ] && ACTION=apply
if [ -z "$ACTION" ]; then usage; exit 0; fi
for p in "${NAMES[@]}"; do
    [ -n "$(describe "$p")" ] || { echo "Unknown app: $p (run ./setup.sh help for the list)"; exit 1; }
done
case "$ACTION" in
    adopt|reset|unlink) [ ${#NAMES[@]} -gt 0 ] || { echo "Name the apps, e.g. ./setup.sh --$ACTION kitty"; exit 1; } ;;
esac

# shellcheck source=gnome/settings.sh
. "$HERE/gnome/settings.sh"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
backup_path() {   # move ~/$1 into the backup folder
    run "mkdir -p \"$BACKUP/$(dirname "$1")\" && mv \"$HOME/$1\" \"$BACKUP/$1\""
}

# ---------------------------------------------------------------- status
if [ "$ACTION" = status ]; then
    [ ${#NAMES[@]} -gt 0 ] || NAMES=("${PARTS[@]}")
    for p in "${NAMES[@]}"; do
        [ -d "$STOW/$p" ] || continue
        printf '\033[1m%s\033[0m\n' "$p"
        while IFS= read -r f; do
            if is_our_link "$f" "$p"; then s="linked"
            elif [ -L "$HOME/$f" ]; then s="LINK ELSEWHERE -> $(readlink "$HOME/$f")"
            elif [ -e "$HOME/$f" ]; then
                if cmp -s "$HOME/$f" "$STOW/$p/$f"; then s="plain file (same as repo)"; else s="PLAIN FILE, DIFFERS"; fi
            else s="missing"; fi
            printf '  %-28s ~/%s\n' "$s" "$f"
        done < <(part_files "$p")
    done
    exit 0
fi

# ---------------------------------------------------------------- interactive choice
declare -A WANT=()
if [ "$ACTION" = interactive ]; then
    echo "Choose what to set up on this machine (Enter = yes, n = no):"
    for p in "${PARTS[@]}"; do
        printf '  \033[1m%-9s\033[0m %s\n            set up? [Y/n] ' "$p" "$(describe "$p")"
        read -r ans || ans=n
        case "$ans" in n|N|no|No) ;; *) WANT[$p]=1 ;; esac
    done
    ACTION=apply
    echo; say "Plan$([ "$DRY" = 1 ] && echo ' (dry run, nothing changes)'):"
    for p in "${PARTS[@]}"; do if [ -n "${WANT[$p]:-}" ]; then printf '    + %s\n' "$p"; fi; done
    if [ "$DRY" = 0 ]; then
        printf 'Go ahead? [Y/n] '; read -r ans || ans=n
        case "$ans" in n|N|no|No) echo "Nothing changed."; exit 0 ;; esac
    fi
else
    for p in "${NAMES[@]}"; do WANT[$p]=1; done
fi
want() { [ -n "${WANT[$1]:-}" ]; }

# ---------------------------------------------------------------- apply helpers
do_packages() {
    local pm missing=() p
    local apt_pkgs=(stow fish tmux kitty git curl unzip jq ripgrep fd-find eza gh btop copyq tesseract-ocr tesseract-ocr-eng wl-clipboard libnotify-bin python3-gi)
    local dnf_pkgs=(stow fish tmux kitty git curl unzip jq ripgrep fd-find eza gh btop copyq tesseract tesseract-langpack-eng wl-clipboard libnotify python3-gobject gnome-shell-extension-appindicator)
    pm=$(pkg_mgr)
    case "$pm" in
        apt) for p in "${apt_pkgs[@]}"; do dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q "ok installed" || missing+=("$p"); done ;;
        dnf) for p in "${dnf_pkgs[@]}"; do rpm -q "$p" >/dev/null 2>&1 || missing+=("$p"); done ;;
        *) echo "No apt or dnf found; install the programs listed in README.md by hand."; return ;;
    esac
    # setup.sh never installs anything itself: it prints the commands for you to run
    local cmds=()
    if [ ${#missing[@]} -gt 0 ]; then
        if [ "$pm" = apt ]; then cmds+=("sudo apt-get update && sudo apt-get install -y ${missing[*]}")
        else cmds+=("sudo dnf install -y ${missing[*]}"); fi
    fi
    if ! have nvim; then
        cmds+=("curl -fL -o /tmp/nvim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
               "sudo rm -rf /opt/nvim; sudo mkdir -p /opt/nvim; sudo tar -C /opt/nvim --strip-components=1 -xzf /tmp/nvim.tar.gz"
               "sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim")
    fi
    if ! have starship; then cmds+=("curl -sS https://starship.rs/install.sh | sh -s -- -y"); fi
    if [ ${#cmds[@]} -eq 0 ]; then
        say "Packages: everything is installed"
        return
    fi
    if [ ${#missing[@]} -gt 0 ]; then say "Packages missing: ${missing[*]}"; fi
    if ! have nvim; then say "Neovim missing (official build goes to /opt/nvim)"; fi
    if ! have starship; then say "starship missing"; fi
    echo "    Commands (they use sudo):"
    for p in "${cmds[@]}"; do printf '      %s\n' "$p"; done
    local ans=n
    if [ "$DRY" = 0 ] && [ -t 0 ]; then
        printf '    Install them now? [y/N] '; read -r ans || ans=n
    fi
    case "$ans" in
        y|Y|yes|Yes)
            for p in "${cmds[@]}"; do eval "$p"; done ;;
        *)
            echo "    Not installed. Run the commands above yourself, then ./setup.sh again."
            echo "    More apps (VS Code, Chrome, Teams for Linux, Toshy): README.md, 'Install the programs'" ;;
    esac
}

link_part() {   # $1 = part; real files in the way are backed up, then Stow links the repo files
    local p=$1 f d gone="" moved=0 linked=0
    [ -d "$STOW/$p" ] || return 0
    have stow || { echo "    GNU Stow is not installed: sudo apt install stow (or ./setup.sh packages)"; exit 1; }
    while IFS= read -r f; do
        if is_our_link "$f" "$p"; then linked=$((linked + 1)); continue; fi
        if [ -n "$gone" ] && [[ "$f" == "$gone"/* ]]; then continue; fi
        # a parent folder that is a link elsewhere (e.g. ~/.config/nvim -> an old dotfiles copy):
        # back up the link itself, not the files inside the folder it points to
        d=$(dirname "$f")
        while [ "$d" != . ]; do
            if [ -L "$HOME/$d" ]; then backup_path "$d"; moved=$((moved + 1)); gone=$d; break; fi
            d=$(dirname "$d")
        done
        if [ -n "$gone" ] && [[ "$f" == "$gone"/* ]]; then continue; fi
        if [ -e "$HOME/$f" ] || [ -L "$HOME/$f" ]; then
            if [ -d "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
                echo "    ~/$f is a folder but the repo has a file there; fix it by hand. Skipping $p."; return 0
            fi
            backup_path "$f"; moved=$((moved + 1))
        fi
    done < <(part_files "$p")
    say "Linking $p ($moved file(s) backed up, $linked already linked)"
    if [ "$DRY" = 1 ]; then
        echo "    [dry-run] stow -d \"$STOW\" -t \"$HOME\" --no-folding --restow $p"
    else
        stow -d "$STOW" -t "$HOME" --no-folding --restow "$p"
    fi
}

adopt_part() {   # copy this machine's real files into the repo first
    local p=$1 f n=0
    while IFS= read -r f; do
        if [ -f "$HOME/$f" ] && [ ! -L "$HOME/$f" ] && ! cmp -s "$HOME/$f" "$STOW/$p/$f"; then
            run "cp -a \"$HOME/$f\" \"$STOW/$p/$f\""; n=$((n + 1))
        fi
    done < <(part_files "$p")
    say "Adopted $n file(s) of $p from this machine into the repo (see: git diff)"
}

apply_extras() {   # $1 = part: the non-file steps
    case "$1" in
        shell)
            if have fish && ! fish -c 'functions -q fisher' 2>/dev/null; then
                say "Installing fish plugins (fisher)"
                run "fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher update' >/dev/null"
            fi ;;
        git)
            if [ -e "$HOME/.gitconfig" ]; then
                echo "    Keeping your ~/.gitconfig (personal; not in this repo). Template: examples/gitconfig.example"
            else
                say "Creating ~/.gitconfig from examples/gitconfig.example"
                run "cp \"$HERE/examples/gitconfig.example\" \"$HOME/.gitconfig\""
                if [ "$DRY" = 0 ] && [ -t 0 ]; then
                    local name email
                    printf '    git name: '; read -r name || true
                    printf '    git email: '; read -r email || true
                    [ -n "$name" ] && git config --global user.name "$name"
                    [ -n "$email" ] && git config --global user.email "$email"
                fi
                echo "    Check it: git config --global --list"
            fi ;;
        tmux)
            # start tmux at login so tmux-continuum restores the last save (path written for this machine)
            local auto="$HOME/.config/autostart/tmux-restore.desktop"
            if [ ! -e "$auto" ]; then
                run "mkdir -p \"$HOME/.config/autostart\" && printf '[Desktop Entry]\\nType=Application\\nName=tmux restore\\nComment=Start tmux at login so tmux-continuum restores the last saved sessions\\nExec=%s/.local/bin/tmux-restore\\nX-GNOME-Autostart-enabled=true\\nNoDisplay=true\\n' \"$HOME\" > \"$auto\""
            fi
            if have tmux && [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
                say "Installing tmux plugin manager (tpm) and plugins"
                run "git clone --depth 1 https://github.com/tmux-plugins/tpm \"$HOME/.tmux/plugins/tpm\""
                run "\"$HOME/.tmux/plugins/tpm/bin/install_plugins\" >/dev/null || true"
            fi ;;
        tools)
            # btop: the only setting changed from its defaults is sorting by memory
            local btop="$HOME/.config/btop/btop.conf"
            if [ -f "$btop" ]; then
                if ! grep -q '^proc_sorting = "memory"' "$btop"; then
                    say "btop: sort processes by memory"
                    run "sed -i 's/^proc_sorting = .*/proc_sorting = \"memory\"/' \"$btop\""
                fi
            else
                say "btop: sort processes by memory"
                run "mkdir -p \"$HOME/.config/btop\" && printf 'proc_sorting = \"memory\"\\n' > \"$btop\""
            fi ;;
        copyq)
            # CopyQ settings changed from its defaults: start at login through XWayland,
            # so it can see clipboard changes on Wayland (also enables autostart)
            local auto="$HOME/.config/autostart/copyq.desktop"
            if ! grep -qs 'QT_QPA_PLATFORM=xcb' "$auto"; then
                say "CopyQ: start at login through XWayland (sees the clipboard on Wayland)"
                if [ -e "$auto" ]; then backup_path ".config/autostart/copyq.desktop"; fi
                run "mkdir -p \"$HOME/.config/autostart\" && printf '[Desktop Entry]\\nType=Application\\nName=CopyQ\\nIcon=copyq\\nExec=env QT_QPA_PLATFORM=xcb copyq\\nX-GNOME-Autostart-Delay=3\\nX-GNOME-Autostart-enabled=true\\n' > \"$auto\""
            fi
            # Enter only copies the item and closes CopyQ (paste with Cmd+V). CopyQ's own paste fakes
            # Ctrl+V through XWayland, which GNOME answers with a "Remote Desktop" permission prompt
            # that eats the key. And CopyQ only sees XWayland windows, so "focus the previous window"
            # focused the wrong one; with it off, GNOME gives focus back to the window you were in.
            local cq="$HOME/.config/copyq/copyq.conf"
            if ! grep -qs '^activate_pastes=false' "$cq" || ! grep -qs '^activate_focuses=false' "$cq"; then
                say "CopyQ: Enter copies the item and returns to your window (paste with Cmd+V)"
                run "env QT_QPA_PLATFORM=xcb copyq --start-server config activate_pastes false >/dev/null"
                run "env QT_QPA_PLATFORM=xcb copyq config activate_focuses false >/dev/null"
            fi ;;
        podman)
            if [ ! -e "$HOME/.config/containers/registries.conf" ]; then
                run "mkdir -p \"$HOME/.config/containers\" && printf 'unqualified-search-registries = [\"docker.io\"]\n' > \"$HOME/.config/containers/registries.conf\""
            fi ;;
        keyboard)
            # prerequisites first (extensions running, then Toshy), see keyboard_ready in gnome/settings.sh
            if have gsettings; then gnome_key_extensions; fi
            if keyboard_ready; then
                if have gsettings; then gnome_keyboard; else echo "    GNOME not found; skipping GNOME keyboard settings"; fi
                toshy_rules
            else
                echo "    GNOME keyboard settings and Toshy rules left unchanged until then."
            fi ;;
        desktops) if have gsettings; then gnome_desktops; fi ;;
        lock)     if have gsettings; then gnome_lock; fi ;;
        teams)    teams_settings ;;
    esac
}

reset_part() {   # $1 = part: config files out (backed up), settings back to defaults
    local p=$1 f n=0
    if [ "$p" = packages ]; then echo "    'packages' has nothing to reset (remove programs with apt/dnf)"; return; fi
    if [ "$p" = git ]; then echo "    'git': your ~/.gitconfig is personal and is left alone"; return; fi
    while IFS= read -r f; do
        if is_our_link "$f" "$p"; then
            run "rm \"$HOME/$f\""; n=$((n + 1))   # just our link: the content is safe in the repo
            if [ -f "/etc/skel/$f" ]; then run "cp /etc/skel/$f \"$HOME/$f\""; fi
        elif [ -e "$HOME/$f" ] || [ -L "$HOME/$f" ]; then
            backup_path "$f"; n=$((n + 1))
            # bash needs a .bashrc / .profile: put back the system default
            if [ -f "/etc/skel/$f" ]; then run "cp /etc/skel/$f \"$HOME/$f\""; fi
        fi
    done < <(part_files "$p")
    say "Reset $p: $n file(s) removed from your home folder (plain files backed up; the repo copy is untouched)"
    case "$p" in
        keyboard) if have gsettings; then reset_keyboard_settings; fi ;;
        desktops) if have gsettings; then reset_desktops_settings; fi ;;
        lock)     if have gsettings; then reset_lock_settings; fi ;;
        teams)    reset_teams_settings ;;
        copyq)    if [ -e "$HOME/.config/autostart/copyq.desktop" ]; then backup_path ".config/autostart/copyq.desktop"; fi ;;
        tmux)     if [ -e "$HOME/.config/autostart/tmux-restore.desktop" ]; then run "rm \"$HOME/.config/autostart/tmux-restore.desktop\""; fi
                  echo "    tmux plugins in ~/.tmux/plugins were left in place" ;;
    esac
}

# ---------------------------------------------------------------- run
[ "$DRY" = 1 ] && say "Dry run: nothing will change"
case "$ACTION" in
    apply|adopt)
        if want packages; then do_packages; fi
        for p in "${PARTS[@]}"; do
            if want "$p"; then
                if [ "$ACTION" = adopt ]; then adopt_part "$p"; fi
                link_part "$p"
                apply_extras "$p"
            fi
        done
        ;;
    unlink)
        for p in "${PARTS[@]}"; do
            want "$p" || continue
            say "Unlinking $p: links become plain copies of the repo files"
            while IFS= read -r f; do
                if is_our_link "$f" "$p"; then run "rm \"$HOME/$f\" && cp -a \"$STOW/$p/$f\" \"$HOME/$f\""; fi
            done < <(part_files "$p")
        done ;;
    reset)
        for p in "${PARTS[@]}"; do if want "$p"; then reset_part "$p"; fi; done ;;
esac

echo
say "Done$([ "$DRY" = 1 ] && echo ' (dry run)')."
if { want keyboard || want desktops; } && [ "$ACTION" != unlink ]; then
    echo "    Log out and back in once so GNOME loads (or unloads) the extensions."
fi
if [ -d "$BACKUP" ]; then echo "    Files that were in the way are in $BACKUP"; fi
echo "    Check the links any time: ./setup.sh --status"
