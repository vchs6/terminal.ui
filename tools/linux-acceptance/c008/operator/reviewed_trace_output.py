#!/usr/bin/env python3
"""External, complete -ff native output coverage with reversible validator cuts."""
import argparse
import csv
from decimal import Decimal
import hashlib
import json
import os
from pathlib import Path
import re
import stat
import time

TRACE_SYSCALLS = 'write,writev,poll,clone,clone3,fork,vfork,execve,execveat,exit,exit_group'
# Keep full writev/clone decoding, but never expand exec environment vectors.
# The per-syscall abbreviation override must follow the global -v option.
TRACE_FLAGS = ['-ff', '-ttt', '-yy', '-v', '-e', 'abbrev=execve,execveat',
               '-s', '128', '-e', 'trace=' + TRACE_SYSCALLS]


def demand(ok, why):
    if not ok:
        raise ValueError(why)


def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def writej(path, value):
    with Path(path).open('x', encoding='utf-8') as stream:
        stream.write(json.dumps(value, indent=2, sort_keys=True) + '\n')


def fd_capture(args):
    pid = int(args.pid)
    executable = Path(f'/proc/{pid}/exe').resolve()
    demand(executable == Path(args.executable).resolve(), 'actual executable/PID mismatch')
    status = Path(f'/proc/{pid}/status').read_text()
    demand(int(re.search(r'^Tgid:\s+(\d+)', status, re.M)[1]) == pid, 'PID must be TGID leader')
    argv = Path(f'/proc/{pid}/cmdline').read_bytes().rstrip(b'\0').decode().split('\0')
    demand('--run-id' in argv and argv[argv.index('--run-id') + 1] == args.run_id,
           'actual process run identity mismatch')
    tty = Path(args.tty).resolve()
    demand(tty.is_char_device(), 'target is not a real terminal descriptor')
    matches = []
    for entry in Path(f'/proc/{pid}/fd').iterdir():
        try:
            if entry.resolve() == tty and stat.S_ISCHR(entry.stat().st_mode):
                matches.append(int(entry.name))
        except FileNotFoundError:
            pass
    demand(matches, 'no actual terminal fd on process')
    result = dict(pid=pid, tgid=pid, executable=str(executable), executable_sha256=sha(executable),
                  argv=argv, process_start_ticks=Path(f'/proc/{pid}/stat').read_text().rsplit(')', 1)[1].split()[19],
                  tty=str(tty), tty_device=os.stat(tty).st_rdev, fds=sorted(matches),
                  utc_ns=time.time_ns(), run_id=args.run_id)
    writej(args.out, result)


def trace_paths(full):
    prefix = full.name.rsplit('.', 1)[0]
    paths = sorted(full.parent.glob(prefix + '.*'))
    demand(all(p.is_file() and p.name[len(prefix) + 1:].isdigit() for p in paths),
           'unexpected/compressed original -ff inventory member')
    demand(full in paths, 'leader missing from complete original -ff inventory')
    return paths


def seal_capture(full, evidence_path, launch, host_exit):
    """Call only after the ordinary host/script/strace completion wait succeeds."""
    full = Path(full)
    evidence = json.loads(Path(evidence_path).read_text())
    demand(host_exit == 0 and launch[1:1 + len(TRACE_FLAGS)] == TRACE_FLAGS,
           'full annotated lineage capture and successful tracer completion required')
    paths = trace_paths(full)
    manifest = dict(run_id=evidence['run_id'], pid=evidence['pid'], host_exit=host_exit,
                    tracer_complete=True, launch=launch, fd_evidence_sha256=sha(evidence_path),
                    streams={p.name:dict(tid=int(p.suffix[1:]), sha256=sha(p), bytes=p.stat().st_size)
                             for p in paths})
    path = full.parent / 'native-inventory.json'
    writej(path, manifest)
    return path


