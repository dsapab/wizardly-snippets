# CHANGELOG

## 2026.08.24.01.23

- Add a self-built prompt font in `fonts/`: JetBrains Mono patched with only the seven Font Awesome icons the prompt uses (home, clock, calendar, laptop, git branch, apple, linux)
- Build it reproducibly from official pinned sources with FontForge via `build_font.py`, shipping both OFL licenses and a checksummed provenance record
- Remove the prebuilt Meslo font (ambiguous license) in favour of this OFL-only build

## 2026.08.23.14.31

- Add an OS-aware prompt icon (Apple on macOS, penguin on Linux) plus home, clock and calendar icons
- Show a success/failure status indicator on the right (green tick, or red cross with the exit code)

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
