#!/usr/bin/env python3
"""Write transport-derived supervisor source only after GO; compile separately."""
import hashlib,json,os,pathlib,sys
assert os.environ.get('C008_ROOT_ACTUAL_GO')=='1' or sys.argv[1:]==['--source-only']
original=pathlib.Path('/workspace/work/linux-vt-product-probe/probes/vt-product-supervisor.c');text=original.read_text()
header=pathlib.Path(__file__).with_name('vt-supervisor-transport.h')
changes=[
 ('static int logfd;static int seq;','static int logfd;static int seq;\n#include "vt-supervisor-transport.h"'),
 ('pid_t child=fork();','tr_init(argv[1]);tr_fixture_boot(argv[1],control);pid_t child=fork();'),
 ('if(!child){char trace[128];','if(!child){tr_require_foreground("trace-child");char trace[128];'),
 ('dprintf(logfd,"PRODUCT_STARTED pid=%d\\n",child);','tr_require_foreground("supervisor-parent");tr_trace_start();dprintf(logfd,"PRODUCT_STARTED pid=%d\\n",child);'),
 ('snprintf(trace,sizeof trace,"/evidence/%s.strace",argv[1]);','snprintf(trace,sizeof trace,"%s",tr_fifo_path);tr_trace_child_close();'),
 ('struct pollfd p={control,POLLIN,0};','tr_drain();struct pollfd p={control,POLLIN,0};'),
 ("for(int i=0;i<n;i++){if(b[i]=='s')", "for(int i=0;i<n;i++){if(tr_control(b[i]))continue;if(b[i]=='s')"),
 ('tcgetattr(0,&after);','tr_require_foreground("before-restoration");tr_finish();tcgetattr(0,&after);'),
 ("if(b[i]=='k')kill(child,SIGTERM);","if(b[i]=='k')tr_owned_terminate(child);"),
 ('snprintf(app,sizeof app,"/apps/%s",argv[1]);','snprintf(app,sizeof app,"/apps/%s",!strcmp(argv[1],"showcase-file")?"showcase":argv[1]);'),
 ('execl("/usr/bin/strace","strace","-f","-xx","-s","65535","-e","trace=read,write,ioctl","-o",trace,app,(char*)0);',
  'if(!strcmp(argv[1],"showcase-file"))execl("/usr/bin/strace","strace","-f","-ttt","-yy","-xx","-v","-s","65535","-e","raw=ioctl","-e","trace=read,write,readv,writev,ioctl","-o",trace,app,"--theme-file","/evidence/selected.toml",(char*)0);else execl("/usr/bin/strace","strace","-f","-ttt","-yy","-xx","-v","-s","65535","-e","raw=ioctl","-e","trace=read,write,readv,writev,ioctl","-o",trace,app,(char*)0);')]

for before,after in changes:
 assert text.count(before)==1,('source changed; require owner rebind',before)
 text=text.replace(before,after)
out=pathlib.Path(os.environ['C008_VT_OPERATOR_BUILD']);out.mkdir(exist_ok=False)
(out/'vt-product-supervisor.c').write_text(text);(out/header.name).write_bytes(header.read_bytes())
pump=header.with_name('vt-trace-pump.h');(out/pump.name).write_bytes(pump.read_bytes())
(out/'transport-source-provenance.json').write_text(json.dumps({'status':'DERIVED_SOURCE_NOT_BUILT','original':str(original),'original_sha256':hashlib.sha256(original.read_bytes()).hexdigest(),'overlay':str(header),'overlay_sha256':hashlib.sha256(header.read_bytes()).hexdigest(),'trace_pump':str(pump),'trace_pump_sha256':hashlib.sha256(pump.read_bytes()).hexdigest(),'literal_substitutions':changes,'exec_environment_tracing':False,'product_changes':False},indent=2)+'\n')
print(out)
