import hashlib,lzma,pathlib,subprocess,sys,json
base=pathlib.Path(__file__).resolve().parents[1]
entries={}
for s in lzma.open(base/'packages/Packages.xz','rt').read().split('\n\n'):
 d={}
 for l in s.splitlines():
  if l and not l[0].isspace() and ': ' in l:
   k,v=l.split(': ',1);d[k]=v
 if 'Package' in d: entries[d['Package']]=d
for name in sys.argv[1:]:
 d=entries[name];out=base/'packages'/pathlib.Path(d['Filename']).name
 if not out.exists(): subprocess.run(['curl','--fail','--location','--max-time','90','https://deb.debian.org/debian/'+d['Filename'],'-o',str(out)],check=True)
 sha=hashlib.sha256(out.read_bytes()).hexdigest()
 if sha!=d['SHA256']:raise Exception('hash mismatch '+name)
 with open(base/'raw/package-manifest.jsonl','a') as f:f.write(json.dumps({k:d.get(k) for k in ['Package','Version','Filename','SHA256','Depends','Size']})+'\n')
 subprocess.run(['dpkg-deb','-x',str(out),str(base/'hosts/debian')],check=True)
 print(name,d['Version'],d.get('Depends',''))
