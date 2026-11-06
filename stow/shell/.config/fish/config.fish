# Most settings live in conf.d/ (loaded first, in name order) and functions/ (loaded on first use)
starship init fish | source

# >>> claude-multiprofile >>>
# Managed by claude-multiprofile. Edits inside this block may be overwritten.
# Run `claude-multiprofile list` to see what's configured.
# updated 2026-10-28T11:27:28.247Z

function claude-test; CLAUDE_CONFIG_DIR="/home/viswa2k/.claude-test" claude $argv; end
function claude-b; CLAUDE_CONFIG_DIR="/home/viswa2k/.claude-bhakiya" claude $argv; end

# <<< claude-multiprofile <<<
