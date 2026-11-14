#!/usr/bin/env python3
"""Create the TASK020 indexed-intermediate addendum; never remove source files."""
import base64
import gzip
import hashlib
import io
import json
import os
import pathlib
import stat
import tarfile

HERE = pathlib.Path(__file__).resolve().parent
ROLES = (
    (pathlib.Path('/workspace/work/session-lifecycle-formal-tests'), '06b9228d'),
    (pathlib.Path('/workspace/work/session-lifecycle-formal-tests/fix-r1'), 'a0d0d428'),
)
ARCHIVE = HERE / 'packed-build-targets.tar.gz'
MAP = HERE / 'packed-build-targets-map.json'


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def users_of_targets():
    needles = tuple(str(role / 'source/tests/session_lifecycle/target') for role, _ in ROLES)
    matches = []
    for proc in pathlib.Path('/proc').iterdir():
        if not proc.name.isdigit():
            continue
        paths = []
        for name in ('cwd', 'exe'):
            try:
                paths.append(os.readlink(proc / name))
            except OSError:
                pass
        try:
            for fd in (proc / 'fd').iterdir():
                try:
                    paths.append(os.readlink(fd))
                except OSError:
                    pass
        except OSError:
            pass
        try:
            paths.extend(line for line in (proc / 'maps').read_text().splitlines() if any(n in line for n in needles))
        except OSError:
            pass
        if any(any(n in p for n in needles) for p in paths):
            matches.append(proc.name)
    return matches


def source_record(path, indexed, index_sha):
    s = path.lstat()
    assert stat.S_ISREG(s.st_mode) and s.st_nlink == 1 and not path.is_symlink(), path
    assert str(path) == indexed['path'] == indexed['resolvedPath'], path
    assert s.st_size == indexed['bytes'] and digest(path) == indexed['sha256'], path
    attrs = {name: base64.b64encode(os.getxattr(path, name, follow_symlinks=False)).decode('ascii')
             for name in os.listxattr(path, follow_symlinks=False)}
    return dict(original=str(path), resolvedPath=indexed['resolvedPath'], member='objects/' + indexed['sha256'],
                bytes=s.st_size, sha256=indexed['sha256'], role=indexed['role'], indexSha256=index_sha,
                mode=stat.S_IMODE(s.st_mode), uid=s.st_uid, gid=s.st_gid, mtime_ns=s.st_mtime_ns,
                xattrs=attrs, sourceDevice=s.st_dev, sourceInode=s.st_ino, sourceCtimeNs=s.st_ctime_ns)


def main():
    assert not ARCHIVE.exists() and not MAP.exists(), 'addendum already exists'
    assert not users_of_targets(), 'active process refers to a pinned target'
    rows, unique, index_info = [], {}, []
    for role, prefix in ROLES:
        index = role / 'evidence/index.json'
        index_sha = digest(index)
        assert index_sha.startswith(prefix), index
        entries = json.loads(index.read_text())['files']
        pinned = {e['path']: e for e in entries if e['path'].endswith(('.a', '.cjo')) and
                  '/tests/session_lifecycle/target/' in e['path']}
        target = role / 'source/tests/session_lifecycle/target'
        actual = {str(p) for p in target.rglob('*') if p.is_file() and p.suffix in ('.a', '.cjo')}
        assert len(pinned) == 62 and actual == set(pinned), (index, len(pinned), len(actual))
        for name, entry in sorted(pinned.items()):
            path = pathlib.Path(name)
            assert path.is_relative_to(target) and all(not a.is_symlink() for a in path.parents if a != pathlib.Path('/'))
            row = source_record(path, entry, index_sha)
            rows.append(row)
            unique.setdefault((row['bytes'], row['sha256']), path)
        index_info.append(dict(path=str(index), sha256=index_sha, entries=len(entries), pinned=62))
    assert len(rows) == 124 and len(unique) == 67
    temp_archive = HERE / '.packed-build-targets.tar.gz.part'
    temp_map = HERE / '.packed-build-targets-map.json.part'
    assert not temp_archive.exists() and not temp_map.exists()
    try:
        with temp_archive.open('xb') as raw:
            with gzip.GzipFile(filename='', mode='wb', fileobj=raw, mtime=0, compresslevel=6) as gz:
                with tarfile.open(fileobj=gz, mode='w|', format=tarfile.PAX_FORMAT) as tar:
                    for (size, sha), path in sorted(unique.items(), key=lambda item: item[0][1]):
                        info = tarfile.TarInfo('objects/' + sha)
                        info.size, info.mode, info.uid, info.gid, info.mtime = size, 0o600, 0, 0, 0
                        with path.open('rb') as source:
                            tar.addfile(info, source)
            raw.flush()
            os.fsync(raw.fileno())
        with tarfile.open(temp_archive, 'r:gz') as tar:
            members = tar.getmembers()
            assert len(members) == 67 and all(m.isfile() for m in members)
            assert {m.name for m in members} == {'objects/' + sha for _, sha in unique}
            for (size, sha) in unique:
                stream = tar.extractfile('objects/' + sha)
                h, count = hashlib.sha256(), 0
                for chunk in iter(lambda: stream.read(1024 * 1024), b''):
                    h.update(chunk); count += len(chunk)
                assert count == size and h.hexdigest() == sha
        for row in rows:
            p = pathlib.Path(row['original']); s = p.lstat()
            assert (s.st_size, s.st_dev, s.st_ino, s.st_ctime_ns, s.st_mtime_ns) == (row['bytes'], row['sourceDevice'], row['sourceInode'], row['sourceCtimeNs'], row['mtime_ns'])
            assert digest(p) == row['sha256']
        assert not users_of_targets(), 'active process appeared during packing'
        mapping = dict(schema=1, status='STAGED_SOURCE_PATHS_STILL_PRESENT',
                       archive=dict(path=ARCHIVE.name, bytes=temp_archive.stat().st_size, sha256=digest(temp_archive)),
                       indices=index_info, sourceFiles=124, uniqueMembers=67, mapping=rows,
                       resolution='An original path is historical after separately authorized removal; resolve with member and verify bytes/SHA. No claim that the direct path still exists.')
        with temp_map.open('x') as f:
            json.dump(mapping, f, sort_keys=True, separators=(',', ':'))
            f.write('\n'); f.flush(); os.fsync(f.fileno())
        os.replace(temp_archive, ARCHIVE)
        os.replace(temp_map, MAP)
        fd = os.open(HERE, os.O_RDONLY | os.O_DIRECTORY)
        try: os.fsync(fd)
        finally: os.close(fd)
        print(json.dumps(dict(archiveBytes=ARCHIVE.stat().st_size, archiveSha256=digest(ARCHIVE),
                              mapBytes=MAP.stat().st_size, mapSha256=digest(MAP),
                              sourceFiles=124, uniqueMembers=67, sourceUnchanged=True)))
    finally:
        for p in (temp_archive, temp_map):
            if p.exists(): p.unlink()


if __name__ == '__main__':
    main()