def records(path, tid):
    """Join only explicitly paired unfinished/resumed records; keep both raw ordinals."""
    result, pending, previous = [], None, None
    data = path.read_bytes()
    demand(data and data.endswith(b'\n'), 'empty/truncated native stream: ' + path.name)
    for ordinal, line in enumerate(data.decode('utf-8').splitlines(keepends=True), 1):
        match = re.match(r'^(\d+\.\d+)\s+(.*)\n$', line)
        demand(match, 'require exact -ttt timestamp on every original line')
        instant, body = match.groups()
        demand(previous is None or Decimal(instant) >= previous, 'nonmonotonic native realtime; cuts ambiguous')
        previous = Decimal(instant)
        if '<unfinished ...>' in body:
            demand(pending is None and body.endswith('<unfinished ...>'), 'ambiguous unfinished syscall')
            pending = (instant, body.removesuffix('<unfinished ...>').rstrip(), ordinal)
            continue
        resumed = re.match(r'<\.\.\. (\w+) resumed>(.*)', body)
        if resumed:
            demand(pending and pending[1].startswith(resumed[1] + '('), 'unpaired resumed syscall')
            stamp, first, start = pending
            result.append(dict(tid=tid, ordinals=[start, ordinal], time=Decimal(stamp),
                               timestamp=stamp, body=first + resumed[2]))
            pending = None
            continue
        # Signal and exit lines can occur between paired syscall halves.
        demand(pending is None or body.startswith(('--- ', '+++ ')), 'interleaved unfinished syscall')
        result.append(dict(tid=tid, ordinals=[ordinal], time=Decimal(instant), timestamp=instant, body=body))
    demand(pending is None, 'unfinished syscall at tracer completion')
    return sorted(result, key=lambda r:r['ordinals'][0])


def returned(body):
    match = re.search(r'\)\s+=\s+(-?\d+)(?:\s|$)', body)
    demand(match, 'missing/unresolved native syscall return')
    return int(match[1])


def proven_records(full, inventory_path, evidence):
    demand(inventory_path and Path(inventory_path).is_file(),
           'coverage-unverified: complete lineage/per-write inventory missing; needs new instrumented observation')
    inventory = json.loads(Path(inventory_path).read_text())
    demand(inventory['run_id'] == evidence['run_id'] and inventory['pid'] == evidence['pid'] and
           inventory['tracer_complete'] and inventory['host_exit'] == 0, 'capture completion/identity unverified')
    demand(inventory['launch'][1:1 + len(TRACE_FLAGS)] == TRACE_FLAGS, 'capture lacks complete lineage/targets')
    demand(inventory['fd_evidence_sha256'] == evidence['_hash'], 'capture/fd binding mismatch')
    suffix = inventory['launch'][1 + len(TRACE_FLAGS):]
    demand(suffix == ['-o', str(full.with_name(full.name.rsplit('.', 1)[0]))] + evidence['argv'],
           'capture prefix/product argv binding mismatch')
    paths = trace_paths(full)
    demand(set(inventory['streams']) == {p.name for p in paths}, 'original -ff inventory changed')
    all_records, streams = [], {}
    for path in paths:
        info = inventory['streams'][path.name]
        tid = int(path.suffix[1:])
        demand(info['tid'] == tid and info['sha256'] == sha(path) and info['bytes'] == path.stat().st_size,
               'original -ff stream changed')
        stream = records(path, tid)
        demand(stream[-1]['body'] == '+++ exited with 0 +++', 'native thread exit0 missing')
        demand(sum(r['body'].startswith('+++ ') for r in stream) == 1, 'duplicate/abnormal native exit')
        for record in stream:
            record['source'] = str(path.resolve())
        streams[tid] = stream
        all_records.extend(stream)
    leader = evidence['pid']
    # The initial exec binds the actual ELF/run argv; no later exec is in scope.
    execs = [r for r in all_records if re.match(r'execve(?:at)?\(', r['body'])]
    demand(len(execs) == 1 and execs[0]['tid'] == leader and returned(execs[0]['body']) == 0,
           'unexpected/missing product exec')
    first_exec = execs[0]
    demand(first_exec == streams[leader][0] and
           first_exec['body'].startswith('execve(' + json.dumps(evidence['executable']) + ', ') and
           json.dumps(evidence['run_id']) in first_exec['body'], 'native exec ELF/run binding missing')
    parents = {}
    for record in all_records:
        body = record['body']
        if re.match(r'(clone3?|fork|vfork)\(', body):
            child = returned(body)
            if child < 0:
                continue
            demand(child > 0 and body.startswith(('clone(', 'clone3(')) and
                   'CLONE_THREAD' in body and 'CLONE_FILES' in body,
                   'unexpected child or nonshared thread/FD membership')
            demand(child not in parents and child != leader, 'ambiguous/reused native thread identity')
            parents[child] = record
    known = {leader}
    while True:
        added = {child for child, parent in parents.items() if parent['tid'] in known}
        if added <= known:
            break
        known |= added
    demand(known == set(streams) and set(parents) == known - {leader}, 'unproved/missing -ff thread lineage')
    for tid, stream in streams.items():
        if tid != leader:
            birth = parents[tid]
            demand(stream[0]['time'] > birth['time'], 'ambiguous thread birth/write order')
    return all_records, inventory


