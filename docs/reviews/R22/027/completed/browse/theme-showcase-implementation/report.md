# TASK027 product command facts

Product base: e0711b288f932fa84eb3aed169aec5d01b8f4588.
Product commits: 954d7492b91c2f490dcb15d2d42190af5dbe52ae and 46dc8e2badcb352f0619f6566231285009378a28.
Test-inclusive source HEAD: b5de3dd6610e90fcdcd951c5703a1429ec13b417.
Example build: `cd examples/theme_showcase && cjpm build`, exit 0; `evidence/build-r1.log`.
ELF: `source/examples/theme_showcase/target/release/bin/main`, 19139712 bytes; SHA256 dc10aee0d5ebea4aa3a49a1fcefd97d742dcad0ae305e629a8bb177e6a5f108a.
`node tests/theme_showcase/selftest.mjs`, exit 0; `evidence/r1-selftest.log`.
`node tests/theme_showcase/preset-contract.mjs`, exit 0; `evidence/r1-preset.log`.
`node tests/theme_showcase/smoke.mjs`, exit 0; `evidence/r1-smoke.log`.
`node tests/theme_showcase/modal-keys.mjs`, exit 0 (2 cases); `evidence/r1-retry2-modal.log`.
`node tests/theme_showcase/pty.mjs`, exit 0 (7 cases); `evidence/r1-retry2-pty.log`.
Normal root `cjpm bundle`, exit 0; `evidence/bundle-v2.log`; first attempt failed ENOSPC, `evidence/bundle-v1.log`.
CJP: `source/target/cjtui-0.0.0.cjp`, 179148 bytes; SHA256 29cab0f8de79a3b42ebc6a8bf7e2c2648217b565ccbc0e03f77f4cb915852c7a.
Bundle ran test and lint without skip flags: test total 0; lint emitted 789 warnings and 0 errors; no severity override found in root/example manifests or repository configs. See `evidence/bundle-facts.json`.
Package member list: `evidence/bundle-members.txt`; fourteen requested example/theme/document files match source bytes.
Raw frame gzip mappings preserve original paths, sizes, and hashes; `evidence/*gzip-map.json`.
SDK: `/workspace/work/validation/sdk/cangjie/envsetup.sh`; CANGJIE_STDX_PATH `/workspace/work/linux-build-recon/stdx-env`; CJTUI_UCD_ARCHIVE `/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip`.
Independent execution, GUI captures and acceptance are separate pending roles.
