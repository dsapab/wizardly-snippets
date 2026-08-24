#!/bin/sh
# ============================================================================
#  install.sh — fetch the framework-free zsh config into your home directory
# ----------------------------------------------------------------------------
#  Fetches .zshrc and the .zsh/ directory from the repo (no git clone), after
#  backing up whatever you already have. Private ~/.zsh/*.local.zsh files are
#  left untouched. POSIX sh, so it runs fine piped straight from curl.
#
#  Quick run (default; also installs the bundled JetBrainsMono FA font):
#    curl -fsSL https://raw.githubusercontent.com/dsapab/wizardly-snippets/main/zsh-setup/install.sh | ZSH_PROMPT_ICONS=nerd-font sh
#  No font to install (symbols in any preinstalled font):
#    curl -fsSL .../zsh-setup/install.sh | ZSH_PROMPT_ICONS=plain sh    # or ZSH_PROMPT_ICONS=emoji
#
#  Override the source with env vars if you forked it:
#    ZSH_SNIPPETS_REPO=you/yourfork ZSH_SNIPPETS_BRANCH=main sh install.sh
# ============================================================================
set -eu

# -- Pretty output (colors only when writing to a terminal) ------------------
if [ -t 1 ]; then
  BOLD="$(printf '\033[1m')"; DIM="$(printf '\033[2m')"; GREEN="$(printf '\033[32m')"
  CYAN="$(printf '\033[36m')"; YELLOW="$(printf '\033[33m')"; RESET="$(printf '\033[0m')"
else
  BOLD='' DIM='' GREEN='' CYAN='' YELLOW='' RESET=''
fi
step() { printf '\n%s==>%s %s\n' "$CYAN$BOLD" "$RESET" "$1"; }
ok()   { printf '    %s✓%s %s\n' "$GREEN" "$RESET" "$1"; }
note() { printf '    %s%s%s\n' "$DIM" "$1" "$RESET"; }

REPO="${ZSH_SNIPPETS_REPO:-dsapab/wizardly-snippets}"
BRANCH="${ZSH_SNIPPETS_BRANCH:-main}"
SUBDIR="zsh-setup"
TOP="$(basename "$REPO")-$BRANCH"     # GitHub tarball top folder, e.g. wizardly-snippets-main
ICONS_ENV="${ZSH_PROMPT_ICONS:-}"     # optional icon choice for first install + font step

printf '%s%szsh-setup%s  %sframework-free zsh config%s\n' "$BOLD" "$CYAN" "$RESET" "$DIM" "$RESET"
note "source: $REPO ($BRANCH)"

ts="$(date +%Y%m%d-%H%M%S)"
backup="$HOME/.zsh/backups/$ts"
mkdir -p "$backup"

# -- Back up anything we might overwrite (into ~/.zsh so it travels with the config)
step "Backing up current config"
if [ -e "$HOME/.zshrc" ]; then
  cp -a "$HOME/.zshrc" "$backup/"
fi
for f in "$HOME"/.zsh/*.zsh; do
  [ -e "$f" ] && cp -a "$f" "$backup/"
done
ok "saved to $backup"

# -- Keep only the 10 most recent backups so the folder does not grow forever.
# Timestamped names sort chronologically, so 'sort -r' is newest-first and
# 'tail -n +11' selects everything past the 10 newest. (tail -n +N is POSIX.)
ls -1d "$HOME"/.zsh/backups/*/ 2>/dev/null | sort -r | tail -n +11 | while IFS= read -r old; do
  rm -rf "$old"
done

# -- Fetch only .zshrc and the .zsh/ directory from the repo tarball (no clone)
step "Fetching config"
curl -fsSL "https://codeload.github.com/$REPO/tar.gz/refs/heads/$BRANCH" \
  | tar -xz -C "$HOME" --strip-components=2 \
      "$TOP/$SUBDIR/.zshrc" \
      "$TOP/$SUBDIR/.zsh"

ok "installed ~/.zshrc and ~/.zsh/"

# -- Create the persistent user config ONCE (never overwritten on later updates)
if [ ! -f "$HOME/.zsh/config.zsh" ]; then
  cp "$HOME/.zsh/config.example.zsh" "$HOME/.zsh/config.zsh"
  # On first creation, honor an icon style passed in the install command.
  if [ -n "$ICONS_ENV" ]; then
    tmp="$(mktemp)"
    sed "s/^ZSH_PROMPT_ICONS=.*/ZSH_PROMPT_ICONS=$ICONS_ENV/" "$HOME/.zsh/config.zsh" > "$tmp" && mv "$tmp" "$HOME/.zsh/config.zsh"
  fi
  ok "created ~/.zsh/config.zsh (your settings, kept on future updates)"
else
  ok "kept your existing ~/.zsh/config.zsh"
fi

# -- Effective icon mode: env override, else the value in config.zsh, else default
MODE="$ICONS_ENV"
if [ -z "$MODE" ]; then MODE="$(sed -n 's/^ZSH_PROMPT_ICONS=//p' "$HOME/.zsh/config.zsh" | head -1)"; fi
if [ -z "$MODE" ]; then MODE="nerd-font"; fi

# -- Install the bundled font only in nerd-font mode
step "Prompt icons: $MODE"
if [ "$MODE" = nerd-font ]; then
  case "$(uname -s)" in
    Darwin) fdir="$HOME/Library/Fonts" ;;
    *)      fdir="$HOME/.local/share/fonts" ;;
  esac
  mkdir -p "$fdir"
  for w in Regular Bold; do
    curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/$SUBDIR/fonts/JetBrainsMonoFA-$w.ttf" \
      -o "$fdir/JetBrainsMonoFA-$w.ttf"
  done
  command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$fdir" >/dev/null 2>&1 || true
  ok "installed JetBrainsMono FA into $fdir"
  note "set your terminal font to 'JetBrainsMono FA' to see the icons"
else
  ok "no font needed for '$MODE' mode"
fi

# -- Done --------------------------------------------------------------------
printf '\n%s%s✓ All set.%s\n' "$BOLD" "$GREEN" "$RESET"
note "start now:  exec zsh"
note "roll back:  cp \"$backup/.zshrc\" ~/.zshrc && cp \"$backup\"/*.zsh ~/.zsh/ && exec zsh"
