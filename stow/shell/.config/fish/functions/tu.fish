function tu --description "Tailscale up (nodivert: Tailscale keeps its firewall rules switched off, so other software using 100.64.0.0/10 still works; DNS off, SSH on)"
    sudo tailscale up --netfilter-mode=nodivert --accept-dns=false --ssh $argv
end
