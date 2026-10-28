# Reset to stock

`reset-to-stock.sh` undoes this repo's setup and your other personal changes, so a work laptop is close to how IT handed it over. Use it before you give the laptop back. It removes:

- Toshy and the keyboard tweaks, GNOME shortcuts, extensions and settings
- personal packages, and the fish login shell
- logins: SSH, git, GitHub, Claude, browsers
- caches

With `--delete` it also deletes your own files, asking before each folder.

It only removes what each part lists. Software your company installed stays, as long as it isn't in those lists. Settings for one machine (what to keep, extra work-tool paths) go in `reset/local.conf`, which isn't in git. The template is [`examples/reset-local.conf.example`](../examples/reset-local.conf.example).

## Before you start

1. **Push your work.** `--delete` lists every git repo with unpushed commits or uncommitted files, so push them or copy them somewhere first.
2. **Copy the personal files** you want to keep to a USB drive or cloud storage.
3. **Run `--delete` before `logins`.** `logins` deletes your SSH keys, so `git push` stops working after it.

## How to run it

```bash
cd ~/dotfiles/reset
./reset-to-stock.sh                      # help
./reset-to-stock.sh --all --delete -n    # dry run of everything: shows what would happen, changes nothing
./reset-to-stock.sh --delete             # delete your files, asking before each folder
./reset-to-stock.sh --all                # reset every part in the background
tail -f logs/latest.log                  # watch the background run
```

| Command / flag | What it does |
|---|---|
| `<part> [<part>…]` | Resets only these parts, now. Example: `./reset-to-stock.sh toshy shortcuts` |
| `--all` | Every part, in the background. It asks `Type yes` and your sudo password first, and you can close the terminal after that. A desktop notification tells you when it's done. |
| `--delete` | Deletes your own files. Type `DELETE` to start, then answer for each folder. It never runs in the background. |
| `-n`, `--dry-run` | Prints every command it would run and changes nothing. Always run this first. |
| `-y`, `--yes` | Skips `Type yes to continue`. `--delete` still asks about each folder. |
| `--bg` | Runs the parts you named in the background, the same way `--all` does. |
| `--list` | Lists the parts. |

Run it as your normal user, not with `sudo`. It asks for your password when a part needs it.

### The `--delete` questions

For each folder it shows the size, plus a warning if a git repo inside has unpushed work.

| Key | Meaning |
|---|---|
| `y` | Delete this folder |
| `n` | Keep it |
| `i` | Go inside the folder and ask about each file or subfolder |
| `l` | List what's inside |
| `a` | Yes to all remaining folders. Repos with unpushed work still ask. |
| `q` | Stop asking |

How deleting works:

- Nothing is deleted while you answer. At the end you see the full list, type `DELETE` again, and then everything goes at once.
- A folder with unpushed work also needs its own `DELETE`.
- Desktop, Documents, Downloads and the other standard folders are emptied and recreated empty.
- Before `~/OneDrive` is deleted, the OneDrive client is signed out. Otherwise its next sync would also delete the files in the cloud.
- The script's own folder is kept, so delete it yourself at the very end.

## Speed: everything runs in parallel

All the parts start at the same time, so a full `--all` should take a few minutes.

- **One apt run.** apt can only run one install or removal at a time, so the parts queue their packages. When every part has finished, one `apt-get purge` removes them all, then `apt-get autoremove` runs.
- **Big folders are deleted with 4 rm workers each.**

The log shows `done: <part>` as each part finishes, then each part's detailed steps in order, so it stays readable.

## The parts

**[sudo]** means the part changes system files.

