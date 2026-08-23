# ============================================================================
#  ~/.zsh/aliases.zsh — personal, portable command aliases
# ----------------------------------------------------------------------------
#  Generic shortcuts, safe to commit. (General ls/cd aliases live in core.zsh;
#  machine-specific/private aliases live in ~/.zsh/*.local.zsh files.)
# ============================================================================

# Become root, keeping my environment (-E) in an interactive shell (-s).
alias suroot='sudo -E -s'

# Launch IPython via python3 without needing a separate ipython shim.
alias ipython="python3 -c 'import IPython; IPython.terminal.ipapp.launch_new_instance()'"

# ───────────────────────── Git shortcuts (curated) ─────────────────────────
# The most-used git aliases, borrowed from Oh My Zsh's git plugin. All start
# with `g`, so none shadow a real command. Plain git subcommands only.
alias g='git'                       # `g` == `git`
alias gst='git status'              # working-tree status
alias gss='git status -s'           # short/compact status
alias ga='git add'                  # stage file(s)
alias gaa='git add --all'           # stage everything (incl. deletions)
alias gc='git commit -v'            # commit; show the diff in the editor
alias gcmsg='git commit -m'         # commit with an inline message
alias gco='git checkout'            # switch branch / restore files
alias gcb='git checkout -b'         # create and switch to a new branch
alias gb='git branch'               # list/manage branches
alias gbd='git branch -d'           # delete a merged branch
alias gd='git diff'                 # unstaged changes
alias gds='git diff --staged'       # staged changes (what will commit)
alias gp='git push'                 # push
alias gl='git pull'                 # pull
alias gf='git fetch'                # fetch remotes
alias glog='git log --oneline --decorate --graph'         # compact history graph
alias gloga='git log --oneline --decorate --graph --all'  # ...across all branches
alias gsta='git stash push'         # stash current changes
alias gstp='git stash pop'          # re-apply the latest stash
alias gstl='git stash list'         # list stashes

# ──────────────────────── Files & navigation extras ────────────────────────
alias lt='ls -lth'                  # long list, newest first
alias ldot='ls -ld .*'              # list only dotfiles in the current dir
alias dud='du -d 1 -h'              # disk usage of each immediate subdir
alias duf='du -sh *'                # disk usage of each item in the current dir
alias ff='find . -type f -name'     # find a file by name, e.g. ff '*.log'

# ────────────────────────────── Shell & tools ──────────────────────────────
alias reload='exec zsh'             # reload the shell after editing config
alias py='python3'                  # shorthand for python3
alias pyserver='python3 -m http.server'   # serve the current dir over HTTP
alias ofd='open .'                  # open the current folder in Finder (macOS)
