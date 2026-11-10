# Commands actually used; no stub or product behavior run.
source /workspace/work/validation/sdk/cangjie/envsetup.sh
# workdir /workspace/work/viewport-tests/source
cjc -v
cjpm --version
cjpm build
bash tests/interaction_b/run.sh
python tests/interaction_b/pty_driver.py --self-test
python tests/interaction_b/pty_driver.py --binary /workspace/work/viewport-tests/missing-product-binary --output /workspace/work/viewport-tests/raw/not-launched
bash -n tests/interaction_b/run.sh
