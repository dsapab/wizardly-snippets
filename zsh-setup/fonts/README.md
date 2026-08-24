# Prompt font (JetBrains Mono + a few Font Awesome icons)

This is the font my zsh prompt uses. It is JetBrains Mono with seven Font Awesome icons merged in, and nothing else.

## Why I build it myself

My prompt shows a small set of icons: an OS logo, a home marker, a clock, a calendar, and a git branch. Those glyphs are not in ordinary fonts. The usual fix is a prebuilt Nerd Font, but I did not want to go that way. The Meslo font I had traces back to Apple's Menlo and still carries an Apple copyright and trademark, so its license is murky, and I would rather not depend on the Nerd Fonts project's prebuilt binaries either.

So I patch my own from two first-party projects under clear open licenses: JetBrains Mono for the text, Font Awesome for the icons. The build is reproducible and every download is checksummed, so I know exactly what went in.

## What it contains

JetBrains Mono, Regular and Bold, with these seven glyphs copied from Font Awesome 4.7:

`home U+F015 · clock U+F017 · calendar U+F073 · laptop U+F109 · code-fork U+F126 · apple U+F179 · linux U+F17C`

The family is renamed `JetBrainsMono FA` so it never clashes with a stock JetBrains Mono install. Nothing else is added, which keeps the file small and the licensing simple.

## Rebuilding it

FontForge does the merge, and it is not a pip package, so install it from your OS first:

```
macOS:          brew install fontforge
Debian/Ubuntu:  sudo apt install fontforge python3-fontforge
Fedora/RHEL:    sudo dnf install fontforge
```

Then run the one command:

```
python3 build_font.py
```

The script downloads the pinned JetBrains Mono release and the Font Awesome webfont into a temp dir, merges the seven glyphs through FontForge, checks that every one made it in, and writes the patched TTFs, the two license files, and `BUILD-PROVENANCE.txt` into this folder. The temp dir is deleted when it finishes.

## Installing the font

Building it does not install it. Copy the TTF into your OS font directory, then select `JetBrainsMono FA` in your terminal.

```
macOS:  cp JetBrainsMonoFA-*.ttf ~/Library/Fonts/
Linux:  cp JetBrainsMonoFA-*.ttf ~/.local/share/fonts/ && fc-cache -f
```

## Licenses and sources

Both fonts are SIL Open Font License 1.1, and both licenses ship here.

- JetBrains Mono, `LICENSE-JetBrainsMono.txt`, https://github.com/JetBrains/JetBrainsMono
- Font Awesome 4.7, `LICENSE-FontAwesome.txt`, https://github.com/FortAwesome/Font-Awesome
- FontForge (build tool), https://fontforge.org

No Nerd Fonts code or glyphs are used, so nothing from that project needs attributing.
