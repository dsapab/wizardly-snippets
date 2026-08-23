# CHANGELOG

## 2026.08.23.14.01

- Prune old backups on install, keeping only the 10 most recent in `~/.zsh/backups`

## 2026.08.23.13.58

- Rename the directory from `linux-zsh-setup` to `zsh-setup` now that it runs on both macOS and Linux
- Update the installer and README fetch URLs to the new path

## 2026.08.23.13.39

- Detect GNU vs BSD `ls` so colors work on both Linux and macOS
- Source syntax-highlighting and autosuggestions from Homebrew or Linux paths, dropping the per-startup `brew --prefix` call
- Point `ofd` at `open` on macOS and `xdg-open` on Linux

## 2026.08.23.01.27

- Add framework-free native zsh setup replacing Oh My Zsh and Powerlevel9k
- Build the git prompt from zsh's built-in `vcs_info`, with no theme or plugins
- Split config into `core`, `prompt`, `aliases` and `security` modules under `~/.zsh`
- Auto-source `~/.zsh/*.local.zsh` for private, machine-specific config kept out of git
- Add `install.sh` to fetch and install the files with automatic backups
