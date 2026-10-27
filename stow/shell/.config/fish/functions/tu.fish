function tu --description "Tailscale up (Tailscale DNS stays off)"
    sudo tailscale up --netfilter-mode=on --accept-dns=false $argv
end
