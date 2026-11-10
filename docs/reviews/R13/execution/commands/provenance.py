from pathlib import Path
import subprocess,json,hashlib,datetime,shutil
b=Path('/workspace/work/dynamic-execution');s=b/'source';e=b/'evidence'
def git(*args):return subprocess.check_output(['git','-C',str(s),*args]).decode()
def hash(p):return hashlib.sha256(p.read_bytes()).hexdigest()
files=git('ls-files','-z').split('\0');inventory={r:hash(s/r) for r in files if r and (s/r).is_file()}
(e/'source-inventory.json').write_text(json.dumps(inventory,indent=2)+'\n')
proof=[]
for label,rev,paths in [('formal34','10c4ee3',['tests/dynamic']),('original32','3ee1a9b',['tests/dynamic/src/assertions.cj','tests/dynamic/src/conditional_cases.cj','tests/dynamic/src/identity_cases.cj','tests/dynamic/src/lifecycle_cases.cj','tests/dynamic/src/slot_cases.cj','tests/dynamic/src/validation_cases.cj']),('macro-negative','f07ff63303071764ea4acef5ba547d617e9d9a7c',['src/macros','tests/runtime/macros']),('lowlevel','c3d743d2dd5cb125e4ca435b2842d1b10c501281',['src/frame.cj','src/cell.cj','src/ansi_encoding.cj','src/color_mapping.cj','src/style','src/text','src/render_profile.cj'])]:
 diff=git('diff','--name-only',rev,'HEAD','--',*paths);proof.append(dict(label=label,baseline=rev,paths=paths,changed=diff.splitlines()));assert not diff,(label,diff)
(e/'fixed-content-proof.json').write_text(json.dumps(proof,indent=2)+'\n')
(e/'source-scope.json').write_text(json.dumps(dict(task='TASK079',classification='execution',model_requested='Sol/medium',source=git('rev-parse','HEAD').strip(),integrated_main='5de716f',utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),formal_tests='3ee1a9b + 10c4ee3; 34 groups, original32 preserved',inputs=['fixed contract/source/tests/raw','task-079-brief.md'],excluded=['product author reports/self-assessment','product/test/contract mutations','composition/benchmark completion','parent Linux AC closure','TASK080 acceptance']),indent=2)+'\n')
for p in [s/'cjpm.lock',s/'cangjie-repo.toml',Path('/workspace/work/validation/sdk/cangjie/envsetup.sh')]:
 if p.is_file():shutil.copy2(p,e/('root-'+p.name if p.parent==s else 'sdk-envsetup.sh'))
(e/'source-git-status.txt').write_text(git('status','--short'))
