function tu --description "Tailscale up (Tailscale DNS off, Tailscale SSH on)"
    sudo tailscale up --netfilter-mode=on --accept-dns=false --ssh $argv
end
