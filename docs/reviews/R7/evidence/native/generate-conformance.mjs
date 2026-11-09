#!/usr/bin/env node
// Builds probe input from official boundaries; does not implement segmentation.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
const [ucd, target] = process.argv.slice(2);
if (!ucd || !target) throw new Error('Usage: generate-conformance.mjs UCD_DIRECTORY PROBE_DIRECTORY');
const file = path.join(ucd, 'auxiliary/GraphemeBreakTest.txt');
const raw = fs.readFileSync(file);
const cases = [];
for (const [index, line] of raw.toString('utf8').split(/\r?\n/).entries()) {
  const text = line.split('#')[0].trim();
  if (!text) continue;
  const cps = [], boundaries = [];
  for (const token of text.split(/\s+/)) {
    if (token === '÷') boundaries.push(cps.length);
    else if (token !== '×') cps.push(Number.parseInt(token, 16));
  }
  cases.push({ line: index + 1, cps, boundaries });
}
fs.mkdirSync(path.join(target, 'src'), { recursive: true });
fs.writeFileSync(path.join(target, "cjpm.toml"), "[package]\ncjc-version = \"1.2.0\"\nname = \"grapheme_conformance\"\nversion = \"0.0.1\"\nsrc-dir = \"src\"\noutput-type = \"executable\"\n[dependencies]\nunicode = { path = \"../unicode-0.1.0\" }\n");
let code = "package grapheme_conformance\nimport unicode.GraphemeIterator\nimport std.collection.ArrayList\nvar failed: Int64 = 0\nvar total: Int64 = 0\nfunc check(line: Int64, cps: Array<UInt32>, expected: Array<Int64>): Unit {\n total++\n let it = GraphemeIterator(cps)\n let actual = ArrayList<Int64>()\n actual.add(0)\n var pos: Int64 = 0\n var contentOk = true\n while (true) {\n  match(it.next()) {\n   case None => break\n   case Some(g) =>\n    for (cp in g) {\n     if (pos >= cps.size || cp != cps[pos]) { contentOk = false }\n     pos++\n    }\n    actual.add(pos)\n  }\n }\n if (!contentOk || pos != cps.size || actual.toArray() != expected) {\n  failed++\n  println(\"FAIL line=${line} cps=${cps} expected=${expected} actual=${actual.toArray()} contentOk=${contentOk}\")\n }\n}\n";
for (let i = 0; i < cases.length; i += 50) {
  code += `func group${i / 50}(): Unit {\n`;
  for (const { line, cps, boundaries } of cases.slice(i, i + 50)) {
    code += ` check(${line}, [${cps.map(cp => '0x' + cp.toString(16) + '_u32').join(', ')}], [${boundaries.join(', ')}])\n`;
  }
  code += '}\n';
}
code += 'main(): Int64 {\n';
for (let i = 0; i < cases.length; i += 50) code += ` group${i / 50}()\n`;
code += " println(\"GraphemeBreakTest17 raw total=${total} failed=${failed}\")\n let rawEmpty = GraphemeIterator(\"\")\n match (rawEmpty.next()) {\n  case None => println(\"EMPTY raw=zero clusters\")\n  case Some(g) => println(\"EMPTY raw=one cluster isEmpty=${g.isEmpty()}; adapter must return zero without invoking iterator\")\n }\n if (failed > 0) { return 1 }\n return 0\n}\n";
fs.writeFileSync(path.join(target, 'src/main.cj'), code);
fs.writeFileSync(path.join(target, 'input.json'), JSON.stringify({ source: 'UCD17/auxiliary/GraphemeBreakTest.txt', sha256: crypto.createHash('sha256').update(raw).digest('hex'), cases: cases.length }, null, 2) + '\n');
console.log(`generated ${cases.length} cases`);
