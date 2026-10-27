function sfc --description "Send local clipboard (image or text) to ~/clip.png or ~/clip.txt on a remote host"
    # usage: sfc [host]   host = ssh alias, IP, or user@host (default: fedora)
    set -l host fedora
    if test (count $argv) -ge 1
        set host $argv[1]
    end
    set -l tmp

    if wl-paste -l 2>/dev/null | grep -q '^image/png'
        set tmp (mktemp --suffix=.png)
        wl-paste -t image/png > $tmp
    else if xclip -selection clipboard -t TARGETS -o 2>/dev/null | grep -q image/png
        set tmp (mktemp --suffix=.png)
        xclip -selection clipboard -t image/png -o > $tmp
    else
        set tmp (mktemp --suffix=.txt)
        wl-paste > $tmp 2>/dev/null; or xclip -selection clipboard -o > $tmp
    end

    set -l ext (string match -r '\.\w+$' -- $tmp)
    scp -q $tmp $host:~/clip$ext
    and echo "Sent to ~/clip$ext on $host"
    rm -f $tmp
end
