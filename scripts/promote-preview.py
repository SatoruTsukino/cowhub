#!/usr/bin/env python3
"""Promote staging (luascripts/preview.lua) to production (luascripts/cowhub.lua).

Production is kept at parity with staging (user request, 2026-11-08): the output is
preview.lua with only these changed:
  - window theme "frost" (staging) -> "rose" (production), per .agents/rules/script_environments.md
  - self-reload links .../luascripts/preview.lua -> .../luascripts/cowhub.lua
The staging-only chomp debug log stays in, off by default (Chomp Debug Log toggle).
It fails, without writing anything, if the theme line isn't found exactly once or a
preview.lua link survives.

Usage: python3 scripts/promote-preview.py
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "luascripts" / "preview.lua"
DST = ROOT / "luascripts" / "cowhub.lua"

THEME = re.compile(r'^(\s*theme = )"frost",\s*$', re.M)
LINK = "/luascripts/preview.lua"


def main():
    text = SRC.read_text()
    text, themed = THEME.subn(r'\1"rose",', text)
    if themed != 1:
        sys.exit(f"promote: expected one frost theme line in preview.lua, found {themed}")
    links = text.count(LINK)
    text = text.replace(LINK, "/luascripts/cowhub.lua")
    if "preview.lua" in text.replace("-- Cow Hub", ""):
        bad = [f"{n}: {l.strip()}" for n, l in enumerate(text.splitlines(), 1) if "preview.lua" in l]
        sys.exit("promote: preview.lua references left in output:\n" + "\n".join(bad))
    DST.write_text(text)
    print(f"promote: {SRC.name} -> {DST.name} (theme rose, {links} link(s) retargeted)")


if __name__ == "__main__":
    main()
