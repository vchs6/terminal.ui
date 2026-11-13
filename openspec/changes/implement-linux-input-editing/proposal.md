# Linux keyboard input and text editing

## Implementation status v1 — 2026-11-13

K001–K004已获独立117有限验收并集成main；[原件与限制](../../../docs/reviews/K/README.md)。下文Why保留立项时的问题背景，非当前K缺失声明。E001–E005未实现，118实际独立测试进行中；119–122和完整Linux/父AC仍pending，本变更尚不整体归档。

## Why

Linux当前设备解码仍只有文本、enter、backspace、escape、方向和interrupt。括号paste未实现时换行/0x03会变提交或退出，标准编辑快捷键缺失。需要先交付完整有界键盘/paste，再用统一公共Canvas/focus/viewport构造单多行编辑，保持用户组件与内置控件同权。

## What Changes

* 单一KeyboardDecoder扩展现KeyEvent、标准Linux序列和三修饰位；100ms裸ESC、跨块UTF-8/控制串、完整paste、1MiB超限drain、EOF与外部signal区分。
* paste在开始时锁定有效目标及输入域，合法结束前不交业务，目标失效/新模态阻挡时整次丢弃。
* 第二单元提供TextInput/TextArea、簇级选区/删除/移动、undo/redo、统一viewport与caret、标准快捷键；单行坏paste原子拒绝，多行LF硬换行，不软换行。
* copy/cut消费**另案148–152独立验收的TASK030会话扩展copyLocalText子接口**。SentUnconfirmed保留原文；仅Applied且revision/选区/代际匹配删除。Unknown真实TTY显式Direct请求按030可best-effort发送且仍SentUnconfirmed，headless/Disabled等如实报告，编辑核心可独立使用。

## Capabilities

### New Capabilities

无新增平行能力命名；复用现有ui-runtime。

### Modified Capabilities

* `ui-runtime`：细化归一化键盘、paste、单多行Unicode编辑与默认快捷操作；delta只增加精确要求，原场景保留。

无删除或弱化原requirements/AC；017/020/028/030/041对应分段投影见tasks.md。完整REQ009.1仍须focus/modal集成，完整030仍须标题/图片图标与宿主能力证据。

## Impact

变更现输入decoder/KeyEvent/native读取和Application输入桥接；编辑仅通过公共Canvas/defaultAction/focus/viewport/主题resolver，不增加编辑kind、Frame/Unicode/ANSI内核、GUI、鼠标、系统命令或主动剪贴板读取。源码一类型一文件。113–117与118–122各自独立测试/产品/审查/执行/验收，主代理冻结与preflight之前状态全为planned。Linux授权已具备；本草稿不扩大到发布或其他OS。
