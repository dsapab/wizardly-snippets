# ============================================================================
#  ~/.zshrc — native zsh configuration (no Oh My Zsh, no theme framework)
# ----------------------------------------------------------------------------
#  Portable, framework-free zsh setup. Behaviour and prompt are defined in
#  $HOME/.zsh/{core,prompt,aliases,security}.zsh. Machine-specific or private
#  setup goes in $HOME/.zsh/*.local.zsh files, auto-sourced only if present.
#
#  To roll back an install, restore the newest backup the installer saved in
#  $HOME/.zsh/backups/ (see the README for the one-line restore command).
# ============================================================================

# ───────────────────────────────── PATH ────────────────────────────────────
# Personal bin + Homebrew/local ahead of the system path.
export PATH="$HOME/bin:/usr/local/bin:$PATH"

# ───────────────────────── Native zsh config files ─────────────────────────
# Order matters: core (options/completion + ZLE widgets) → prompt → aliases.
source "$HOME/.zsh/core.zsh"      # completion, history, dir aliases, ls colors, QoL
source "$HOME/.zsh/prompt.zsh"    # two-line git-aware prompt
source "$HOME/.zsh/aliases.zsh"   # personal + git/file/shell shortcuts
source "$HOME/.zsh/security.zsh"  # security hardening (Log4Shell mitigation, etc.)

# ─────────────────────────── Environment / tools ───────────────────────────
# Source my bash profile if present (shared exports/functions).
if [ -f "$HOME/.bash_profile" ]; then
    . "$HOME/.bash_profile"
fi

# iTerm2 shell integration (marks, command status, etc.), if installed.
[ -e "$HOME/.iterm2_shell_integration.zsh" ] && source "$HOME/.iterm2_shell_integration.zsh"

# ──────────────────── Command-line UX plugins (Homebrew) ────────────────────
# NOTE: syntax-highlighting must be sourced LATE so it can wrap the ZLE widgets
# defined earlier (e.g. our history-search bindings) before it hooks them.
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"  # colorize typed commands
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"          # fish-like inline suggestions

# ─────────────────── Machine-local extensions (convention) ─────────────────
# Auto-source any ~/.zsh/*.local.zsh files (loaded in alphabetical order).
# These are per-machine / private and NOT committed — drop in as many as you
# like (e.g. work.local.zsh, host.local.zsh). The (N) null-glob qualifier
# makes this a no-op when none exist, so the committed config works anywhere.
for _local_rc in "$HOME"/.zsh/*.local.zsh(N); do
  source "$_local_rc"
done
unset _local_rc
