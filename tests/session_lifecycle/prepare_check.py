"""Tool-only preparation checks. Never import/execute the PTY driver or product."""
import sys
sys.dont_write_bytecode = True
import ast
import copy
import json
import pathlib
import tomllib
import tempfile
import errno
from oracle import PASTE_ON, PASTE_OFF, QUERY, SHOW, HIDE, verify_wire, verify_native, verify_records, verify_termios_snapshots

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
    second = PASTE_ON + QUERY + (SHOW if cursor == 'hidden' else b'') + b'BASE' + PASTE_OFF + (HIDE if cursor == 'hidden' else b'')
    raw = first + second
    verify_wire(raw, cursor)
    rejects(lambda: verify_wire(raw.replace(PASTE_OFF, b'', 1), cursor))
    rejects(lambda: verify_wire(raw.replace(QUERY, b'', 1), cursor))
    if cursor == 'unknown':
        rejects(lambda: verify_wire(raw + SHOW, cursor))
    else:
        rejects(lambda: verify_wire(first[:-len(restore)] + second, cursor))
        if cursor == 'hidden':
            rejects(lambda: verify_wire(first + second[:-len(HIDE)], cursor))
            rejects(lambda: verify_wire(first + second.replace(PASTE_OFF + HIDE, HIDE + PASTE_OFF), cursor))
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
        for extra in ['UNEXPECTED', case['first_extras'][0]]:
            broken = copy.copy(records); broken['extras-1'] += '\n' + extra
            rejects(lambda: verify_records(broken, case))
# A two-extra literal fixture makes ordering independently observable.
ordered = dict(matrix['cases'][10], first_extras=['L020_CLEANUP', 'terminal restore failed'])
ordered_records = dict(complete='yes', **{'closed-1':'0/0/0/0','closed-2':'0/0/0/0','error-1':'L020_CALLBACK','primary-1':'L020_CALLBACK','extras-1':'L020_CLEANUP\nterminal restore failed\n'})
verify_records(ordered_records, ordered)
rejects(lambda: verify_records(dict(ordered_records, **{'extras-1':'terminal restore failed\nL020_CLEANUP\n'}), ordered))
for failure in (False, True):
    one = 'open\t0\t0\nraw-active\t1\t0\ncompeting-open\t-1\t0\nbuffer-free\t1\t0\nbuffer-released\t1\t1\n' + ''.join(f'signal-flags\t{n}\t1\n' for n in [28,2,15]) + ''.join(f'signal-restored\t{n}\t1\n' for n in [28, 2, 15]) + f'close\t0\t{int(failure)}\n'
    verify_native(one * 2, failure)
    rejects(lambda: verify_native(one, failure))
    rejects(lambda: verify_native((one * 2).replace('signal-restored\t2\t1', 'signal-restored\t2\t0', 1), failure))
# Synthetic oracle-development snapshots, not native or host evidence.
with tempfile.TemporaryDirectory(prefix='termios-oracle-fixture-') as temp:
    directory = pathlib.Path(temp)
    fields = {'iflag':1280,'oflag':5,'cflag':191,'lflag':35387,'line':0,
              'cc':[3,28,127,21,4,0,1,0,17,19,26,0,18,15,23,22]+[0]*16,
              'ispeed':15,'ospeed':15}
    before = {'rc':0,'errno':None,'endpoint':{'fd':0,'dev':80,'ino':3,'rdev':34816},'fields':fields}
    (directory / 'native-termios-before-1.json').write_text(json.dumps(before))
    target = directory / 'native-termios-after-1.json'
    target.write_text(json.dumps(before)); verify_termios_snapshots(directory, runs=1)
    for field in fields:
        broken = copy.deepcopy(before)
        if field == 'cc': broken['fields']['cc'][31] = 1
        else: broken['fields'][field] += 1
        target.write_text(json.dumps(broken))
        rejects(lambda: verify_termios_snapshots(directory, runs=1))
    broken = copy.deepcopy(before); broken['endpoint']['ino'] += 1
    target.write_text(json.dumps(broken)); rejects(lambda: verify_termios_snapshots(directory, runs=1))
    unavailable = dict(before, rc=-1, errno=errno.EIO, fields=None)
    target.write_text(json.dumps(unavailable))
    verify_termios_snapshots(directory, runs=1, destroyed=True)
    rejects(lambda: verify_termios_snapshots(directory, runs=1))
print('PASS tool checks + literal positive/negative oracle fixtures; runtime evidence is separate')
