TASK113 三项最小边界回归，原c96全部断言/历史原件保持。
fixed test-onlySHA=f7ec9f0f02a9fd0b8e3ecce17164aab6b1b2eaac；source父39f4260c774a6ee9aced897308b030ef9e980a9c。
产品固定c643d5e773ebf160ff29a0b1fafe57962f3cfdec；独立正常build实际0，三个Cj body均已对真实K API完整编译。
paste-native实际断言RED/child1：合法ASCII native paste进入target一次，caught=true但same=false，最终message=session is inactive，原IllegalArgumentException sentinel丢失。
native观察issues=0/InvalidPasteEncoding=0/fallbackq=0；不得写成实际收到伪编码诊断。cleanup1/资源0、真实TTY精确恢复及2004清理控制通过，无超时/强制退出。
c1-byte-budget实际RED/1：raw8/max8 Unsupported@1正控通过；UTF8九字节/max8实际Unsupported@1，应SequenceTooLong@1；max9观察Unsupported@1，A/B未丢。
ctrl-text实际RED/1：合法ctrl-a空text与custom合法payload正控通过；非法ctrl-a非空text被NO_ERROR接受、handler+1，session仍健康。
三次实际执行前后同一binary SHA256=608f5f2200e3c8f3c206c50ac55038f13a05089a69538e04c08a66edf1c22b19。
pre/post核对180个输入、172个固定产品tracked输入、755个依赖/SDK文件；6个新公开测试文件source/replay相同，audit0。
首次native驱动名pty.py遮蔽stdlib，产品未启动；工具失败原raw保留且排除RED，仅改名native_pty.py，无Cj/bin变化，不重跑两项有效结果。
未达断言：C1 max9最后正控；native主失败后的零issue/禁止fallback断言（数值已观察）；ctrl无后续未达断言。
修复后GREEN尚未执行；没有跑旧pure/H01/7PTY/27formal或全套，没有改产品/规格/main、读作者report/target或联系作者。
命令/cwd/UTC/真实exit/termios/input/output、pre/post与完整raw/test/contract hash见raw/manifest.json。
本次仅交付三项固定回归与实际RED；后续timeout范围任务未启动。
