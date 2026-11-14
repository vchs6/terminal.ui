"""Frozen ordinary-case host oracle; actual host identity/PNG inspected separately."""
import sys
sys.dont_write_bytecode = True
import argparse
import json
import pathlib
from oracle import verify_wire, verify_native, verify_records, verify_termios_snapshots


def verify(out, case_id):
    matrix = json.loads((pathlib.Path(__file__).parent / 'cases.json').read_text())
    case = next(item for item in matrix['cases'] if item['id'] == case_id)
    before = json.loads((out / 'host-before.json').read_text())['observations']
    after = json.loads((out / 'host-after.json').read_text())['observations']
    cursor = {'set': 'visible', 'reset': 'hidden', 'unknown': 'unknown'}[before['25']['state']]
    status = {'visible': 'original-visible', 'hidden': 'original-hidden', 'unknown': 'unknown-timeout'}[cursor]
    records = {p.name: p.read_text() for p in out.iterdir() if p.is_file() and p.name in {
        'complete', 'assertion', 'closed-1', 'closed-2', 'error-1', 'error-2', 'primary-1', 'extras-1', 'prevented'}}
    assert (out / 'direct.exit').read_text().strip() == '0'
    verify_termios_snapshots(out)
    raw = (out / 'wire.bin').read_bytes()
    if case_id.startswith('initial-'):
        assert records.get('complete') == 'yes' and 'assertion' not in records
        assert records.get('closed-1') == records.get('closed-2') == '0/0/0/0'
        assert records.get('error-1') == case['first_primary'] and 'error-2' not in records
        count = 1 if case_id in ('initial-getter', 'initial-mount') else 2
        assert raw.count(b'\x1b[?25$p') == raw.count(b'\x1b[?2004h') == raw.count(b'\x1b[?2004l') == count
        assert (out / 'probe-2').read_text() == status
        native = (out / 'native.tsv').read_text()
        assert native.count('open\t0\t0') == native.count('close\t0\t0') == 2
        assert native.count('raw-active\t1\t0') == native.count('buffer-released\t1') == 2
        assert native.count('buffer-free\t') == count
        assert native.count('signal-flags\t') == 6 and not any(row.endswith('\t0') for row in native.splitlines() if row.startswith('signal-flags'))
    else:
        verify_records(records, case); verify_native((out / 'native.tsv').read_text(), case['close_failure'])
        verify_wire(raw, cursor)
        host_auto = (out / 'session-policy').read_text() == 'Auto/NoTitleRequest'
        count = 0 if host_auto else 2
        assert raw.count(b'\x1b[22;2t') == raw.count(b'\x1b[23;2t') == count
        if host_auto: assert b'\x1b]2;' not in raw
        for number in (1, 2):
            assert (out / f'probe-{number}').read_text() == (out / f'state-{number}').read_text() == status
            assert (out / f'title-closed-{number}').read_text() == ('Auto/NoTitleScope' if host_auto else 'RestoreSentUnconfirmed')
    if cursor == 'unknown':
        assert not any(seq in raw for seq in (b'\x1b[?25h',b'\x1b[?25l',b'\x1b[?25s',b'\x1b[?25r'))

    if cursor != 'unknown':
        assert before['25']['responseHex'] == after['25']['responseHex'], 'actual host original mode25 restored'
        literal = b'\x1b[?25;1$y' if cursor == 'visible' else b'\x1b[?25;2$y'
        assert (out / 'input.bin').read_bytes().count(literal) >= (1 if case_id.startswith('initial-') else 2), 'actual forwarded host reports both runs'
    if after['2004']['state'] != 'unknown':
        assert after['2004']['state'] == 'reset', 'owned disable, independent of prior2004'
    result = {'passed': True, 'case': case_id, 'cursor': cursor,
        'prior2004Observation': before['2004'], 'post2004Observation': after['2004'],
        'titleProtocol': 'Auto no title request/scope; explicit stress RestoreSentUnconfirmed only, actual X11 originals still required',
        'applicationEndpointTermios': 'all defined fields observed before native open and after each safe close; exact same endpoint equality',
        'hostIdentityAndPNG': 'independent executor/acceptor must verify actual host originals'}
    (out / 'host-check.json').write_text(json.dumps(result, indent=2) + '\n')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(); parser.add_argument('--output', type=pathlib.Path, required=True)
    parser.add_argument('--case', required=True); args = parser.parse_args(); verify(args.output, args.case)
