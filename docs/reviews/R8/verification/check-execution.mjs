import {readFileSync,writeFileSync} from 'node:fs';
import {execFileSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
const base='/workspace/work/first-slice-execution/';
const repo='/workspace/work/first-slice-acceptance/repo/';
const hash=b=>createHash('sha256').update(b).digest('hex');
const read=p=>readFileSync(base+p);
const data=JSON.parse(read('slice-results.json'));
const result={source:data.final_source,commands:[],artifacts:[],payload:[],observations:{}};
for(const cmd of data.commands){
 const raw=readFileSync(cmd.log,'utf8');
 const exits=[...raw.matchAll(/^exit_code=(\d+)$/gm)].map(m=>Number(m[1]));
 assert.equal(exits.at(-1),cmd.exit_code,cmd.id+' raw exit');
 assert(raw.includes('cwd='+cmd.cwd+'\n'),cmd.id+' cwd');
 assert(raw.includes('command='+cmd.command+'\n'),cmd.id+' command');
 assert(raw.includes('started='+cmd.started+'\n'),cmd.id+' start');
 assert(raw.includes('ended='+cmd.ended+'\n'),cmd.id+' end');
 result.commands.push({id:cmd.id,exit_code:cmd.exit_code,log_sha256:hash(Buffer.from(raw))});
}
assert.equal(data.commands.find(x=>x.id==='slice-product').exit_code,1);
assert.equal(data.commands.find(x=>x.id==='slice-cold-product').exit_code,0);
const cold=read('logs/slice-cold-product.log').toString();
const coldPass=cold.split('\n').filter(s=>s.startsWith('PASS'));
assert.equal(coldPass.length,134);
assert(cold.includes('Implemented slice checks complete; not a final product/release verification.'));
assert(cold.includes('owner: open1=0 open2=-1 successes=1 close=0 restored=1'));
assert(cold.includes('setup-signal: open=0 read_after_SIGTERM=-2 close=0 restored=1'));
for(const mode of ['q','ctrl-c','sigint','sigterm','resize','exception','osc-ctrl-c','utf8-ctrl-c','utf8-fragmented','sos-ignore','sos-escape-utf8']){
 const code=mode==='exception'?1:0;
 assert(cold.includes(`PASS PTY ${mode}: exit=${code}, termios restored`),mode);
}
assert(cold.includes('OBSERVED PTY utf8-fragmented: [{"code":"text","text":"中"},{"code":"text","text":"q"}]'));
for(const mode of ['sos-ignore','sos-escape-utf8'])assert(cold.includes(`OBSERVED PTY ${mode}: [{"code":"text","text":"q"}]`));
assert.deepEqual(data.suite.final_cold_entry.pass_lines,coldPass);
const all=read('logs/slice-tests-all.log').toString();
assert.deepEqual(data.suite.standalone.pass_lines,all.split('\n').filter(s=>s.startsWith('PASS')));
for(const a of JSON.parse(read('slice-artifacts.json'))){const b=read(a.path);assert.equal(b.length,a.size,a.path+' size');assert.equal(hash(b),a.sha256,a.path+' hash');result.artifacts.push({path:a.path,sha256:a.sha256,size:a.size});}
const minimal=JSON.parse(read('minimal-pty/result.json'));
assert(minimal.binary.endsWith('/examples/minimal/target/release/bin/main'));
assert.equal(minimal.application_exit,0);assert.equal(minimal.script_exit,0);assert.equal(minimal.signal,null);
assert.equal(read('minimal-pty/before').toString().trim(),read('minimal-pty/after').toString().trim());
assert.equal(read('minimal-pty/application-exit').toString().trim(),'0');
const stdout=read('minimal-pty/stdout.bin');for(const s of ['cjtui','中文','👩‍💻','\x1b['])assert(stdout.includes(Buffer.from(s)));
assert.equal(stdout.length,182);assert.equal(read('minimal-pty/stderr.bin').length,0);
const archive=base+data.package.source_cjp;
const paths=execFileSync('tar',['-tzf',archive],{encoding:'utf8'}).trim().split('\n');
const files=paths.filter(p=>!p.endsWith('/'));
assert.equal(files.length,37);
for(const p of paths){assert(!p.startsWith('/')&&!p.split('/').includes('..'));}
const types=execFileSync('tar',['-tvzf',archive],{encoding:'utf8'}).trim().split('\n');
assert(types.every(x=>/^[-d]/.test(x)));
const required=['build.cj','native/build.sh','native/cjtui_terminal.c','src/application.cj','src/component.cj','src/frame.cj','src/unicode.cj','examples/minimal/src/main.cj','docs/product/README.md'];
for(const rel of required)assert(files.includes('cjtui-0.0.0/'+rel));
for(const p of files){const rel=p.replace(/^cjtui-0.0.0\//,'');assert(!/(?:^|\/)(?:tests|scripts|target|node_modules|openspec|\.cjtui-build|build-script-cache)(?:\/|$)/.test(rel));assert(!/\.(?:a|o|so|cjp|zip)$/.test(rel));const b=execFileSync('tar',['-xOzf',archive,p]);assert(b.equals(readFileSync(repo+rel)),rel+' acceptance source identity');result.payload.push({path:rel,sha256:hash(b)});}
assert.equal(hash(readFileSync(archive)),data.package.sha256);
const plain=read('snapshot-plain.txt').toString(),ansi=read('snapshot-ansi.txt').toString();
assert.equal(plain,'Source package  \n中文 👩‍💻         \n                ');
assert(!plain.includes('\x1b')&&!plain.endsWith('\n'));
assert(ansi.startsWith('\x1b[0m\x1b[1;1H')&&ansi.endsWith('\x1b[0m')&&!ansi.includes('\n'));
assert(ansi.includes('\x1b[2;1H')&&ansi.includes('\x1b[3;1H'));
const trace=read('logs/slice-runtime-file.trace').toString();assert(!/\/workspace\/work\/(first-slice|validation\/replay-dependencies|terminal.ui)/.test(trace));assert(trace.includes('exited with 0'));
assert(read('slice-cache-before.sha256').equals(read('slice-cache-after.sha256')));
result.observations={cold_pass_lines:coldPass.length,pty_modes:11,actual_minimal:true,minimal_stdout_bytes:182,packaged_files:files.length,package_sha256:data.package.sha256,plain_snapshot_exact:true,ansi_snapshot_boundary:true,cache_lists_identical:true,runtime_development_path_access:false};
writeFileSync('/workspace/work/first-slice-acceptance/execution-evidence-check.json',JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({commands:result.commands,artifacts_verified:result.artifacts.length,observations:result.observations},null,2));
