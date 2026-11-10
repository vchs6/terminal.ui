source /workspace/work/validation/sdk/cangjie/envsetup.sh
export CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
cd /workspace/work/frame-tests/repo
./tests/run-slice.sh composition > delivery-red.stdout 2> delivery-red.stderr
# Actual status stored in delivery-red.exit; no cjpm run wrapper and no stubs.
