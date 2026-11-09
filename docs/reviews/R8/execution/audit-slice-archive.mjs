import fs from 'node:fs';import {execFileSync} from 'node:child_process';import assert from 'node:assert/strict';import crypto from 'node:crypto';
const archive=process.argv[2];const output=process.argv[3];
const entries=execFileSync('tar',['-tzf',archive],{encoding:'utf8'}).trim().split('\n');
const types=execFileSync('tar',['-tvzf',archive],{encoding:'utf8'}).trim().split('\n');
assert(types.every(l=>/^[-d]/.test(l)),'archive only regular files/directories');
const prefix='cjtui-0.0.0/';assert(entries.every(p=>p.startsWith(prefix)&&!p.startsWith('/')&&!p.split('/').includes('..')));
const files=entries.filter(p=>!p.endsWith('/')).map(p=>p.slice(prefix.length));
const allowed=/^(?:src\/|examples\/|benchmarks\/|docs\/product\/|native\/.*\.(?:sh|c|h|S|cj)$|third_party\/licenses\/|build\.cj$|cjpm\.toml$|README(?:_zh)?\.md$|LICENSE$|NOTICE$|CHANGELOG\.md$)/;
for(const p of files){assert(allowed.test(p),'unexpected archive file '+p);assert(!p.split('/').some(s=>s.startsWith('.')||['target','node_modules','cache','build-script-cache','tests','scripts','openspec'].includes(s)),'development path '+p);assert(!/\.(?:a|o|so|cjo|cjp|zip|tar|gz)$/i.test(p),'binary/build payload '+p);assert(!/(?:^|\/)(?:cangjie-repo\.toml|cjpm\.lock|AGENTS\.md)$/.test(p),'environment payload '+p);}
for(const p of ['src/unicode.cj','build.cj','native/build.sh','native/cjtui_terminal.c','examples/minimal/cjpm.toml','examples/minimal/src/main.cj','docs/product/README.md','docs/product/native-build.md','LICENSE','NOTICE','cjpm.toml','third_party/licenses/UNICODE-DATA-LICENSE.txt'])assert(files.includes(p),'missing '+p);
for(const name of ['unicode','unicodewidth','ansies','bitarray'])assert(files.some(p=>p.startsWith('third_party/licenses/'+name+'/')),'missing attribution '+name);
const sha=crypto.createHash('sha256').update(fs.readFileSync(archive)).digest('hex');
const result={archive,sha256:sha,files,regular_files_only:true,no_build_artifacts:true,no_development_or_test_directories:true,required_slice_sources_and_attributions:true,full_release_gate:'not evaluated; composition and benchmark remain pending'};
fs.writeFileSync(output,JSON.stringify(result,null,2)+'\n');console.log('PASS slice source archive boundary: '+files.length+' files, SHA256='+sha);
