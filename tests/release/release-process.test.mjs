import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {chmodSync, copyFileSync, mkdtempSync, mkdirSync, readFileSync, rmSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {dirname, join} from 'node:path';
import {fileURLToPath} from 'node:url';
import test from 'node:test';

const sourceRoot = fileURLToPath(new URL('../..', import.meta.url));
const projects = [
  'examples/minimal', 'examples/composition', 'examples/theme_showcase',
  'benchmarks/rendering', 'benchmarks/rendering/compat', 'benchmarks/rendering/workloads',
];

function put(root, name, contents, executable = false) {
  const dest = join(root, name);
  mkdirSync(dirname(dest), {recursive: true});
  writeFileSync(dest, contents);
  if (executable) chmodSync(dest, 0o755);
}

function release(fail = '') {
  const root = mkdtempSync(join(tmpdir(), 'cjtui-release-process-'));
  try {
    const script = join(root, 'scripts/check-product.sh');
    mkdirSync(dirname(script), {recursive: true});
    copyFileSync(join(sourceRoot, 'scripts/check-product.sh'), script);
    put(root, 'src/main.cj', '// Release process fixture\n');
    put(root, 'cjpm.toml', '[package]\nname="cjtui"\nversion="0.0.0"\n');
    for (const project of projects) {
      put(root, `${project}/cjpm.toml`, `[package]\nname="${project.split('/').at(-1)}"\n`);
      put(root, `${project}/src/main.cj`, '// Project fixture\n');
    }
    const log = join(root, 'calls.log');
    const bin = join(root, 'fake-bin');
    put(bin, 'cjc', '#!/bin/sh\nprintf "cjc:%s\\n" "$*" >> "$CJTUI_TEST_LOG"\n', true);
    put(bin, 'cjpm', '#!/bin/sh\nprintf "cjpm:%s:%s\\n" "$PWD" "$*" >> "$CJTUI_TEST_LOG"\n', true);
    put(bin, 'node', '#!/bin/sh\nprintf "node:%s\\n" "$*" >> "$CJTUI_TEST_LOG"\ncase "$1" in --input-type=module) printf "cjtui-0.0.0.cjp\\n";; esac\n', true);
    put(bin, 'timeout', '#!/bin/sh\nprintf "timeout:%s:%s\\n" "$PWD" "$*" >> "$CJTUI_TEST_LOG"\ncase "$PWD" in *"/$CJTUI_TEST_FAIL") exit 7;; esac\n', true);
    put(bin, 'tar', `#!/bin/sh
printf 'tar:%s\n' "$*" >> "$CJTUI_TEST_LOG"
while [ "$#" -gt 0 ]; do
  if [ "$1" = '-C' ]; then destination="$2"; break; fi
  shift
done
test -n "$destination" || exit 9
product="$destination/cjtui-0.0.0"
mkdir -p "$product"
printf '[package]\nname="cjtui"\n' > "$product/cjpm.toml"
cp -R "$CJTUI_TEST_ROOT/examples" "$product/"
cp -R "$CJTUI_TEST_ROOT/benchmarks" "$product/"
mkdir -p "$product/benchmarks/rendering/target/release/bin"
cat > "$product/benchmarks/rendering/target/release/bin/main" <<'DIRECT'
#!/bin/sh
printf 'direct:%s:%s\n' "$PWD" "$*" >> "$CJTUI_TEST_LOG"
if [ "$CJTUI_TEST_FAIL_DIRECT" = 1 ]; then exit 7; fi
DIRECT
chmod +x "$product/benchmarks/rendering/target/release/bin/main"
`, true);
    const result = spawnSync('bash', [script, 'release'], {
      cwd: root, encoding: 'utf8', timeout: 15000,
      env: {
        ...process.env,
        PATH: `${bin}:${process.env.PATH}`,
        CJTUI_TEST_LOG: log,
        CJTUI_TEST_ROOT: root,
        CJTUI_TEST_FAIL: fail,
        CJTUI_TEST_FAIL_DIRECT: fail === 'direct' ? '1' : '0',
      },
    });
    return {result, calls: readFileSync(log, 'utf8')};
  } finally {
    rmSync(root, {recursive: true, force: true});
  }
}

test('release fails when an ordinary example smoke exits nonzero', () => {
  const {result, calls} = release('examples/minimal');
  assert.equal(result.error, undefined);
  assert.notEqual(result.status, 0, 'nonzero minimal smoke was masked');
  assert.match(calls, /timeout:[^\n]*examples\/minimal:/);
  assert.doesNotMatch(result.stdout, /Release candidate verified locally/);
});

test('release exercises showcase and all benchmark projects from the extracted ordinary source package', () => {
  const {result, calls} = release();
  assert.equal(result.error, undefined);
  assert.equal(result.status, 0, result.stderr);
  assert.match(calls, /timeout:[^\n]*examples\/theme_showcase:/);
  for (const project of ['benchmarks/rendering', 'benchmarks/rendering/compat', 'benchmarks/rendering/workloads']) {
    assert.match(calls, new RegExp(`cjpm:[^\\n]*cjtui-0\\.0\\.0/${project}:build`));
  }
  assert.match(calls, /direct:[^\n]*benchmarks\/rendering:/);
});

test('release runs the showcase smoke and propagates its nonzero exit', () => {
  const {result, calls} = release('examples/theme_showcase');
  assert.equal(result.error, undefined);
  assert.match(calls, /timeout:[^\n]*examples\/theme_showcase:/);
  assert.notEqual(result.status, 0, 'nonzero showcase smoke was masked');
  assert.doesNotMatch(result.stdout, /Release candidate verified locally/);
});

test('release runs a direct benchmark binary and propagates its nonzero exit', () => {
  const {result, calls} = release('direct');
  assert.equal(result.error, undefined);
  assert.match(calls, /direct:[^\n]*benchmarks\/rendering:/);
  assert.notEqual(result.status, 0, 'nonzero benchmark binary was masked');
  assert.doesNotMatch(result.stdout, /Release candidate verified locally/);
});
