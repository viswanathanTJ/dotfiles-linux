# Dotfiles

Configs for fish, tmux, Neovim, kitty, VS Code, CopyQ, Mac-style keys (Toshy) and GNOME desktops, kept in git and linked into the home folder with **GNU Stow**. Editing a file here edits the real config, because the real path is a link to the file in this repo.

```
~/.config/kitty/kitty.conf  ->  ~/dotfiles/stow/kitty/.config/kitty/kitty.conf
   (where kitty looks)            (the real file, tracked by git)
```

## Quick start

```fish
./setup.sh                      # help: every app, every command
./setup.sh --dry-run kitty      # preview
./setup.sh kitty tmux code toshy
./setup.sh --status             # what is linked
```

On a new machine:

```fish
sudo apt install git stow       # Fedora: sudo dnf install git stow
git clone <this repo> ~/dotfiles
cd ~/dotfiles
./setup.sh -i                   # asks y/n for each app, shows the plan, then applies
```

## Install the programs (Ubuntu 24.04)

`./setup.sh packages` installs the basics in one go. These are the same steps by hand, one program at a time, plus the apps that come from their vendors. Run them in fish or bash.

### Basics

```fish
sudo apt update
sudo apt install -y git stow curl unzip tmux kitty ripgrep fd-find eza jq btop \
    copyq tesseract-ocr tesseract-ocr-eng wl-clipboard libnotify-bin python3-gi
```

| Package | What it is |
|---|---|
| `git`, `stow` | This repo and the links it makes |
| `tmux` | Terminal sessions that survive closing the window |
| `kitty` | The terminal |
| `ripgrep` (`rg`), `fd-find` (`fdfind`), `eza`, `jq` | Search, find files, `ls` with colours, JSON |
| `btop` | Process monitor (Force Quit, Caps+Shift+Esc) |
| `copyq` | Clipboard history (Alt+Shift+V) |
| `tesseract-ocr*`, `wl-clipboard`, `libnotify-bin`, `python3-gi` | Screen OCR (Alt+Shift+2) |

### fish 4 (official PPA, newer than Ubuntu's)

```fish
sudo add-apt-repository -y ppa:fish-shell/release-4
sudo apt install -y fish
```

Make it your login shell:

```fish
chsh -s /usr/bin/fish                                  # log out and in afterwards
```

### starship prompt

```fish
curl -sS https://starship.rs/install.sh | sh -s -- -y  # installs to /usr/local/bin (asks for sudo)
```

### Font: FiraCode Nerd Font (kitty and VS Code use it)

```fish
mkdir -p ~/.local/share/fonts/FiraCodeNerd
curl -fL --retry 5 -o /tmp/FiraCode.tar.xz https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.tar.xz
tar -xJf /tmp/FiraCode.tar.xz -C ~/.local/share/fonts/FiraCodeNerd --wildcards '*.ttf'
fc-cache -f ~/.local/share/fonts
fc-list | rg -c "FiraCode Nerd Font Mono"              # more than 0 = installed
```

### Neovim (official build; Ubuntu's is old)

```fish
curl -fL -o /tmp/nvim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim; sudo mkdir -p /opt/nvim
sudo tar -C /opt/nvim --strip-components=1 -xzf /tmp/nvim.tar.gz
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
nvim --version | head -1
```

Plugins install themselves the first time you open `nvim`.

### tmux plugins

```fish
git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins                # or inside tmux: Ctrl+a then I (capital i)
```

### GitHub CLI (official apt repo)

```fish
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
sudo apt update; sudo apt install -y gh
gh auth login
```

### VS Code (Microsoft .deb; it adds Microsoft's repo for updates)

```fish
curl -fL -o /tmp/code.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
sudo apt install -y /tmp/code.deb
code --install-extension asvetliakov.vscode-neovim     # the Neovim extension the settings expect
```

### Google Chrome (Google .deb; adds Google's repo for updates)

```fish
curl -fL -o /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y /tmp/chrome.deb
```

### Teams for Linux (project's apt repo)

```fish
sudo mkdir -p /etc/apt/keyrings
sudo curl -fsSL -o /etc/apt/keyrings/teams-for-linux.asc https://repo.teamsforlinux.de/teams-for-linux.asc
echo "deb [signed-by=/etc/apt/keyrings/teams-for-linux.asc arch=amd64] https://repo.teamsforlinux.de/debian/ stable main" | sudo tee /etc/apt/sources.list.d/teams-for-linux.list
sudo apt update; sudo apt install -y teams-for-linux
```

