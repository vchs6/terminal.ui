Test-only fixedSHA 3e860b738a0c8d5e2a26920f8820cf952f9564a5; BASE5e1f276634974e26abcefd9c342ed9b2da532758.
Cause: old S007 oracle omitted K004 restoration of already-requested2004 after synchronized zero-byte title-set failure; no product defect shown.
Manual K004/S007/S008: initial2004h, complete title save, failed set0, safe pop, exactlyone bare2004l beforeclose; partialUnsafe forbids all later output.
Observed actualseq4 packet is1b5b3f323030346c (8byte disable), notmode25 query1b5b3f32352470 (7bytes); startup wire shows2004h beforelater x/arm.
PristineacceptedK f38c72784f440ff96a118233ad0237e1a1b57504 reproduces4fail/29pass; currentE original278 reports4fail/274pass, samefour offset0cases.
Original baselineSUMS52f061e6466c2cb9b44864e11f3374012238774def39638f302642b867151963/current948a047cf1cbd072fa6267fa3a9f562ff660ff7cbaa3586f5b7fb7105a3d3d5e and relevant files unchanged.
Only Session oracle/runner/selfcheck/README changed: require observed init, exactsave+pop+disable, sequence/results/bytecounts/order beforeclose; extension wire remains save+pop.
verifyLive wholefunction includingpartialUnsafe and first-error/sentinel checks are byte-identical toBASE; no arbitrary count-only allowance.
Synthetic oracle selfchecks actual0:3positive/57negative, no native/product run; stored8 originalzero-failure observations replay throughneworacle actual0 (oracle-only).
Diff/node syntax/sourcehash checks pass; no new compile, productruntime,33/278coldrerun, main/spec/product/otherEtest edit.
Sourceauthor owns one targetedfixedfault-set33 execution; change.patch and immutable raw/manifest.json freeze exactscope/commands/proofs; sourceclean.
