#!/usr/bin/env python3
"""Attribute isolated compiler diagnostics only; never assert runtime behavior."""
import re
import sys
from pathlib import Path

text = re.sub(r"\x1b\[[0-9;]*m", "", Path(sys.argv[1]).read_text())
expected = {8: ("MenuEntry", "undeclared identifier 'MenuEntry'"),
            9: ("HorizontalMenu", "no matching function for operator '()' function call"),
            10: ("PopupMenu", "no matching function for operator '()' function call"),
            11: ("StatusBar", "no matching function for operator '()' function call"),
            12: ("SplitPane", "no matching function for operator '()' function call"),
            13: ("SplitAxis", "undeclared identifier 'SplitAxis'")}
errors = re.findall(r"^error: ([^\n]+)\n\s*==> ([^\n]+):(\d+):(\d+):", text, re.M)
assert len(re.findall(r"^error:", text, re.M)) == 6, text
assert len(errors) == 6, text
seen = set()
for message, source, line, column in errors:
    line = int(line)
    assert line in expected and source.endswith("/missing_targets/src/main.cj"), (message, source, line)
    symbol, want = expected[line]
    assert message == want and line not in seen, (message, want, line)
    assert symbol in Path(sys.argv[2]).read_text().splitlines()[line - 1]
    seen.add(line)
assert "6 errors generated, 6 errors printed." in text
assert not re.search(r"unexpected|cannot import|package.*not found|syntax|macro.*error|not accessible", text, re.I), text
print("GENUINE_TARGET_API_RED MenuEntry HorizontalMenu PopupMenu StatusBar SplitPane SplitAxis; compiler_exit=1; no behavior pass claimed")
