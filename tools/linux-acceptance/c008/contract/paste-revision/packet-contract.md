# PASTE002 complete received-wire contract — pending independent scoped review

This is an explicit external actual-host binding revision authorized in brief.md. Source-only preparation; no host execution or helper implementation. Same logical multiline scenario on XTerm, VTE, tmux, screen, SSH and direct VT: UTF-8 `qrcvzy` + ONE LF + `review 中文 👩‍💻`. Exact source hex is `717263767a790a72657669657720e4b8ade6968720f09f91a9e2808df09f92bb`. `transform.mjs` makes exactly one anchored replacement of the original composition multiline `paste(...)` literal. It changes neither the original CRLF input files/synthetic coverage nor any other input expression/assertion/expected grid, product decoder or renderer. Original input events and raw failures remain archived as failures.

## API and fixed policy table

`packet-policy.mjs` exports `preparePolicy(declaration, readEvidence)` and `verifyReceivedPacket(receipt, sourceHex, raw, observation)` plus fixed source/opener/closer constants. The helper author adopts these exports; it must not implement a looser substitute. This module does not import or alter Screen/WireScreen or any application/helper/product module.

| Policy ID | Proven actual owning input engine/configuration | Exact expected received payload |
|---|---|---|
| XTERM398_DEFAULT_NL_TO_CR | XTerm398; GUI selection path; bracketed2004 set, quote2005 reset, literal-newline2006 reset | `717263767a790d72657669657720e4b8ade6968720f09f91a9e2808df09f92bb` |
| VTE0801_FIXED_NL_TO_CR | VTE0.80.1; GUI widget selection path;2004 set;2005/2006 fixed-reset per official source and proven actual owning engine/config | same exact single-CR payload |
| DIRECT_VT_RAW_LF | Actual kernel text VT; controlled keyboard raw source path proved to preserve LF; quote/literal-NL modes not applicable, bracket delimiters enabled | exact common source LF payload unchanged |

For every policy the full new packet is **`1b5b3230307e` + listed payload + `1b5b3230317e`**, including unchanged Unicode/non-newline bytes. No CRLF/CRCR/LF/CR alternates, missing delimiters, quoted bytes or C1 delimiters are accepted as equivalent. Unsupported/unknown engine/version/config/mode/route policy fails `INSUFFICIENT_EVIDENCE PASTE002` before comparison; it must not be guessed from the bytes returned or the displayed frame. Policy is owned by the actual outer selection engine for mux/SSH, not by inner TERM/host labels. Forwarding along the entire route to the app must be independently evidenced. This is a three-row fixed contract, not a new capability detector. A new proven host/mode requires test-role review, not executor inference.

## Declaration, preparation and evidence

Before the paste action, create/freeze this minimal declaration and call `preparePolicy` with a reader returning original evidence bytes by path:

```
{
 "schema":"C008-PASTE002-v1", "policyId":"XTERM398_DEFAULT_NL_TO_CR",
 "owner":{"engine":"XTerm","version":"398"},
 "route":{"kind":"gui-selection","chain":["owned XTerm window+PID/config","any mux/SSH hops and source IDs","actual app tty+PID"]},
 "modes":{"bracketedPaste":"set","pasteQuote":"reset","literalNewline":"reset","basis":"genuine-observation"},
 "declaredBeforeOffset":0, "declaredUTC":"2026-11-15T00:00:00.000Z",
 "evidence":[
  {"kind":"owner-config","path":"...","sha256":"<64 lowercase hex>"},
  {"kind":"newline-policy","path":"...","sha256":"<64 lowercase hex>"},
  {"kind":"mode-state","path":"...","sha256":"<64 lowercase hex>"},
  {"kind":"raw-route","path":"...","sha256":"<64 lowercase hex>"}
 ]
}
```

`readEvidence(path)` returns Buffer/Uint8Array of the immutable original; every reference hash is checked. Evidence must establish actual engine/version/owned window and tty route, exact configuration, documented policy and relevant mode state **before** the test paste. `mode-state` records genuine query/reply bytes/time or verified default configuration/control history; no injected replies, private app hook or observation inferred from the payload under test. XTerm permits basis `genuine-observation` or `verified-default-config`;2005 and2006 must both be reset and2004 set. XTerm2006 set is intentionally outside this default policy. VTE0.80.1 requires fixed-reset2005/2006 and permits `fixed-official-source` only when actual engine/version/config matches and the pinned official source plus mode/control facts establish the path; no claimed actual2006 reply is synthesized from source. Direct VT uses owner.engine=`LinuxVT`, actual kernel version, route.kind=`controlled-keyboard-raw`,2005/2006=`not-applicable` and independent raw-route proof of LF preservation; no GUI paste-source claim. VTE evidence may instead include genuine observations. All rawmode queries/replies and host control changes must be preserved where used.