def native_counts(lines, fd):
    requested = success = calls = failed = shorts = 0
    for line in lines:
        demand('<unfinished ...>' not in line and 'resumed>' not in line, 'incomplete syscall')
        match = re.search(r'\b(write|writev)\(' + re.escape(str(fd)) + r', (.*)\)\s+=\s+(-?\d+)(?:\s|$)', line)
        if not match:
            continue
        kind, body, result = match.groups()
        if kind == 'writev':
            lengths = re.findall(r'iov_len=(\d+)\}', body)
            demand(lengths and '...' not in re.sub(r'"(?:\\.|[^"\\])*"(?:\.\.\.)?', '""', body), 'incomplete verbose iovec')
            demand(int(body.rsplit(', ', 1)[-1]) == len(lengths), 'writev iovec inventory incomplete')
            amount = sum(map(int, lengths))
        else:
            amount = int(body.rsplit(', ', 1)[-1])
        requested += amount
        result = int(result)
        if result <= 0:
            demand(result >= -1, 'unexpected negative native return')
            failed += 1
        else:
            demand(result <= amount, 'native return exceeds request')
            success += result; calls += 1
            shorts += result < amount
    return requested, success, calls, failed, shorts


def write_record(record):
    match = re.match(r'(writev?)\((\d+)(<[^\"\n]*>)?, (.*)\)\s+=\s+(-?\d+)(.*)$', record['body'])
    demand(match, 'unparseable native write')
    kind, fd, annotation, body, result, tail = match.groups()
    demand(annotation, 'write target lacks actual descriptor annotation')
    # The fd annotation is isolated by the comma before the payload; embedded
    # payload strings may contain arbitrary punctuation, including angle brackets.
    return kind, int(fd), annotation[1:-1], body, int(result), tail


def tty_write(record, evidence, target_fd):
    kind, fd, target, body, result, tail = write_record(record)
    dev = re.fullmatch(r'(.+)<char (\d+):(\d+)>', target)
    is_tty = bool(dev and dev[1] == evidence['tty'] and
                  os.makedev(int(dev[2]), int(dev[3])) == evidence['tty_device'])
    demand(fd != target_fd or is_tty, 'declared terminal fd changed/unknown per-write target')
    demand(not (target.startswith(evidence['tty']) and not is_tty), 'ambiguous terminal device annotation')
    if not is_tty:
        demand(not (dev and dev[1].startswith(('/dev/pts/', '/dev/tty'))), 'unexpected terminal target')
        return None
    # All descriptors targeting the actual PTY are included; the canonical view
    # uses the validated target fd, with original descriptor retained in mapping.
    line = f'{record["timestamp"]} {kind}({target_fd}, {body}) = {result}{tail}\n'
    native_counts([line], target_fd)
    return line


def before(left, right):
    if left['tid'] == right['tid']:
        return left['ordinals'][0] < right['ordinals'][0]
    demand(left['time'] != right['time'], 'ambiguous cross-thread native boundary tie')
    return left['time'] < right['time']


def initial_boundaries(all_records, events, csvpath, warmup, updates):
    demand(updates > 0 and warmup >= 0, 'invalid initial lifecycle counts')
    demand(csvpath, 'initial CSV identity required')
    labels = [f'warmup-{i}' for i in range(warmup)] + [f'measured-{i}' for i in range(updates)]
    expected = [(label, marker) for label in labels for marker in ('starting', 'captured', 'closed')]
    observed = [(e['label'], e['kind'].removeprefix('initial_')) for e in events if e['kind'].startswith('initial_')]
    demand(observed == expected, 'driver lifecycle identity/order incomplete')
    found, snapshots = {}, []
    expected_paths = {str(Path(str(csvpath) + '.' + label + '.' + marker).resolve()):(label, marker)
                      for label, marker in expected}
    for record in all_records:
        if not re.match(r'writev?\(', record['body']):
            continue
        kind, fd, target, body, result, tail = write_record(record)
        if target not in expected_paths:
            demand(not target.startswith(str(Path(csvpath).resolve()) + '.'), 'unexpected marker path')
            continue
        label, marker = expected_paths[target]
        path = Path(target)
        payload = (marker + '\n').encode()
        demand(path.is_file() and path.read_bytes() == payload, 'immutable marker content missing/changed')
        demand(kind == 'write' and body == json.dumps(marker + '\n') + ', ' + str(len(payload)) and
               result == len(payload), 'marker native content/return mismatch')
        demand((label, marker) not in found, 'duplicate native marker write')
        found[label, marker] = record
        snapshots.append(dict(path=target, label=label, marker=marker, sha256=sha(path),
                              tid=record['tid'], original_ordinals=record['ordinals'],
                              epoch_entry=record['timestamp'], source=record['source']))
    demand(set(found) == set(expected), 'native lifecycle markers incomplete')
    sequence = [found[item] for item in expected]
    demand(all(before(a, b) for a, b in zip(sequence, sequence[1:])), 'native lifecycle source order invalid')
    return found['measured-0', 'starting'], found[f'measured-{updates - 1}', 'captured'], snapshots


