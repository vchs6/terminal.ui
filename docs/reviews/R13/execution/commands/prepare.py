from pathlib import Path
b=Path('/workspace/work/dynamic-execution');s=b/'source'
config='[repository.cache]\npath = "'+str(b/'cache')+'"\n[repository.home]\nregistry = "http://127.0.0.1:18973"\nversion = 0\n'
for p in s.rglob('cjpm.toml'):(p.parent/'cangjie-repo.toml').write_text(config)
(b/'evidence').mkdir(exist_ok=True)
(b/'env.sh').write_text('source /workspace/work/validation/sdk/cangjie/envsetup.sh\nexport CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip\nexport CJTUI_RUNTIME_ARTIFACTS=/workspace/work/dynamic-execution/evidence\nunset cjHeapSize\n')
