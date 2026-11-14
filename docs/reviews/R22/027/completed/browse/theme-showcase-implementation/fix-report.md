# TASK027-R1 fix facts

Product base: e0711b288f932fa84eb3aed169aec5d01b8f4588
Initial product: 954d7492b91c2f490dcb15d2d42190af5dbe52ae
Fix commit: 46dc8e2badcb352f0619f6566231285009378a28 (`examples/theme_showcase/src/commands.cj`).
Final test alias HEAD: b5de3dd6610e90fcdcd951c5703a1429ec13b417.
Old ELF 92dd71989fe12658477dc9aceef8a62c633318f74d99bcc336aed62ce0398bb5 is preserved in `evidence/candidate-main-92dd.gz`; `evidence/candidate-main-92dd-map.json` records its verified restoration.
Build: `cd examples/theme_showcase && cjpm build`, exit 0, `evidence/build-r1.log`.
Built ELF: `examples/theme_showcase/target/release/bin/main`, SHA256 dc10aee0d5ebea4aa3a49a1fcefd97d742dcad0ae305e629a8bb177e6a5f108a, 19139712 bytes.
`node tests/theme_showcase/selftest.mjs`, exit 0, `evidence/r1-selftest.log`.
`node tests/theme_showcase/preset-contract.mjs`, exit 0, `evidence/r1-preset.log`.
`node tests/theme_showcase/smoke.mjs`, exit 0, `evidence/r1-smoke.log`.
`node tests/theme_showcase/modal-keys.mjs`, exit 0, two cases, `evidence/r1-retry2-modal.log`.
`node tests/theme_showcase/pty.mjs`, exit 0, seven cases, `evidence/r1-retry2-pty.log`.
Terminal raw frames and original hashes are mapped in `evidence/r1-retry2-gzip-map.json`.
Earlier corrected-binary terminal attempts failed close predicates; `evidence/r1-modal.log` and `evidence/r1-pty.log` and associated maps retain those results.
Normal bundle v1 failed ENOSPC; `evidence/bundle-v1.log`. Bundle retry pending.
