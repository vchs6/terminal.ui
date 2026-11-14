# TASK143 preparation plan

Binding input: approved incremental-rendering design §11/§14 M003/M005/M006/
M011/M012 and canonical M013/spec at `6bbf179e`. Preparation source is
`e151f204a69925edde33fe91d968942c8f9d7aa2`, accepted C plus frozen D tests;
D139 is not an accepted input. Requested independent Sol/high; actual serving
configuration cannot be verified. No product draft or author rationale consumed.

1. Inspect public render/snapshot/viewport/caret and old/new compilation boundary.
2. Freeze every approved workload, action/epoch, complete Cell and separate caret
   expectations, CSV units, and ordinary CLI/build acceptance in this directory.
3. Prepare only independent validators/runners. Product benchmark is absent;
   do not create a fake implementation or modify production/shared configuration.
4. M013 protocol/CLI/run-id, eligibility, windows and independent stateful
   expectations are reconciled source-only to canonical `6bbf179e`.
5. After D142 fixed input and explicit root GO: record source/artifact hashes,
   normally build test validator, compat+workloads against old/new products and
   diagnostic against new product; execute formal RED once, record exact failures.
6. Freeze formal index/baseline separately; independent execution owns later CPU,
   real-host output, allocation evidence and final acceptance.

The TDD skill and writing-good-tests reference are applied to independent literal
expectations. RED/builds are intentionally deferred by the preparation boundary.
Read-only SDK documentation lookup is not compilation evidence. No assertion here
claims production, methodology, packaging or performance acceptance.
