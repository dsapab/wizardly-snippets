# ============================================================================
#  ~/.zsh/prompt.zsh — native two-line prompt (replaces Powerlevel9k)
# ----------------------------------------------------------------------------
#  Reproduces the look I liked from Powerlevel9k using only built-in zsh:
#    left line : OS icon · user · path · (lock if unwritable) · git · venv
#    input line: colored ➜ (green on success, red on failure)
#    right side: exit status · last-command duration · clock · date
#
#  Git info comes from zsh's built-in `vcs_info` (the same engine P9k wrapped).
#  Icons () need a Nerd Font in the terminal — iTerm already uses one.
#  Everything here (glyphs, colors, thresholds) is safe to tweak.
# ============================================================================

zmodload zsh/datetime 2>/dev/null            # provides $EPOCHREALTIME (command timing)
autoload -Uz add-zsh-hook vcs_info           # hook helper + git/vcs prompt engine
setopt prompt_subst                          # allow $(...) and ${...} inside prompts

# ─────────────────────── Git / VCS integration (colors) ────────────────────
zstyle ':vcs_info:*'      enable git                       # only care about git
zstyle ':vcs_info:git:*'  check-for-changes true           # detect dirty/staged state
zstyle ':vcs_info:git:*'  unstagedstr   ' %F{red}✗%f'      # marker: unstaged changes
zstyle ':vcs_info:git:*'  stagedstr     ' %F{green}●%f'    # marker: staged changes
#  '' is the Nerd Font git-branch glyph. %b = branch, %c = staged, %u = unstaged.
zstyle ':vcs_info:git:*'  formats       ' %F{magenta} %b%f%c%u'
#  actionformats is used mid-operation (rebase/merge); %a = the action name.
zstyle ':vcs_info:git:*'  actionformats ' %F{magenta} %b%f %F{yellow}(%a)%f%c%u'

# ──────────────────────────── Python virtualenv ────────────────────────────
export VIRTUAL_ENV_DISABLE_PROMPT=1          # stop venv from editing PROMPT itself
_venv() {                                    # we render it ourselves, our way
  [[ -n $VIRTUAL_ENV ]] && print -Pn " %F{cyan}(${VIRTUAL_ENV:t})%f"  # (envname)
}

# ───────────────── Last-command execution time (like P9k) ──────────────────
_timer_start() { _timer=$EPOCHREALTIME }     # preexec: stamp start time
_timer_stop()  {                             # precmd: compute & format duration
  _elapsed=""                                # reset each prompt (cleared if unused)
  [[ -z $_timer ]] && return                 # nothing ran (e.g. empty Enter) → skip
  local e=$(( EPOCHREALTIME - _timer ))       # seconds elapsed (float)
  unset _timer
  (( e < 2 )) && return                      # only show for commands >= 2s (tunable)
  local h=$(( e/3600 )) m=$(( (e/60)%60 )) s=$(( e%60 ))  # split into h/m/s
  local out=""; (( h )) && out+="${h}h"; (( m )) && out+="${m}m"; out+="${s}s"
  _elapsed="%F{yellow}${out}%f "             # e.g. "3s " shown on the right
}
add-zsh-hook preexec _timer_start            # runs just before a command executes
add-zsh-hook precmd  _timer_stop             # runs just before each prompt is drawn
add-zsh-hook precmd  vcs_info                # refresh git info before each prompt

# ────────────────────────── Static prompt pieces ───────────────────────────
# Nerd Font glyphs, set via \u escapes so the source stays readable. They are
# interpolated into the prompts below (prompt_subst expands them each render).
case "$OSTYPE" in
  darwin*) _os_icon=$'' ;;              # macOS: Apple logo
  linux*)  _os_icon=$'' ;;              # Linux: Tux
  *)       _os_icon=$'' ;;              # fallback: laptop
esac
_home_icon=$''                          #  home, shown before the path
_clock_icon=$''                         #  clock, shown before the time
_cal_icon=$''                           #  calendar, shown before the date

_writable() {                                # show a red lock when cwd isn't writable
  [[ -w $PWD ]] || print -Pn '%F{red} %f'  #  = lock glyph
}

# Status indicator: green tick on success, red cross + exit code on failure.
_status='%(?:%F{green}✓%f:%F{red}✗ %?%f)'

# ─────────────────────────── The prompt itself ─────────────────────────────
# Line 1 = info; line 2 = the input line (mirrors P9k's PROMPT_ON_NEWLINE).
#   %n = username   %~ = cwd (with ~)   %(?:A:B) = A if last cmd ok else B
PROMPT='%F{white}${_os_icon}%f %F{cyan}%n%f %F{blue}${_home_icon} %~%f$(_writable)${vcs_info_msg_0_}$(_venv)
%(?:%F{green}➜%f:%F{red}➜%f) '

# Right prompt: [status] [duration]  HH:MM   DD Mon
#   %? = last exit status   %D{..} = strftime-formatted date/time
RPROMPT='${_status} ${_elapsed}%F{244}${_clock_icon} %D{%H:%M}%f %F{240}${_cal_icon} %D{%a %d %b}%f'
