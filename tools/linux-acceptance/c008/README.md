# C008 Linux 六宿主接续输入

此目录保留 C008 实施和复核所需的固定输入。目标、六宿主场景和验收门槛以 [Linux 收尾设计](../../../openspec/changes/complete-linux-integration/design.md)和[任务](../../../openspec/changes/complete-linux-integration/tasks.md)为准。全阶段执行顺序见 [Linux 交接](../../../docs/development/continue-linux.md)。

- [operator](operator/) 为 helper `6a399c88ea231d307e365eeca12f1c35328dd128` 的固定源码，含 PASTE002、VT supervisor 派生和公平调度修订。
- [contract](contract/) 为绑定、冻结 oracle、PASTE002 packet 契约和选定的产品/测试输入，绑定产品源码 `d7e9d1445f98021a798d223de97b97b45239de93`。
- [checks](checks/)、[probes](probes/) 以及 [旧公平性负控](fixtures/pre-fair/vt-supervisor-transport.h)提供宿主工具和后续复核所需的原输入。
- [source-manifest.json](source-manifest.json) 的路径相对于本目录。来源字段记录原项目与版本身份。原字节中的旧机器路径属于冻结证据，后续执行需要重新绑定。

## 在新检出核对原件

在 Linux 上使用 Python ≥3.10、Node.js、Bash、POSIX sh、GCC 和 Linux 用户空间头文件。从仓库根目录运行。

```bash
python3 tools/linux-acceptance/c008/check-source.py
```

检查固定文件的 SHA-256、大小和可执行位，并检查 Python、JavaScript、Shell 及可直接解析的 C 源语法。C harness 的旧负控与 fatal 选项由原组装流程产生头文件，源检查验证这些输入的固定字节。源检查无需 SDK、VM、TTY、网络或历史卷。

## 恢复实机执行

1. 按原 [绑定契约](contract/binding-contract.md)和 [C008 场景](contract/contract.md)准备新宿主、固定依赖、输入投影及输出目录。按照 [operator 记录](operator/README.md)识别旧宿主绑定，先移植或重新生成路径与外部输入，再交独立复核。
2. 从当前产品源码和锁定依赖重建，重新生成与所用源码、二进制及宿主配置一致的绑定和校验记录。源清单和旧产物可作比较输入。
3. 真实 Linux VT 仍需在受控宿主按现行契约执行。此前 VT 镜像早于当前 supervisor 公平调度修订。旧实机结果的适用范围由各自固定版本和实际场景确定。
