import pathlib,json,hashlib,tarfile,gzip,stat,collections,re
BASE=pathlib.Path('/workspace/work/migration-part05')
manifest_bytes=(BASE/'manifest.json').read_bytes()
manifest=json.loads(manifest_bytes)
delivery=json.loads((BASE/'delivery.json').read_bytes())
expected={x['archive_path']:x for x in manifest['files']}
def sha_file(p):
 h=hashlib.sha256()
 with open(p,'rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
 return h.hexdigest()
def unsafe(n):
 return n.startswith('/') or '\\' in n or '..' in n.split('/') or '\x00' in n
sensitive_re=re.compile(r'(^|/)(\.ssh|\.aws|\.azure|\.gnupg|\.config/gcloud|\.git|\.env(?:\.[^/]*)?|id_rsa|id_dsa|id_ecdsa|id_ed25519|credentials|authorized_keys|known_hosts|shadow|gshadow)(/|$)',re.I)
private_re=re.compile(br'-----BEGIN (?:RSA |DSA |EC |OPENSSH |ENCRYPTED )?PRIVATE KEY-----')
class HashReader:
 def __init__(self,f):self.f=f;self.h=hashlib.sha256();self.n=0
 def read(self,n=-1):
  b=self.f.read(n);self.h.update(b);self.n+=len(b);return b
 def drain(self):
  while self.read(1024*1024):pass

def exact(f,n):
 b=f.read(n)
 if len(b)!=n:raise ValueError('truncated cpio')
 return b

def cpio_list(raw):
 z=gzip.GzipFile(fileobj=raw,mode='rb'); rows=[]; names=set(); dup=[]; suspicious=[]; keys=[]; totals=collections.Counter(); trailer=False; tail_nonzero=False
 while True:
  h=exact(z,110)
  if h[:6] not in (b'070701',b'070702'):raise ValueError('invalid newc magic '+repr(h[:6]))
  v=[int(h[i:i+8],16) for i in range(6,110,8)]
  ino,mode,uid,gid,nlink,mtime,size,devmaj,devmin,rmaj,rmin,namesize,check=v
  if not 0<namesize<65536:raise ValueError('invalid cpio namesize')
  nb=exact(z,namesize)
  if not nb.endswith(b'\0'):raise ValueError('unterminated cpio name')
  name=nb[:-1].decode('utf-8','surrogateescape');exact(z,(-(110+namesize))%4)
  if name=='TRAILER!!!':
   if size:raise ValueError('nonempty trailer')
   trailer=True
   while True:
    b=z.read(1024*1024)
    if not b:break
    if b.strip(b'\0'):tail_nonzero=True
   break
  typ=stat.S_IFMT(mode);kind={stat.S_IFREG:'file',stat.S_IFDIR:'directory',stat.S_IFLNK:'symlink',stat.S_IFCHR:'char',stat.S_IFBLK:'block',stat.S_IFIFO:'fifo',stat.S_IFSOCK:'socket'}.get(typ,'unknown')
  if name in names:dup.append(name)
  names.add(name)
  if unsafe(name) or sensitive_re.search(name):suspicious.append(name)
  left=size; buf=b''; link=b''; digest=hashlib.sha256()
  while left:
   b=exact(z,min(left,1024*1024));left-=len(b);digest.update(b)
   if kind=='symlink':link+=b
   if kind=='file' and private_re.search(buf+b):keys.append(name)
   buf=b[-100:]
  exact(z,(-size)%4)
  row={'name':name,'type':kind,'mode':oct(mode),'bytes':size}
  if kind=='file':row['sha256']=digest.hexdigest()
  if kind=='symlink':
   row['target']=link.decode('utf-8','surrogateescape')
   if '/workspace' in row['target'] or '/home/' in row['target'] or sensitive_re.search(row['target']):suspicious.append(name+' -> '+row['target'])
  if kind in ('char','block'):row['rdev']=[rmaj,rmin]
  rows.append(row);totals[kind]+=1
 z.close();raw.drain()
 return {'members':len(rows),'types':dict(totals),'trailer_present':trailer,'nonzero_trailing_uncompressed_data':tail_nonzero,'duplicates':dup,'suspicious_paths':suspicious,'private_key_marker_files':sorted(set(keys)),'listing':rows}

p=delivery['archive_path'];st=pathlib.Path(p).stat(); h=hashlib.sha256();blob=hashlib.sha1(('blob '+str(st.st_size)+'\0').encode())
with open(p,'rb') as f:
 for b in iter(lambda:f.read(1024*1024),b''):h.update(b);blob.update(b)
result={'archive':{'path':p,'bytes':st.st_size,'sha256':h.hexdigest(),'git_blob_hash':blob.hexdigest(),'delivery_size_match':st.st_size==delivery['bytes'],'delivery_sha_match':h.hexdigest()==delivery['sha256'],'delivery_blob_match':blob.hexdigest()==delivery['git_blob']},'tar':{'members':[],'duplicates':[],'unsafe_paths':[],'nonregular':[],'unexpected':[],'missing':[],'payload_mismatches':[]},'cpio':{}}
seen=set();small={}
with tarfile.open(p,'r|gz') as t:
 for m in t:
  n=m.name
  if n in seen:result['tar']['duplicates'].append(n)
  seen.add(n)
  if unsafe(n):result['tar']['unsafe_paths'].append(n)
  if not m.isfile():result['tar']['nonregular'].append(n);continue
  hr=HashReader(t.extractfile(m))
  if n.endswith('.cpio.gz'):result['cpio'][n]=cpio_list(hr)
  elif m.size<200000:
   data=hr.read();small[n]=data
  else:hr.drain()
  row={'name':n,'bytes':hr.n,'sha256':hr.h.hexdigest(),'mode':m.mode,'uid':m.uid,'gid':m.gid,'uname':m.uname,'gname':m.gname}
  result['tar']['members'].append(row)
  if n in expected:
   e=expected[n]
   if hr.n!=e['bytes'] or hr.h.hexdigest()!=e['sha256'] or m.mode!=e['mode']:result['tar']['payload_mismatches'].append(n)
  elif n=='migration-part05/manifest.json':
   result['tar']['metadata_exact_bytes_match']=small[n]==manifest_bytes
   result['tar']['metadata_mode']=m.mode
  else:result['tar']['unexpected'].append(n)
result['tar']['missing']=sorted(set(expected)-seen)
result['tar']['count']=len(seen)
result['tar']['outer_sensitive_paths']=[n for n in seen if sensitive_re.search(n)]
result['tar']['outer_private_key_marker_files']=[n for n,b in small.items() if private_re.search(b)]
# Historical pins are read from existing records only; migration's new manifest is not a historical pin.
root=pathlib.Path('/workspace/work/linux-final-host-actual/actual/runtime')
historical=[root/'vt-control-diagnostic-once/diagnostic-record.json',root/'vt-control-diagnostic-once/diagnostic-index.json',root/'vt-preparation-r3/artifact-receipt.json',root/'vt-preparation-r3/allocation-plan.json',root/'vt-preparation-r3/preserved-old-artifacts.json']
pins=[]
def walk(o,ks=()):
 if isinstance(o,dict):
  for k,v in o.items():yield from walk(v,ks+(k,))
 elif isinstance(o,list):
  for i,v in enumerate(o):yield from walk(v,ks+(str(i),))
 else:yield ks,o
for image,e in expected.items():
 if '/linux-final-host-actual/' not in '/'+image or not image.endswith('.cpio.gz'):continue
 hits=[]
 for rec in historical:
  if not rec.exists():continue
  data=json.loads(rec.read_bytes())
  for ks,value in walk(data):
   if value==e['sha256']:hits.append({'record':str(rec),'record_sha256':sha_file(rec),'field':'.'.join(ks)})
 pins.append({'image':image,'sha256':e['sha256'],'historical_matches':hits,'matched':bool(hits)})
result['historical_pins']=pins
recpath=root/'vt-control-diagnostic-once/diagnostic-record.json';rec=json.loads(recpath.read_bytes());argv=rec['qemu_argv'];kernel=argv[argv.index('-kernel')+1]
result['diagnostic_kernel']={'record':str(recpath),'kernel_argument':kernel,'matches_original_path':kernel=='/workspace/work/linux-console-hosts/packages/linux','sha256':sha_file(kernel),'matches_migrated_kernel':sha_file(kernel)==expected['work/linux-console-hosts/packages/linux']['sha256']}
# Checksums tie the preserved packages/kernel to the retained acquisition records; no network or signature verification.
packages=pathlib.Path('/workspace/work/linux-console-hosts/packages')
checks=[]
for line in (packages/'installer-SHA256SUMS').read_text().splitlines():
 if line.endswith('./netboot/debian-installer/amd64/linux'):
  checks.append({'entry':line,'matches_kernel':line.split()[0]==result['diagnostic_kernel']['sha256']})
result['acquisition']={'installer_kernel_checksum_matches':checks,'inrelease_has_clearsigned_pgp_markers':b'-----BEGIN PGP SIGNED MESSAGE-----' in small['work/linux-console-hosts/packages/InRelease'] and b'-----BEGIN PGP SIGNATURE-----' in small['work/linux-console-hosts/packages/InRelease'],'signature_verified_in_this_audit':False,'network_used':False,'source_report_sha256':expected['work/linux-console-hosts/report.md']['sha256']}
# Read-only stream of official compressed package index, retaining only the selected .deb stanzas.
import lzma
selected={pathlib.Path(x['path']).name:x for x in expected.values() if x['path'].endswith('.deb')}
selected_matches=[]
with lzma.open(packages/'Packages.xz','rt') as f:
 fields={}
 for line in f:
  if line.strip():
   if line[0].isspace():continue
   k,_,v=line.partition(':');fields[k]=v.strip()
  else:
   filename=pathlib.Path(fields.get('Filename','')).name
   if filename in selected:
    e=selected[filename];selected_matches.append({'file':filename,'package':fields.get('Package'),'version':fields.get('Version'),'sha256_match':fields.get('SHA256')==e['sha256'],'size_match':fields.get('Size')==str(e['bytes'])})
   fields={}
result['acquisition']['deb_index_matches']=selected_matches
result['acquisition']['deb_index_missing']=sorted(set(selected)-{x['file'] for x in selected_matches})
# Link Packages.xz bytes to the retained InRelease checksum entry without asserting signature trust.
idx=expected['work/linux-console-hosts/packages/Packages.xz']
entries=[]
for line in small['work/linux-console-hosts/packages/InRelease'].decode().splitlines():
 parts=line.split()
 if len(parts)==3 and parts[2]=='main/binary-amd64/Packages.xz' and len(parts[0])==64:
  entries.append({'sha256_match':parts[0]==idx['sha256'],'size_match':parts[1]==str(idx['bytes'])})
result['acquisition']['inrelease_index_checksum_matches']=entries
(BASE/'independent-findings.json').write_text(json.dumps(result,ensure_ascii=True,indent=2)+'\n')
print(json.dumps({'archive':result['archive'],'tar_count':result['tar']['count'],'metadata_exact_bytes_match':result['tar'].get('metadata_exact_bytes_match'),'tar_issues':{k:result['tar'][k] for k in ['duplicates','unsafe_paths','nonregular','unexpected','missing','payload_mismatches','outer_sensitive_paths','outer_private_key_marker_files']},'cpio':{k:{a:b for a,b in v.items() if a!='listing'} for k,v in result['cpio'].items()},'historical_pins':[{k:v for k,v in x.items() if k!='historical_matches'} for x in pins],'kernel':result['diagnostic_kernel'],'acquisition':result['acquisition']},ensure_ascii=False,indent=2))
