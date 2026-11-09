# TASK049 F049-01 re-review

Reviewed fixed revision `a3032bdd9559c56cf9265f5af5f33c55fe275e41` against `67e62024c34792f8d7a41456e7df0002a81b840d` in the original independent clone. The complete diff changes only `scripts/check-bundle.mjs` (three lines); no author self-assessment was used.

- Contract conclusion: **approve** for this TASK049 correction.
- Code-quality conclusion: **approve**.
- F049-01 status: **resolved**. No remaining blocking finding in this reviewed scope.

The actual validator gate now accepts `build.cj`, native `.sh/.c/.h/.S/.cj` inputs and attribution files under `third_party/licenses`. It explicitly rejects native archives/objects/shared libraries, Cangjie binary objects, input archives and cache/target directories. The existing full-release `required` array, its presence check and required source-directory check are byte-for-byte unchanged. The manifest-selection change correctly selects only root `cjpm.toml` or an actual `/cjpm.toml` basename, so the supplied `package-cjpm.toml` attribution copy is not treated as a build manifest.

Verification: `node --check scripts/check-bundle.mjs` and `git diff --check` passed. A short independent diagnostic evaluated the actual gate expression from the reviewed file: eight intended build/attribution paths were accepted, nine generated/cache paths were rejected, and the required-boundary lines matched the previous revision. No complete bundle, native build or network operation was run for this re-review. This closes the prior code-review finding, without asserting full product release readiness or replacing separately assigned build/run acceptance.
