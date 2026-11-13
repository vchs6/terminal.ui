import pathlib,sys,hashlib,json,datetime
p=pathlib.Path(sys.argv[1]);manifest=p/'phase-index.json';assert not manifest.exists();files={}
for f in sorted(p.rglob('*')):
 if f.is_file() and not f.is_symlink():files[str(f.relative_to(p))]=dict(size=f.stat().st_size,sha256=hashlib.sha256(f.read_bytes()).hexdigest())
manifest.write_text(json.dumps(dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),source_sha='c3c4642d84df57bbd9550d222ed22f602acd13ef',files=files),indent=2)+'\n');manifest.chmod(0o444);print(str(manifest),hashlib.sha256(manifest.read_bytes()).hexdigest())
