import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {execFileSync} from 'node:child_process';

const own='/workspace/work/glyph-acceptance';
const repo='/workspace/work/terminal.ui';
const product='1f67e27358254e9daef637b5c2f5a93707ee7cef';
const root='b3b24f896672336797cec009cfe0cd830a955aa7';
const testRoot='ca565720f4a7c63330ad6e07bf25d1c198da2498';
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const git=(...args)=>execFileSync('git',['-C',repo,...args],{maxBuffer:32*1024*1024});
const write=(name,data)=>fs.writeFileSync(path.join(own,name),typeof data==='string'?data:JSON.stringify(data,null,2)+'\n');
const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(d,e.name)):[path.join(d,e.name)]);
const files=walk(path.join(own,'source')).map(p=>{
  const rel=path.relative(path.join(own,'source'),p);
  const commit=rel.startsWith('tests/glyphs/')?root:product;
  const bytes=fs.readFileSync(p), fixed=git('show',commit+':'+rel);
  if(!bytes.equals(fixed))throw Error('Source copy mismatch '+rel);
  if(rel.startsWith('tests/glyphs/')&&!bytes.equals(git('show',testRoot+':'+rel)))throw Error('Test root mismatch '+rel);
  if(!rel.startsWith('tests/glyphs/')&&!bytes.equals(git('show',root+':'+rel)))throw Error('Integrated product mismatch '+rel);
  return {path:rel,commit,sha256:sha(bytes)};
});
const contracts=[
 'AGENTS.md',
 'openspec/changes/implement-linux-vt-glyph-fallback/design.md',
 'openspec/changes/implement-linux-vt-glyph-fallback/tasks.md',
 'openspec/changes/implement-linux-vt-glyph-fallback/decisions.md',
 'openspec/changes/implement-linux-vt-glyph-fallback/specs/terminal-output/spec.md',
 'openspec/changes/implement-linux-vt-glyph-fallback/specs/development-workflow/spec.md',
 'openspec/changes/fix-uncertain-glyph-advance/design.md',
 'openspec/changes/fix-uncertain-glyph-advance/specs/terminal-output/spec.md',
 'openspec/changes/fix-uncertain-glyph-advance/tasks.md',
 'docs/reviews/R18/acceptance/report.md',
 'docs/reviews/R18/acceptance/acceptance-matrix.md',
 'docs/tasks.md','docs/acceptance.md'
].map(p=>{const b=fs.readFileSync(path.join(repo,p));return {path:p,sha256:sha(b),matches_frozen_root:b.equals(git('show',root+':'+p))};});
if(contracts.some(c=>!c.matches_frozen_root))throw Error('Contract working-tree drift');
const reviewRoot='/workspace/work/glyph-review';
const reviewNames=['report.md','findings.json','reviewed-hashes.json','artifacts.sha256'];
const review=reviewNames.map(p=>({path:path.join(reviewRoot,p),sha256:sha(fs.readFileSync(path.join(reviewRoot,p)))}));
const reviewer=JSON.parse(fs.readFileSync(path.join(reviewRoot,'reviewed-hashes.json')));
for(const [p,h] of Object.entries(reviewer.official_tests)){const rel=p.startsWith('tests/')?p:'tests/glyphs/'+p;const found=files.find(f=>f.path===rel);if(!found||found.sha256!==h)throw Error('095 test record mismatch '+p);}
const rawRows=[
 ['AC093–097','固定来源与独立性','产品/base/root/测试lineage、096实际源/二进制/依赖/配置完整hash；不使用作者自评。'],
 ['AC093','正式RED与fixture修正','旧正常build与真实缺API/internal RED；原11 Observable/capture1设施RED保留；bfd/dc6仅getter/counter修正，原oracle不降级。'],
 ['AC095','独立代码审查复用','095固定18文件、spec/quality结果及hash；095仅代码范围，不能替代096真实宿主。'],
 ['AC096/G002','正常SDK及公开兼容','SDK1.2.0根/普通consumer build及binary直接exit；两构造/legacy参数、enum/reexport、set/get签名。'],
 ['G002','能力只读正负控制','完整API正向先成功；六字段各var-local写入拒绝；构造包内、无公共bitmap。'],
 ['G002/G004','探测生命周期与事实','每成功run open后cleanup围栏内一次；Unicode/Ascii仍探测；离线不探测、关闭后last保留。'],
 ['G004/G011','具体stdout VT身份','isatty/fstat/S_ISCHR/major4 minor1..63/VT_GETMODE/KD_TEXT；实际fd1，alias/PTY/非文本不读map。'],
 ['G004/G011','有界unimap与释放','65535 pairs/262140临时bytes一次alloc/read，8192 bitmap副本，所有退出free；重复原pair计数与空map有效。'],
 ['G003/G011','失败诊断分类','闭集source/reason、errno、entryCount0；真实kernel失败与controlled syscall/PTY注入分别标注。'],
 ['G005/G010','policy所有权与预算','唯一生产policy/factories；mapped长度8192、防御复制；width0/负值/合法正预算，无固定width<=2。'],
 ['G003/G005','Ascii及mapped投影','单可打印ASCII或mapped单BMP单列gate；宽/CJK/组合/VS/ZWJ/非BMP整簇等宽，无NFC或业务改写。'],
 ['G005','装饰与缺备用字符','共享border数据；专用ASCII→?→空格有限回退，empty/no-question/no-border真实bytes和diagnostic。'],
 ['G012/A003–005','未知PTY保守Unicode','唯一displayWidth逐scalar与Cell.width相等放行，否则整簇?；保留类/替代类、true宽策略与零面积边界。'],
 ['G006','生成marker纯接口','真实generatedEllipsis、ambiguous false/true、mapped/missing、可用<=0/1/2/3/5；字面…仅原width投影。'],
 ['G007','单一布局policy接线','设备private produce与离线入口解析；同一renderLayout，无第二snapshot/Frame/布局内核。'],
 ['G007','缓存与mounted交替','Unicode/Ascii/Auto交替snapshot及mounted render，marker内容cache key与measure失效，节点身份保留。'],
 ['G002/G007/G008','模式唤醒与pump时序','actual-change唤醒/布局失效、同值静默；pump中修改使用实际旧policy基线，下一refresh不丢更新。'],
 ['G008/A004','投影列等价diff','中→文、宽簇↔两个?及空间替代，old/new各profile；style投影共同等价零bytes。'],
 ['G008/A004','输出与基线边界','宽→窄/缩短清残留、尺寸变化重绘；仅全写成功提交logical/profile，零面积不遍历巨轴。'],
 ['G009','离线文件独立','默认/显式Auto=Unicode、Ascii仅生成marker；实际plain/ANSI文件完整Unicode且不受设备/最近map污染。'],
 ['G001/G009','原回归与唯一权威','固定Frame/颜色/富文本/runtime回归与源码关联复用；业务跨span、clip/continuation、颜色事实不污染。'],
 ['S008/G008','失败安全与资源恢复','唯一writer/unsafe/reopen/zero-byte-safe-title/silentclose/首错聚合；失败后无后续设备输出；nativeclose、termios、signal原件。'],
 ['AC096/G001/G004','NEW真实kernel VT来源','新产品真实kernel/tty1，kernel版本/UID/major-minor/KD_TEXT/source/binary/config/viewport/UTC；非旧6a7b、TERM换名或合成VT。'],
 ['G001/G004','UTF8输出前置','实际boot默认+未改codec链+已知UTF8 native cells与原PNG经验对应；IUTF8/键盘/fontmap均不能单独证明。'],
 ['AC094/096/G003','真实VT普通Auto与override','同普通Application业务源无终端if，Auto fallback及Unicode/Ascii；原始map/字体来源、权限、诊断facts不被override改写。'],
 ['AC096/G009/G012','真实GUI物理输出','真正XTerm/VTE版本/config/font，同实际源/二进制；native物理数据和原PNG，保留/替代类与delta不越行。'],
 ['AC096/097','原图和原生数据独立核查','两类实际render profile代表原PNG亲看并hash，全部PNG来源/退出后封存；host观察器与产品分离，不用逻辑宽度模型作物理oracle。'],
 ['Session152 P30/REQ010/011','有限真实VT Session组合','当前产品普通Session例/正式consumer实际copy/title/restore/icon，NoAdapter或Unknown发送未确认诚实，永不因OSC wire推Applied；仅已证subset可闭合。'],
 ['AC096/G009','正常bundle lint','正常cjpm bundle实际命令/exit和warning计数，无skip、压级或suppression；保留advisory。'],
 ['AC096/097','全CJP及cleanconsumer','143实际regular members逐bytes对fixed git、全inventory；clean普通consumer仅manifest路径改，实际源和binary/exit。'],
 ['AC097','strictJSON与制品封存','全部原件/curated/hash及命令cwd/UTC/exit；host退出后final hash；omit ELF/CJP/CJO/SDK/cache/整checkout/私钥/Markdown源快照并记录外部hash理由。'],
 ['G006/AC097/Theme013','后续Theme输入边界','policy/marker/context可交013，085实际端到端追加后准入；完整ellipsis前缀与布局仍待013/085/088。'],
 ['AC041/P30/M2/AC023–024','父范围与发行边界','本097有限glyph不关041全部输入/resize/恢复/全组件、020/008/027/010/M2/Linux/跨OS/发布；whole checker缺composition/benchmark exit1保留。']
];
const rows=rawRows.map((r,i)=>({id:'G97-'+String(i+1).padStart(2,'0'),contract:r[0],obligation:r[1],required_evidence:r[2],status:'pending_evidence',received_evidence:i===2?['/workspace/work/glyph-review/report.md','/workspace/work/glyph-review/findings.json','/workspace/work/glyph-review/reviewed-hashes.json','/workspace/work/glyph-review/artifacts.sha256']:[],judgment:null}));
write('pending-matrix.json',{task:'TASK097',phase:'read_only_preparation',acceptance_verdict:'NOT_ASSESSED',task097_ready:false,rows});
write('pending-matrix.md','# TASK097 前读待证据矩阵\n\n仅待证据；未实际验收，不代表 ready/PASS。按合同义务划分33项，与既有单测数量无关。\n\n| ID | 合同 | 义务 | 待核证据 | 状态 |\n|---|---|---|---|---|\n'+rows.map(r=>`| ${r.id} | ${r.contract} | ${r.obligation} | ${r.required_evidence} | pending_evidence |`).join('\n')+'\n');
write('preparation-hashes.json',{utc:new Date().toISOString(),task:'TASK097',phase:'read_only_preparation',base:'7681999e501ca3a6d019648bca34528e6eaa990c',product,integrated_root:root,official_test_root:testRoot,official_test_base:'df21f3def32de39a415d1d8d9845b83514dc2902',official_test_repairs:['bfd0715cc342fe7c334bd7ce222cdda9c4fb37d5','dc6fdbfb4003a3151dab21d8de7cf7e54a1598b9'],source_files:files,contracts,review,brief:{path:repo+'/.superpowers/sdd/tasks-implement-linux-vt-glyph-fallback/task-097-brief.md',sha256:sha(fs.readFileSync(repo+'/.superpowers/sdd/tasks-implement-linux-vt-glyph-fallback/task-097-brief.md'))},product_executed:false,source_copy_archive_policy:'Local analysis input only; omit source directory from curated acceptance artifacts.'});
write('findings.json',{task:'TASK097',phase:'read_only_preparation',verdict:'NOT_ASSESSED',task097_ready:false,findings:[],assessment_complete:false,observations:[{id:'PREP-01',kind:'historical_text_superseded',text:'Glyph spec Unknown emulator coverage and decisions table retain original Unicode wording; explicit G012/A005 and root brief resolve device Auto to conservativeUnicode. This is not a new behavioral decision or a blocking ambiguity.'}],limitations:['TASK096 final original evidence has not been handed off.','No product build/run or host launch performed.','No TASK097/041/P30 acceptance judgment issued.','Actual serving model is unverified.']});
console.log(JSON.stringify({product_source_files:files.filter(f=>!f.path.startsWith('tests/')).length,official_test_files:files.filter(f=>f.path.startsWith('tests/')).length,contracts:contracts.length,rows:rows.length,all_copies_and_contracts_match_fixed_objects:true,product_executed:false}));
