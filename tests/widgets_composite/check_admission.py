#!/usr/bin/env python3
"""Require fixed accepted commits before future formal consumer execution."""
import json
import subprocess
import sys
from pathlib import Path

NEEDED = ("runtime080", "rich084", "theme088", "glyph097", "interaction_a102",
          "viewport107", "overlay112", "keyboard117", "small157", "composite159")


def main(path, repo):
    data = json.loads(Path(path).read_text(encoding="utf-8"))
    failures = []
    for key in NEEDED:
        row = data.get(key, {})
        sha = row.get("sha", "")
        evidence = row.get("evidence", "")
        if row.get("status") != "accepted" or len(sha) != 40 or not evidence or not Path(evidence).is_file():
            failures.append(f"{key}: no fixed accepted SHA/evidence")
            continue
        result = subprocess.run(["git", "-C", repo, "merge-base", "--is-ancestor", sha, "HEAD"], check=False)
        if result.returncode:
            failures.append(f"{key}: accepted SHA absent from source history")
    for failure in failures:
        print("BLOCKED", failure, file=sys.stderr)
    return 77 if failures else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1], sys.argv[2]))
