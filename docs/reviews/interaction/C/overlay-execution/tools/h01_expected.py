"""Literal native text projection of frozen H01 at actual40x10.
Source: native_fixture.cj fixed labels + design C.6 floor-centered natural boxes.
This is an external capture check, not a replacement/new formal test oracle.
"""
def expected_rows(stage):
    rows=[' '*40 for _ in range(10)];rows[0]='BASE-OVERLAY-READY'.ljust(40)
    if stage in ['confirmation','prevented']:rows[4]=' '*16+'CONFIRM'+' '*17
    elif stage=='escaped-to-popup':rows[4]=' '*17+'POPUP'+' '*18
    elif stage!='base':return None
    return rows
def judge_rows(stage,rows):
    expected=expected_rows(stage)
    if expected is None:return
    # Native printer may omit trailing spaces, never trim text or drop cells.
    normalized=[row.rstrip('\n').ljust(40) for row in rows]
    if normalized!=expected:raise RuntimeError('native cells differ from H01 source/Center projection at '+stage)