| Part | What it resets |
|---|---|
| `autostart` | **All** your startup items (`~/.config/autostart`) and user services/timers. A startup file of yours that hid a system startup item is deleted too, so that item comes back. |
| `toshy` [sudo] | Toshy: services, tray, `~/.config/toshy` + backups, its udev rule and `uinput` module, your `input` group membership, and the installers in Downloads |
| `shortcuts` | GNOME shortcuts, custom shortcuts, and the Caps/Shift keyboard options |
| `extensions` | Your GNOME extensions and their settings. Ubuntu's own extensions (dock, tiling, desktop icons) stay. |
| `launchers` | Your menu-entry copies (Wayland flags), Chrome web apps, default-app choices |
| `gnome` | **All** other GNOME settings back to Ubuntu defaults. A backup is saved first as `logs/gnome-settings-<date>.ini` (restore it with `dconf load / < file`). |
| `configs` [sudo] | The lock screen asks for your password again, after the screen blanks and after suspend. It also turns autologin (login without a password) off if it was on, resets the idle and power settings, and removes any config still linked into `~/dotfiles` |
| `shell` [sudo] | Login shell back to bash (removes the sssd override), deletes the fish/starship/tmux/kitty/nvim/btop configs, fresh `.bashrc`/`.profile` from `/etc/skel` |
| `tailscale` [sudo] | `tailscale logout`, then removes Tailscale and its apt repo |
| `rustdesk` [sudo] | Removes RustDesk and its config |
| `wine` [sudo] | Removes Wine (64- and 32-bit), the `~/.wine*` prefixes and Wine's menu entries, and drops the 32-bit (i386) architecture once no 32-bit package is left |
| `apps` [sudo] | Removes the personal packages: ZapZap, Telegram, VibeTyper, CopyQ, kitty, tmux, fish, btop, eza, ripgrep, fd, jq, gh, glow, uv, stow, ydotool, OCR, FileZilla, Flatpak, x11vnc, sshfs, adb, 7zip, Ruby, gedit, Cheese and more. Also Neovim, starship, FiraCode fonts and the fish + dpScreenOCR PPAs. The build libraries Toshy installed are marked "automatic", so `apt autoremove` deletes the ones nothing else needs. fish goes only once it's no longer your login shell. |
| `devstack` [sudo] | MongoDB + Compass, Elasticsearch, Podman (+ the `docker` shim, compose, all containers and images), Go, Obsidian, Postman: packages, apt repos, data in `/var/lib`, configs, and the Podman sub-UID ranges in `/etc/subuid`/`/etc/subgid` |
| `m365` [sudo] | Teams for Linux, the OneDrive client (signed out first, so the cloud files are safe) and Entra SSO for Chrome: packages, apt repos, configs |
| `system` [sudo] | Removes the inotify watch-limit tweak and the touchpad hwdb file, then runs `local_system()` from `local.conf` (system files you changed by hand on that machine) |
| `logins` | Signs out of OneDrive and deletes `~/.ssh` (keys + config), `.gitconfig`, git credentials, GitHub CLI (`gh`), all Claude data (every `~/.claude*` profile, Claude Desktop, state, caches), all Chrome data (profiles, web apps, caches), every other browser profile, GNOME keyrings, GPG, and the logins of Teams, FileZilla, PuTTY, Remmina, TeamViewer, Copilot, Cursor, Genymotion and adb |
| `appdata` | Telegram/ZapZap messages, VS Code/Obsidian/Postman/Compass settings, shell history, recent files |
| `caches` | `~/.cache`, npm, gradle, Trash, core dumps |

Last of all, after apt, the script runs `local_last()` from `local.conf` if there is one. Use it for steps that must come at the very end, such as leaving the `sudo` group.

## Things the script can't do (do these by hand)

| What | Where |
|---|---|
| Remove the laptop's SSH keys from GitHub | https://github.com/settings/keys |
| Revoke the `gh` CLI token | GitHub → Settings → Applications → Authorized OAuth Apps → GitHub CLI |
| Remove the laptop from your Tailscale network | https://login.tailscale.com/admin/machines |
| Unlink WhatsApp and Telegram | Phone → WhatsApp → Linked devices; Telegram → Settings → Devices |
| Podman images and containers | `podman system reset` (asks first) |

## After the reset

Log out and back in, or restart. Check `logs/latest.log`: the last line reports how many steps failed.

## References

| Topic | Official doc |
|---|---|
| Toshy (what its installer adds) | [RedBearAK/toshy](https://github.com/RedBearAK/toshy) |
| `dconf reset` / `dconf dump` | [dconf(1)](https://manpages.ubuntu.com/manpages/noble/man1/dconf.1.html) |
| `sss_override` (login shell override) | [sss_override(8)](https://manpages.ubuntu.com/manpages/noble/man8/sss_override.8.html) |
| `apt-get purge` / `autoremove` | [apt-get(8)](https://manpages.ubuntu.com/manpages/noble/man8/apt-get.8.html) |
| Uninstall Tailscale | [Tailscale: uninstall](https://tailscale.com/kb/1069/uninstall) |
| OneDrive client `--logout` | [abraunegg/onedrive usage](https://github.com/abraunegg/onedrive/blob/master/docs/usage.md) |
| `gh auth logout` | [GitHub CLI manual](https://cli.github.com/manual/gh_auth_logout) |
