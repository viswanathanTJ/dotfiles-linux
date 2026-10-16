# Aliases and short commands. fish loads every conf.d/*.fish file at start, in name order.

if command -q nvim
    function vi; nvim $argv; end
    function v; nvim $argv; end
end

if command -q eza
    function l; eza $argv; end
    function ls; eza $argv; end
    function ll; eza -l $argv; end
    function la; eza -la $argv; end
end

function ..; test (count $argv) -gt 0; and for i in (seq 1 (math $argv[1])); cd ..; end; or cd ..; end
function rc_up; for f in ~/.config/fish/conf.d/*.fish; source $f; end; source ~/.config/fish/config.fish; end
function python; python3 $argv; end
function py; python3 $argv; end
function pip; pip3 $argv; end
function e; exit; end
function h; history; end

function co; claude --model opus; end
function cr; claude --resume; end
function ccr; cd ~/claude; and claude --resume $argv; end

# Git functions
function g; git $argv; end
function gm; git merge $argv; end
function ga; git add $argv; end
function gp; git push $argv; end
function gpf; git push -f $argv; end
function gsh; git stash $argv; end
function gr; git reset $argv; end
function grc; git rebase --continue $argv; end
function gri; git rebase -i $argv; end
function grs; git reset --soft $argv; end
function grh; git reset --hard $argv; end
function grb; git rebase $argv; end
function gcl; git clone $argv; end
function gs; git status $argv; end
function gc; git commit $argv; end
function gac; git add -u; git commit -m $argv; end
function gch; git checkout $argv; end
function gchj; git checkout -- "*json" $argv; end
function gchm; git checkout origin/master $argv; end
function gcp; git cherry-pick $argv; end
function gcm; git commit -m $argv; end
function glog; git log $argv; end
function glo; git log --oneline --decorate $argv; end   # glo --author=name, glo -5, glo main..dev
function gb; git branch $argv; end
function G; git add . && git commit -m $argv; end
function gl; git pull origin $argv; end
function glb; git pull origin $(git branch --show-current) $argv; end
function gca; git commit --amend --no-edit $argv; end
function gcap; git commit --amend --no-edit; git push -f $argv; end
function gcb; git branch --show-current; end
function gpm; git pull origin master $argv; end
function gpmp; git pull origin master --no-edit && git push $argv; end
function gf; git fetch $argv; end
function gfrp; git fetch origin master; git rebase origin/master; git push -f $argv; end
function gsfrp; git fetch; git stash; git rebase origin/master; git stash pop; git push -f $argv; end
function gfr; git fetch; git rebase master $argv; end
function gwt; git worktree $argv; end
function modified; git status --porcelain --untracked-files=no | awk "{if (\$1 == \"M\") print \$2}"; end

function nrd; npm run dev -- -H 0.0.0.0 $argv; end

function fu; set arg $argv[1]; set argv $argv[2..-1]; find . -iname "$arg" $argv; end

function t; tmux $argv; end
function tat; tmux attach -t $argv; end
