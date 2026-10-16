# ~/.local/bin first on PATH (claude, uv tools, screen-ocr, tmux-restore …)
if test -d ~/.local/bin; and not contains ~/.local/bin $PATH
    set -gx PATH ~/.local/bin $PATH
end
