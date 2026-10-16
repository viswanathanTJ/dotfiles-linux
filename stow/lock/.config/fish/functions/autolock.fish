function autolock --description 'Ask for the password after screen blank and suspend (on) or not (off)'
    switch "$argv[1]"
        case on
            gsettings set org.gnome.desktop.screensaver lock-enabled true
            gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend true
            echo "Auto-lock ON: idle blank, Alt+Caps+L and waking from suspend ask for the password."
        case off
            gsettings set org.gnome.desktop.screensaver lock-enabled false
            gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false
            echo "Auto-lock OFF: idle blank, Alt+Caps+L and waking from suspend need no password. Alt+Caps+Q still locks."
        case '' status
            set -l blank (gsettings get org.gnome.desktop.screensaver lock-enabled)
            set -l suspend (gsettings get org.gnome.desktop.screensaver ubuntu-lock-on-suspend)
            echo "Password after screen blank: $blank"
            echo "Password after suspend (lid close): $suspend"
        case '*'
            echo "Usage: autolock on | off | status"
            return 1
    end
end
