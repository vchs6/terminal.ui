from pathlib import Path
import sys,json,hashlib,datetime,os
(d,profile,host,version,before,after,cap,scenario,scene,commit,fcommit,fsha,bsha,hsha)=sys.argv[1:]
d=Path(d)
m=dict(schema='cjtui-dynamic-terminal-task079-v1',profile=profile,host=host,host_version=Path(version).read_text(),scenario=scenario,scene=scene,source_commit=commit,fixture_commit=fcommit,fixture_source_sha256=fsha,fixture_binary_sha256=bsha,harness_source_sha256=hsha,captured_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),locale={k:os.environ.get(k,'') for k in ['LANG','LC_ALL','LC_CTYPE']},capability_scope=Path(cap).read_text(),outer_tty=(d/'outer-tty.txt').read_text(),inner_tty=(d/'inner-tty.txt').read_text(),x11_before=Path(before).read_text(),x11_after=Path(after).read_text())
m['artifacts']={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(d.iterdir()) if p.is_file()}
(d/'metadata.json').write_text(json.dumps(m,indent=2,ensure_ascii=False)+'\n')
