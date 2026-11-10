#!/usr/bin/python3
"""Offline verification of this development facility's frozen raw evidence."""
from pathlib import Path
import datetime, hashlib, json
B=Path(__file__).resolve().parent.parent
M=B/'raw/final-module';N=B/'raw/final-baseline'
def load(p):return json.loads(p.read_text())
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
checks=[]
def require(value,label):
    assert value,label
    checks.append(label)
def stream_payload(p):
    raw=p.read_bytes()
    require(raw.endswith(b'[COMMAND_EXIT_CODE="0"]\n'),'script recorded real child exit zero: '+str(p.parent.name))
    return raw.split(b'\n',1)[1].rsplit(b'\nScript done on ',1)[0]
expected0='NORMAL_SCREEN_OWNED\nCURRENT_NORMAL\n中文 中😀 e\u0301\nGREEN_NATIVE\n\n\nROW7_NORMAL\n'+'\n'*21
expected1='ALTERNATE_SCREEN_OWNED\nCURRENT_ALT\nALT 中文 中😀 e\u0301\nRED_NATIVE\n'+'\n'*23+'BOTTOM_ROW28_ALT\n'
expected3=''.join('SCROLL_%02d\n'%i for i in range(14,41))+'\n'
for index,expected in enumerate([expected0,expected1,expected0,expected3]):
    text=(M/('native-%d-visible.txt'%index)).read_text()
    require(text==expected,'exact native visible text phase %d'%index)
    require(len(text.splitlines())==28,'28 native visible text rows phase %d'%index)
    meta=load(M/('native-%d-meta.json'%index))
    require(meta['cols']==100 and meta['rows']==28 and meta['candidateCount']==1,'actual single VTE 100x28 phase %d'%index)
    require(meta['widgetType']=='TerminalWidget','actual XFCE VTE subclass phase %d'%index)
    require(meta['pid']==load(M/'status.json')['terminalPid'],'API reads actual terminal process phase %d'%index)
    require(meta['writeContentsResult']==1 and meta['streamCloseResult']==1 and not meta['errorPresent'],'native write_contents completed phase %d'%index)
    require(datetime.datetime.fromisoformat(meta['utc'].replace('Z','+00:00')) is not None,'native API UTC phase %d'%index)
for root in [M,N]:
    status=load(root/'status.json');child=load(root/'child.json')
    require(status['hostExitCode']==0 and status['childExit']['exitCode']==0 and status['xorgExitCode']==0,'owned child/host/Xorg exit zero '+root.name)
    require(child['termiosBefore']==status['childExit']['termiosAfter'],'exact child termios restored '+root.name)
    require(status['privateHomeRemoved'] and status['displaySocketRemoved'],'private home/module/display cleaned '+root.name)
    require(stream_payload(root/'outer-ansi.bin')==(root/'emitted.bin').read_bytes(),'full actual PTY output equals fixed emitted bytes '+root.name)
    for phase in load(root/'phases.json'):
        name=phase['phase']
        require(digest(root/(name+'.png'))==phase['pngSha256'],'original PNG hash '+root.name+' '+name)
        require(phase['pngUnchangedAcrossRead'] and phase['propertiesUnchangedAcrossRead'],'same PNG/title/icon before and after read '+root.name+' '+name)
        require(phase['privateClipboardOwnerBefore']==phase['privateClipboardOwnerAfter']==0 and not phase['clipboardContentRead'],'private empty selection owner unchanged, no contents read '+root.name+' '+name)
        require((M/(name+'.png')).read_bytes()==(N/(name+'.png')).read_bytes(),'module vs uninstrumented identical original PNG '+name)
require((M/'emitted.bin').read_bytes()==(N/'emitted.bin').read_bytes(),'module vs baseline identical fixed output')
require((M/'native-0-visible.txt').read_bytes()==(M/'native-2-visible.txt').read_bytes(),'normal screen text restored after alternate')
require(b'SCROLL_01' in (M/'native-3-contents.txt').read_bytes() and b'SCROLL_01' not in (M/'native-3-visible.txt').read_bytes(),'native contents contains history; native visible excludes history')
require(b'\0' in (M/'native-1-contents.txt').read_bytes(),'native contents raw NUL cells preserved')
require('ALTERNATE' not in (M/'native-1-range.txt').read_text(),'naive adjustment-based range negative preserved')
maps=(M/'terminal-maps.txt').read_text()
require('native-module.so' in maps and 'libvte-2.91.so.0.8000.1' in maps and '/usr/bin/xfce4-terminal' in maps,'actual loaded module/XFCE/VTE maps retained')
result={'kind':'vte-grid-development-facility-verification-v1','verifiedUtc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'assertions':len(checks),'checks':checks,'productTested':False,'strict148HostOracleRun':False}
(B/'raw/verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2))
print(json.dumps({'facilityEvidenceVerified':True,'assertions':len(checks),'productTested':False}))
