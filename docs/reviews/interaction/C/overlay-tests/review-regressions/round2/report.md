TASK108 Round2：两项修复delta边界回归，执行型追加测试。
fixedSHA=7469f27e5715829ba44d07463378f07a1eb89323；父9265a070a266527a94ec2ddf342221818b9ae1b5。
受检产品f8f0493a7f5aa3b74bd59bdc7e6d82af6696426d；只提交source五个测试文件，旧测试/断言/golden保持。
一次正常cjpm build实际exit=0；cjc/cjpm均1.2.0；两selector独立运行，均实际断言RED/exit=1。
R1-I01：普通删除无层正控选NEXT；modal owner删除关闭OwnerGone，但仍选NEXT，C.4要求先选最近存活祖先root的FIRST。
R1-I02：默认host为[B P  ]；显式root host为[P    ]，C.2/C.6要求两者均按实际5×1终端居中为[B P  ]。
每次执行前/后即时捕获同一真实binary SHA256：3ec5da29473faaf1dc84f1e6c4ad9e38be629d9b6001f416f271e3bd7689e9d2。
pre/post核对209个repo输入、755个依赖/SDK文件；166个产品tracked输入对应固定产品；40个source/replay测试文件一致。
命令/argv/cwd/UTC/实际exit、binary pre/post、完整raw/test/config/依赖/SDK hash见raw/manifest.json。
正式round1/findings.json及冻结C.4/C.2/C.6为依据；独立print-only probe仅复现材料，不计asserting RED。
缺项：修复后GREEN；两selector均已到最后行为断言，无后续未达断言。
未读作者报告/target、未联系作者、未改产品/契约/主仓；未运行旧十项或全套，未重建registry服务。
复用既有OpenSpec TASK108及verification流程；本批不代表Unit C/native/package验收完成。
