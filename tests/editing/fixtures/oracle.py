#!/usr/bin/env python3
"""Hand-written TASK118 expectations; no product imports or generated result oracle."""

from dataclasses import dataclass


@dataclass(frozen=True)
class Row:
    name: str
    before: str
    selection: tuple[int, int]
    action: str
    after: str
    next_selection: tuple[int, int]
    text_delta: int
    selection_delta: int
    change_count: int
    issue: str = ""


ROWS = (
    Row("first mount", "e", (0, 0), "mount", "e", (0, 0), 0, 0, 0),
    Row("combining joins base", "e", (1, 1), "text U+0301", "e\u0301", (1, 1), 1, 0, 1),
    Row("same text collapse", "abc", (0, 3), "replace abc", "abc", (3, 3), 0, 1, 0),
    Row("empty no-op", "abc", (3, 3), "replace empty", "abc", (3, 3), 0, 0, 0),
    Row("reverse emoji deletion", "中👩🏽‍💻🇨🇦", (3, 1), "delete", "中", (1, 1), 1, 1, 1),
    Row("single LF paste", "ab", (2, 2), "paste x LF y", "ab", (2, 2), 0, 0, 0,
        "MultilinePasteRejected"),
    Row("single HT paste", "ab", (2, 2), "paste x HT y", "ab", (2, 2), 0, 0, 0,
        "ControlCharacterRejected"),
    Row("multiline CRLF", "A", (1, 1), "paste CRLF B CR C", "A\nB\nC", (5, 5), 1, 1, 1),
    Row("same-value external notify", "abc", (3, 3), "Observable.notify", "abc", (3, 3),
        1, 0, 0),
)

# This is a policy oracle, never a fake SessionResult-producing backend.
CUT_POLICY = {
    "Applied and all identities match": ("delete once", ""),
    "Applied and stale identity": ("retain", "CutStale"),
    "Applied and source CAS loses": ("retain", "CutStale"),
    "SentUnconfirmed": ("retain", "CutUnconfirmed"),
    "Unsupported": ("retain", "ClipboardUnavailable"),
    "Unknown": ("retain", "ClipboardUnavailable"),
    "Failed": ("retain", "ClipboardUnavailable"),
    "SentUnconfirmed and source changed": ("retain", "CutUnconfirmed"),
    "Unsupported and source changed": ("retain", "ClipboardUnavailable"),
    "Unknown and source changed": ("retain", "ClipboardUnavailable"),
    "Failed and source changed": ("retain", "ClipboardUnavailable"),
}

def main() -> None:
    assert len({row.name for row in ROWS}) == len(ROWS)
    assert all(row.text_delta in (0, 1) and row.selection_delta in (0, 1) for row in ROWS)
    assert all(row.change_count == row.text_delta or row.action == "Observable.notify"
               for row in ROWS)
    assert CUT_POLICY["SentUnconfirmed"] == ("retain", "CutUnconfirmed")
    assert CUT_POLICY["Applied and stale identity"] == ("retain", "CutStale")
    print(f"PASS hand-written oracle schema: {len(ROWS)} editing rows, {len(CUT_POLICY)} cut rows")


if __name__ == "__main__":
    main()