### Toshy (Mac-style keys)

Install as your normal user, not with sudo (it asks for the password itself), then log out and in:

```fish
curl -fL -o /tmp/toshy.zip https://github.com/RedBearAK/toshy/archive/refs/heads/main.zip
unzip -o /tmp/toshy.zip -d ~/Downloads/
cd ~/Downloads/Toshy-main; ./setup_toshy.py install
```

### Then the configs

```fish
git clone <this repo> ~/dotfiles; cd ~/dotfiles
./setup.sh -i
```

### Fedora

Same apps, with `dnf`:

```fish
sudo dnf install -y git stow fish tmux kitty ripgrep fd-find eza jq btop copyq \
    tesseract tesseract-langpack-eng wl-clipboard libnotify python3-gobject gnome-shell-extension-appindicator gh
```

starship, the font, Neovim, tmux plugins and Toshy use the same commands as above. Install VS Code and Chrome from their `.rpm` downloads, and Teams for Linux from the `.rpm` on its GitHub releases page.

## Commands

| Command | Does |
|---|---|
| `./setup.sh` or `./setup.sh help` | Help: apps, commands, examples |
| `./setup.sh <app> [<app>...]` | **Apply**: link the repo files. A real file in the way is moved to `~/.dotfiles-backup/<date-time>/` first. Also applies that app's settings (GNOME, Toshy, plugins) |
| `./setup.sh all` | Apply every app |
| `./setup.sh -i` | Interactive: y/n per app, plan, "Go ahead?" |
| `./setup.sh --adopt <app>...` | **Keep this machine's version**: copy the real files into the repo, then link. Check with `git diff` |
| `./setup.sh --reset <app>...` | **Back to the app's defaults**: remove the config from your home folder (plain files are backed up, the repo copy stays) and undo its GNOME/Toshy settings. `.bashrc`/`.profile` get Ubuntu's defaults from `/etc/skel` |
| `./setup.sh --unlink <app>...` | Stop linking: each link becomes a plain copy of the repo file |
| `./setup.sh --status [<app>...]` | Each file: `linked`, `plain file (same as repo)`, `PLAIN FILE, DIFFERS`, or `missing` |
| add `--dry-run` | Show what would happen, change nothing |

Apps can be comma-separated (`kitty,tmux`). Other names work: `code` = vscode, `toshy` = keyboard, `vim` = nvim, `fish` = shell, `btop` = tools, `docker` = podman, `workspaces` = desktops.

## Apps

