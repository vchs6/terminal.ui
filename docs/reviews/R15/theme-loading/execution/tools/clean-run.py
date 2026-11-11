import importlib.util,sys,pathlib
B=pathlib.Path('/workspace/work/theme-load-execution');source=B/'product/tests/theme-loading';sys.path.insert(0,str(source));spec=importlib.util.spec_from_file_location('fixed_runner',source/'run.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
logs=B/'raw/clean-async/detail';logs.mkdir(parents=True,exist_ok=False);binary=B/'clean-consumer/tests/theme-loading/consumer/target/release/bin/main';gate=B/'raw/async-all/detail/libtheme_io_gate.so'
for case in ['latest-success','atomic-caches']:m.run_controlled(binary,case,logs/('work-'+case),gate,logs,'fa6a46ec339ea0f098dea521c814226a7a373c7e',30)
print('PASS clean source-package public async consumers, real-file and atomic fixes')
