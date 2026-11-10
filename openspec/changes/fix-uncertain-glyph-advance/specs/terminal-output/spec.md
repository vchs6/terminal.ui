## ADDED Requirements

### Requirement: Conservative device glyph advance

框架 SHALL 保留canonical Unicode字素/逻辑Frame/离线文件，在实际设备默认profile中使用同一私有字形投影；当唯一宽度库逐scalar之和与Cell.width不等时，以恰同列数ASCII问号整簇呈现，不改变业务数据或要求应用分支。full/diff SHALL 比较样式映射后的实际投影列并只在完整输出成功后提交基线。未知能力不构成所有Font已支持证明。

#### Scenario: ZWJ and VS16 disagreement
- **WHEN** 逻辑2列的序列在传统scalar推进宿主可能占4或1列
- **THEN** 默认设备投影为两列问号，原逻辑Unicode仍保留，局部更新不覆盖下一行；宽度模型一致的普通Unicode/单emoji继续原样

#### Scenario: Equal projected output
- **WHEN** 原宽簇与两个单列ASCII问号在相应profile下都呈现相同列与样式
- **THEN** 差分无屏幕bytes，不能仅因raw head/continuation结构不同误发更新
