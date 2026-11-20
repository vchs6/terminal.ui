#!/usr/bin/env python3
"""Verify the retained C008 input bytes and parse selected source files."""
from collections import Counter
import hashlib
import json
from pathlib import Path, PurePosixPath
import subprocess
import sys


def verify_manifest(root):
    manifest = json.loads((root / "source-manifest.json").read_bytes())
    if manifest["schema"] != "c008-source-manifest-v1":
        raise ValueError("unrecognized source manifest")

    sources = []
    paths = set()
    for entry in manifest["files"]:
        relative = PurePosixPath(entry["path"])
        if relative.is_absolute() or ".." in relative.parts or relative.as_posix() != entry["path"]:
            raise ValueError(f"invalid manifest path: {entry['path']}")
        path = root / relative
        if relative in paths or path.resolve() != path or not path.is_file():
            raise ValueError(f"duplicate, missing, or indirect source: {relative}")
        paths.add(relative)
        content = path.read_bytes()
        if len(content) != entry["bytes"] or hashlib.sha256(content).hexdigest() != entry["sha256"]:
            raise ValueError(f"source digest mismatch: {relative}")
        if bool(path.stat().st_mode & 0o111) != entry["executable"]:
            raise ValueError(f"executable mode mismatch: {relative}")
        sources.append((path, content))
    if not sources:
        raise ValueError("source manifest is empty")
    return sources


def main():
    root = Path(__file__).resolve().parent
    sources = verify_manifest(root)
    checked = Counter()
    for path, content in sources:
        match path.suffix:
            case ".py":
                compile(content, str(path), "exec")
            case ".mjs":
                subprocess.run(["node", "--check", path], check=True)
            case ".sh":
                shell = "sh" if content.startswith(b"#!/bin/sh\n") else "bash"
                subprocess.run([shell, "-n", path], check=True)
            case ".c":
                subprocess.run(
                    ["gcc", "-std=c11", "-fsyntax-only", "-I", root / "operator", path],
                    check=True,
                )
            case _:
                continue
        checked[path.suffix] += 1

    counts = ", ".join(f"{suffix} {count}" for suffix, count in sorted(checked.items()))
    print(f"Verified {len(sources)} C008 source files and modes. Syntax checked: {counts}.")
    print("Source checks complete. Host collection and acceptance remain separate.")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, SyntaxError, subprocess.CalledProcessError) as error:
        sys.exit(str(error))
