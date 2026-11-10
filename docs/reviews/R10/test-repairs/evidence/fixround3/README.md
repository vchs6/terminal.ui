# Final two-line terminal-infrastructure repair

Fixed test-only commits:

- 4c952025f34dd0fa90191ff32e9c3181baa9a9bc: Bash shebang and corresponding README instruction.
- 6f5f4be5722dafbf215769870501fad431efdf94: DISPLAY-bound, host-supported version option and README instruction.

The local starting run.sh was byte-identical to the executed bf308bfccb43d0e88305c6d0ec64b4a92adbc892. body-equivalence.json proves the final script differs at only lines 1 and 105. Restoring those two lines reproduces the original entire script SHA256 48c04d04548a51d17f2607cf51478be10148fd5cbcec36a89244868035415953. All input, application launch, rendering, raw/PNG capture, assertions, restoration and exit-oracle lines are identical. README is the only other changed file. two-line-script.patch and complete-test-only.patch preserve the exact diffs.

## Direct Bash entry

The independent executor's original stage-b-real-fixture.log contains Unsupported shell: unknown; its .meta records the original direct-entry actual_exit=1 on bf308bf. Its later explicit-bash fixture and example logs/.meta report actual_exit=0, with 9 fixture and 3 ordinary-example rows. These original files are copied unchanged under executor-originals/; original-preservation.json records their source paths and SHA256. Original files and original acceptance PNGs were not edited.

The shebang is now #!/usr/bin/env bash. A controlled early check invoked the real executable script directly, with the real SDK 1.2.0 envsetup.sh, verified host bundle and a deliberately nonexistent fixture BIN path. The actual script returned 1 at fixture binary missing, with no Unsupported shell diagnostic. That demonstrates successful SDK setup without building or launching an application, Xorg or matrix. sdk-early-check/ contains raw stdout/stderr/result.json with exact argv, environment inputs, UTC times and actual exit. The expected early failure is not reported as application success.

Reproduction command used:

```sh
python3 evidence/fixround3/check-sdk-entry.py
```

## Actual XFCE version metadata

The executor's original XFCE host-version.txt contains only Gtk cannot open display. That file and its metadata.json were preserved unchanged. Its separate installed binary/package version evidence is also retained; it is not relabeled as an original successful DISPLAY query.

A first direct prefix-only probe on a fresh actual Xorg found that xfce4-terminal -version did not complete within 10 seconds. check-xfce-version-initial.py, the Xorg logs and probe-failure.json preserve that unsuccessful observation; the query's process exit was not captured as a normal exit and no positive version claim is made for it. The temporary Xorg was terminated in finally. Therefore the final single metadata line selects each known host's correct option: xterm -version, XFCE --version, and passes DISPLAY=$display.

The corrected real installed /usr/bin/xfce4-terminal --version query on another fresh temporary Xorg :219 exited 0 and printed xfce4-terminal 1.1.4 (Xfce 4.20). Its exact argv/DISPLAY/times/actual exit and original stdout/stderr are in xfce-version-positive/. Xorg/xdpyinfo output and the validation script are retained. The binary SHA256 752c95cbd8ac8f6d85ab96b102ba2c1212b626dfd3d3c70a89e901b0a5d03143 matches the executor's separately captured binary identity. No cjtui application, scene, matrix or screenshot capture was run for this check.

Reproduction command used:

```sh
python3 evidence/fixround3/check-xfce-version.py
bash -n tests/terminals/run.sh
git diff --check
```

## Evidence reuse boundary

The accepted real GUI rows remain the independent executor's bf308bf runs under explicit Bash. No new successful 9+3 matrix is asserted here and no original raw/PNG/metadata file was rewritten. Only the interpreter selection and future version-text collection changed; body-equivalence.json supports reuse of the unchanged rendering/byte/PNG/oracle body. The coordinator and independent reviewer decide that reuse, rather than changing the recorded source hashes to the new commit.
