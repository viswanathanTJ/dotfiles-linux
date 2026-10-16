# codebase-memory-mcp: cbm index|update|delete|list|status|changes|visual
function cbm
    set -l bin codebase-memory-mcp
    set -l sub $argv[1]
    set -e argv[1]

    # resolve a dir (default: cwd) to the indexed project name
    function __cbm_project -a dir
        set -l root (realpath (test -n "$dir"; and echo $dir; or pwd))
        codebase-memory-mcp cli --quiet list_projects --format json --limit 500 \
            | jq -r --arg r $root '.projects[] | select(.root_path == $r) | .name'
    end

    switch "$sub"
        case index i
            # cbm index [dir] [full|moderate|fast]
            set -l dir (realpath (test -n "$argv[1]"; and echo $argv[1]; or pwd))
            set -l mode (test -n "$argv[2]"; and echo $argv[2]; or echo full)
            $bin cli --progress index_repository --repo-path $dir --mode $mode
        case update u
            # cbm update [dir|all]  (re-index; 'all' = every indexed project)
            if test "$argv[1]" = all
                for root in ($bin cli --quiet list_projects --format json --limit 500 | jq -r '.projects[].root_path')
                    echo "==> $root"
                    $bin cli --progress index_repository --repo-path $root
                end
            else
                cbm index $argv
            end
        case delete d rm
            # cbm delete [dir|project-name]
            set -l proj (__cbm_project $argv[1])
            test -z "$proj"; and set proj $argv[1]
            if test -z "$proj"
                echo "cbm: no indexed project for "(pwd) >&2; return 1
            end
            $bin cli delete_project --project $proj
        case list ls l
            $bin cli list_projects --detail stats
        case status s
            set -l proj (__cbm_project $argv[1])
            $bin cli index_status --project $proj --diagnostics summary
        case changes c
            # cbm changes [dir] [base-branch]
            set -l proj (__cbm_project $argv[1])
            set -l base (test -n "$argv[2]"; and echo $argv[2]; or git -C (test -n "$argv[1]"; and echo $argv[1]; or pwd) branch --show-current)
            $bin cli detect_changes --project $proj --base-branch $base
        case visual v ui
            set -l port ($bin config get ui_port 2>/dev/null | string match -r '\d+'; or echo 9749)
            if not curl -s -o /dev/null http://localhost:$port/
                echo "cbm: graph UI not running on :$port (it is served by a running MCP server, e.g. an open Claude session). Enable with: $bin --ui=true" >&2
                return 1
            end
            xdg-open http://localhost:$port/ >/dev/null 2>&1 &
            echo "Opened http://localhost:$port/"
        case '*'
            echo "usage: cbm index [dir] [full|moderate|fast]
       cbm update [dir|all]
       cbm delete [dir|project]
       cbm list | status [dir] | changes [dir] [base]
       cbm visual"
    end
end
