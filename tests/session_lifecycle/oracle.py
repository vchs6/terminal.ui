"""Literal lifecycle expectations, not a terminal parser or renderer."""
from collections import Counter

QUERY = b'\x1b[?25$p'
PASTE_ON = b'\x1b[?2004h'
PASTE_OFF = b'\x1b[?2004l'
SHOW = b'\x1b[?25h'
HIDE = b'\x1b[?25l'


def verify_wire(raw, cursor):
    assert raw.count(QUERY) == 2, 'exactly one I015 query per real run'
    assert raw.count(PASTE_ON) == 2 and raw.count(PASTE_OFF) == 2, 'each owned 2004 request closed once'
    starts = [i for i in range(len(raw)) if raw.startswith(PASTE_ON, i)]
    for segment in (raw[starts[0]:starts[1]], raw[starts[1]:]):
        assert segment.index(PASTE_ON) < segment.index(QUERY) < segment.index(PASTE_OFF), 'owned mode order'
    if cursor == 'unknown':
        assert not any(b in raw for b in (SHOW, HIDE, b'\x1b[?25s', b'\x1b[?25r')), 'Unknown preserves native visibility'
    else:
        first = raw[starts[0]:starts[1]]
        change, restore = (HIDE, SHOW) if cursor == 'visible' else (SHOW, HIDE)
        assert change in first and restore in first, 'first run actually changes and restores native visibility'
        assert first.rfind(restore) > first.rfind(change), 'restoration follows actual managed change'
        assert first.rfind(restore) > first.rfind(PASTE_OFF), 'mode restoration order after owned paste cleanup'


def verify_records(records, case):
    assert records.get('complete') == 'yes', 'consumer asserts public resources/restart isolation'
    assert 'assertion' not in records, records.get('assertion')
    assert records.get('closed-1') == records.get('closed-2') == '0/0/0/0', 'both runtime closures observed'
    primary = case['first_primary']
    if primary is None:
        assert 'error-1' not in records, 'ordinary/cancellation run reports no synthetic error'
    else:
        assert primary in records.get('error-1', ''), 'first error remains observable'
        if not case['first_extras']:
            assert records.get('error-1') == primary, 'single failure exact literal primary'
        if case['first_extras']:
            assert records.get('primary-1') == primary, 'business error remains primary'
            for extra in case['first_extras']:
                assert extra in records.get('extras-1', ''), 'cleanup error remains additional'
    if case['close_failure']:
        assert records.get('error-2') == 'terminal restore failed', 'native close injection remains a reported second-run cleanup error'
    else:
        assert 'error-2' not in records, 'restart has no retained first-run failure'
    if case['id'] == 'prevented':
        assert records.get('prevented') == 'yes', 'prevented raw03 was actually consumed'


def verify_native(text, close_failure):
    entries = [line.split('\t') for line in text.splitlines()]
    opened = [entry for entry in entries if entry[0] == 'open']
    closed = [entry for entry in entries if entry[0] == 'close']
    assert [e[0] for e in entries if e[0] in ('open', 'close')] == ['open', 'close', 'open', 'close'], 'single owner closes before next open'
    assert len(opened) == 2 and all(e[1] == '0' for e in opened), 'same-process reopen reacquires real native owner'
    assert len(closed) == 2 and all(e[1:] == ['0', str(int(close_failure))] for e in closed), 'real close called exactly once per run before injection'
    restored = [entry for entry in entries if entry[0] == 'signal-restored']
    assert Counter(e[1] for e in restored) == Counter({'28': 2, '2': 2, '15': 2}), 'Linux WINCH/INT/TERM observations per run'
    assert all(e[2] == '1' for e in restored), 'original handler address and mask restored'

    assert Counter(e[1] for e in entries if e[0] == 'signal-flags' and e[2] == '1') == Counter({'28': 2, '2': 2, '15': 2}), 'all original custom handler flags restored'
    assert [e[1] for e in entries if e[0] == 'raw-active'] == ['1', '1'], 'actual native raw mode both runs'
    assert [e[1] for e in entries if e[0] == 'buffer-released'] == ['1', '1'], 'native tracked buffer freed both runs'
    assert len([e for e in entries if e[0] == 'buffer-free']) == 2, 'real native allocation freed exactly once per run'
    assert [e[1] for e in entries if e[0] == 'competing-open'] == ['-1', '-1'], 'single native owner rejects actual competing open'