`declaredBeforeOffset` is the current monotonic app-input.raw byte count when the independent policy is established, before sending the action; `declaredUTC` precedes the paste. Receipt expected bytes are selected internally from the fixed table, never from a helper-supplied expected payload. The receipt clones the declaration and carries no mutable expected-value field. Files/hashes and chronological claims still require independent acceptance review of the underlying originals; the guard does not authenticate an operator's transcription by itself.

## Exact received-packet observation

Deliver the exact common LF selection source, without helper substitution. Capture original app-received input bytes unchanged. Call `verifyReceivedPacket(receipt, SOURCE_HEX, rawBuffer, observation)` with:

```
{"beforeOffset":101,"afterOffset":144,"packetStart":102,"packetEnd":144,
 "sentUTC":"2026-11-15T00:00:01.000Z",
 "capturedUTC":"2026-11-15T00:00:02.000Z", "rawSha256":"<hash of entire unaltered rawBuffer>"}
```

The numbers above illustrate schema only. All offsets are zero-based, exclusive-end byte offsets into the **app endpoint's** input.raw, not GUI clipboard UTF-8 or terminal output. `beforeOffset` is recorded before the clipboard/controlled-keyboard paste action; `afterOffset` is its captured completion boundary. Packet start/end enclose the entire opener/payload/closer. Declaration offset <= beforeOffset <= packetStart < packetEnd <= afterOffset <= raw.length, and declaration/send/capture UTC order, are required. The new window must contain exactly one opener and one closer; its selected whole packet must equal the independently predeclared exact expected bytes. Missing delimiters cannot be supplied by bytes outside the window. Any prefix/suffix key/reply bytes must have their own logged provenance; they cannot conceal another or nested paste packet. Raw identity hash is checked and input is never normalized or mutated. A mere payload/packet substring search without all these checks is inadmissible.

The return record contains policy/source/expected complete packet/received complete packet hex, exact offsets and raw hash, status=`EXACT_RECEIVED_PACKET_MATCH`, finalAcceptance=false. Missing provenance/unknown policy/source/offset/chronology/raw identity gives `INSUFFICIENT_EVIDENCE PASTE002`; differing actual wire gives `FAILED_PASTE_WIRE PASTE002` and retains original bytes as transport/input-route evidence, not an automatic product-decoder failure. All independent application full grids, data-as-input/selection/theme/undo/layers/worker/scroll and lifecycle assertions must still execute under their original expectations. The wire match alone never passes a host tuple.

## Fixed facts, replay and vectors

Pinned diagnosis references: followup report SHA256`a08f85a65cb398637d8dd92ae949b519bccd64bb84ab220fc3b5fa7ab7b11336`; sources.sha256 SHA256`3954e5fa5a4f4f1e3ac58293cfff518f3b4ba3fc27021a2363c773c1248864b2`. Copies are in diagnosis/. Source facts: VTE widget_paste calls pastify_string with genuine bracket mode and C1=false; pastify maps lone LF to CR and collapsesCRLF to one CR;2005/2006 are fixed reset. XTerm ctlseqs documents default NL->CR and2006 literal-NL mode. These do not themselves establish actual current XTerm mode/route or VTE instance identity.

`vectors.json` contains15 pure positive/negative packet fixtures plus exact policy/observation records generated by `validate-paste002.mjs`; all evidence placeholders are explicitly fixture-only and cannot admit a real host. Checks cover exact XTerm/VTE translated packets, direct VT LF, missing delimiters, mixed Unicode bytes, wrong newline policies, inherited CRLF source, original XTermCRCR mismatch, VTE old-source non-upgrade, extra/new packets, stale offsets and late declaration. Additional unknown-policy/owner/mode/unprepared-receipt negatives fail closed. The source check proves the generated case differs from the preserved prior case by only the authorized literal and retains the F001 guard.

Retained old raw records may be replayed only when original source/selection identity, independently established policy/modes/route, packet offsets and scope meet this contract, with original failures unchanged. An old inherited CRLF source cannot be relabeled LF to obtain a pass even when VTE returned the same CR payload. Replay proves only the specific wire guard over that exact old record; it does not upgrade the whole old tuple or substitute a new application run. This revision grants no actual GO; independent scoped review precedes helper implementation/adoption and separately admitted host execution.
