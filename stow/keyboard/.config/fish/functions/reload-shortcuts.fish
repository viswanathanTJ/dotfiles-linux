function reload-shortcuts --description 'Reload Run or Raise and Toshy after editing their configs'
    # Check the Toshy config first: a typo would stop Toshy and leave the keyboard unmapped
    set -l cfg ~/.config/toshy/toshy_config.py

    # Keep the Toshy rules in ~/dotfiles/keyboard/toshy_user_apps.py and Toshy's own config in sync:
    # whichever was edited last wins (Toshy's config can't be a symlink; Toshy rewrites it on upgrade)
    set -l repo ~/dotfiles/keyboard/toshy_user_apps.py
    if test -f $repo
        cp -a $cfg $cfg.bak-reload
        python3 -I ~/dotfiles/keyboard/sync-toshy-rules.py $cfg $repo
        or return 1
    end

    if not ~/.config/toshy/.venv/bin/python -I -m py_compile $cfg
        if test -f $cfg.bak-reload; and not cmp -s $cfg $cfg.bak-reload
            cp -a $cfg.bak-reload $cfg
            echo "The repo's Toshy rules have an error (see above); Toshy's config put back, nothing reloaded."
        else
            echo "Toshy config has an error (see above); nothing reloaded."
        end
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
