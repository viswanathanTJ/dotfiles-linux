# Most settings live in conf.d/ (loaded first, in name order) and functions/ (loaded on first use)
starship init fish | source

# >>> claude-multiprofile >>>
# Managed by claude-multiprofile. Edits inside this block may be overwritten.
# Run `claude-multiprofile list` to see what's configured.
# updated 2026-10-23T10:18:20.545Z

function claude-c; CLAUDE_CONFIG_DIR="/home/16931/.claude-c" claude $argv; end
function claude-test; CLAUDE_CONFIG_DIR="/home/16931/.claude-test" claude $argv; end
function cw; CLAUDE_CONFIG_DIR="/home/16931/.claude-b" claude $argv; end

# <<< claude-multiprofile <<<

