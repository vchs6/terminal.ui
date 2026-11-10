import {readFileSync,writeFileSync,readdirSync,statSync} from 'node:fs';
import {execFileSync} from 'node:child_process';
import {createHash} from 'node:crypto';
const root='/workspace/work/glyph-tests-refresh/source', dir='/workspace/work/glyph-tests-refresh/report';
const hash=b=>createHash('sha256').update(b).digest('hex');
const git=(...args)=>execFileSync('git',args,{cwd:root});
const records=readdirSync(dir).filter(n=>n.endsWith('.json')).map(n=>JSON.parse(readFileSync(dir+'/'+n))).filter(r=>r.argv).sort((a,b)=>a.start.localeCompare(b.start));
const byName=Object.fromEntries(records.map(r=>[r.name,r]));
for(const [name,code] of Object.entries({'baseline-build':0,'api-final-red':1,'internal-conservative':0,'internal-full-red':1,'public-red':1,'rich-red':1,'session-red':1,'readonly-final-blocked':2,'readonly-control-mutable-parameter':1,'readonly-control-mutable-local':0,'readonly-control-readonly-local':1,'shell-final-syntax':0,'node-syntax':0,'native-compile':0,'final-diff-check':0})) {
  if(byName[name]?.code!==code) throw Error(`Unexpected/missing ${name}`);
}
writeFileSync(dir+'/commands.json',JSON.stringify(records,null,2)+'\n');
const paths=git('ls-files','-z','tests/glyphs','src','native','cjpm.toml','build.cj').toString().split('\0').filter(Boolean);
writeFileSync(dir+'/sourcehash.sha256',paths.map(p=>`${hash(readFileSync(root+'/'+p))}  ${p}`).join('\n')+'\n');
writeFileSync(dir+'/test-only.patch',git('diff','04a5289361d990e5a340ace22bbd50c9b805a9d9','HEAD','--binary','--','tests/glyphs'));
const classes={
'environment':'SDK cjc/CJPM 1.2.0；固定BASE',
'baseline-build':'PASS 正常根build；产品无改动',
'api-red':'初次真实完整Glyph API missing RED；最终见api-final-red',
'api-final-red':'最终正常跨包missing API RED；缺TerminalGlyphCapabilities/GlyphMode，binary未运行',
'internal-conservative':'PASS 5/5；仅既有有限内核；无Ascii/map/marker/API',
'internal-full-red':'真实RED：现有GlyphRenderPolicy缺ascii/mapped；完整13项未运行',
'public-red':'真实RED：缺GlyphMode/TerminalGlyphCapabilities/render+Application参数；离线/File/cache行为未运行',
'rich-red':'真实RED：缺GlyphMode及render参数；4个已打印诊断无缺RichText前置',
'session-red':'真实RED：缺GlyphMode/terminalGlyphCapabilities/glyphMode；PTY/native动态未启动；非finalSession扩展证据',
'readonly-blocked':'初次正向API gate失败，readonly未尝试',
'readonly-final-blocked':'BLOCKED：最终正向API gate失败；旧combined+六独立readonly检查均未运行',
'readonly-control-mutable-parameter':'纯编译预期拒绝：parameter value is immutable；复现旧fixture假阳性',
'readonly-control-mutable-local':'纯编译允许：var local可写public var字段；从未执行',
'readonly-control-readonly-local':'纯编译预期拒绝：variable flag is immutable；从未执行',
'shell-syntax':'早期shell语法；最终见shell-final-syntax',
'shell-final-syntax':'PASS 最终shell语法',
'node-syntax':'PASS Node parse；未执行PTY',
'native-compile':'PASS gcc -Wall -Wextra -Werror；未执行native分支',
'staged-check':'早期diff检查；最终见final-diff-check',
'source-and-diff-check':'PASS 产品相对BASE无diff，原public/rich/native/negative fixture/Frame tests未变',
'final-diff-check':'PASS 最终staged whitespace与产品无diff',
'final-verification':'PASS 全受检sourcehash、工作树clean、product无diff与全部改动仅tests/glyphs',
};
let results='# 真实命令结果\n\n完整时间和argv见commands.json；raw为每项同名.log。预期编译RED、语言控制和真实产品运行分别解释。\n\n| 命令记录 | exit | run / blocked解释 |\n|---|---:|---|\n';
for(const r of records)results+=`| ${r.name} | ${r.code} | ${classes[r.name]??'见原始日志'} |\n`;
results+='\n编译器默认最多打印8项诊断；报告只分类实际打印的错误，不虚构被截断错误。真实readonly、完整marker、PTY/syscall行为均未运行。三个结构体语法控制不计为产品readonly通过。\n';
writeFileSync(dir+'/results.md',results);
const contracts=['openspec/changes/implement-linux-vt-glyph-fallback/design.md','openspec/changes/implement-linux-vt-glyph-fallback/tasks.md','openspec/changes/implement-linux-vt-glyph-fallback/specs/terminal-output/spec.md','openspec/changes/fix-uncertain-glyph-advance/design.md','openspec/changes/fix-uncertain-glyph-advance/tasks.md','openspec/changes/fix-uncertain-glyph-advance/specs/terminal-output/spec.md','AGENTS.md'];
const manifest={task:'TASK093 G012 formal test-only refresh',base:'04a5289361d990e5a340ace22bbd50c9b805a9d9',testOnlyCommit:git('rev-parse','HEAD').toString().trim(),originalTest:'daf2a2523c5aacb27e2ea3b564b9b057bd6430de',originalRootTest:'901b06a',source:root,report:dir,cache:'/workspace/work/glyph-tests-refresh/cache',sdkSetup:'/workspace/work/validation/sdk/cangjie/envsetup.sh',sdkVersion:'1.2.0',dependencies:{ansies:'1.3.113',unicode:'0.1.0',unicodewidth:'0.1.113'},requestedRole:'Sol/high; actual serving model/effort not independently exposed',contracts:contracts.map(path=>({path,sha256:hash(readFileSync(root+'/'+path))})),patchSha256:hash(readFileSync(dir+'/test-only.patch')),sourcehashSha256:hash(readFileSync(dir+'/sourcehash.sha256')),commandsSha256:hash(readFileSync(dir+'/commands.json')),productChanged:false,oldEvidenceCopiedByHash:true,partialConservativeTests:5,fullGlyphStatus:'missing API RED / behavior blocked',readonlyStatus:'positive API compile gate blocked; no product readonly PASS',realVtStatus:'not executed; required in actual096',full094Status:'not admitted; still waits152 and all specified upstream',declarationControls:'3 cjc staticlib compile-only language controls; never executed',finished:new Date().toISOString()};
writeFileSync(dir+'/manifest.json',JSON.stringify(manifest,null,2)+'\n');
const report=readFileSync(dir+'/report.md','utf8').replace(/固定test-only full SHA：[^\n]*\n\n/g,'');const title=`固定test-only full SHA：\`${manifest.testOnlyCommit}\`；patch SHA256：\`${manifest.patchSha256}\`；受检sourcehash清单SHA256：\`${manifest.sourcehashSha256}\`。\n\n`;
writeFileSync(dir+'/report.md',report.replace(/^(# TASK093 G012 正式测试刷新\n\n)/,'$1'+title));
function list(path,prefix=''){return readdirSync(path).sort().flatMap(name=>{const rel=prefix+name;return statSync(path+'/'+name).isDirectory()?list(path+'/'+name,rel+'/'):[rel];});}
const evidence=list(dir).filter(p=>p!=='evidence-sha256.txt'&&!p.startsWith('files/')&&!p.endsWith('.mjs'));
writeFileSync(dir+'/evidence-sha256.txt',evidence.map(p=>`${hash(readFileSync(dir+'/'+p))}  ${p}`).join('\n')+'\n');
process.stdout.write(JSON.stringify({testOnlyCommit:manifest.testOnlyCommit,patchSha256:manifest.patchSha256,sourcehashSha256:manifest.sourcehashSha256,records:records.length,evidenceFiles:evidence.length})+'\n');