def output(args):
    evidence = json.loads(Path(args.fd_evidence).read_text(encoding='utf-8'))
    events = json.loads(Path(args.events).read_text(encoding='utf-8'))
    evidence['_hash'] = sha(args.fd_evidence)
    demand(evidence['run_id'] == args.run_id, 'fd run identity mismatch')
    demand(evidence['pid'] == int(args.pid) and int(args.fd) in evidence['fds'], 'PID/fd unverified')
    demand(evidence['executable'] == str(Path(args.executable).resolve()) and
           evidence['executable_sha256'] == sha(args.executable), 'executable changed')
    full = Path(args.trace)
    demand(Path(args.strace).is_file() and args.strace_version.strip(), 'actual strace tool/version required')
    demand(full.name.endswith('.' + str(args.pid)), 'require original unmerged -ff leader trace')
    all_records, inventory = proven_records(full, args.inventory, evidence)
    demand(str(Path(inventory['launch'][0]).resolve()) == str(Path(args.strace).resolve()),
           'capture strace tool binding mismatch')
    markers = []
    if any(e['kind'] == 'measurement_begin' for e in events):
        for kind in ('measurement_begin', 'measurement_end_request'):
            demand(sum(e['kind'] == kind for e in events) == 1, 'missing/duplicate phase boundary ' + kind)
        begin = Decimal(next(e['utc_ns'] for e in events if e['kind'] == 'measurement_begin')) / 10**9
        end = Decimal(next(e['utc_ns'] for e in events if e['kind'] == 'measurement_end_request')) / 10**9
        demand(begin < end, 'invalid steady phase order')
        phase_of = lambda r: 'initial' if r['time'] < begin else 'update' if r['time'] < end else 'exit'
        boundary = dict(scope='steady_driver_utc_ns_unchanged', begin=str(begin), end=str(end))
        limitation = 'instrumented_strace_separate_from_cpu;complete_proved_threads_actual_per_write_tty'
    else:
        argv = evidence['argv']
        for option, value in (('--csv', args.csv), ('--warmup', str(args.warmup)), ('--updates', str(args.updates))):
            demand(option in argv and argv[argv.index(option) + 1] == value, 'initial native argv/marker identity mismatch')
        begin, end, markers = initial_boundaries(all_records, events, args.csv, int(args.warmup), int(args.updates))
        demand(before(begin, end), 'invalid initial phase order')
        main_exit = next(r for r in all_records if r['tid'] == evidence['pid'] and r['body'] == '+++ exited with 0 +++')
        final_closed = next(r for r in all_records if any(m['marker'] == 'closed' and
                            m['label'] == f'measured-{int(args.updates) - 1}' and
                            m['source'] == r['source'] and m['original_ordinals'] == r['ordinals'] for m in markers))
        demand(before(final_closed, main_exit), 'final native markers must precede actual main exit0')
        phase_of = lambda r: 'initial' if before(r, begin) else 'update' if before(r, end) else 'exit'
        boundary = dict(scope='initial_batch_first_measured_starting_to_final_captured',
                        begin={k:begin[k] for k in ('timestamp','tid','ordinals','source')},
                        end={k:end[k] for k in ('timestamp','tid','ordinals','source')})
        limitation = ('instrumented_strace_separate_from_cpu;initial_batch_includes_inter_lifecycle_restoration;'
                      'not_isolated_first_target_or_steady_or_presentation_cost;native_epoch_syscall_entry')
    phases = {phase:[] for phase in ('initial', 'update', 'exit')}
    first_records, writes = {}, []
    # Sorting is only serialization; no cross-thread order is inferred from TID.
    ordered = sorted(all_records, key=lambda r:(r['time'], r['tid'], r['ordinals'][0]))
    for record in ordered:
        phase = phase_of(record)
        first_records.setdefault(phase, record)
        if re.match(r'writev?\(', record['body']):
            line = tty_write(record, evidence, int(args.fd))
            if line:
                phases[phase].append((record,line)); writes.append((record,line))
    out = Path(args.out)
    demand(not out.exists(), 'output summary exists')
    out.parent.mkdir(parents=True, exist_ok=True)
    rows, mappings, cuts = [], {}, {}

    def cut_file(path, selected, fallback=None):
        mapping = []
        demand(not path.exists(), 'derived cut exists')
        if not selected and fallback is not None:
            demand(not re.match(r'writev?\(', fallback['body']), 'zero phase cannot hide an original write')
            selected = [(fallback, fallback['timestamp'] + ' ' + fallback['body'] + '\n')]
        with path.open('x', encoding='utf-8') as stream:
            for n, (record,line) in enumerate(selected, 1):
                stream.write(line)
                mapping.append(dict(derived_line=n, tid=record['tid'], original_path=record['source'],
                                    original_ordinals=record['ordinals'], epoch_entry=record['timestamp'],
                                    original_body=record['body']))
        mappings[str(path.resolve())] = mapping
        return dict(path=str(path.resolve()), sha256=sha(path), derived=True)

    for phase, selected in phases.items():
        demand(phase in first_records, 'empty phase has no original native trace: ' + phase)
        if not selected:
            fallback = next((r for r in ordered if phase_of(r) == phase and
                             not re.match(r'writev?\(', r['body'])), None)
            demand(fallback, 'empty phase lacks original nonwrite record')
        else:
            fallback = None
        cut = out.with_name(out.stem + '-' + phase + '.trace')
        cuts[phase] = cut_file(cut, selected, fallback)
        counts = native_counts([line for _,line in selected], args.fd)
        rows.append(dict(run_id=args.run_id, phase=phase, observer='native_write_returns',
                         target_fd=args.fd, trace_path=str(cut.resolve()), host=args.host,
                         host_version=args.host_version, width=args.width, height=args.height,
                         capability_source=args.capability_source, output_requested_bytes=counts[0],
                         output_success_bytes=counts[1], output_success_calls=counts[2],
                         output_failed_calls=counts[3], output_short_calls=counts[4], limitations=limitation))
    actions = [e for e in events if e['kind'] == 'before_key' and e.get('key') == 'a']
    fences = [e for e in events if e['kind'] == 'before_key' and e.get('key') == 'f']
    presented = [e for e in events if e['kind'] == 'action_presented']
    demand(len(actions) == len(fences) == len(presented), 'action/fence event count mismatch')
    subphases = []
    for index, (action, fence, done) in enumerate(zip(actions, fences, presented), 1):
        for label, low, high in (('action',action['utc_ns'],fence['utc_ns']),('fence',fence['utc_ns'],done['utc_ns'])):
            demand(low < high, 'invalid action/fence timing')
            selected = [(r,line) for r,line in writes if Decimal(low)/10**9 <= r['time'] < Decimal(high)/10**9]
            info = cut_file(out.with_name(f'{out.stem}-{index}-{label}.trace'), selected)
            subphases.append(dict(index=index,phase=label,**info, counts=native_counts([s for _,s in selected],args.fd),empty=not selected))
    with out.open('x', encoding='utf-8', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=list(rows[0])); writer.writeheader(); writer.writerows(rows)
    manifest = dict(run_id=args.run_id, pid=args.pid, fd=args.fd,
                    strace_executable=str(Path(args.strace).resolve()), strace_sha256=sha(args.strace),
                    strace_version=args.strace_version, full_trace=str(full.resolve()),
                    full_trace_sha256=sha(full), full_trace_bytes=full.stat().st_size,
                    inventory=str(Path(args.inventory).resolve()), inventory_sha256=sha(args.inventory),
                    original_streams=inventory['streams'], all_writers_tgid=evidence['pid'],
                    fd_evidence=str(Path(args.fd_evidence).resolve()), fd_evidence_sha256=evidence['_hash'],
                    events=str(Path(args.events).resolve()), events_sha256=sha(args.events),
                    phase_boundary=boundary, initial_markers=markers,
                    limitations='-ttt syscall entry; cross-thread equal boundary timestamps rejected; original bytes preserved',
                    action_fence_subphases=subphases, cuts=cuts, reversible_mapping=mappings)
    writej(str(out) + '.json', manifest)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    cap = sub.add_parser('fd-capture')
    for name in ('pid','executable','tty','run-id','out'):
        cap.add_argument('--' + name, required=True)
    out = sub.add_parser('output')
    for name in ('run-id','pid','fd','executable','fd-evidence','events','trace','inventory','out',
                 'host','host-version','width','height','capability-source','strace','strace-version'):
        out.add_argument('--' + name, required=True)
    for name in ('csv','warmup','updates'):
        out.add_argument('--' + name)
    args = parser.parse_args()
    {'fd-capture':fd_capture,'output':output}[args.command](args)


if __name__ == '__main__':
    main()
