from pathlib import Path
import json,hashlib
b=Path('/workspace/work/rich-text-execution');e=b/'evidence'
def inventory(root):
 return {str(f.relative_to(root)):hashlib.sha256(f.read_bytes()).hexdigest() for f in root.rglob('*') if f.is_file() and f.suffix in ['.cj','.toml','.c','.h'] and f.name not in ['cangjie-repo.toml','cjpm.lock'] and 'target' not in f.parts and 'build-script-cache' not in f.parts}
a=inventory(b/'cache/repository/source');c=inventory(b/'clean-cache/repository/source');assert a==c
(e/'clean-dependency-source-equality.json').write_text(json.dumps(dict(normal_and_clean_dependency_files=len(a),all_equal=True,sha256=a),indent=2)+'\n')
print('normal/clean dependency source/configuration manifests equal:',len(a))
