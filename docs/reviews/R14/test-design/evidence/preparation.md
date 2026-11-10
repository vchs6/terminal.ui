# TASK081 independent preparation

- Classification: execution; exact API/behavior at `7a33ddc7fb93da3f30007e49538cb00821a2d81b`.
- Independent clone/branch: `/workspace/work/rich-text-tests/source`, `task081-tests`.
- Requested model: Sol/high, actual serving not exposed and not independently attestable.
- Skills actually read: cloud TDD and verification-before-completion; local `/workspace/work/CangjieSkills/SKILL` (277f2e1234ca5217496966887243c679653887a8), local cangjie-rules scope/reference only. Batch `search_docs.py` output retained in search-docs.txt.
- No new requirement, implementation, product-author analysis or self-evaluation used. Formal tests contain only public imports and hand-authored goldens.
- Private cache copied from `/workspace/work/validation/replay-dependencies/cache` into own parent directory; cache sources/artifacts not edited. Ignored configs point to registry18973.
- Initial ordinary product build: exit0; first core consumer RED exit1: real missing public APIs. Initial test-only commit e6b3229.
- Declaration-only scratch exists outside repository and has never been executed. Its normal static build checks consumer syntax only, with every placeholder callable throwing; no pass claim about product behavior follows from it.
- SDK: `/workspace/work/validation/sdk/cangjie/envsetup.sh`; normal CJPM builds only, no rescue FFI flags. Direct binary is used by committed run.sh after compilation becomes available.
- Full old test suite is not rerun: no old tests or product code were changed. Runtime integration depends on the separately frozen A+B product and rich-text implementation, not scratch execution.
