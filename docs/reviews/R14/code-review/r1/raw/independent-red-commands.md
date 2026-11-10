# Commands and cwd

All builds source `/workspace/work/validation/sdk/cangjie/envsetup.sh` and export
`CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip`.
No product compiler/linker rescue flags are supplied. Registry/cache configuration
is private and ignored; seed cache was copied to task-local cache, never edited.

```sh
git clone --shared --no-checkout /workspace/work/terminal.ui /workspace/work/rich-text-regression-tests/source
git -C /workspace/work/rich-text-regression-tests/source checkout --detach 034685dacd76f1450317b0352411ddc4be112136
cp -a /workspace/work/validation/replay-dependencies/cache /workspace/work/rich-text-regression-tests/cache
# cwd source, native build's verified official archive seed:
mkdir -p .cjtui-build
cp /workspace/work/validation/replay-dependencies/archives/unicode-0.1.0.cjp .cjtui-build/unicode-0.1.0.cjp
git ls-files src native tests/rich-text | xargs sha256sum > ../raw/source-initial.sha256
cjc -v > ../raw/sdk-version.log 2>&1
cjpm --version >> ../raw/sdk-version.log 2>&1
sha256sum tests/rich-text/src/csi_utf8_first_fault.cj tests/rich-text/src/main.cj tests/rich-text/README.md > ../raw/regression-initial.sha256
cjpm build > ../raw/initial-product-build.log 2>&1
# actual status saved immediately to initial-product-build.exit
# cwd source/tests/rich-text:
cjpm build > ../../../raw/initial-consumer-build.log 2>&1
# actual status saved immediately to initial-consumer-build.exit
# cwd source, SDK env still sourced:
TERM=dumb COLORTERM= timeout 60s tests/rich-text/target/release/bin/main </dev/null > ../raw/initial-consumer-direct.log 2>&1
# actual status saved immediately to initial-consumer-direct.exit
git add tests/rich-text/src/csi_utf8_first_fault.cj tests/rich-text/src/main.cj tests/rich-text/README.md
git diff --cached --check
git ls-files src native tests/rich-text | xargs sha256sum > ../raw/source-final.sha256
sha256sum tests/rich-text/src/csi_utf8_first_fault.cj tests/rich-text/src/main.cj tests/rich-text/README.md > ../raw/regression-final.sha256
cmp ../raw/regression-initial.sha256 ../raw/regression-final.sha256
sha256sum -c ../raw/retained-source-initial.sha256 > ../raw/retained-source-final-check.log
git commit -m 'test: regress immediate CSI UTF-8 framing first fault'
git diff --quiet 034685dacd76f1450317b0352411ddc4be112136 HEAD -- src native
git diff --check 034685dacd76f1450317b0352411ddc4be112136 HEAD
```

Language queries before writing tests:

```sh
python /workspace/work/CangjieSkills/scripts/search_docs.py --query 'try catch Exception message' --query 'Array slice' --max-results 1
python /workspace/work/CangjieSkills/scripts/search_docs.py --query 'Exception message' --view leaves --max-results 1
```
