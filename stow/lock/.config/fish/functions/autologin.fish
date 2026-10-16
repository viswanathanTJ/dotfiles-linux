function autologin --description 'Skip the login-screen password (on) or ask for it again (off); needs sudo'
    set -l conf /etc/gdm3/custom.conf
    set -l user (id -un)
    switch "$argv[1]"
        case on
            # keep one backup of the original file, then set the two lines under [daemon]
            sudo cp -n $conf $conf.bak
            and sudo sed -i -e '/^AutomaticLogin/d' -e "/^\[daemon\]/a AutomaticLoginEnable=true\nAutomaticLogin=$user" $conf
            and echo "Auto-login ON for $user (from the next boot or logout)."
            and echo "The keyring stays locked after auto-login: apps may ask for your password once."
        case off
            sudo sed -i '/^AutomaticLogin/d' $conf
            and echo "Auto-login OFF: the login screen asks for the password again."
        case '' status
            if string match -q 'AutomaticLoginEnable=true' < $conf
                echo "Auto-login is ON: "(string match -r '^AutomaticLogin=.*' < $conf)
            else
                echo "Auto-login is OFF."
            end
        case '*'
            echo "Usage: autologin on | off | status"
            return 1
    end
end
