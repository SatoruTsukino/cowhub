#!/usr/bin/env python3
"""Promote staging (luascripts/preview.lua) to production (luascripts/cowhub.lua).

The output is a copy of preview.lua with the staging-only chomp debug log removed:
the log state fields, chomp.log / chomp.flushLog, every call to them, and the
"Chomp Debug Log" toggle. The "Caravan Debug Log" toggle is removed too; its log
helpers stay but never write, since caravan.debug can't turn on without it. The golden-grass probe that feeds that log (Plan 4.1:
chomp.sanitize / goldenState / findNodeById / watchStats, chomp.statConns, the
per-send Golden capture) is removed with it. The window theme is switched from "frost" (staging)
to "rose" (production), per .agents/rules/script_environments.md. It fails,
without writing anything, if any debug reference survives or the theme line
isn't found.

Usage: python3 scripts/promote-preview.py
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "luascripts" / "preview.lua"
DST = ROOT / "luascripts" / "cowhub.lua"

STATE_FIELD = re.compile(r"^\s*(debug = false|logBuf = \{\}|logPath = nil|lastFlush = 0|lastIdleLog = 0|statConns = \{\}),\s*(--.*)?$")
LOG_CALL = re.compile(r"^\s*chomp\.(log|flushLog|watchStats)\(.*\)\s*$")
DEBUG_FUNCS = ("log", "flushLog", "sanitize", "goldenState", "findNodeById", "watchStats")
GOLDEN_LOCAL = re.compile(r"^\s*local golden = chomp\.goldenState\(.*\)\s*$")
GOLDEN_FIELD = re.compile(r", Golden = golden \}")
DEBUG_TOGGLES = {"MainTab": "Chomp Debug Log", "CaravanTab": "Caravan Debug Log"}
DEBUG_IF_LINE = re.compile(r"^\s*if chomp\.debug then .* end\s*$")
THEME = re.compile(r'^(\s*theme = )"frost",\s*$')
LEFTOVER = re.compile(
    r"chomp\.(log|flushLog|debug|logBuf|logPath|lastFlush|lastIdleLog|sanitize|goldenState|findNodeById|watchStats|statConns)\b"
    r"|ChompDebug|chomplogs|Golden probe|\bgolden\b|Caravan Debug Log|Toggle_CaravanDebugLog"
)


def indent(line):
    return len(line) - len(line.lstrip())


def skip_block(lines, i, closer):
    """Index after the line that closes the block opened at lines[i] (same indent)."""
    base = indent(lines[i])
    for j in range(i + 1, len(lines)):
        if indent(lines[j]) == base and lines[j].strip().startswith(closer):
            return j + 1
    sys.exit(f"promote: unclosed block at preview.lua:{i + 1}")


def strip(lines):
    out, i = [], 0
    while i < len(lines):
        line = lines[i]
        s = line.strip()
        if any(s.startswith(f"function chomp.{name}(") for name in DEBUG_FUNCS):
            while out and out[-1].strip().startswith("--"):
                out.pop()  # drop the function's leading comment
            i = skip_block(lines, i, "end")
            while i < len(lines) and not lines[i].strip():
                i += 1  # drop the blank line after the function
            continue
        if s == "if chomp.debug then":
            i = skip_block(lines, i, "end")
            continue
        tab = s[: -len(":CreateToggle({")] if s.endswith(":CreateToggle({") else None
        if tab in DEBUG_TOGGLES and i + 1 < len(lines) and DEBUG_TOGGLES[tab] in lines[i + 1]:
            i = skip_block(lines, i, "})")
            while i < len(lines) and not lines[i].strip():
                i += 1
            continue
        if STATE_FIELD.match(line) or LOG_CALL.match(line) or DEBUG_IF_LINE.match(line) or GOLDEN_LOCAL.match(line):
            i += 1
            continue
        out.append(GOLDEN_FIELD.sub(" }", line))
        i += 1
    return out


def main():
    lines = SRC.read_text().splitlines(keepends=True)
    out = strip(lines)
    themed = 0
    for n, l in enumerate(out):
        m = THEME.match(l)
        if m:
            out[n] = m.group(1) + '"rose",\n'
            themed += 1
    if themed != 1:
        sys.exit(f"promote: expected one frost theme line in preview.lua, found {themed}")
    bad = [f"{n}: {l.strip()}" for n, l in enumerate(out, 1) if LEFTOVER.search(l)]
    if bad:
        sys.exit("promote: debug references left in output:\n" + "\n".join(bad))
    DST.write_text("".join(out))
    print(f"promote: {SRC.name} -> {DST.name} ({len(lines) - len(out)} debug lines removed)")


if __name__ == "__main__":
    main()
