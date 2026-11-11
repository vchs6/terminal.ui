from pathlib import Path
import subprocess,json,hashlib,datetime,re
B=Path('/workspace/work/theme-acceptance');R=Path('/workspace/work/terminal.ui')
P='8d75233c664fd61be08d441f74d464cbcdff2d9c';BASE='81cd29cdf173cd02a390f3d992037de395caafaf'
def git(*args):return subprocess.check_output(['git','-C',str(R),*args])
def sha(x):return hashlib.sha256(x).hexdigest()
def write(name,d):(B/name).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
B.mkdir(parents=True,exist_ok=True)
contract=R/'openspec/changes/implement-theme-styles/design.md'
assert sha(contract.read_bytes())=='084b1623937055426e0e7c57c2cc5b9cfa2e474a787ce7e81fee3cea286c30a4'
assert git('rev-parse',P+'^').decode().strip()=='95c1186a8ec5b184d5d2f15af0cac2e81499ce68'
assert git('diff','--numstat',P+'^',P).decode().strip()=='0\t4\tsrc/theme/theme_decoder.cj'
paths=git('ls-tree','-r','--name-only',P,'src','native','themes','tests/themes','cjpm.toml','build.cj','docs/product','openspec/changes/implement-theme-styles/fixtures').decode().splitlines()
inventory=[{'path':p,'git_commit':P,'sha256':sha(git('show',P+':'+p))} for p in paths]
presets=[]
for name in ['dark','light','high-contrast','classic']:
 ps=['themes/'+name+'.toml','tests/themes/fixtures/'+name+'.toml','openspec/changes/implement-theme-styles/fixtures/themes/'+name+'.toml']
 digests=[sha(git('show',P+':'+p)) for p in ps];assert len(set(digests))==1
 presets.append({'name':name,'paths':ps,'sha256':digests[0],'byte_equal':True})
keys=re.findall(r'public static let (\w+): StyleKey',git('show',P+':src/style/style_keys.cj').decode());assert len(keys)==36
inputs=[contract,R/'openspec/changes/implement-theme-styles/specs/theme-config/spec.md',R/'openspec/changes/implement-theme-styles/tasks.md',R/'.superpowers/sdd/tasks-implement-theme-styles/task-088-brief.md',R/'docs/tasks.md',R/'docs/acceptance.md',R/'AGENTS.md']
reviews=[]
for parent,names in [('/workspace/work/theme-review',['report.md','reviewed-hashes.json']),('/workspace/work/theme-review/round1',['report.md','reviewed-hashes.json']),('/workspace/work/theme-review/cleanup-closure',['report.md','evidence.json','artifacts.sha256'])]:
 for n in names:
  p=Path(parent)/n;reviews.append({'path':str(p),'sha256':sha(p.read_bytes()),'bytes':p.stat().st_size})
