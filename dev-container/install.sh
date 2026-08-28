#!/bin/sh
# ============================================================================
#  install.sh — drop the devbox dev-container config into your workspace
# ----------------------------------------------------------------------------
#  Creates your workspace directory (default ~/Workspace) and fetches the
#  .devcontainer/ into it from the repo (no git clone). That directory is the
#  one you open in VS Code and "Reopen in Container" — every project you keep
#  under it then runs inside the same box. An existing .devcontainer is backed
#  up first. POSIX sh, so it runs fine piped straight from curl.
#
#  Quick run (default workspace ~/Workspace):
#    curl -fsSL https://raw.githubusercontent.com/dsapab/wizardly-snippets/main/dev-container/install.sh | sh
#  Pick a different workspace directory:
#    curl -fsSL .../dev-container/install.sh | WORKSPACE_DIR=~/code sh
#
#  Override the source with env vars if you forked it:
#    DEVBOX_REPO=you/yourfork DEVBOX_BRANCH=main sh install.sh
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

REPO="${DEVBOX_REPO:-dsapab/wizardly-snippets}"
BRANCH="${DEVBOX_BRANCH:-main}"
SUBDIR="dev-container"
TOP="$(basename "$REPO")-$BRANCH"          # GitHub tarball top folder
WORKSPACE_DIR="${WORKSPACE_DIR:-$HOME/Workspace}"

printf '%s%sdev-container%s  %sone warm box for every project%s\n' "$BOLD" "$CYAN" "$RESET" "$DIM" "$RESET"
note "source:    $REPO ($BRANCH)"
note "workspace: $WORKSPACE_DIR"

# -- Create the workspace directory -----------------------------------------
step "Preparing workspace"
mkdir -p "$WORKSPACE_DIR"
ok "ready at $WORKSPACE_DIR"

# -- Back up an existing .devcontainer so we never clobber your edits --------
if [ -e "$WORKSPACE_DIR/.devcontainer" ]; then
  ts="$(date +%Y%m%d-%H%M%S)"
  backup="$WORKSPACE_DIR/.devcontainer.backup-$ts"
  step "Backing up current .devcontainer"
  cp -a "$WORKSPACE_DIR/.devcontainer" "$backup"
  ok "saved to $backup"
fi

# -- Fetch only dev-container/.devcontainer/ from the repo tarball (no clone) -
step "Fetching .devcontainer"
curl -fsSL "https://codeload.github.com/$REPO/tar.gz/refs/heads/$BRANCH" \
  | tar -xz -C "$WORKSPACE_DIR" --strip-components=2 \
      "$TOP/$SUBDIR/.devcontainer"
ok "installed $WORKSPACE_DIR/.devcontainer/"

# -- Done --------------------------------------------------------------------
printf '\n%s%s✓ All set.%s\n' "$BOLD" "$GREEN" "$RESET"
note "next:  open $WORKSPACE_DIR in VS Code, then run 'Dev Containers: Reopen in Container'"
note "then:  keep your projects under $WORKSPACE_DIR and open them from inside the box"
