# SDK 1.2.0 分配与 CPU 诊断微验证

日期2026-11-10。只在独立目录创建正常外部 CJPM 小程序与开发侧观察器，未修改产品/正式测试、SDK、系统设置、共享seed或registry。SDK现成envsetup；私有cache及relay18973配置，无第三方依赖实际无需下载。实际 serving model/effort不可核验。复现入口：`bash /workspace/work/m2-contract-draft/probe-tools/run.sh`；原始输出在probe-evidence。只证明工具可执行及量测口径，不证明M2性能或产品验收通过。

## 结论与采用口径

1. SDK/CJPM/cjprof实际版本均1.2.0，正常CJPM小程序成功构建/运行。`std.runtime`可读当前堆占用、累计GC回收、GC次数/耗时，**没有证明精确累计全进程CJ对象allocated bytes/count**。
2. 推荐并已由主代理采用生产通用诊断`RuntimeStats.frameAllocatedCells`：实际新分配Cell存储槽容量的累计值。与arranges/cellWrites一起真实解释M2优化效果。它不是字节、对象总数、RSS或完整heap统计，CSV必须用`frame_allocated_cell_slots`。语义见OpenSpec候选design最终裁决。
3. 精确进程CPU可用自有C启动器的Linux `wait4` user/system time，wall来自CLOCK_MONOTONIC，maxrss单列KiB。无需root或perf权限，无生产库改动。strace可观测真实write调用返回字节，但有扰动，应在独立输出采集运行中使用。
4. cjprof CPU采样实际失败：Open perf event failed (1)，record返回0仍未产出可用采样，report返回255并报No sampling data。不能把工具存在/record exit0当采样通过。不改perf_event_paranoid=2或提权。
5. 外部LD_PRELOAD NewArray8慢路径观察器能正常运行，却已被反例证实不覆盖全部CJ分配，不能用它验收总分配。保留作为覆盖边界实证，正式benchmark不需要依赖它。

## 正常小程序与可复现结果

probe/src/main.cj仅使用std.runtime、ArrayList、Array；两轮各创建4096个UInt8数组、访问元素累积checksum，再释放集合引用并请求gc(heavy:true)。支持--empty（零业务数组）、--small（每数组32bytes）、默认4096bytes；checksum均在工作完成后打印。计量窗口内不打印；sample返回tuple本身也有微小分配，所以不把堆差值当业务净分配。编译优化为CJPM默认release，保留真实manifest/build日志。

三种负载各3次普通进程、3次慢路径观察进程，所有程序exit0，checksum在small/large均1010320，empty为0。首次探索因Tuple不实现ToString编译失败，改为解构输出后正常构建；未修改任何产品。输出标签after_gc_request准确表示已请求GC，不能假设gc调用返回时回收已完成。

| 微负载 | 业务已执行数组创建数 | 三次观察到NewArray8外部慢调用 | 累计请求payload bytes（此符号范围） |
| --- | ---: | ---: | ---: |
| empty | 0 | 17/17/17 | 1820/1820/1820 |
| small | 8192 | 17/17/17 | 1820/1820/1820 |
| large | 8192 | 15/15/15 | 1806/1806/1806 |

这些计数不是分配总数：empty与small相同已直接否定覆盖。编译器可选不同array入口，内联快路径也绕过导出符号。probe-evidence/program-disassembly.txt中有实际bump allocation：检查buffer末尾，直接写type/length并推进指针，只有不足才调用CJ_MCC_NewArray8@plt；还存在本地CJ_MCC_NewObjectFast。不能加几个导出hook就宣称捕获全部分配。

array8_counter.S不调用仓颉/C函数，保存flags后仅原子累计rsi的已核验数组payload长度与尝试次数，再tail-jump真实入口；C构造器用dlsym解析，析构输出。仅适用于本次Linux x86_64固定SDK二进制，入口ABI由该二进制及调用点核对；不推广到其他SDK/平台。计的是请求/尝试，未声称分配成功计数、不含header/alignment、不捕获内联/其他入口/内部直接调用。没有把native malloc冒充CJ对象分配。

普通三次进程user+system CPU：empty约0.0050–0.0060s，small约0.0144–0.0226s，large约0.4599–0.5026s；插桩large约0.4605–0.5048s。wall受共享主机干扰显著，18次工具验证不能精确估计hook开销或证明“没有开销”。这些值只验证计量链可用；正式基准需更长稳定窗口、交替顺序/足够重复及独立未插桩CPU样本。

## 为什么heap+freed不是精确allocated bytes

知识库公开getAllocatedHeapSize定义为当前已被使用的堆大小，getUsedHeapSize为实际物理内存；两者不是累计对象分配。SDK二进制中CJ_MCC_GetGCFreedSize读取g_gcCollectedTotalBytes，证实该版本的GC累计回收来源。RegionManager::GetAllocatedSize的实现会把region计数乘UNIT_SIZE并加线程buffer信息，不能认为全是对象请求容量。

真实运行中当前used会跨GC下降，freed会上升；样本记录accounted=used+freed仅用于检查候选推导，**该字段不是allocated bytes**。它含region口径及非原子两次取样问题；正式基准改用明确原值`cj_heap_used_bytes`、`cj_gc_freed_bytes_total`、`gc_count`、`gc_time_us`，不输出名为allocated的推导值。占用/回收/GC与RSS互补，但均不能替代frameAllocatedCells的明确分配位置累计。

## 实际工具边界与后续可执行证据方案

- `/usr/bin/time`、perf、heaptrack、valgrind在当前PATH不存在；未安装系统工具。strace和gcc现有可用。
- probe-tools/measure_process.c可直接包裹任一正常基准二进制，无库专属接口，给出user/system CPU、wall、peak RSS与真实exit。
- `strace -qq -f -e trace=write,writev -o trace.log -- benchmark...`已在小程序运行成功；统计必须按真实目标fd及write/writev返回值区分成功bytes/失败/重试，输出初帧、更新、退出各区间；不拿仅-c的syscall次数替代bytes。正式TTY仍需真实宿主与同业务输入。
- SDK公开堆/GC读取可直接在基准正常Cj源码的批次边界使用；列明counter采样开销/进程级范围，冻结后台写入后做正确性配对，性能另进程。
- frameAllocatedCells在正式实施中由Frame实际Cell数组分配点累计，独立测试作者手算小尺寸初建/完整copy共享/COW首写/同帧重复写/自合成暂存/外部snapshot修改等，不使用产品代码计算自己的期望；与真实CPU、heap/GC/RSS及输出共同判断局部收益和全局退化。
- 不要求为原AC031逆向全部内联分配或取得perf特权。若将来确需全进程累计对象bytes/count，必须另行选有完整覆盖证据的编译器/运行时分配事件工具，不能将此未证能力写成当前验收已满足。

## 工件核验

run.sh再次正常构建/执行18个微负载，并记录cjprof真实失败、strace与反汇编。SDK/runtime、编译产物和源码hash在probe-evidence/environment.log；全部可复现输入与结果hash在probe-evidence/SHA256SUMS。无旧产品套件重跑，无GUI/JS/终端模拟器参与微验证。`probe`、`probe-tools`仅开发证据，禁止加入产品包。
