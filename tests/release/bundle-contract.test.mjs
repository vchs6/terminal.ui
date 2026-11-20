import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {mkdtempSync, mkdirSync, rmSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {dirname, join} from 'node:path';
import {fileURLToPath} from 'node:url';
import test from 'node:test';

const root = fileURLToPath(new URL('../..', import.meta.url));
const checker = join(root, 'scripts/check-bundle.mjs');
const packageRoot = 'cjtui-0.0.0';

// Small ordinary source archive, with no SDK, build output, or measured benchmark data.
const files = {
  'cjpm.toml': '[package]\nname = "cjtui"\nversion = "0.0.0"\n',
  'README.md': 'Fixture source package\n',
  'LICENSE': 'Fixture license\n',
  'NOTICE': 'Fixture notice\n',
  'docs/product/README.md': 'Fixture product guide\n',
  'src/main.cj': '// Fixture product source\n',
  'examples/minimal/cjpm.toml': '[package]\nname = "minimal"\n[dependencies]\ncjtui = { path = "../.." }\n',
  'examples/minimal/src/main.cj': '// Fixture minimal example\n',
  'examples/composition/cjpm.toml': '[package]\nname = "composition"\n[dependencies]\ncjtui = { path = "../.." }\n',
  'examples/composition/src/main.cj': '// Fixture composition example\n',
  'examples/theme_showcase/cjpm.toml': '[package]\nname = "theme_showcase"\n[dependencies]\ncjtui = { path = "../.." }\n',
  'examples/theme_showcase/src/main.cj': '// Fixture theme showcase\n',
  'themes/classic.toml': '[theme]\nname = "Classic"\n',
  'themes/dark.toml': '[theme]\nname = "Dark"\n',
  'themes/light.toml': '[theme]\nname = "Light"\n',
  'themes/high-contrast.toml': '[theme]\nname = "High contrast"\n',
  'benchmarks/rendering/cjpm.toml': '[package]\nname = "rendering"\n[dependencies]\ncjtui = { path = "../.." }\nworkloads = { path = "./workloads" }\n',
  'benchmarks/rendering/src/main.cj': '// Fixture final-library benchmark\n',
  'benchmarks/rendering/compat/cjpm.toml': '[package]\nname = "compat"\n[dependencies]\ncjtui = { path = "../../.." }\nworkloads = { path = "../workloads" }\n',
  'benchmarks/rendering/compat/src/main.cj': '// Fixture dual-version benchmark\n',
  'benchmarks/rendering/workloads/cjpm.toml': '[package]\nname = "workloads"\n[dependencies]\ncjtui = { path = "../../.." }\n',
  'benchmarks/rendering/workloads/src/workloads.cj': '// Fixture shared public workloads\n',
};

function runArchive(changes = {}) {
  const temp = mkdtempSync(join(tmpdir(), 'cjtui-bundle-contract-'));
  try {
    const staged = join(temp, packageRoot);
    for (const [name, contents] of Object.entries({...files, ...changes})) {
      if (contents === null) continue;
      const dest = join(staged, name);
      mkdirSync(dirname(dest), {recursive: true});
      writeFileSync(dest, contents);
    }
    const archive = join(temp, 'fixture.cjp');
    const packed = spawnSync('tar', ['-czf', archive, '-C', temp, packageRoot], {encoding: 'utf8'});
    assert.equal(packed.status, 0, packed.stderr);
    return spawnSync(process.execPath, [checker, archive], {
      cwd: root, encoding: 'utf8', timeout: 15000,
    });
  } finally {
    rmSync(temp, {recursive: true, force: true});
  }
}

function rejected(changes, missing) {
  const result = runArchive(changes);
  assert.equal(result.error, undefined);
  assert.notEqual(result.status, 0, 'checker accepted a defective source archive');
  assert.match(result.stderr + result.stdout, new RegExp(missing.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')));
}

test('accepts ordinary source delivery with four themes, showcase, and all three benchmark manifests', () => {
  const result = runArchive();
  assert.equal(result.error, undefined);
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /product archive content boundary passed/i);
});

for (const missing of [
  'themes/light.toml',
  'examples/theme_showcase/cjpm.toml',
  'benchmarks/rendering/cjpm.toml',
  'benchmarks/rendering/compat/cjpm.toml',
  'benchmarks/rendering/workloads/cjpm.toml',
]) {
  test(`rejects source archive missing ${missing}`, () => rejected({[missing]: null}, missing));
}

for (const missing of [
  'examples/theme_showcase/src/main.cj',
  'benchmarks/rendering/compat/src/main.cj',
  'benchmarks/rendering/workloads/src/workloads.cj',
]) {
  test(`rejects source archive missing ${missing}`, () => {
    const result = runArchive({[missing]: null});
    assert.equal(result.error, undefined);
    assert.notEqual(result.status, 0, `checker accepted missing source: ${missing}`);
    assert.match(result.stderr + result.stdout, /Missing product source|Incomplete product bundle/i);
  });
}

test('rejects an author-machine absolute dependency path inside an otherwise complete archive', () => {
  const result = runArchive({
    'examples/minimal/cjpm.toml': '[package]\nname = "minimal"\n[dependencies]\ncjtui = { path = "/home/author/private/cjtui" }\n',
  });
  assert.equal(result.error, undefined);
  assert.notEqual(result.status, 0, 'checker accepted a private absolute dependency');
  assert.doesNotMatch(result.stdout, /product archive content boundary passed/i);
});
