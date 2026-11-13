#!/usr/bin/env python3
"""Compare public-observation JSON to independent hand-authored expectations."""
import json
import sys
from pathlib import Path

EXPECTED = Path(__file__).with_name("expected.json")


def compare(actual, expected):
    errors = []
    for case_id, fields in expected["cases"].items():
        if case_id not in actual.get("cases", {}):
            errors.append(f"{case_id}: missing observation")
            continue
        observed = actual["cases"][case_id]
        for field, value in fields.items():
            if field not in observed or observed[field] != value:
                errors.append(f"{case_id}.{field}: expected {value!r}; got {observed.get(field, '<missing>')!r}")
    return errors


def self_test(expected):
    cases = expected["cases"]
    assert len(cases) >= 20
    assert cases["M02-manual-move"]["physical_keys"] != cases["M02-manual-move"]["source_keys"]
    assert cases["M02-modified"]["callback_counts"] == [1, 1, 0, 0, 0, 0]
    assert cases["M03-select-stays-open"]["open_after_choose"]
    assert not cases["M03-select-app-close"]["open_after_choose"]
    assert cases["M04-split-horizontal-odd"]["grid"] == ["A  B "]
    sample = {"cases": {key: dict(value) for key, value in cases.items()}}
    assert not compare(sample, expected)
    sample["cases"]["M02-manual-move"]["focus_after"] = ["b"]
    assert any("M02-manual-move.focus_after" in e for e in compare(sample, expected))
    print(f"ORACLE_SELF_TEST_OK {len(cases)} hand-authored cases; mutation rejected")


def main():
    expected = json.loads(EXPECTED.read_text(encoding="utf-8"))
    if len(sys.argv) == 2 and sys.argv[1] == "--self-test":
        self_test(expected)
        return 0
    if len(sys.argv) != 2:
        print("usage: oracle.py --self-test|PUBLIC_OBSERVATION.json", file=sys.stderr)
        return 64
    actual = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    errors = compare(actual, expected)
    for error in errors:
        print(error, file=sys.stderr)
    print(f"ORACLE {'PASS' if not errors else 'FAIL'} {len(expected['cases'])} cases")
    return 0 if not errors else 1


if __name__ == "__main__":
    sys.exit(main())
