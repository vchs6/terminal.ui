from pathlib import Path
b=Path('/workspace/work/dynamic-execution')
s=Path('/workspace/work/runtime-execution/gui-reactive.sh').read_text()
s=s.replace('/workspace/work/runtime-execution/source',str(b/'source')).replace('/workspace/work/runtime-execution/gui-key',str(b/'gui-key')).replace('examples/reactive','examples/dynamic').replace('scenarios=interrupt','scenarios=q').replace('TASK066 $profile','TASK079 $profile')
s=s.replace('example_key increment-one c; example_key increment-two c', 'example_key hidden v; example_key inserted i; example_key reordered r; example_key emptied e; example_key refilled e; example_key shown v')
s=s.replace('DISPLAY=$display "$interrupt" "$after" > "$dir/xtest-example-ctrl-c.txt"','DISPLAY=$display /workspace/work/dynamic-execution/gui-key "$after" q 0 0 > "$dir/xtest-example-q.txt"')
a=s.index('  capline=$(tr');z=s.index('\n}\ncapture_example()',a)
s=s[:a]+'''  python3 /workspace/work/dynamic-execution/gui-metadata.py "$dir" "$profile" "$host" "$version" "$before" "$after" "$cap" "$scenario" "$scene_source" "$source_commit" "$fixture_commit" "$fixture_sha" "$binary_sha" "$harness_sha"
'''+s[z:]
(b/'gui-dynamic.sh').write_text(s)
