# ccs NAME: switch the Claude login to a saved one. Copies claudeAiOauth from
# ~/.claude/.credentials.json.NAME into ~/.claude/.credentials.json (see json_key_swap).
# ccs with no name lists the saved logins.
function ccs --description 'Switch Claude login: ccs NAME (from ~/.claude/.credentials.json.NAME)'
    set -l live ~/.claude/.credentials.json
    if test (count $argv) -eq 0
        echo "Usage: ccs NAME   (copies claudeAiOauth from $live.NAME)"
        echo "Saved logins:"
        for f in $live.*
            set -l name (string replace -- "$live." '' $f)
            string match -q 'bak' -- $name; or echo "  $name"
        end
        return 1
    end
    set -l saved $live.$argv[1]
    if not test -f $saved
        echo "ccs: no saved login '$argv[1]' ($saved not found). Run 'ccs' to list them." >&2
        return 1
    end
    json_key_swap $saved $live claudeAiOauth
end
