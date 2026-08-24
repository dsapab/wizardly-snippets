#!/usr/bin/env python3
# =============================================================================
#  build_font.py — self-contained builder for my prompt font
# -----------------------------------------------------------------------------
#  Patches JetBrains Mono (OFL) with the handful of Font Awesome (OFL) icons my
#  zsh prompt uses, and nothing else. No Nerd Fonts assets or tooling involved.
#
#  Run it with a single command:
#      python3 build_font.py
#
#  REQUIREMENT: the FontForge application must be on PATH. FontForge is NOT a
#  pip package; install it from your OS package manager:
#      macOS:         brew install fontforge
#      Debian/Ubuntu: sudo apt install fontforge python3-fontforge
#      Fedora/RHEL:   sudo dnf install fontforge
#
#  The orchestration (downloads, checksums, licenses) runs under plain python3;
#  the actual glyph merge runs under FontForge's own Python via `fontforge
#  -script`. Downloads live in a temp dir that is removed afterwards. Every
#  input is checksummed and recorded in BUILD-PROVENANCE.txt.
# =============================================================================

import os
import sys
import glob
import shutil
import hashlib
import zipfile
import tempfile
import subprocess
import urllib.request

# =============================================================================
#  CONFIG — pinned sources and the exact glyphs to include
# =============================================================================

# Base font: JetBrains Mono, official release (SIL OFL 1.1).
JBM_VERSION = "2.304"
JBM_URL = (
    "https://github.com/JetBrains/JetBrainsMono/releases/download/"
    f"v{JBM_VERSION}/JetBrainsMono-{JBM_VERSION}.zip"
)

# Icons: Font Awesome 4.7, pulled from the OFFICIAL repo. This webfont maps the
# icons to exactly the codepoints below, so a straight copy lands them in place.
FA_TAG = "4.7.0"
FA_URL = (
    "https://github.com/FortAwesome/Font-Awesome/raw/"
    f"v{FA_TAG}/fonts/fontawesome-webfont.ttf"
)

# The ONLY glyphs my prompt uses (codepoint -> human name, for logs).
GLYPHS = {
    0xF015: "home",
    0xF017: "clock",
    0xF073: "calendar",
    0xF109: "laptop",
    0xF126: "code-fork",   # git branch indicator
    0xF179: "apple",       # macOS OS icon
    0xF17C: "linux",       # Linux OS icon
}

# Weights to patch.
WEIGHTS = ["Regular", "Bold"]

# Output family name (distinct from stock JetBrains Mono to avoid any confusion).
FAMILY = "JetBrainsMono FA"

# Optional integrity pins: once you trust a build, paste the printed SHA-256 here
# to lock future runs to the exact bytes (leave None for trust-on-first-use).
EXPECT_SHA256 = {
    "jbm_zip": None,
    "fa_ttf": None,
}

# This script lives in (and writes its output to) the fonts/ folder.
OUT_DIR = os.path.dirname(os.path.abspath(__file__))


# =============================================================================
#  PATCH MODE — runs under FontForge's Python:
#      fontforge -quiet -script build_font.py --patch <base> <fa> <out> <style>
#  (kept in this same file so there is only one script to read and ship)
# =============================================================================

if len(sys.argv) == 6 and sys.argv[1] == "--patch":
    import fontforge  # only importable under `fontforge -script`

    base_ttf, fa_ttf, out_ttf, style = sys.argv[2:]
    base = fontforge.open(base_ttf)
    fa = fontforge.open(fa_ttf)

    scale = base.em / float(fa.em)          # bring FA outlines into the base em
    advance = base[ord("A")].width          # monospace cell width (single-width icons)
    target_cy = base.capHeight / 2.0 if base.capHeight > 0 else base.em * 0.35

    for cp in GLYPHS:
        fa.selection.select(("unicode",), cp)
        fa.copy()
        base.selection.select(("unicode",), cp)
        base.paste()
        g = base[cp]
        g.transform((scale, 0, 0, scale, 0, 0))            # scale to base em
        xmin, ymin, xmax, ymax = g.boundingBox()
        dx = (advance - (xmax - xmin)) / 2.0 - xmin        # center horizontally
        dy = target_cy - (ymin + ymax) / 2.0               # center vertically ~cap/2
        g.transform((1, 0, 0, 1, dx, dy))
        g.width = advance

    # Rename so it is clearly our variant, not stock JetBrains Mono.
    base.familyname = FAMILY
    base.fontname = FAMILY.replace(" ", "") + "-" + style
    base.fullname = f"{FAMILY} {style}"
    base.appendSFNTName("English (US)", "Family", FAMILY)
    base.appendSFNTName("English (US)", "SubFamily", style)
    base.appendSFNTName("English (US)", "Fullname", f"{FAMILY} {style}")
    base.appendSFNTName("English (US)", "PostScriptName", base.fontname)
    base.generate(out_ttf)

    # Validate in place: every requested codepoint must exist with an outline.
    missing = [f"U+{cp:04X} {n}" for cp, n in GLYPHS.items()
               if not base[cp].isWorthOutputting()]
    base.close()
    fa.close()
    if missing:
        sys.stderr.write("MISSING glyphs: " + ", ".join(missing) + "\n")
        sys.exit(1)
    sys.exit(0)


