# TASK097 固定有限验收制品

先读 `report.md` 与 `acceptance-matrix.md`；唯一最终结论是 PASS_FINITE_SCOPE。`pending-matrix*`、`preparation*` 为最初只读阶段的历史记录，保持 NOT_ASSESSED，不能替代最终结论。

`artifacts.sha256` 索引每个归档文件（自身除外）；`hash-manifest.json` 记录验收自有源文件及外部原件。复核可在本目录运行 `sha256sum -c artifacts.sha256`。此操作不运行产品。

三个核心核验脚本依赖原来已固定的 `/workspace/work/glyph-execution` 原件，以及 `/workspace/work/terminal.ui` Git 对象；这些不复制进本归档。`verify_oracles.mjs` 的少量正式源输入位于原 `/workspace/work/glyph-acceptance/source/tests/`：Glyph `pty.mjs` 从root b3b24f896672336797cec009cfe0cd830a955aa7 取，Session `oracle.mjs`、`cases.mjs`、`fixtures/wire.json` 同root取。精确hash记录在本包；运行脚本需以原验收目录为cwd。归档不含可执行产品、SDK或cache。

097的核验仅解析已记录raw和固定纯oracle，未启动产品或真实host。原始39张PNG及21张PPM位于独立096归档 `docs/reviews/R16/execution/raw/`；本包视觉记录链接回原图并记hash，不重新画图。根目录的 `seal-verification.json` 是归档外的交接收据，避免自包含hash循环。

`finalize.py`、`seal.py` 留作完整生成过程记录；不要用它们更新已封存目录。重新检查应读取固定原件并输出到新目录。
