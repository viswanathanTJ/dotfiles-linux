// Wayland paste: CopyQ (XWayland) can't fake keys without GNOME's Remote Desktop prompt,
// so press the paste keys through ydotool's virtual keyboard instead.
// Terminals paste with Ctrl+Shift+V, everything else with Ctrl+V.
global.paste = function() {
    sleep(150)  // let CopyQ hide and GNOME give focus back to your window
    var r = execute('gdbus', 'call', '--session', '--dest', 'org.gnome.Shell',
        '--object-path', '/org/gnome/shell/extensions/FocusedWindow',
        '--method', 'org.gnome.shell.extensions.FocusedWindow.Get')
    var win = r ? str(r.stdout) : ''
    var terminal = /"wm_class":"(kitty|org\.gnome\.Ptyxis|gnome-terminal[^"]*|com\.mitchellh\.ghostty|alacritty|foot|org\.wezfurlong\.wezterm)"/i.test(win)
    var keys = terminal
        ? ['29:1', '42:1', '47:1', '47:0', '42:0', '29:0']   // Ctrl+Shift+V
        : ['29:1', '47:1', '47:0', '29:0']                   // Ctrl+V
    execute.apply(null, ['ydotool', 'key'].concat(keys))
}
