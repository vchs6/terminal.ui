# scoped-r1 限定复核

固定修正版本 `9b3776d475cd8888dc13d45ec6a978aba9cf33ef`。仅复核LC-PF-001–003；首轮report/findings/dq/hashes完整保留，无主仓修改、功能套件或代理委派。

结论：**仍有修正行自身的两处最小文档残留，尚不签发规划通过**。

- LC-PF-001：完整snapshot glyphMode默认Unicode、旧双参兼容、097实际输入、Unicode/Auto/Ascii与业务Unicode不转码均已正确加入。但C003新增“边框/ellipsis等标记”将离线生成语义扩展到边框；正式Glyph G005在projectTerminalGlyph中处理装饰码点（字面业务同码点同映射），G006负责布局前生成ellipsis，G009禁止文件应用设备glyph投影。最小改为仅明确生成ellipsis，边框继续按正式布局/设备契约；无需新增产品API。
- LC-PF-002：原组已无L3状态，五个原编号分别有checkbox、输入、文件、manifest、原AC、L4和planning_gaps；041.a明确M1不等147且不关完整AC。原粒度问题已解决。新卡001误列REQ008/011（REQ008是主题），原AC001为003/004/007/011；003新卡遗漏原REQ004。只需对齐两行需求映射，避免机械迁移丢原追踪。
- LC-PF-003：**verified**，WP005及010/020 M1前置明确，021仍不等待027/最终041。

没有因未来源/test/cjp/hash/命令未产生而要求产品先完成；planned是正确状态。上述仅是本次修正引入的接口边界/原项追踪复核，不扩大审查到其他文件或功能。修正后可仅核这些行。

规划通过后的最小迁移：在一个固定提交中将本change标成所列原任务唯一状态权威；docs/tasks对应活动checkbox/status改编号/父项/需求/依赖与指向tasks的引用，历史保留且不再复制进度；theme027仍唯一并回链C006，022/031/030及123–162保持原权威；acceptance事实不变，所有未来卡保持planned，逐卡满足实际依赖/固定输入/工具技能/DQ后才ready。无需先完成产品以进行规划迁移。
