#!/usr/bin/env python3
"""Read existing infocmp/tput data, transcribe raw VT ioctl records, hash envelope.
No color/attribute/glyph policy resolver: independent binding owns that logic.
"""
import hashlib,json,os,pathlib,re,struct,subprocess as S,sys,time
assert os.environ.get('C008_ROOT_ACTUAL_GO')=='1'
out=pathlib.Path(sys.argv[1]);out.mkdir(exist_ok=False);host=os.environ['C008_HOST_KIND'];term=os.environ.get('TERM','')
assert host in ['xterm','vte','tmux','screen','ssh','vt']
commands=[]
def collect(label,args):
 p=S.run(args,capture_output=True);(out/(label+'.stdout')).write_bytes(p.stdout);(out/(label+'.stderr')).write_bytes(p.stderr)
 commands.append({'label':label,'argv':args,'returncode':p.returncode,'stdout_sha256':hashlib.sha256(p.stdout).hexdigest(),'stderr_sha256':hashlib.sha256(p.stderr).hexdigest()});return p
utf8=collect('locale-charmap',[os.environ['C008_LOCALE'],'charmap']);assert utf8.returncode==0 and utf8.stdout.strip().upper() in [b'UTF-8',b'UTF8'],'INSUFFICIENT_EVIDENCE genuine UTF-8 prerequisite'
geometry=collect('actual-stdout-size',[os.environ['C008_STTY'],'-F',os.environ['C008_ACTUAL_STDOUT_DEVICE'],'size']);assert geometry.returncode==0 and re.fullmatch(rb'\d+ \d+\n?',geometry.stdout),'INSUFFICIENT_EVIDENCE actual stdout dimensions'
info=collect('infocmp',[os.environ['C008_INFOCMP'],'-1','-x','--',term]);known=info.returncode==0
facts={'term':term,'colorterm':os.environ.get('COLORTERM',''),'terminfoKnown':known,'colors':-1,'RGB':False,'Tc':False,'ncv':-1,'attributeStrings':{name:None for name in ['bold','dim','sitm','smul','rev','smxx']},'failureReason':'','nativeVt':host=='vt','mapKnown':False}
if known:
 for cap in ['colors','ncv','RGB','Tc','bold','dim','sitm','smul','rev','smxx']:
  entry=info.stdout.decode('utf8')
  if cap in ['RGB','Tc']:
   facts[cap]=bool(re.search(r'^\s*'+cap+r',\s*$',entry,re.M));continue
  marker='#' if cap in ['colors','ncv'] else '='
  if not re.search(r'^\s*'+cap+re.escape(marker),entry,re.M):continue
  p=collect('tput-'+cap,[os.environ['C008_TPUT'],'-T',term,cap]);assert p.returncode in [0,1],('INSUFFICIENT_EVIDENCE tput failure',cap,p.returncode)
  if cap in ['colors','ncv']:
   assert p.stdout.strip(),('INSUFFICIENT_EVIDENCE numeric capability',cap);facts[cap]=int(p.stdout.strip())
  elif p.returncode==0:facts['attributeStrings'][cap]=p.stdout.decode('utf8')
else:
 # Formal failure name must come from existing actual native capability evidence.
 facts['failureReason']=os.environ['C008_ACTUAL_TERMINFO_FAILURE_REASON'];assert facts['failureReason']
provenance={'utc':time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()),'rawDirectory':str(out.resolve()),'commands':commands,'actualStdoutDevice':os.environ['C008_ACTUAL_STDOUT_DEVICE'],'hostIdentityEvidence':os.environ['C008_ACTUAL_HOST_IDENTITY_EVIDENCE'],'environment':{k:os.environ.get(k) for k in ['TERM','COLORTERM','TERMINFO','TERMINFO_DIRS','LANG','LC_ALL','LC_CTYPE']},'resolver':'none; fixed independent binding resolves raw fields'}
if known:
 entry_path=pathlib.Path(os.environ['C008_ACTUAL_TERMINFO_ENTRY']);assert entry_path.is_file();provenance['terminfoEntryPath']=str(entry_path.resolve());provenance['terminfoEntrySha256']=hashlib.sha256(entry_path.read_bytes()).hexdigest()
identity=pathlib.Path(provenance['hostIdentityEvidence']);assert identity.is_file();provenance['hostIdentityEvidenceSha256']=hashlib.sha256(identity.read_bytes()).hexdigest()
if host=='vt':
 serial=pathlib.Path(os.environ['C008_VT_ACTUAL_SERIAL']);text=serial.read_text(errors='replace')
 assert re.search(r'STDOUT_IDENTITY fd=1 tty=/dev/tty1 .*VT_GETSTATE_rc=0 active=1 KDGETMODE_rc=0 mode=0 TIOCGWINSZ_rc=0 cols=80 rows=25',text),'INSUFFICIENT_EVIDENCE real stdout concrete text VT'
 row=re.search(r'^STDOUT_UNIMAP fd=1 rc=(-?\d+) errno=(\d+) count=(\d+) pair_size=(\d+) hex=([0-9a-f]*)$',text,re.M);assert row,'INSUFFICIENT_EVIDENCE same-stdout map query'
 rc,error,count,size,he=row.groups();provenance.update({'actualStdoutDevice':'/dev/tty1','kernelSerial':str(serial.resolve()),'kernelSerialSha256':hashlib.sha256(serial.read_bytes()).hexdigest(),'mapQueryRc':int(rc),'mapQueryErrno':int(error),'mapCount':int(count)})
 if int(rc)==0:
  blob=bytes.fromhex(he);assert int(size)==4 and len(blob)==int(count)*4;facts['mapKnown']=True;facts['mappedCodePoints']=[a for a,b in struct.iter_unpack('<HH',blob)]
  (out/'stdout-unimap.bin').write_bytes(blob);provenance['mapSha256']=hashlib.sha256(blob).hexdigest()
else:assert provenance['actualStdoutDevice'].startswith('/dev/pts/'),'INSUFFICIENT_EVIDENCE actual PTY identity'
facts['provenance']=provenance
path=out/'facts.json';path.write_text(json.dumps(facts,ensure_ascii=False,indent=2)+'\n')
envelope={'hostKind':host,'sourceCommit':'d7e9d1445f98021a798d223de97b97b45239de93','factsPath':str(path.resolve()),'factsSha256':hashlib.sha256(path.read_bytes()).hexdigest()}
(out/'profile-envelope.json').write_text(json.dumps(envelope,indent=2)+'\n')
print(out/'profile-envelope.json')
