"""Keep keyboard/toshy_user_apps.py and Toshy's config (its user_apps section) in sync.

Whichever was edited last wins. Called by the fish function reload-shortcuts.
Usage: python3 -I sync-toshy-rules.py ~/.config/toshy/toshy_config.py ~/dotfiles/keyboard/toshy_user_apps.py
"""
import os
import re
import sys

cfg, repo = sys.argv[1], sys.argv[2]
pat = r"###  SLICE_MARK_START: user_apps .*?###  SLICE_MARK_END: user_apps [^\n]*"
live_text = open(cfg).read()
m = re.search(pat, live_text, re.S)
if not m:
    sys.exit("user_apps section not found in " + cfg)
live, mine = m.group(0), open(repo).read().rstrip("\n")
if live == mine:
    sys.exit(0)
if os.path.getmtime(cfg) > os.path.getmtime(repo):
    open(repo, "w").write(live + "\n")
    print("Toshy rules: copied your edits from Toshy's config into the repo (" + repo + ")")
else:
    open(cfg, "w").write(re.sub(pat, lambda _: mine, live_text, count=1, flags=re.S))
    print("Toshy rules: applied the repo version to Toshy's config")
