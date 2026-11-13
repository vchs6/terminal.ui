import datetime, hashlib, json, pathlib, subprocess, sys
phase, cwd, *command = sys.argv[1:]
root = pathlib.Path('/workspace/work/editing-tests/final/raw') / phase
root.mkdir(exist_ok=False)
record = dict(cwd=cwd, argv=command, start_utc=datetime.datetime.now(datetime.timezone.utc).isoformat())
with (root/'stdout').open('wb') as out, (root/'stderr').open('wb') as err:
    result = subprocess.run(command, cwd=cwd, stdout=out, stderr=err)
record.update(exit=result.returncode, end_utc=datetime.datetime.now(datetime.timezone.utc).isoformat())
(root/'exit').write_text(str(result.returncode)+'\n')
(root/'command.json').write_text(json.dumps(record, indent=2)+'\n')
manifest={p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in root.iterdir() if p.is_file()}
(root/'manifest.json').write_text(json.dumps(manifest,sort_keys=True,indent=2)+'\n')
for p in root.iterdir(): p.chmod(0o444)
print(json.dumps(record))
sys.exit(result.returncode)
