#!/bin/sh
# ============================================================================
#  install.sh — fetch the framework-free zsh config into your home directory
# ----------------------------------------------------------------------------
#  Fetches .zshrc and the .zsh/ directory from the repo (no git clone), after
#  backing up whatever you already have. Private ~/.zsh/*.local.zsh files are
#  left untouched. POSIX sh, so it runs fine piped straight from curl.
#
#  Quick run:
#    curl -fsSL https://raw.githubusercontent.com/dsapab/wizardly-snippets/main/zsh-setup/install.sh | sh
#
#  Override the source with env vars if you forked it:
#    ZSH_SNIPPETS_REPO=you/yourfork ZSH_SNIPPETS_BRANCH=main sh install.sh
# ============================================================================
set -eu

REPO="${ZSH_SNIPPETS_REPO:-dsapab/wizardly-snippets}"
BRANCH="${ZSH_SNIPPETS_BRANCH:-main}"
SUBDIR="zsh-setup"
TOP="$(basename "$REPO")-$BRANCH"     # GitHub tarball top folder, e.g. wizardly-snippets-main

ts="$(date +%Y%m%d-%H%M%S)"
backup="$HOME/.zsh/backups/$ts"
mkdir -p "$backup"

# ── Back up anything we might overwrite (into ~/.zsh so it travels with the config)
if [ -e "$HOME/.zshrc" ]; then
  cp -a "$HOME/.zshrc" "$backup/"
fi
for f in "$HOME"/.zsh/*.zsh; do
  [ -e "$f" ] && cp -a "$f" "$backup/"
done
echo "Backed up existing config to $backup"

# ── Keep only the 10 most recent backups so the folder does not grow forever.
# Timestamped names sort chronologically, so 'sort -r' is newest-first and
# 'tail -n +11' selects everything past the 10 newest. (tail -n +N is POSIX.)
ls -1d "$HOME"/.zsh/backups/*/ 2>/dev/null | sort -r | tail -n +11 | while IFS= read -r old; do
  rm -rf "$old"
done

# ── Fetch only .zshrc and the .zsh/ directory from the repo tarball (no clone)
curl -fsSL "https://codeload.github.com/$REPO/tar.gz/refs/heads/$BRANCH" \
  | tar -xz -C "$HOME" --strip-components=2 \
      "$TOP/$SUBDIR/.zshrc" \
      "$TOP/$SUBDIR/.zsh"

echo "Installed ~/.zshrc and ~/.zsh/"
echo "Start using it now:   exec zsh"
echo "Undo this install:    cp \"$backup/.zshrc\" ~/.zshrc && cp \"$backup\"/*.zsh ~/.zsh/ && exec zsh"
