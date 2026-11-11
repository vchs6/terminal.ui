# TASK098 readonly acquisition correction

Test-only `f07635e75f2b68d7bd78f41e777e9d2d481d0bef` (parent76b8dd1), one file +3/-2; clean. Formal A.4 line149 requires Component.reference to use the UI read guard; only an already acquired NodeRef.isValid/sameNode are thread safe. The old worker first acquired Component.reference through ref(root), so its uncaught WrongUIContext was a test acquisition error. Original dev3 build0/direct1 raw remains copied/hash-preserved; no product expectation was weakened.

Owner now acquires saved NodeRef before spawn. Worker independently asserts WrongUIContext for Component.reference, saved.isFocused and app.focusedNode, then asserts saved.isValid and saved.sameNode(saved). Other assertions remain unchanged.

Independent replay product6125934a98dff2bda9a26576ca0c0bce8cc983da: ordinary cjpm build exit0; direct timeout60s readonlyQueries only exit0, stdout PASS, stderr empty. Replay uses exact corrected test/checks/group/box bytes and a single-call main. Product source/native/manifest unchanged; no current I015 edits, full suite or87native run.

Pure raw manifest: `raw/manifest.json`, SHA256 `55097cc0d33918a41e82905320964adb66e08640134b094c22129b95a7bf4d6f`. Exact argv/cwd/UTC/exits and prehash are included. This correction supplements the preserved final-report; broader100 validation remains later.
