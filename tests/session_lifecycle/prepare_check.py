"""Tool-only preparation checks. Never import/execute the PTY driver or product."""
import sys
sys.dont_write_bytecode = True
import ast
import copy
import json
import pathlib
import tomllib
from oracle import PASTE_ON, PASTE_OFF, QUERY, SHOW, HIDE, verify_wire, verify_native, verify_records

HERE = pathlib.Path(__file__).resolve().parent
for path in HERE.glob('*.py'):
    ast.parse(path.read_text(), filename=str(path))
manifest = tomllib.loads((HERE / 'cjpm.toml').read_text())
assert manifest['package']['cjc-version'] == '1.2.0'
assert manifest['dependencies']['cjtui']['path'] == '../..'
matrix = json.loads((HERE / 'cases.json').read_text())
assert matrix['status'] == 'formal-author-tests'
assert len(matrix['cases']) == 21 and len({c['id'] for c in matrix['cases']}) == 21
assert matrix['cursor_states'] == ['visible', 'hidden', 'unknown']


def rejects(action):
    try:
        action()
    except AssertionError:
        return
    raise AssertionError('negative fixture was not rejected')


for cursor, change, restore in [('visible', HIDE, SHOW), ('hidden', SHOW, HIDE), ('unknown', b'', b'')]:
    first = PASTE_ON + QUERY + b'BASE' + change + b'LAYER1' + PASTE_OFF + restore
    second = PASTE_ON + QUERY + b'BASE' + PASTE_OFF
    raw = first + second
    verify_wire(raw, cursor)
    rejects(lambda: verify_wire(raw.replace(PASTE_OFF, b'', 1), cursor))
    rejects(lambda: verify_wire(raw.replace(QUERY, b'', 1), cursor))
    if cursor == 'unknown':
        rejects(lambda: verify_wire(raw + SHOW, cursor))
    else:
        rejects(lambda: verify_wire(first[:-len(restore)] + second, cursor))
for case in matrix['cases']:
    records = {'complete': 'yes', 'closed-1': '0/0/0/0', 'closed-2': '0/0/0/0'}
    if case['first_primary']:
        records['error-1'] = case['first_primary']
    if case['first_extras']:
        records['primary-1'] = case['first_primary']
        records['extras-1'] = '\n'.join(case['first_extras'])
    if case['close_failure']:
        records['error-2'] = 'terminal restore failed'
    if case['id'] == 'prevented':
        records['prevented'] = 'yes'
    verify_records(records, case)
    broken = copy.copy(records); del broken['complete']
    rejects(lambda: verify_records(broken, case))
    if case['first_extras']:
        broken = copy.copy(records); broken['extras-1'] = ''
        rejects(lambda: verify_records(broken, case))
for failure in (False, True):
    one = 'open\t0\t0\nraw-active\t1\t0\ncompeting-open\t-1\t0\nbuffer-free\t1\t0\nbuffer-released\t1\t1\n' + ''.join(f'signal-flags\t{n}\t1\n' for n in [28,2,15]) + ''.join(f'signal-restored\t{n}\t1\n' for n in [28, 2, 15]) + f'close\t0\t{int(failure)}\n'
    verify_native(one * 2, failure)
    rejects(lambda: verify_native(one, failure))
    rejects(lambda: verify_native((one * 2).replace('signal-restored\t2\t1', 'signal-restored\t2\t0', 1), failure))
print('PASS tool checks + literal positive/negative oracle fixtures; runtime evidence is separate')
