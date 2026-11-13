import pathlib,shutil,hashlib,json
B=pathlib.Path('/workspace/work/keyboard-execution');product=B/'clean-unpacked/cjtui-0.0.0';external=B/'clean-consumers';external.mkdir(exist_ok=False);bindings=[]
for name,rel in [('keyboard','tests/keyboard'),('dispatch','tests/keyboard/formal_dispatch')]:
 src=B/'source'/rel;dest=external/name;dest.mkdir();shutil.copytree(src/'src',dest/'src');text=(src/'cjpm.toml').read_text();old='path = "../.."' if name=='keyboard' else 'path = "../../.."';assert old in text;new=text.replace(old,'path = "'+str(product)+'"');(dest/'cjpm.toml').write_text(new);(dest/'cangjie-repo.toml').write_bytes((B/'cangjie-repo.toml').read_bytes())
 for p in (src/'src').rglob('*'):
  if p.is_file():q=dest/'src'/p.relative_to(src/'src');assert p.read_bytes()==q.read_bytes();bindings.append(dict(source=str(p),clean=str(q),sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
 bindings.append(dict(source=str(src/'cjpm.toml'),clean=str(dest/'cjpm.toml'),manifest_change_only=dict(before=old,after='path = "'+str(product)+'"')))
p=B/'raw/clean-input-bindings.json';p.write_text(json.dumps(dict(source_sha='c3c4642d84df57bbd9550d222ed22f602acd13ef',bindings=bindings),indent=2)+'\n');p.chmod(0o444)
print('Clean public consumer sources byte-equal; only dependency manifest path changed')
