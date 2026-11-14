TASK027-R1 scoped fixed-source re-review
Range: 954d7492b91c2f490dcb15d2d42190af5dbe52ae → b5de3dd6610e90fcdcd951c5703a1429ec13b417; product fix 46dc8e2badcb352f0619f6566231285009378a28.
Scope: original TASK027-R1 plus new breakage in this fix diff; original review remains unchanged.
Declined to judge: unchanged source uses the original review; independent execution/GUI/AC027 and final M1/M2/Linux/release are separate gates.
R1: ADDRESSED. Source SPEC: PASS_SCOPED. Source QUALITY: PASS_SCOPED. No new findings.
commands.cj:61 now forwards F1–F10 through the existing action method and consumes each handled event once; non-F keys retain menu/editor semantics.
Popup consumption stops double dispatch through Preview; F5 retains the existing open-modal guard; owner ancestry and F9/F10 lifecycle remain unchanged.
F8 uses the existing public active-session scroll API without moving focus or violating its domain checks; loader and accepted-file routing reuse unchanged actions.
Independent old-ELF regression evidence shows two F2-in-modal failures after pre-modal F2/F1 positive controls; fixed-ELF evidence shows both Preview and owned-popup cases passing.
New checks require accepted Dark palette/name, visible retained layers, disabled Delete navigation skip, and complete close frames; they do not substitute requested labels for acceptance.
The close-oracle correction is valid: Preview persists in the horizontal menu; full literal frame equality replaces the impossible !Preview predicate and rejects open/partially-cleared layers.
Final test bytes match independent dd483163bfe31ed4251ff533a005a5e2582289f6; previously reviewed preset corrections are unchanged.
Verified all 230 bindings in fix-index-v2 SHA256 9e284bb68f1bf6300dedf619d43fb38d071b75879e7dadb13a568ee216b8a475.
Supplied raw exits: normal example build 0; self/preset/direct smoke+invalid CLI 0; modal-key two cases 0; full PTY seven cases 0.
Fixed ELF SHA256 dc10aee0d5ebea4aa3a49a1fcefd97d742dcad0ae305e629a8bb177e6a5f108a; old 92dd ELF remains separately mapped, not inferred from the current executable path.
Runtime bound: regression directly exercises F2 in two domains; the remaining F-key forwarding is a source judgment, not an exhaustive shortcut runtime claim.
Bundle-v1 ENOSPC remains historical failure; retry/CJP, actual four-GUI and independent AC027 success are not claimed.
No builds, test reruns, source edits, subagents or author contact; pure factual fix report/raw only. Inputs and output SHA256/bytes are sealed in round1/index.json.
