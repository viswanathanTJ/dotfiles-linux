function ccsr --description 'Switch Claude login (ccs NAME), then restart the Claude sessions in tmux that use it, each on its own conversation'
    # Running Claude sessions keep the login they started with, so after ccs each session using
    # ~/.claude (the login ccs changes) is ended (SIGTERM) and started again in its pane with
    # `claude [--model …] --resume <its session id>`, always on ~/.claude (the claude-multiprofile
    # wrapper is bypassed so it can't switch profile). Session ids come from tmux-assistant-resurrect's
    # per-process state files. Busy sessions (replying, or background agents) are listed first and
    # need a yes; with none busy it goes ahead.
    set -l state ~/.local/state/tmux-assistant-resurrect
    set -l pids
    set -l panes
    set -l sids
    set -l models
    set -l labels
    set -l busy 0
    for f in $state/claude-*.json
        set -l pid (string replace -r '.*/claude-(\d+)\.json$' '$1' -- $f)
        kill -0 $pid 2>/dev/null; or continue
        set -l pane (jq -r '.env.tmux_pane // empty' $f)
        set -l sid (jq -r '.session_id // empty' $f)
        test -n "$pane" -a -n "$sid"; or continue
        # the live process's own config dir decides which login it uses
        set -l cfg (string split0 < /proc/$pid/environ 2>/dev/null | string replace -rf '^CLAUDE_CONFIG_DIR=' '')
        if test -n "$cfg"; and test (path resolve $cfg) != (path resolve ~/.claude)
            continue
        end
        set -l where (tmux display -p -t $pane '#I.#P #{pane_title}' 2>/dev/null); or continue
        set -l model
        set -l args (string split0 < /proc/$pid/cmdline)
        for i in (seq 2 (count $args))
            if test "$args[$i]" = --model; and test $i -lt (count $args)
                set model --model (string escape -- $args[(math $i + 1)])
            end
        end
        set -l label "  tab $where"
        if tmux capture-pane -p -t $pane | string match -rq 'esc to interrupt|\d+ (background )?agents?'
            set label "$label   ← BUSY (reply or background agents running; they'll be stopped)"
            set busy (math $busy + 1)
        end
        set -a pids $pid
        set -a panes $pane
        set -a sids $sid
        set -a models "$model"
        set -a labels $label
    end

    if test (count $pids) -eq 0
        ccs $argv; or return 1
        echo "ccsr: no running Claude sessions use ~/.claude; nothing to restart"
        return 0
    end

    echo "ccsr: "(count $pids)" Claude session(s) will restart on the new login:"
    printf '%s\n' $labels
    if test $busy -gt 0
        echo "Warning: $busy busy session(s) will be interrupted (their conversations are kept and resumed)."
        read -l -P "Proceed? [y/N] " answer
        string match -qi y -- $answer; or begin
            echo "ccsr: cancelled; login not changed"
            return 1
        end
    end

    ccs $argv; or return 1
    set -l done 0
    for n in (seq (count $pids))
        set -l pid $pids[$n]
        set -l pane $panes[$n]
        kill -TERM $pid 2>/dev/null
        for t in (seq 20)
            kill -0 $pid 2>/dev/null; or break
            sleep 0.25
        end
        kill -0 $pid 2>/dev/null; and kill -KILL $pid 2>/dev/null
        # wait for the pane's shell to be back at its prompt
        for t in (seq 20)
            string match -q fish -- (tmux display -p -t $pane '#{pane_current_command}'); and break
            sleep 0.25
        end
        tmux send-keys -t $pane -l "env -u CLAUDE_CONFIG_DIR claude $models[$n] --resume $sids[$n]"
        tmux send-keys -t $pane Enter
        set done (math $done + 1)
    end
    echo "ccsr: restarted $done session(s) on the new login"
end
