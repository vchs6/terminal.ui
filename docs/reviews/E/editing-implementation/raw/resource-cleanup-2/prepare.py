import os,glob,hashlib,json,stat,time
from pathlib import Path
root=Path('/workspace/work/editing-implementation')
raw=root/'raw'
indexes=[]
for p in raw.rglob('*'):
    if p.is_file() and (p.name in ('SHA256SUMS','binaries.sha256','binary.sha256','input.sha256') or p.name.endswith('.sha256')):
        try: indexes.append(p.read_text(errors='replace'))
        except OSError: pass
indexed='\n'.join(indexes)
proc=[]; gaps=[]
for d in Path('/proc').iterdir():
    if not d.name.isdigit(): continue
    for name in ('cwd','exe'):
        try: proc.append(os.readlink(d/name))
        except (OSError,PermissionError) as e: gaps.append({'pid':d.name,'entry':name,'error':str(e)})
records=[]; skipped=[]
for tree in (root/'source/tests',):
    for target in tree.rglob('target'):
        if not target.is_dir() or target.is_symlink(): continue
        project=str(target.parent.resolve())
        if any(p == project or p.startswith(project+'/') for p in proc):
            skipped.append({'target':str(target),'reason':'active project'}); continue
        for p in target.rglob('*'):
            if p.suffix not in ('.o','.a','.cjo','.bc') or p.is_symlink(): continue
            try:
                st=p.stat()
                if not stat.S_ISREG(st.st_mode): continue
                full=str(p.resolve()); rel=os.path.relpath(full,str(root/'source'))
                if full in indexed or rel in indexed:
                    skipped.append({'path':full,'reason':'indexed'}); continue
                h=hashlib.sha256(p.read_bytes()).hexdigest()
                records.append({'path':full,'size':st.st_size,'inode':st.st_ino,'device':st.st_dev,'mtime_ns':st.st_mtime_ns,'sha256':h,'project':project})
            except OSError as e: skipped.append({'path':str(p),'reason':str(e)})
out={'time_ns':time.time_ns(),'proc_cwd_exe':proc,'proc_visibility_gaps':gaps,'skipped':skipped,'files':records,'total_bytes':sum(x['size'] for x in records)}
p=raw/'resource-cleanup-2'/'before.json';p.write_text(json.dumps(out,indent=2)+'\n');os.chmod(p,0o444)
(raw/'resource-cleanup-2'/'before.sha256').write_text(hashlib.sha256(p.read_bytes()).hexdigest()+'  before.json\n')
print('candidates',len(records),'bytes',out['total_bytes'],'skipped',len(skipped),'proc gaps',len(gaps))
