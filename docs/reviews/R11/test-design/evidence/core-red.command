source /workspace/work/validation/sdk/cangjie/envsetup.sh
export CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
cd /workspace/work/frame-tests/repo
./tests/run-slice.sh composition > core-red.stdout 2> core-red.stderr
# Record actual wrapper status in core-red.exit; runner requires ordinary cjpm build then direct binary.
