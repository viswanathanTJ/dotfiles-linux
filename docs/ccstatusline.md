# ccstatusline setup (Claude Code status line)

ccstatusline 2.2.32, installed globally with npm (`npm install -g ccstatusline`; with nvm it lands in `~/.nvm/versions/node/<version>/bin/`).

What it shows:

```
Model: Opus | ⎇ master | (+0,-0) | ~/W/P/app
Session: 6.0% | Weekly: 80.0% | Reset: 2hr 47m | you@example.com
```

| Row | Widgets |
|---|---|
| 1 | model · context length · git branch · git changes · current folder (fish style, no `cwd:` label) |
| 2 | session usage · weekly usage · reset timer · signed-in account email (custom command) |

## Files in this repo

| File | What it is | Goes to |
|---|---|---|
| `stow/tools/.config/ccstatusline/settings.json` | ccstatusline's own settings (rows, widgets, colours) | `~/.config/ccstatusline/settings.json` (linked by `./setup.sh tools`) |
| `examples/claude-statusLine.json` | The `statusLine` block that makes Claude Code run ccstatusline | merged into `~/.claude/settings.json` |

## Set it up on another machine

1. Install ccstatusline (needs Node.js):
   ```
   npm install -g ccstatusline
   ```
2. Link the ccstatusline settings from this repo:
   ```
   ./setup.sh tools
   ```
3. Tell Claude Code to use it. Add the block from `examples/claude-statusLine.json` to `~/.claude/settings.json`, or merge it with jq (keeps your other settings; makes a backup first):
   ```
   cp ~/.claude/settings.json ~/.claude/settings.json.bak
   jq -s '.[0] * .[1]' ~/.claude/settings.json examples/claude-statusLine.json > /tmp/s.json && mv /tmp/s.json ~/.claude/settings.json
   ```
   For a Claude profile (`CLAUDE_CONFIG_DIR`, for example `~/.claude-b`), do the same with that folder's `settings.json`.
4. Needs `jq` for the email widget: `sudo apt install jq`.
5. Start Claude Code; the status line appears after the first message.

To change it later, run `npx ccstatusline` (or `ccstatusline` with no input) for its settings screen, or edit `settings.json` directly.

## How it was built

Starting point: row 1 = model, context, git branch, git changes; row 2 = session usage, weekly usage, a `jj-workspace` widget, reset timer.

### 1. Account email (row 2, custom command)

Claude Code's `/status` reads the email from the signed-in account it saves in `.claude.json`: `~/.claude.json` normally, or `$CLAUDE_CONFIG_DIR/.claude.json` when a profile is used. The Custom Command widget runs:

```
sh -c 'jq -r ".oauthAccount.emailAddress // empty" "${CLAUDE_CONFIG_DIR:-$HOME}/.claude.json"'
```

| Part | What it does |
|---|---|
| `sh -c '…'` | Runs it in `sh`, so it also works when typed in fish (fish doesn't understand `${VAR:-default}`) |
| `jq -r '.oauthAccount.emailAddress'` | Reads the email field; `-r` prints it without quotes |
| `// empty` | Prints nothing instead of `null` when not signed in |
| `${CLAUDE_CONFIG_DIR:-$HOME}` | The profile's folder if one is in use, otherwise the home folder |

Added through the settings screen: edit line 2, add widget **Custom Command**, paste the command.

### 2. Removed "no jj" (row 2)

The `jj-workspace` widget shows **Jujutsu** workspaces. Jujutsu (`jj`) is a version-control tool that works on top of Git repositories; it's not used here, so the widget only ever said "no jj". It and the separator next to it were removed.

### 3. Current folder (row 1, after git)

Added the `current-working-dir` widget (blue) after git changes, with two options:

| Option in `settings.json` | Settings-screen name | Effect |
|---|---|---|
| `"rawValue": true` | raw value | Hides the `cwd:` label |
| `"metadata": {"fishStyle": "true"}` | fish style | Home becomes `~`, every folder but the last is cut to its first letter: `/home/you/WorkSpace/Project/app` → `~/W/P/app` |

Other options this widget has: `"segments": "2"` (show only the last N folders in full) and `"abbreviateHome": "true"` (only replace the home folder with `~`). `fishStyle` replaces both.

The edits were made directly in `settings.json` with jq (backup first), then checked by feeding ccstatusline sample input:

```
echo '{"cwd":"'$PWD'","workspace":{"current_dir":"'$PWD'"},"model":{"display_name":"Opus"}}' | ccstatusline
```

(bash syntax; that's how Claude Code sends it data on every refresh.)

## References

| Topic | Link |
|---|---|
| ccstatusline | [github.com/sirmalloc/ccstatusline](https://github.com/sirmalloc/ccstatusline) |
| Claude Code status line (`statusLine` setting) | [code.claude.com/docs/en/statusline](https://code.claude.com/docs/en/statusline) |
| Jujutsu | [jj-vcs.github.io/jj](https://jj-vcs.github.io/jj/latest/) |
