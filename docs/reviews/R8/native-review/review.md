# TASK049 independent code review

Fixed revision: `67e62024c34792f8d7a41456e7df0002a81b840d`.
Baseline: `03f67935e11a63c9ce7b0d318a79882ceda90d80`.
Reviewed from an independent `git clone --no-hardlinks` checkout. No product edits, commits, pushes, full native builds, author process notes, or author self-assessments were used.

## Contract conclusion: request changes

One required TASK049 packaging-boundary correction remains (F049-01). The two public signatures, empty-string segmentation, unicode-only segmentation, unicodewidth-only width policy, package-owned `[ffi.c]`, dependency build hook, pinned archive checksums, checked offline UCD input, and package-local generation align with the reviewed contract by static inspection. The CJPM 1.2 manual explicitly supports dependency pre-build hooks. Actual consumer hook CWD, FFI propagation, clean bundle build/link/run and archive contents require the separately assigned execution evidence; this review does not claim them executed.

## Code-quality conclusion: request changes

F049-01 is a directly affected validation caller left inconsistent with the changed product manifest. Otherwise no blocking code-quality defect was found in the reviewed scope: shell path expansions are quoted, failures propagate through `set -euo pipefail`, downloads are checked before extraction/use, generation uses a package-local lock/temp directory, C/ASM build CWD is explicit, and no probe absolute path or upstream shared-cache mutation was found. Third-party originals and historical license inconsistencies are not blockers under the latest user instruction.

## F049-01 — P2: bundle validator rejects newly required native build files

Location: `cjpm.toml` include change and `scripts/check-bundle.mjs:15–17` (existing affected caller).

`cjpm.toml` now includes `/build.cj`, `/native`, and `/third_party/licenses` to deliver the TASK049 build entrypoint and attribution. However, the validator's `allowed` regular expression does not permit any of those paths. At line 17 it throws `Development/unexpected file in bundle` on an otherwise intended product file, before reaching the complete-release required-file checks. The manifest and product archive validation therefore disagree about the valid source distribution.

Short diagnostic on the fixed checkout extracted and evaluated the validator's actual `allowed` expression, producing:

```text
build.cj: allowed=false
native/build.sh: allowed=false
third_party/licenses/UNICODE-DATA-LICENSE.txt: allowed=false
```

Repair standard: synchronize the archive validator with the manifest for the required `build.cj`, native build/source files, and `third_party/licenses` subtree; explicitly continue rejecting generated native archives/objects and build caches. Preserve the existing complete-release `required` list and source-directory requirements. Missing future composition/benchmark deliverables are outside this finding and must not be waived to make TASK049 appear to complete the full product.

## Checks and limits

- `bash -n native/build.sh`: passed.
- `git diff --check` limited to first-party modified implementation/manifest/documentation: passed.
- Minimal validator predicate diagnostic: reproduced F049-01.
- SDK command reported CJPM 1.2.0. A short `cjpm bundle` attempt failed before bundle creation because CJPM could not resolve `pkg.cangjie-lang.cn`; no native build or bundle success is claimed. This environment resolution failure is separate from F049-01.
- Review covers TASK049 only, not TASK050 or final acceptance.
