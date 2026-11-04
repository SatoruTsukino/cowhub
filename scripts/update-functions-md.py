#!/usr/bin/env python3
"""Re-sync the line numbers in FUNCTIONS.md with the scripts they index.

Each row looks like:
  | [N](file:///.../luascripts/<file>.lua#LN) | `name(args)` | description |
The script finds where `name` is defined in <file>.lua and rewrites both N's.
If a name is defined more than once, the definition nearest the old N wins.

Usage: python3 scripts/update-functions-md.py [--check]
  --check  write nothing; exit 1 if any line number is stale.
Unresolved rows are listed on stderr and left unchanged.
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
DOC = ROOT / "FUNCTIONS.md"
ROW = re.compile(
    r"^\| \[(?P<label>(?:preview )?)(?P<n>\d+)\]\((?P<url>file://[^#)]*?/(?P<path>luascripts/[^#)]+))#L\d+\) \| `(?P<name>[\w.:]+)\("
)
_sources = {}


def defs(path, name):
    """1-based line numbers where `name` is defined in path."""
    key = (path, name)
    if key in _sources:
        return _sources[key]
    lines = (ROOT / path).read_text(errors="replace").splitlines()
    parts = re.split(r"[.:]", name)
    qual = r"[.:]".join(map(re.escape, parts))
    pats = [
        re.compile(rf"^\s*(?:local\s+)?function\s+{qual}\s*\("),
        re.compile(rf"^\s*(?:local\s+)?{qual}\s*=\s*function\s*\("),
    ]
    hits = [i + 1 for i, l in enumerate(lines) if any(p.match(l) for p in pats)]
    if not hits and len(parts) > 1:
        # Field defined inside a table constructor: `short = function(` (only if unique)
        short = re.compile(rf"^\s*{re.escape(parts[-1])}\s*=\s*function\s*\(")
        cand = [i + 1 for i, l in enumerate(lines) if short.match(l)]
        if len(cand) == 1:
            hits = cand
    _sources[key] = hits
    return hits


def main():
    check = "--check" in sys.argv
    out, changed, missing = [], 0, []
    for line in DOC.read_text().splitlines(keepends=True):
        m = ROW.match(line)
        if not m:
            out.append(line)
            continue
        old = int(m["n"])
        hits = defs(m["path"], m["name"])
        if not hits:
            missing.append(f"{m['path']}: {m['name']}")
            out.append(line)
            continue
        new = min(hits, key=lambda h: abs(h - old))
        if new != old:
            changed += 1
            head = f"| [{m['label']}{new}]({m['url']}#L{new}) | `{m['name']}("
            line = head + line[m.end():]
        out.append(line)
    for x in missing:
        print(f"update-functions-md: unresolved {x}", file=sys.stderr)
    if check:
        print(f"update-functions-md: {changed} stale line numbers")
        sys.exit(1 if changed else 0)
    if changed:
        DOC.write_text("".join(out))
    print(f"update-functions-md: {changed} line numbers updated, {len(missing)} unresolved")


if __name__ == "__main__":
    main()
