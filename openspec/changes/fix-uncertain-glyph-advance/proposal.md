# 不确定Unicode物理推进的自动降级

## Why

固定91c22f8的TASK083真实XTerm/VTE截图发现仅第3行更新却擦掉第4行AN。独立native完整DSR、原始ANSI重放/单变量对照已确认：逻辑👩‍💻=2列，实际两host=4；VS16又存在逻辑2/实际1，不能改全局宽度。原逻辑grid模型通过不能代表物理无损。

## What Changes

沿用户已授权自动降级，提前交付已规划G005/G007/G010同一私有GlyphRenderPolicy及唯一投影函数的最小子接口。默认设备选择conservativeUnicode：仅当该簇逐scalar唯一unicodewidth之和等于canonical Cell.width才原样输出，否则整簇替为恰width个ASCII?，样式保持。保留逻辑Unicode/分簇/布局及离线输出。比较实际投影后的列单元，full/diff同路径。无新公共API/依赖/探测协议/模式修改。

## Impact

TASK163–167为有限独立测试/实现/审核/执行/验收，修复R14T083001并恢复083→084，不等待未来完整094造环。后续094扩展同一owner加入Ascii/mapped/实际VT探测和公开GlyphMode，不另造kernel。新事实修订未知PTY自动直出政策，不取消Unicode/emoji支持，不改示例绕过。当前为候选，独立preflight后实施；不publish，不关闭完整Linux或041。