# =============================================================================
#  ORCHESTRATOR MODE (plain python3) — helpers
# =============================================================================

def sha256(path):
    """Return the hex SHA-256 of a file."""
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 16), b""):
            h.update(chunk)
    return h.hexdigest()


def fetch(url, dest):
    """Download url to dest and return its SHA-256."""
    print(f"    fetching {url}")
    urllib.request.urlretrieve(url, dest)
    return sha256(dest)


def check_pin(name, digest):
    """Verify a download against EXPECT_SHA256 if a pin is set."""
    expected = EXPECT_SHA256.get(name)
    if expected and expected != digest:
        sys.exit(f"checksum mismatch for {name}:\n  expected {expected}\n  got      {digest}")


def require_fontforge():
    """Ensure the FontForge app is available (installed via the OS package manager)."""
    ff = shutil.which("fontforge")
    if ff is None:
        sys.exit(
            "FontForge was not found on PATH. Install it (it is not a pip package):\n"
            "    macOS:         brew install fontforge\n"
            "    Debian/Ubuntu: sudo apt install fontforge python3-fontforge\n"
            "    Fedora/RHEL:   sudo dnf install fontforge"
        )
    return ff


# =============================================================================
#  ORCHESTRATOR MODE — main
# =============================================================================

def main():
    ff = require_fontforge()
    work = tempfile.mkdtemp(prefix="fontbuild-work-")
    prov = []
    try:
        # --- download pinned inputs ---------------------------------------
        print("[1] downloading pinned sources into a temp dir...")
        jbm_zip = os.path.join(work, "jbm.zip")
        fa_ttf = os.path.join(work, "fontawesome-webfont.ttf")
        jbm_hash = fetch(JBM_URL, jbm_zip);  check_pin("jbm_zip", jbm_hash)
        fa_hash = fetch(FA_URL, fa_ttf);     check_pin("fa_ttf", fa_hash)
        prov += [
            f"JetBrains Mono : v{JBM_VERSION}  sha256={jbm_hash}",
            f"                 {JBM_URL}",
            f"Font Awesome   : v{FA_TAG}  sha256={fa_hash}",
            f"                 {FA_URL}",
            f"FontForge      : {ff} (OS package)",
        ]

        # --- unpack JetBrains Mono ----------------------------------------
        print("[2] unpacking JetBrains Mono...")
        with zipfile.ZipFile(jbm_zip) as z:
            z.extractall(os.path.join(work, "jbm"))

        def find_one(pattern):
            hits = glob.glob(os.path.join(work, "jbm", "**", pattern), recursive=True)
            if not hits:
                sys.exit(f"could not find {pattern} in the JetBrains Mono zip")
            return hits[0]

        # --- patch each weight via FontForge ------------------------------
        print("[3] patching weights via FontForge...")
        outputs = []
        for style in WEIGHTS:
            base = find_one(f"JetBrainsMono-{style}.ttf")
            out = os.path.join(OUT_DIR, f"JetBrainsMonoFA-{style}.ttf")
            print(f"    {style}: {os.path.basename(base)} -> {os.path.basename(out)}")
            subprocess.check_call([ff, "-quiet", "-script", os.path.abspath(__file__),
                                   "--patch", base, fa_ttf, out, style])
            digest = sha256(out)
            print(f"      validated, sha256={digest}")
            prov.append(f"OUTPUT {os.path.basename(out)}  sha256={digest}")
            outputs.append(out)

        # --- write licenses ------------------------------------------------
        print("[4] writing licenses...")
        jbm_ofl_src = find_one("OFL.txt")
        shutil.copyfile(jbm_ofl_src, os.path.join(OUT_DIR, "LICENSE-JetBrainsMono.txt"))
        # Font Awesome 4.7 font is OFL 1.1 too; reuse the same license body with
        # Font Awesome's copyright header so each font ships its own license file.
        ofl_text = open(jbm_ofl_src, encoding="utf-8").read()
        idx = ofl_text.find("This Font Software is licensed")
        body = ofl_text[idx:] if idx != -1 else ofl_text
        fa_license = (
            "Copyright (c) 2016 Dave Gandy / Fonticons, Inc. (https://fontawesome.com)\n\n"
            + body
        )
        with open(os.path.join(OUT_DIR, "LICENSE-FontAwesome.txt"), "w", encoding="utf-8") as fh:
            fh.write(fa_license)

        # --- provenance ----------------------------------------------------
        with open(os.path.join(OUT_DIR, "BUILD-PROVENANCE.txt"), "w", encoding="utf-8") as fh:
            fh.write("Build provenance for the patched prompt font\n")
            fh.write("(generated by build_font.py)\n\n")
            fh.write("\n".join(prov) + "\n")

        print("\nDone. Patched fonts and licenses are in this folder.")
        print("Next: install the TTF in your terminal and select 'JetBrainsMono FA'.")
    finally:
        shutil.rmtree(work, ignore_errors=True)


if __name__ == "__main__":
    main()
