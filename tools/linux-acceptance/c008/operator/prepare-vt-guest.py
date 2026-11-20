#!/usr/bin/env python3
"""After GO only: install final public apps plus explicit necessary file closure.
Does not discover/copy an SDK/cache or rebuild the accepted guest supervisor.
"""
import hashlib,json,os,pathlib,shutil,sys
assert os.environ.get('C008_ROOT_ACTUAL_GO')=='1','NOTEXECUTED until root ACTUAL GO'
manifest_path=pathlib.Path(os.environ['C008_VT_CLOSURE_MANIFEST']);m=json.loads(manifest_path.read_text())
root=pathlib.Path(os.environ['C008_VT_NEW_GUEST_ROOT']).resolve();assert not root.exists();root.mkdir()
assert m['status']=='ROOT_ADMITTED_NECESSARY_RUNTIME_CLOSURE' and m['admission147']==os.environ['C008_147_ADMISSION']
required={'/apps/showcase','/apps/composition','/init','/vt-product-supervisor','/bin/busybox','/usr/bin/strace','/dlmopen-check','/usr/bin/infocmp','/usr/bin/tput','/usr/bin/locale','/usr/share/terminfo/l/linux'}
seen=set();log=[]
for row in m['files']:
 src=pathlib.Path(row['source']).resolve();dest=row['destination'];assert src.is_file() and dest.startswith('/')
 target=(root/dest.lstrip('/')).resolve();assert target.is_relative_to(root) and dest not in seen;seen.add(dest)
 assert row['reason'] and row['sha256']==hashlib.sha256(src.read_bytes()).hexdigest()
 target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,target);log.append(row)
assert required<=seen,('missing actual guest runtime',required-seen)
closure=pathlib.Path(m['elfClosureEvidence']['path']);assert closure.is_file() and hashlib.sha256(closure.read_bytes()).hexdigest()==m['elfClosureEvidence']['sha256'],'actual necessary ELF closure evidence required'
# Same-guest raw ncurses collector, never whole Python/SDK deployment.
collector=pathlib.Path(__file__).with_name('guest-facts.sh');target=root/'operator/guest-facts.sh';target.parent.mkdir();target.write_bytes(collector.read_bytes())
init=root/'init';original=init.read_text();anchor='export PATH=/bin TERM=linux LD_LIBRARY_PATH=/lib/x86_64-linux-gnu';assert original.count(anchor)==1
init.write_text(original.replace(anchor,anchor+'\nexport LANG=C.UTF-8 LC_ALL=C.UTF-8\nexport PATH=/bin:/usr/bin'));init.chmod(0o755)
(root/'operator/init-derivation.json').write_text(json.dumps({'change':'explicit C.UTF-8 and paths for admitted guest ncurses tools','originalSha256':hashlib.sha256(original.encode()).hexdigest()},indent=2)+'\n')
# Only explicit symbolic links from the original base fixture, not directory copies.
for row in m.get('symlinks',[]):
 target=root/row['destination'].lstrip('/');assert target.resolve().is_relative_to(root)
 target.parent.mkdir(parents=True,exist_ok=True);target.symlink_to(row['target'])
for applet in ['sh','mount','setsid','poweroff','sleep','cat','base64','tar','mkdir','stty']:
 p=root/'bin'/applet;assert p.exists(),('missing original init BusyBox applet binding',applet)
for name in ['dev','proc','sys','evidence']: (root/name).mkdir(exist_ok=True)
(root/'operator-runtime-closure.json').write_text(json.dumps({'sourceManifest':str(manifest_path),'files':log},indent=2)+'\n')
# Original /init uses unrestricted scene=NAME; original supervisor execs /apps/NAME.
# Therefore scene=showcase or scene=composition needs no product or supervisor change.
print(json.dumps({'guestRoot':str(root),'scenes':['showcase','composition'],'status':'PREPARED_ONLY_NOT_BOOTED'}))
