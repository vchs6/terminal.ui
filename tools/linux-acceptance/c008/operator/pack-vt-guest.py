#!/usr/bin/env python3
"""Parameterize only original pack-guest.py paths; retain existing CPIO bytes logic."""
import hashlib,json,os,pathlib,sys
assert os.environ.get('C008_ROOT_ACTUAL_GO')=='1'
source=pathlib.Path('/workspace/work/linux-vt-product-probe/probes/pack-guest.py');text=source.read_text()
a='b=pathlib.Path(__file__).resolve().parents[1];r=b/"guest-root"'
b="r=pathlib.Path(os.environ['C008_VT_NEW_GUEST_ROOT'])"
x="b/'packages/vt-initramfs.cpio.gz'";y="pathlib.Path(os.environ['VT_INITRD'])"
assert text.count(a)==1 and text.count(x)==1
output=pathlib.Path(os.environ['VT_INITRD']);assert not output.exists()
exec(compile(text.replace(a,b).replace(x,y),str(source),'exec'),{'__file__':str(source),'__name__':'__main__'})
print(json.dumps({'originalPacker':str(source),'sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'changes':'guest root/output path only'}))
