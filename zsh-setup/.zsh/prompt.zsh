# ============================================================================
#  ~/.zsh/prompt.zsh — native two-line prompt (replaces Powerlevel9k)
# ----------------------------------------------------------------------------
#  Reproduces the look I liked from Powerlevel9k using only built-in zsh:
#    left line : OS icon · user · path · (lock if unwritable) · git · venv
#    input line: colored ➜ (green on success, red on failure)
#    right side: exit status · last-command duration · clock · date
#
#  Git info comes from zsh's built-in `vcs_info`. The icon style is chosen by
#  $ZSH_PROMPT_ICONS (see ~/.zsh/config.zsh): plain, emoji, or nerd-font.
#  Everything here (glyphs, colors, thresholds) is safe to tweak.
# ============================================================================

zmodload zsh/datetime 2>/dev/null            # provides $EPOCHREALTIME (command timing)
autoload -Uz add-zsh-hook vcs_info           # hook helper + git/vcs prompt engine
setopt prompt_subst                          # allow $(...) and ${...} inside prompts

# ------------------------- Icon set (from config) --------------------------
# ZSH_PROMPT_ICONS picks the glyph set (see ~/.zsh/config.zsh). Icons that sit
# before text carry a trailing space so empty ones collapse with no gap.
: ${ZSH_PROMPT_ICONS:=nerd-font}             # safety default if sourced standalone
: ${ZSH_PROMPT_SHOW_HOST:=false}
case "$ZSH_PROMPT_ICONS" in
  plain)                                      # symbols in any preinstalled font
    _os_icon='' ; _home_icon='⌂ ' ; _clock_icon='' ; _cal_icon='' ; _git_icon='⎇' ; _lock_icon=''
    ;;
  emoji)                                      # system emoji, no font to install
    case "$OSTYPE" in
      darwin*) _os_icon='🍎 ' ;;
      linux*)  _os_icon='🐧 ' ;;
      *)       _os_icon='💻 ' ;;
    esac
    _home_icon='🏠 ' ; _clock_icon='🕐 ' ; _cal_icon='📅 ' ; _git_icon='🌿' ; _lock_icon='🔒'
    ;;
  *)                                          # nerd-font (default): JetBrainsMono FA
    case "$OSTYPE" in
      darwin*) _os_icon=$' ' ;;         # apple
      linux*)  _os_icon=$' ' ;;         # tux
      *)       _os_icon=$' ' ;;         # laptop
    esac
    _home_icon=$' ' ; _clock_icon=$' ' ; _cal_icon=$' ' ; _git_icon=$'' ; _lock_icon=$''
    ;;
esac

# Username segment: with or without the hostname (user@host).
[[ $ZSH_PROMPT_SHOW_HOST == true ]] && _user='%n@%m' || _user='%n'

# ----------------------- Git / VCS integration (colors) --------------------
zstyle ':vcs_info:*'      enable git                       # only care about git
zstyle ':vcs_info:git:*'  check-for-changes true           # detect dirty/staged state
zstyle ':vcs_info:git:*'  unstagedstr   ' %F{red}✗%f'      # marker: unstaged changes
zstyle ':vcs_info:git:*'  stagedstr     ' %F{green}●%f'    # marker: staged changes
#  ${_git_icon} (from the icon set above) precedes the branch. %b/%c/%u = branch/staged/unstaged.
zstyle ':vcs_info:git:*'  formats       " %F{magenta}${_git_icon} %b%f%c%u"
#  actionformats is used mid-operation (rebase/merge); %a = the action name.
zstyle ':vcs_info:git:*'  actionformats " %F{magenta}${_git_icon} %b%f %F{yellow}(%a)%f%c%u"

# ---------------------------- Python virtualenv ----------------------------
export VIRTUAL_ENV_DISABLE_PROMPT=1          # stop venv from editing PROMPT itself
_venv() {                                    # we render it ourselves, our way
  [[ -n $VIRTUAL_ENV ]] && print -Pn " %F{cyan}(${VIRTUAL_ENV:t})%f"  # (envname)
}

# ----------------- Last-command execution time (like P9k) ------------------
_timer_start() { _timer=$EPOCHREALTIME }     # preexec: stamp start time
_timer_stop()  {                             # precmd: compute & format duration
  _elapsed=""                                # reset each prompt (cleared if unused)
  [[ -z $_timer ]] && return                 # nothing ran (e.g. empty Enter) → skip
  local e=$(( EPOCHREALTIME - _timer ))       # elapsed seconds (float)
  unset _timer
  (( e < 2 )) && return                      # only show for commands >= 2s (tunable)
  local secs=${e%.*}                          # whole seconds only (drop the fraction)
  local h=$(( secs/3600 )) m=$(( (secs/60)%60 )) s=$(( secs%60 ))  # split into h/m/s
  local out=""; (( h )) && out+="${h}h"; (( m )) && out+="${m}m"; out+="${s}s"
  _elapsed="%F{yellow}${out}%f "             # e.g. "3s " shown on the right
}
add-zsh-hook preexec _timer_start            # runs just before a command executes
add-zsh-hook precmd  _timer_stop             # runs just before each prompt is drawn
add-zsh-hook precmd  vcs_info                # refresh git info before each prompt

# -------------------------- Static prompt pieces ---------------------------
_writable() {                                # red lock after the path when cwd isn't writable
  [[ -w $PWD ]] || { [[ -n $_lock_icon ]] && print -Pn " %F{red}${_lock_icon}%f"; }
}

# Status indicator: green tick on success, red cross + exit code on failure.
_status='%(?:%F{green}✓%f:%F{red}✗ %?%f)'

# --------------------------- The prompt itself -----------------------------
# Line 1 = info; line 2 = the input line (mirrors P9k's PROMPT_ON_NEWLINE).
#   %n = username   %m = short host   %~ = cwd   %(?:A:B) = A if last cmd ok else B
PROMPT='%F{white}${_os_icon}%f%F{cyan}${_user}%f %F{blue}${_home_icon}%~%f$(_writable)${vcs_info_msg_0_}$(_venv)
%(?:%F{green}➜%f:%F{red}➜%f) '

# Right prompt: [status] [duration]  <clock>HH:MM   <cal>DD Mon
RPROMPT='${_status} ${_elapsed}%F{244}${_clock_icon}%D{%H:%M}%f %F{240}${_cal_icon}%D{%a %d %b}%f'
