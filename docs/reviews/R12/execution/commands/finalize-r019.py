from pathlib import Path
import json,subprocess,hashlib
b=Path('/workspace/work/runtime-execution');e=b/'r019-evidence';s=b/'r019-source'
required=['tool-versions','abi-build','abi-direct','root-build','root-check','native-session','resize-coherence','lifecycle-build','lifecycle-resize','integration-build','integration-resize','bundle','clean-root-build','clean-root-check','clean-abi-build','clean-abi-direct','clean-reactive-build','clean-reactive-direct']
statuses={x.parent.name:int(x.read_text()) for x in e.glob('*/exit')}
assert all(statuses.get(k)==0 for k in required),statuses
assert statuses['archive-boundary']==1
tracked=subprocess.check_output(['git','-C',str(s),'diff','HEAD'],text=True);assert not tracked
frozen=subprocess.check_output(['git','-C',str(s),'diff','dddbdd9','HEAD','--','tests'],text=True);assert not frozen
resize={}
for mode in ['coherence','inflight']:
 root=next(e.glob('cjtui-resize-*/'+mode));result=json.loads((root/'result.json').read_text());obs=json.loads((root/'observations.json').read_text());assert result['passed'] and result['code']==0 and not obs['mixed'];resize[mode]=obs
clean=json.loads((e/'clean-reactive-pty/result.json').read_text());assert clean['status']==0 and clean['exactTermiosRestored']
r={'candidate':'0912436b647f701e1de607fe03ce1bfba6a9bbf4','frozenTests':'dddbdd9e02fbb6e8a998b24d447ec9b97a79a439','contract':'fc7667339d39208bbd0c25650696a7f495ca971d','trackedDiffEmpty':True,'testsUnchangedFromFreeze':True,'statuses':statuses,'resizeObservations':resize,'cleanReactive':clean,'finiteVerdict':'PASS: scoped R019 checks plus explicitly audited c3 evidence reuse','fullReleaseVerdict':'NOT VERIFIED: incomplete composition example/rendering benchmark; check-product release not run'}
(e/'final-verification.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(r,indent=2))
