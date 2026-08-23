# ============================================================================
#  ~/.zsh/core.zsh — shell essentials & quality-of-life (native zsh)
# ----------------------------------------------------------------------------
#  Replaces the behaviour Oh My Zsh used to give via its lib/*.zsh files.
#  Sourced from ~/.zshrc. Pure native zsh, no framework, no plugins.
# ============================================================================

# ─────────────────────────── Completion system ─────────────────────────────
# Loads zsh's completion engine (tab-completion for commands, paths, git, ...).
autoload -Uz compinit          # mark compinit as an autoloadable function
compinit -i                    # init completions; -i silently ignores "insecure"
                               # dirs (e.g. group-writable Homebrew dirs) instead
                               # of prompting — matches old ZSH_DISABLE_COMPFIX=true

zmodload -i zsh/complist       # load the completion-list module (menu selection)

# ────────────────────────── Completion styling ─────────────────────────────
zstyle ':completion:*' menu select                       # arrow-key selectable menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case-insensitive matching
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"  # colorize the match list
zstyle ':completion:*' use-cache yes                     # cache slow completions...
zstyle ':completion:*' cache-path "$HOME/.zsh/.zcompcache" # ...here
zstyle ':completion:*' special-dirs true                 # complete . and .. entries

# ───────────────────────────────  History  ─────────────────────────────────
HISTFILE="$HOME/.zsh_history"  # where history is stored
HISTSIZE=50000                 # commands kept in memory for the session
SAVEHIST=10000                 # commands persisted to $HISTFILE

setopt extended_history        # record timestamp + duration for each command
setopt hist_expire_dups_first  # when trimming, drop duplicates before uniques
setopt hist_ignore_dups        # don't record a command identical to the previous
setopt hist_ignore_space       # don't record commands that start with a space
setopt hist_verify             # on history expansion, show it before running
setopt share_history           # share history live across all open shells

# ─────────────────────── Directory navigation & aliases ────────────────────
setopt auto_pushd              # every `cd` pushes onto the directory stack
setopt pushd_ignore_dups       # don't push a directory already on the stack

alias -- -='cd -'              # `-` jumps back to the previous directory
alias ..='cd ..'               # up one level
alias ...='cd ../..'           # up two levels
alias ....='cd ../../..'       # up three levels
alias md='mkdir -p'            # make a directory (and parents)

# ls listing shortcuts (macOS BSD ls flags)
alias ll='ls -lh'              # long listing, human-readable sizes
alias la='ls -lAh'             # long listing incl. dotfiles (except . and ..)
alias l='ls -lah'              # long listing, all files
alias lsa='ls -lah'            # alias kept for muscle memory

# ────────────────────────── Colors for ls / grep ───────────────────────────
export LSCOLORS="Gxfxcxdxbxegedabagacad"  # BSD ls color scheme (matches old OMZ)
alias ls='ls -G'                          # enable colorized output on macOS ls
alias grep='grep --color=auto'            # highlight matches in grep output

# ──────────────────────────── Misc quality-of-life ─────────────────────────
setopt correct                 # offer spelling correction for mistyped commands
setopt interactivecomments     # allow `# comments` on the interactive command line
setopt long_list_jobs          # show jobs in long format (PID etc.)

# ──────────────── Prefix-aware history search on Up/Down arrows ─────────────
# Type the start of a command, then ↑/↓ to cycle only through matching history.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search        # register as ZLE widgets
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search   # Up arrow
bindkey '^[[B' down-line-or-beginning-search # Down arrow