| App | Files (in `stow/<app>/`) | Settings applied by setup.sh |
|---|---|---|
| `packages` | — | apt/dnf: stow fish tmux kitty git ripgrep fd eza gh jq btop CopyQ Tesseract; Neovim to `/opt/nvim`; starship (sudo) |
| `shell` | fish `config.fish`, `conf.d/` (`00-path`, `10-aliases`, `20-keybindings`), `functions/cbm.fish`, `fish_plugins`; `.bashrc`, `.profile`; `starship.toml` | fisher + plugins |
| `git` | — (personal, not in the repo) | Creates `~/.gitconfig` from `examples/gitconfig.example` and asks your name and email; an existing one is kept |
| `tmux` | `.tmux.conf`, `~/.local/bin/tmux-restore` | Autostart entry (written with this machine's path), tpm + plugins. tmux starts at login and restores sessions; Claude Code panes resume |
| `nvim` | `~/.config/nvim/` | Plugins download on first start |
| `kitty` | `kitty.conf` | — |
| `vscode` | `settings.json`, `keybindings.json` | — |
| `copyq` | — (its config files are all defaults) | Autostart entry that runs CopyQ through XWayland, so it sees the clipboard on Wayland |
| `tools` | `screen-ocr`, `blank-screen` | btop: `proc_sorting = "memory"` (the one btop setting changed) |
| `podman` | fish `docker` → podman wrapper | Docker Hub short names |
| `keyboard` | Run or Raise `shortcuts.conf`, fish `reload-shortcuts` | GNOME shortcuts and extensions (`gnome/settings.sh`), Toshy rules from `keyboard/toshy_user_apps.py`, Toshy preferences, file-watch limit (sudo) |
| `desktops` | `desktop-rules@local` GNOME extension | 4 fixed desktops, Super+Alt+1…4 (Alt+Caps+1…4 via Toshy), app rules on |
| `lock` | fish `autolock`, `autologin` | No password after screen blank or suspend |
| `teams` | — | Teams for Linux `"menubar": "hidden"` |

## Daily use

```fish
cd ~/dotfiles
git status; git diff                  # what changed (edits from any app show up here)
git commit -am "kitty: new split keys"
git tag m2                            # a named checkpoint
git checkout m1 -- stow/kitty         # bring back kitty.conf as it was at m1 (live at once: it's linked)
```


## Personal files (not in the repo)

The repo holds only settings that were changed on purpose, and nothing personal. These stay on each machine; `examples/` has templates:

| File | Template | Created by |
|---|---|---|
| `~/.gitconfig` (name, email, GitHub sign-in) | `examples/gitconfig.example` | `./setup.sh git` (asks name and email) |
| `~/.config/fish/conf.d/90-local.fish` (project folders, machine-only aliases) | `examples/90-local.fish.example` | you: `cp examples/90-local.fish.example ~/.config/fish/conf.d/90-local.fish` |

`.gitignore` lists both, so they can't be committed by accident.

## Things that aren't plain links

| What | Why | How it stays in sync |
|---|---|---|
| **Toshy rules** (`keyboard/toshy_user_apps.py`) | Toshy's `toshy_config.py` is generated and rewritten on upgrade, so it can't be a link | `reload-shortcuts` runs `keyboard/sync-toshy-rules.py`: whichever of the two was edited last wins, so edit either and run `reload-shortcuts` |
| **GNOME settings** (`gnome/settings.sh`) | Stored in GNOME's settings database, not files | Edit `gnome/settings.sh`, then `./setup.sh keyboard` (or `desktops`, `lock`) |
| **Teams setting** | Teams' `config.json` also holds the app's own settings | `./setup.sh teams` adds only `"menubar": "hidden"` |

Some apps save by writing a new file and swapping it in, which can replace a link with a plain file. If `./setup.sh --status` shows `PLAIN FILE, DIFFERS`, run `./setup.sh --adopt <app>` to take that version into the repo and link it again.

## Keyboard (Toshy) on a new machine

1. `./setup.sh keyboard desktops` (extensions and GNOME settings).
2. Install **Toshy** as your normal user, not with sudo:
   ```fish
   curl -fL -o /tmp/toshy.zip https://github.com/RedBearAK/toshy/archive/refs/heads/main.zip
   unzip -o /tmp/toshy.zip -d ~/Downloads/
   cd ~/Downloads/Toshy-main; ./setup_toshy.py install
   ```
3. Log out and back in.
4. `./setup.sh keyboard` again: now that Toshy exists, it adds your rules and preferences.

Full key list: `docs/keyboard-setup-rebuild.md` or `docs/keyboard-wiki.html`.

## Layout

```
setup.sh                  the setup command (run with no arguments for help)
stow/<app>/...            each app's files, laid out like the home folder
gnome/settings.sh         GNOME settings, Toshy rules apply, resets
keyboard/                 toshy_user_apps.py (your Toshy rules), sync-toshy-rules.py
docs/                     keyboard docs, repo-map.html (overview diagrams)
examples/                 templates for the personal files
```

## Not included (on purpose)

Secrets, `fish_variables`, CopyQ history, sign-ins, Toshy's generated config, system setup outside the home folder.

## References

| Topic | Official doc |
|---|---|
| GNU Stow | [Stow manual](https://www.gnu.org/software/stow/manual/stow.html) |
| Git | [Pro Git book](https://git-scm.com/book/en/v2) |
| Toshy | [Toshy on GitHub](https://github.com/RedBearAK/toshy) |
| fish shell | [fishshell.com](https://fishshell.com/) |
| starship | [starship.rs guide](https://starship.rs/guide/) |
| kitty | [kitty install](https://sw.kovidgoyal.net/kitty/binary/) |
| Neovim | [Neovim releases](https://github.com/neovim/neovim/releases) |
| tmux plugin manager | [tpm](https://github.com/tmux-plugins/tpm) |
| GitHub CLI | [cli.github.com](https://cli.github.com/) |
| VS Code on Linux | [VS Code: Linux setup](https://code.visualstudio.com/docs/setup/linux) |
| Nerd Fonts | [nerdfonts.com](https://www.nerdfonts.com/) |
| Teams for Linux | [teams-for-linux on GitHub](https://github.com/IsmaelMartinez/teams-for-linux) |
| GNOME settings | [gsettings(1)](https://manpages.debian.org/testing/libglib2.0-bin/gsettings.1.en.html) |
| GNOME Shell extensions | [gjs.guide: extensions](https://gjs.guide/extensions/) |