now=datetime.datetime.now(datetime.timezone.utc).isoformat()
write('prepared-hashes.json',{'utc':now,'phase':'read_only_preparation','base':BASE,'candidate':P,'contract_sha256':sha(contract.read_bytes()),'contracts':[{'path':str(p),'sha256':sha(p.read_bytes())} for p in inputs],'source_test_inventory':inventory,'inventory_note':'Hashes of fixed Git blobs, not a claim every file was independently line-reviewed or executed. No source copies written.','typed_keys':keys,'presets':presets,'independent086':reviews,'cleanup_delta':{'parent':'95c1186a8ec5b184d5d2f15af0cac2e81499ce68','files':1,'added':0,'deleted':4},'product_executed':False})
rows=[
('AC085–088','固定来源与角色','087执行前后产品/tests/SDK/stdx/依赖/ignored配置/实际binary/UTC/scope完整来源；原件→归档hash，不以HEAD标签代替内容。'),
('AC085','正式测试及RED','原085真实缺API RED、正向门禁及追加Glyph/T009/source-type/order/rejected-padding固定测试链；原16negative与4preset未降级。'),
('AC086','独立审查闭环','原完整086+round1四项修复+8d四行helper删除链；0未决C/I/M只作为source review。'),
('T002/T013/T016','typed声明与查询','36typed key不可伪造、只读name、withValue/value原state查询、无Any袋；StyleValue/Rule/Use/enum内容相等与防别名。'),
('T002/T012','真实正向与负例门禁','最终源正常SDK公开values/integration build及direct binary均成功在先；16实际编译拒绝为type/access，不是依赖失败。'),
('T004/T011','声明slot与兼容','旧常量/getter接口、同key/state替换/解绑；getter返回Unset保留依赖，显式Unset删除；widthAuto/ValueAuto/Reset有别。'),
('T004/086-I03','padding slot mutation安全','uniform binding逐side替换、两个setStyle overload先重入/权限校验，拒绝调用不部分解绑；正式回归后pad2位于2,2且node保留。'),
('T003/T014','role和primitive能力','17roles静态矩阵、Generic实际能力、挂载后role拒改、不变kind；全局投影与named非法目标明确失败。'),
('T001/T011','四来源逐属性','显式→后至前styles→role/global→继承/default；不是整体Style覆盖，来源/空列表/数组copy可观察。'),
('T001/T002','状态次序与Reset','每个来源内Disabled/Selected/Focused/Normal；后named normal盖前disabled；Reset终止，false/zero/Default是Value。'),
('T001/T013','继承与root seed','8绘制属性仅逻辑根seed；父已解析传播，子自身来源覆盖；装饰/间距/排版不继承，Reset后的默认可继承。'),
('T015','背景三来源与fill','无fill/root背景-only/local完整Style；继承背景不额外fill、根clip/hidden、Classic inverse/underline空白兼容。'),
('T013/T015','presence/cache相等','相同resolved颜色而explicit mask或fill来源变化仍invalidate/repaint；单一resolver/Runtime/LayoutNode/Frame。'),
('T011/§9','富文本explicit mask','当前组件显式含Reset > span > reuse/theme/inherited/default；祖先显式在子为Inherited；span背景仅其cell。'),
('T001/T004','全部装饰渲染','border默认派生fg与ValueDefault不同、8shadow槽/偏移/开启分别生效；shadow便捷接口不污染正文/不继承。'),
('T001/T004/T005','全部间距渲染','四边padding、固定/最小尺寸、weight、gap、align/justify实际Frame生效；sat/checked极端边界不溢出。'),
('T005/T014','实际分配宽wrap','同LayoutNode Row flex与Column可用宽重测自然高及兄弟；padding/border后内容宽；无第二布局树。'),
('T005/T014','wrap零宽与簇边界','硬LF/CRLF、零宽每硬行1、宽1大簇独占裁剪行且无末尾假行、组合/零宽簇、height/viewport裁剪。'),
('T005/G006','真实ellipsis前缀预算','width0..4、Unicode/Auto/Ascii、先marker宽再整簇prefix；exactfit/clip无标记；仅水平裁剪，不暗示垂直隐藏。'),
('T005/G007','Glyph布局上下文/cache','Row分配/padding/span边界、同mounted root snapshot mode往返、设备与离线上下文独立、逻辑原文/文件保留。'),
('T005/G004/G012','实际run的policy接线','正式PTY未知/Unicode/Ascii、controlled mapped marker有/缺、一次probe、setter唤醒/no-remount和post-run；合成ioctl不冒真实VT。'),
('T009/§3–4','闭集完整schema','根8keys、36properties、17roles、10变量类型、4states，literal/Reset/ref全部；unknown/noinclude，unused坏值也拒。'),
('T009/§3–4','原生类型与范围','无字符串/Bool/Float/date/time强转；Int64/cells/offset/dimension/alignment域、颜色闭集/index/RGB、名称printable与标识符。'),
('T009/§6/086-I01–02','首条诊断与声明序','安全预算内syntax→version/rootrequired→源码序unknown/value/ref，变量value/extra双向，forwardref保留；来源/位置原始。'),
('T009/T014','诊断Rune与source','ref值位置、Rune而非byte、最近table/unavailable真实fallback，不伪造1,1；read错误source/空path/no位置。'),
('T009','同步readFile与路径','有界读取/非法UTF8、空NUL、绝对冻结path、parse label非文件、~/$HOME/URI不解释；文件错误不改应用。'),
('T009/T016','完整联合预算','UTF8 1MiB、4096vars/styles、16depth/effectivepath、65536非EOF含comment、16384声明；at合法或正确下游错误，over先Capacity。'),
('T009末澄清','encoded key所有上下文','11spellings×6contexts 1024/1025，103raw a/103U转义区分，1024成功语义、value/comment控制、Rune超限位置。'),
('T009','上游唯一Lexer/Parser','预算只读public token原始value不解码/自建parser；有效table+dotted+inline累计路径栈恢复、字符串/comment符号惰性；危险深输入先拒。'),
('T010/T014','四preset同模型','4固定fixture/product文本字节同，embedded preset同parse/schema/resolver，全部规则及source标签/immutable bridge独立预期。'),
('T010/T015','Classic兼容与四主题Frame','原默认像素、未声明border/shadow不出现；四preset同业务手写grid/style及state基础输出。'),
('AC087/T010','真实四主题宿主','最终source/binary、真实GUI版本/font/config/尺寸/UTC、四主题同基础业务原PNG/native/raw/termios/exit；不扩作027全控件showcase。'),
('AC013/T011','仅样式变化更新/身份','state/style/getter变更影响实际frame，mounted/业务身份与原runtime契约保留，bindings/mask/fill缓存实际回归。'),
('AC087','受影响旧回归','固定源/配置/范围对应原Runtime/RichText/Glyph/布局/Frame/session实际证据；内容有效可复用，明确缺失与不适用，不按角色重跑。'),
('T012/T013','正常依赖与公共路径','TOML0.2.3 + 官方stdx1.2.0-beta.02.1正常构建；单向package/Alignment根reexport，非作者target/cjo、无开发绝对路径。'),
('T012/AC087','正常bundle/lint','最终8d正常cjpm bundle实际exit与完整lint warning；许可保留，不能skip或把zero-test摘要算Theme覆盖。'),
('T010/T012','实际CJP完整成员','解包真实最终CJP逐成员byte等8d，themes4文件交付；member记录不能替代实际包读取，构建后source仍同。'),
('T012/AC087','clean公开消费者','干净SDK/stdx前置，解包源正常build及同公开consumer只改manifest路径、directbinary原exit；不借作者target/cache。'),
('AC088','strict metadata/原件封存','strictJSON、command/cwd/UTC/exit、原件copy/hash完整、正常host已退出、PNG不可重画；失败/省略大件hash理由明确。'),
('AC088','早期证据时间限制','C1 post-run inventories不当成历史pre-proof；95 pre201与bundle成员记录可保留其原范围，8d最终包/GUI执行待087独立证明。'),
('AC013/025/085–088','公开说明及机械投影','解释visualStates不改业务/rootseed/encoded预算/stdx前置；逐AC必须项全证后才准最终状态，不凭审查PASS替执行。'),
('T006–008/026/027','排除后续范围','异步latestwins/worker/事务与全控件showcase待026/027，fullLinux/M2/fullrelease未由基础主题关闭。')]
matrix={'task':'TASK088','utc':now,'phase':'read_only_preparation','candidate':P,'acceptance_verdict':'NOT_ASSESSED','task088_ready':False,'rows':[{'id':f'T88-{i:02}','contract':c,'obligation':o,'required_evidence':e,'status':'excluded_followup_scope' if i==len(rows) else 'pending_evidence','judgment':None,'received_evidence':[]} for i,(c,o,e) in enumerate(rows,1)]}
write('pending-matrix.json',matrix)
md=['# TASK088 只读准备矩阵','','NOT_ASSESSED；087最终原件尚未正式交接。前41项待证，末项保留后续范围。','','| ID / 合同 | 义务 | 待独立核验原件 | 状态 |','|---|---|---|---|']
for r in matrix['rows']:md.append(f"| {r['id']} / {r['contract']} | {r['obligation']} | {r['required_evidence']} | {r['status']} |")
(B/'pending-matrix.md').write_text('\n'.join(md)+'\n')
write('findings.json',{'task':'TASK088','phase':'read_only_preparation','verdict':'NOT_ASSESSED','task088_ready':False,'assessment_complete':False,'findings':[],'contract_blockers':[],'notes':['086 source review chain received, not substituted for087 execution.','C1 historical post-run identity limits retained;95 pre201 source proof not relabeled8d execution.','No product execution, author directory/report/progress/self-assessment read, author communication, subagent or main/product/test/status mutation.','Actual serving model/effort independently unverified.']})
print(json.dumps({'candidate':P,'git_files_hashed':len(inventory),'formal_theme_files':sum(x['path'].startswith('tests/themes/') for x in inventory),'typed_keys':len(keys),'fixed_presets':len(presets),'matrix_rows':len(rows),'verdict':'NOT_ASSESSED'},ensure_ascii=False))
