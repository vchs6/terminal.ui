"""Offline transcription of original same-guest ncurses/locale/ioctl facts only."""
import hashlib,json,os,pathlib,re,struct,sys
assert os.environ.get('C008_ROOT_ACTUAL_GO')=='1'
raw=pathlib.Path(sys.argv[1]);serial=pathlib.Path(sys.argv[2]);out=pathlib.Path(sys.argv[3]);out.mkdir(exist_ok=False)
assert (raw/'charmap.txt').read_text().strip().upper() in ['UTF-8','UTF8'],'INSUFFICIENT_EVIDENCE same-guest UTF8'
assert (raw/'size.txt').read_text().strip()=='25 80'
env=dict(line.split('=',1) for line in (raw/'environment.txt').read_text().splitlines());entry=(raw/'infocmp.stdout').read_text();known=int((raw/'infocmp.exit').read_text())==0
facts={'term':env['TERM'],'colorterm':env['COLORTERM'],'terminfoKnown':known,'colors':-1,'ncv':-1,'RGB':False,'Tc':False,'attributeStrings':{n:None for n in ['bold','dim','sitm','smul','rev','smxx']},'failureReason':'','nativeVt':True,'mapKnown':False}
if not known:facts['failureReason']=os.environ['C008_ACTUAL_TERMINFO_FAILURE_REASON']
for cap in ['colors','ncv','RGB','Tc','bold','dim','sitm','smul','rev','smxx']:
 if not known:break
 if cap in ['RGB','Tc']:facts[cap]=bool(re.search(r'^\s*'+cap+r',\s*$',entry,re.M));continue
 marker='#' if cap in ['colors','ncv'] else '='
 if not re.search(r'^\s*'+cap+re.escape(marker),entry,re.M):continue
 rc=int((raw/(cap+'.exit')).read_text());assert rc in [0,1],'INSUFFICIENT_EVIDENCE raw tput failure'
 value=(raw/(cap+'.stdout')).read_bytes()
 if cap in ['colors','ncv']:facts[cap]=int(value.strip())
 elif rc==0:facts['attributeStrings'][cap]=value.decode()
text=serial.read_text(errors='replace');assert re.search(r'STDOUT_IDENTITY fd=1 tty=/dev/tty1 .*VT_GETSTATE_rc=0 active=1 KDGETMODE_rc=0 mode=0 TIOCGWINSZ_rc=0 cols=80 rows=25',text)
m=re.search(r'STDOUT_UNIMAP fd=1 rc=(-?\d+) errno=(\d+) count=(\d+) pair_size=(\d+) hex=([0-9a-f]*)',text);assert m
rc,error,count,size,he=m.groups()
if int(rc)==0:
 blob=bytes.fromhex(he);assert int(size)==4 and len(blob)==int(count)*4;facts['mapKnown']=True;facts['mappedCodePoints']=[a for a,b in struct.iter_unpack('<HH',blob)]
facts['provenance']={'actualStdoutDevice':'/dev/tty1','kernelSerial':str(serial.resolve()),'kernelSerialSha256':hashlib.sha256(serial.read_bytes()).hexdigest(),'rawEvidence':[{'path':str(p.resolve()),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in raw.iterdir() if p.is_file()],'mapQueryRc':int(rc),'mapQueryErrno':int(error),'environment':env,'policyResolver':'none'}
p=out/'facts.json';p.write_text(json.dumps(facts,indent=2)+'\n');(out/'profile-envelope.json').write_text(json.dumps({'hostKind':'vt','sourceCommit':'d7e9d1445f98021a798d223de97b97b45239de93','factsPath':str(p.resolve()),'factsSha256':hashlib.sha256(p.read_bytes()).hexdigest()},indent=2)+'\n')
