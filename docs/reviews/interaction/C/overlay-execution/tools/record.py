"""Record own independent commands and source/bin content boundaries."""
import argparse,datetime,hashlib,json,os,pathlib,subprocess,sys
B=pathlib.Path('/workspace/work/overlay-execution');P=B/'product'
def now():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def sha(p):
    h=hashlib.sha256()
    with p.open('rb') as f:
        for c in iter(lambda:f.read(1024*1024),b''):h.update(c)
    return h.hexdigest()
def publish(p,v):p.write_text(json.dumps(v,indent=2)+'\n')
def sources():
    paths=subprocess.check_output(['git','ls-files','-z'],cwd=P).split(b'\0');return {os.fsdecode(x):sha(P/os.fsdecode(x)) for x in paths if x and (P/os.fsdecode(x)).is_file()}
def binaries():
    result={}
    for base in [P,B/'clean-consumer',B/'clean-package']:
        if not base.exists():continue
        for p in base.rglob('main'):
            if p.is_file() and '/target/release/bin/' in str(p):result[str(p.relative_to(B))]=sha(p)
    return result
def configs():
    result={str(p):dict(sha256=sha(p),text=p.read_text()) for p in [B/'env.sh',B/'cangjie-repo.toml']}
    for base in [P,B/'clean-consumer']:
        if not base.exists():continue
        for name in ['cjpm.lock','cangjie-repo.toml']:
            for p in base.rglob(name):
                if '/target/' not in str(p):result[str(p)]=dict(sha256=sha(p),text=p.read_text())
    return result
if __name__=='__main__':
    a=argparse.ArgumentParser();a.add_argument('--name',required=True);a.add_argument('--cwd',type=pathlib.Path,default=P);a.add_argument('--trace-exit',action='store_true');a.add_argument('command',nargs=argparse.REMAINDER);v=a.parse_args();cmd=v.command[1:] if v.command and v.command[0]=='--' else v.command
    out=B/'raw'/v.name;out.mkdir(parents=True,exist_ok=False);pre=sources();publish(out/'input-pre.json',pre);publish(out/'config-pre.json',configs());publish(out/'bin-before.json',binaries())
    actual=['bash','-c','source /workspace/work/overlay-execution/env.sh\nexec "$@"','task111',*cmd]
    if v.trace_exit:actual=['strace','-f','-s','4096','-e','trace=execve,exit_group','-o',str(out/'process-exit.strace'),*actual]
    meta=dict(argv=cmd,actual_argv=actual,cwd=str(v.cwd),utcStart=now(),source=subprocess.check_output(['git','rev-parse','HEAD'],cwd=P,text=True).strip(),env=dict(SDK_ENV='/workspace/work/overlay-execution/env.sh',CANGJIE_STDX_PATH='/workspace/work/linux-build-recon/stdx-env',CJTUI_UCD_ARCHIVE='/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip'))
    publish(out/'command.json',meta);print('RUN',v.name,flush=True)
    with (out/'stdout').open('wb') as stdout,(out/'stderr').open('wb') as stderr:p=subprocess.run(actual,cwd=v.cwd,stdout=stdout,stderr=stderr)
    meta.update(exit=p.returncode,utcEnd=now());publish(out/'command.json',meta);(out/'exit').write_text(str(p.returncode)+'\n');post=sources();publish(out/'input-post.json',post);publish(out/'config-post.json',configs());publish(out/'bin-after.json',binaries());publish(out/'source-comparison.json',dict(unchanged=pre==post))
    print('EXIT',v.name,p.returncode,flush=True);sys.exit(p.returncode)
