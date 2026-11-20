# Linux 本地开发

当前验证基线为 Linux x86_64、GNU 工具链、仓颉 SDK/CJPM 1.2.0。以下步骤在 Bash 中执行。建议使用 [README](../../README.md) 中的部分克隆，交互 C 准入需保留提交祖先。

## 系统工具

- 基础开发工具为 Git、Bash、curl、tar、unzip、sha256sum、realpath、flock、GCC 和 GNU ar。构建需要访问官方 SDK、stdx、仓颉中心仓和 Unicode 下载源。
- SDK 的 Ubuntu 22.04 系统库清单由 [CI](../../.github/workflows/ci.yml)记录，包含 `libssl-dev`、`libffi-dev`、`libncurses5`、`libtinfo5`、`libxml2`。其他发行版按 SDK 要求准备对应库。
- 安装脚本和开发规范检查需要 Node.js ≥20.19.0 与 npm。交互 C 的 Python 辅助检查需要 Python 3。真实终端验证的额外工具见各专项契约。

## 安装 SDK 和 stdx

| 下载 | 平台及版本 | SHA-256 |
|---|---|---|
| [仓颉 SDK](https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-x64-1.2.0.tar.gz&objectKey=6ab1e26eece1f87ff5befa73) | Linux x86_64，1.2.0，附带 CJPM | `8c5fd944cd9cc51ee63d4a240e3ecc4f540345dae1468e8b47c927ecf2ba998f` |
| [仓颉 stdx](https://gitcode.com/Cangjie/cangjie_stdx/releases/download/v1.2.0-beta.02.1/cangjie-stdx-linux-x64-1.2.0-beta.02.1.zip) | Linux x86_64，1.2.0-beta.02.1 | `0d35811d84a770315c6fa2d1090a10568b3f7c763a1d1d54a1433b324f76afc0` |

从仓库根目录执行一次安装。任一步骤失败时，安装立即停止。SDK 安装脚本按 [tools.lock.json](tools.lock.json) 下载并校验。已有同版本 SDK 时，`cjtui_sdk_dir` 指向包含 `cangjie/envsetup.sh` 的父目录。

```bash
bash -eu -o pipefail <<'CJTUI_INSTALL'
cjtui_tool_dir="$HOME/.local/share/cjtui"
cjtui_sdk_dir="$cjtui_tool_dir/sdk-1.2.0"
cjtui_stdx_dir="$cjtui_tool_dir/stdx-1.2.0-beta.02.1"
bash scripts/install-sdk.sh "$cjtui_sdk_dir"

mkdir -p "$cjtui_stdx_dir"
curl --fail --location --retry 2 \
  'https://gitcode.com/Cangjie/cangjie_stdx/releases/download/v1.2.0-beta.02.1/cangjie-stdx-linux-x64-1.2.0-beta.02.1.zip' \
  -o "$cjtui_stdx_dir/stdx.zip"
printf '%s  %s\n' '0d35811d84a770315c6fa2d1090a10568b3f7c763a1d1d54a1433b324f76afc0' "$cjtui_stdx_dir/stdx.zip" | sha256sum --check
unzip -oq "$cjtui_stdx_dir/stdx.zip" -d "$cjtui_stdx_dir"
test -d "$cjtui_stdx_dir/linux_x86_64_cjnative/static/stdx"
ln -sfnT linux_x86_64_cjnative "$cjtui_stdx_dir/linux_x86_64_llvm"
CJTUI_INSTALL
```

在每个构建 shell 中加载环境。stdx 兼容链接提供 TOML 包查找的 `linux_x86_64_llvm/static/stdx` 路径。详见 [产品构建说明](../product/native-build.md)。

```bash
cjtui_tool_dir="$HOME/.local/share/cjtui"
cjtui_sdk_dir="$cjtui_tool_dir/sdk-1.2.0"
source "$cjtui_sdk_dir/cangjie/envsetup.sh"
export CANGJIE_STDX_PATH="$cjtui_tool_dir/stdx-1.2.0-beta.02.1"
cjc --version
cjpm --version
```

## 中心仓与 Unicode 输入

CJPM 从官方仓颉中心仓解析根 [cjpm.toml](../../cjpm.toml) 的固定依赖。下表可用于核对下载，正常构建由 CJPM 与 native hook 完成获取。

| 输入 | 关系 | SHA-256 |
|---|---|---|
| [ansies 1.3.113](https://pkg.cangjie-lang.cn/registry/pkg/ansies/1.3.113) | 直接 | `396ead6ab841eddd12b196fb657848587c4514a435c536146810ee5675344940` |
| [unicode 0.1.0](https://pkg.cangjie-lang.cn/registry/pkg/unicode/0.1.0) | 直接，native hook 也读取其生成器输入 | `d810505f62b43417ce673fb9c811f740503d3df88665307557544eae6d073c4c` |
| [unicodewidth 0.1.113](https://pkg.cangjie-lang.cn/registry/pkg/unicodewidth/0.1.113) | 直接 | `6fa20716cc224c4d774ca83e5a20ebaa1f86b52ac495cff392655dc2b34eea94` |
| [cangjie_toml 0.2.3](https://pkg.cangjie-lang.cn/registry/pkg/cangjie_toml/0.2.3) | 直接，需 stdx 二进制接口 | `297998b23b08f2a43bb6821765c8991b3a078ceb31649068e777db8cb8a5f398` |
| [bitarray 0.1.0](https://pkg.cangjie-lang.cn/registry/pkg/bitarray/0.1.0) | ansies 的传递依赖 | `3c5d7f12e9a1ce68295fb547f0892016911e1cef54218343102a2101ece4d01c` |
| [Unicode 17.0.0 UCD](https://www.unicode.org/Public/17.0.0/ucd/UCD.zip) | native hook 生成数据时下载 | `2066d1909b2ea93916ce092da1c0ee4808ea3ef8407c94b4f14f5b7eb263d28e` |

机器可读版本与来源见 [central-packages.json](central-packages.json)，授权和构建证据见 [依赖说明](dependencies.md)。已有同摘要的 UCD ZIP 可在构建前通过 `CJTUI_UCD_ARCHIVE` 指定。

## 构建和测试

在已加载 SDK 和 stdx 的 shell 中运行。

```bash
cjpm build
cjpm test
bash tests/run-slice.sh contract
(cd examples/minimal && cjpm build && ./target/release/bin/main --smoke)
```

首次构建会运行根 `build.cj` 调用的 native hook，生成 `native/*.a`、`.cjtui-build/`、`cjpm.lock` 与构建缓存。保留默认脚本执行。下载或校验失败时，查看 CJPM 输出和 `build-script-cache/` 下的 `script-log`。中心仓解析失败时，检查当前 SDK 或项目 `cangjie-repo.toml` 选定的仓库及本机网络。真实 Linux ANSI TTY 可进入 `examples/minimal` 执行 `cjpm run`，按 `q` 退出。

运行控件或主题专项时，保持同一 SDK/stdx 环境。入口为 `bash tests/widgets_small/run.sh`、`bash tests/widgets_composite/run.sh formal`、`bash tests/theme_showcase/run.sh`。控件 oracle 可独立运行 `bash tests/widgets_small/run.sh --oracle` 和 `bash tests/widgets_composite/run.sh self-test`。

继续修改规范或做仓库检查时，在根目录安装锁定的开发工具。

```bash
npm ci --ignore-scripts
npm run dev:setup
npm run check
```

`package-lock.json` 固定 OpenSpec 1.14.3 和 smol-toml 1.4.2，`tools.lock.json` 固定 Superpowers 7.0.0 的完整提交 `bb92a77741419a4ab5f06e711a283343f1ada0c3`。安装生成 `node_modules/`、`.dev-tools/` 和本地技能链接。后续操作见 [开发环境与 CI](environment.md)、[当前 Linux 工作](continue-linux.md)。
