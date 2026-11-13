#!/usr/bin/env python3
"""TOOLS_ONLY admission-driver controls; no SDK build or C product execution."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def main():
    task=Path(__file__).resolve().parent
    root=task.parents[1]
    with tempfile.TemporaryDirectory(prefix='cjtui-c108-gates-') as temporary:
        scratch=Path(temporary)
        fixture=scratch/'repo'
        subprocess.run(['git','clone','--quiet','--shared','--no-checkout',str(root),str(fixture)],check=True)
        target=fixture/'tests/interaction_c'
        target.mkdir(parents=True)
        for name in ['run.sh','admission.tsv','admission.current.tsv','admission.current.json']:
            if (task/name).is_file():shutil.copy2(task/name,target/name)
        current=target/'admission.current.tsv'
        original=current.read_text() if current.is_file() else None
        if original:
            for line in original.splitlines()[1:]:
                evidence=line.split('\t')[3]
                src=root/evidence
                dst=fixture/evidence
                if src.is_file() and src!=task/'admission.current.json':
                    dst.parent.mkdir(parents=True,exist_ok=True)
                    shutil.copy2(src,dst)
        bin_dir=scratch/'bin'
        bin_dir.mkdir()
        invoked=scratch/'compiler-invoked'
        executed=scratch/'binary-invoked'
        compiler=bin_dir/'cjpm'
        compiler.write_text('#!/usr/bin/env bash\nprintf "compiler\\n" >> "$OVERLAY_GATE_SENTINEL"\nexit 95\n')
        compiler.chmod(0o755)
        binary=target/'target/release/bin/main'
        binary.parent.mkdir(parents=True)
        binary.write_text('#!/usr/bin/env bash\nprintf "binary\\n" >> "$OVERLAY_BINARY_SENTINEL"\nexit 94\n')
        binary.chmod(0o755)
        env=dict(os.environ,PATH=str(bin_dir)+os.pathsep+os.environ['PATH'],OVERLAY_GATE_SENTINEL=str(invoked),OVERLAY_BINARY_SENTINEL=str(executed))

        def run(name,args,expected,build=False):
            invoked.unlink(missing_ok=True)
            executed.unlink(missing_ok=True)
            result=subprocess.run(['bash',str(target/'run.sh'),*args],cwd=scratch,env=env,stdin=subprocess.DEVNULL,capture_output=True,text=True,timeout=10)
            record=dict(case=name,args=args,expected=expected,actual=result.returncode,compiler_invoked=invoked.exists(),binary_invoked=executed.exists())
            print('TOOLS_ONLY '+json.dumps(record,sort_keys=True),flush=True)
            if result.returncode!=expected or invoked.exists()!=build or executed.exists():
                raise RuntimeError(str(record)+'\n'+result.stdout+result.stderr)

        if original:
            run('current-accepted-relative-evidence-from-unrelated-cwd',['preparation'],0)
            run('default-formal-build-failure-never-runs-binary',[],95,True)
            run('formal-build-failure-never-runs-binary',['formal'],95,True)
            run('device-build-failure-never-runs-driver',['device'],95,True)
            rows=original.splitlines()
            def mutate(name,index,value):
                altered=list(rows)
                fields=altered[5].split('\t')
                fields[index]=value
                altered[5]='\t'.join(fields)
                current.write_text('\n'.join(altered)+'\n')
                run(name,['formal'],77)
                current.write_text(original)
            mutate('unaccepted-current-status',1,'PENDING')
            mutate('short-current-hash',2,'6203955')
            mutate('forged-full-current-hash',2,'0'*40)
            tree=subprocess.check_output(['git','-C',str(fixture),'rev-parse','HEAD^{tree}'],text=True).strip()
            orphan=subprocess.check_output(['git','-C',str(fixture),'-c','user.name=Gate Tools','-c','user.email=gate-tools@example.invalid','commit-tree',tree,'-m','TOOLS_ONLY nonancestor control'],text=True).strip()
            mutate('real-but-nonancestor-hash',2,orphan)
            mutate('missing-relative-evidence',3,'tests/interaction_c/missing-proof')
            current.write_text('\n'.join(rows[:5]+rows[6:])+'\n')
            run('missing-required-gate',['formal'],77)
            current.write_text('\n'.join(rows[:-1]+[rows[1]])+'\n')
            run('duplicate-gate-does-not-count-as-eight',['formal'],77)
            current.write_text(original.replace('TASK107\t','UNKNOWN\t'))
            run('unknown-gate',['formal'],77)
            current.write_text(original)
            evidence=target/'admission.current.json'
            evidence.unlink()
            run('missing-current-freeze-json-evidence',['formal'],77)
            shutil.copy2(task/'admission.current.json',evidence)
            # A valid historical table must NOT rescue invalid current data.
            historical=target/'admission.tsv'
            historical.write_text(original)
            current.write_text(original.replace('\tACCEPTED\t','\tPENDING\t',1))
            run('invalid-current-never-falls-back-to-valid-history',['formal'],77)
            shutil.copy2(task/'admission.tsv',historical)
            current.unlink()
        for mode in ['formal','preparation','device']:
            run('historical-fallback-remains-closed-'+mode,[mode],77)
        run('invalid-mode',['invalid'],64)
        run('extra-argument-rejected',['formal','--skip'],64)
        print('TOOLS_ONLY admission controls complete; no real compiler or C binary executed')


if __name__=='__main__':
    main()
