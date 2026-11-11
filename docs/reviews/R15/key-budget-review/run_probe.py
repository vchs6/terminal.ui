from pathlib import Path
import subprocess,json,datetime,hashlib,sys
root=Path(__file__).resolve().parent
cases=json.loads((root/'cases.json').read_text())
results=[]
for c in cases:
    cmd=[str(root/'probe/target/release/bin/main'),str(root/c['input'])]
    start=datetime.datetime.now(datetime.timezone.utc).isoformat()
    p=subprocess.run(cmd,capture_output=True)
    (root/'raw'/f"{c['name']}.stdout").write_bytes(p.stdout)
    (root/'raw'/f"{c['name']}.stderr").write_bytes(p.stderr)
    tokens=[]
    for l in p.stdout.decode().splitlines():
        f=l.split('\t')
        payload=bytes(int(x) for x in f[7].split(',') if x).decode()
        tokens.append(dict(index=int(f[0]),type=f[1],string_size=int(f[2]),utf8_bytes=int(f[3]),line=int(f[4]),rune_start=int(f[5]),rune_length=int(f[6]),payload=payload))
    matches=[t for t in tokens if t['payload']==c['payload'] and t['type']==c['token_type']]
    ok=p.returncode==0 and bool(matches) and all(t['utf8_bytes']==c['expected_bytes'] and t['string_size']==c['expected_bytes'] for t in matches)
    results.append(dict(case=c['name'],command=cmd,started_utc=start,finished_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),exit=p.returncode,passed=ok,source_sha256=hashlib.sha256((root/c['input']).read_bytes()).hexdigest(),expected=c,tokens=tokens))
(root/'probe-results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(dict(total=len(results),passed=sum(r['passed'] for r in results),failed=[r['case'] for r in results if not r['passed']]),indent=2))
sys.exit(0 if all(r['passed'] for r in results) else 1)
