"""Finite independent recheck of retained actual execution facts; no rerun product."""
import pathlib,json,hashlib,datetime,re,os,subprocess,shutil
from PIL import Image
B=pathlib.Path('/workspace/work/session-extension-execution');S=B/'source';R=B/'raw'
H=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
checks=[]
def check(value,detail):
 checks.append({'ok':bool(value),'detail':detail})
 if not value:raise AssertionError(detail)
source=json.loads((B/'scope/product-source.json').read_text())
for x in source['files']:check(H(S/x['path'])==x['sha256'],'fixed product '+x['path'])
tests=json.loads((B/'scope/formal-tests.json').read_text())
for x in tests['files']:check(H(S/x['path'])==x['sha256'],'fixed formal test '+x['path'])
binary=S/'tests/session_extensions/target/release/bin/main'
check(H(binary)=='dc5c0dde2548b9bd9ac74d5a390e82b6a2ee65cdf5777eb6668e2fda74a3677a','final actual consumer binary unchanged')
for name in ['build','formal-all','bundle','package-inspect','clean-build','clean-example-pty','process-trace']:
 m=json.loads((R/name/'execution.json').read_text());check(m['exitCode']==0,name+' actual exit 0')
check(json.loads((R/'full-bundle-check/execution.json').read_text())['exitCode']==1,'full bundle checker retained exit1 composition gap')
suite=(R/'formal-all/stdout').read_text();check('session-extensions cases=278 failures=0' in suite,'complete278 runtime matrix')
cases=sorted(p for p in (R/'session-matrix').iterdir() if p.is_dir());check(len(cases)==278,'278 original directories')
for p in cases:
 if 'headless' in p.name:continue
 result=json.loads((p/'check.json').read_text());check(result['passed'] and result['code']==0 and result['signal'] is None,p.name+' direct binary exit/assertions')
 check((p/'before').read_bytes()==(p/'after').read_bytes(),p.name+' exact termios')
hostpaths=[]
for x in json.loads((R/'hosts2/oracle-rerun-summary.json').read_text()):
 check(x['exit']==0,x['profile']+' corrected manifest formal oracle');hostpaths.append(pathlib.Path(x['manifest']))
for root in ['hosts3','hosts4']:
 m=json.loads((R/root/'summary.json').read_text());check(m['xorgExit']==0 and m['sshdExit']==0 and m['displaySocketRemoved'],root+' owned Xorg/sshd cleaned')
 for x in m['results']:
  if x.get('oracleExit')==0:hostpaths.append(R/root/x['profile']/'manifest.json')
check(len(hostpaths)==14,'all14 unique host profiles')
pngcount=0;hosts=[]
for path in hostpaths:
 m=json.loads(path.read_text());p=path.parent;o=json.loads((p/m['observations']).read_text())
 check(m['binarySha256']==H(binary),m['profile']+' same actual binary')
 check(o['termiosBefore']==o['termiosAfter'] and o['exitCode']==0,m['profile']+' native termios/direct exit')
 for item in m['screenshots']:
  f=p/item['file'];check(H(f)==item['sha256'],m['profile']+' original PNG hash '+item['file'])
  with Image.open(f) as im:dimensions=im.size;im.verify()
  check(dimensions==((1017,561) if m['profile'].startswith('vte') else (1004,536)),m['profile']+' real PNG dimensions')
  pngcount+=1
 grid=p/m['nativeGrid'];check(grid.stat().st_size>0,m['profile']+' host native viewport/grid exists')
 if m['profile'].startswith('vte'):
  meta=json.loads((p/'native-2-meta.json').read_text());check(meta['candidateCount']==1 and meta['rows']==28 and meta['cols']==100,m['profile']+' actual VteTerminal widget')
  check('CJTUI_SESSION_READY' in grid.read_text(),m['profile']+' actual native visible text')
 if 'ssh' in m:
  log=(p/m['ssh']['clientLog']).read_text();check('Authenticated to ' in log and 'publickey' in log and 'kex: algorithm:' in log and 'Exit status 0' in log,m['profile']+' real SSH auth/kex/exit')
  check((p/'client-termios-before').read_bytes()==(p/'client-termios-after').read_bytes(),m['profile']+' client termios restored')
 hosts.append({'profile':m['profile'],'manifest':str(path.relative_to(B)),'binarySha256':m['binarySha256'],'clipboardApplied':m['expected']['clipboardApplied'],'title':o['title'],'hostGrid':m['host']['grid'],'sourceSha':m['sourceSha']})
# Process syscalls from the actual binary: runtime threads are permitted, no subprocess or extra exec.
traces=list((R/'no-product-process').glob('trace.*'));execs=[];clones=[]
for p in traces:
 for line in p.read_text().splitlines():
  if line.startswith('execve('):execs.append(line);check(str(binary) in line,'trace exec only final consumer')
  if line.startswith(('fork(','vfork(')):check(False,'unexpected product fork')
  if line.startswith(('clone(','clone3(')):
   clones.append(line);check('CLONE_THREAD' in line,'clone creates runtime thread only')
check(len(execs)==3 and clones,'three actual routed consumer process traces')
check(not os.path.lexists('/tmp/.X11-unix/X173'),'no task X socket remains')
remaining=[]
for p in pathlib.Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:
  data=(p/'cmdline').read_bytes()
  if b'Xorg\x00:173\x00' in data:remaining.append(int(p.name))
 except (OSError,ProcessLookupError):pass
check(not remaining,'no task Xorg remains')
members=json.loads((B/'scope/package-members.json').read_text());check(len(members['members'])==138 and all(x['equal'] for x in members['members']),'all138 package member bytes match fixed git blobs')
check(H(S/'target/cjtui-0.0.0.cjp')==members['archiveSha256'],'actual external CJP final hash')
check(json.loads((B/'scope/bundle-advisories.json').read_text())['warningLines']==331,'actual unsuppressed331 bundle advisories')
report={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks':checks,'count':len(checks),'allPassed':True,'hostProfiles':hosts,'originalPngCount':pngcount,'processTraceFiles':len(traces),'productExecs':len(execs),'runtimeThreadCloneCalls':len(clones),'remainingOwnedXorg':remaining,'limitations':['Full bundle checker remains exit1; not full Linux release','VTE native viewport is instrumented text, not full cell attributes','Kernel VT fixed830 execution not performed by this script']}
(R/'verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2));print(json.dumps({'checks':len(checks),'allPassed':True,'hostProfiles':len(hosts),'originalPngCount':pngcount,'productExecs':len(execs)}))
