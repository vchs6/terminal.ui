#!/usr/bin/env python3
"""Use original real QMP control, extending only recognized public exit key."""
import hashlib,json,os,pathlib
assert os.environ.get('C008_ROOT_ACTUAL_GO')=='1'
p=pathlib.Path('/workspace/work/linux-vt-product-probe/probes/control-vt.py');s=p.read_text()
a="if key in ['q','ctrl-c','e']:";assert s.count(a)==1
s=s.replace(a,"if key in ['q','ctrl-c','e','f10']:")
print(json.dumps({'source':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'transportOnlyChange':'recognize f10 as exit; same QMP send-key/wait PRODUCT_EXIT/screendump'}),flush=True)
exec(compile(s,str(p),'exec'),{'__file__':str(p),'__name__':'__main__'})
