import os,sys,subprocess,pathlib,json,datetime
binary,out=sys.argv[1:];p=pathlib.Path(out)
def run(a):return subprocess.check_output(a,text=True).strip()
meta={'utcStart':datetime.datetime.now(datetime.timezone.utc).isoformat(),'tty0':os.ttyname(0),'tty1':os.ttyname(1),'uid':os.getuid(),'grid':run(['stty','size']),'before':run(['stty','-g']),'TERM':os.getenv('TERM'),'LANG':os.getenv('LANG'),'LC_ALL':os.getenv('LC_ALL')}
(p/'terminal-before.json').write_text(json.dumps(meta,indent=2))
env=os.environ.copy();env['CJTUI_GLYPH_REPORT']=str(p/'profile.txt')
cmd=['strace','-f','-xx','-s','65535','-e','trace=read,write,ioctl,newfstatat,fstat,openat,execve','-o',str(p/'product.strace'),binary];(p/'product-command.json').write_text(json.dumps(cmd))
r=subprocess.run(cmd,env=env)
meta.update(exit=r.returncode,after=run(['stty','-g']),utcEnd=datetime.datetime.now(datetime.timezone.utc).isoformat());(p/'terminal-after.json').write_text(json.dumps(meta,indent=2));sys.exit(r.returncode)
