# TASK108 preparation coverage and remaining barriers

All rows are **BLOCKED for actual overlay execution**. `source` means a prepared
Cangjie assertion; it does not mean compiled or run. `recipe` is a hand-authored
historical test vector. The final-preparation mappings below now give public
consumer functions. No row is counted as executed C behavior or task acceptance.

| IDs | AC / formal clause | Prepared action and independent expected observation | Form |
|---|---|---|---|
| S01–03 | C-04 / C.1 | Option fields/defaults; all placement constructors; both surface overloads; explicit overlayHost; no public handle constructor invented | source public_shapes |
| P01 | C-04 / C.1 | Accepted handle isOpen true, content None, reason None; close before boundary: mount0, cleanup0, contentNone, terminal Requested | source pending_and_identity |
| P02 | C-04 / C.1 | Closed close twice is idempotent in original UI domain; closed getters readable after dispose, immutable reason | source pending_and_identity |
| P03 | C-04 / C.1/shared errors | Same unmounted content reserved twice in one batch: second AlreadyMounted, no half-published second layer | recipe |
| P04 | C-04 / C.1/shared errors | Component constructor/build or onMount throws: preserve original exception, stop session, close pending handles, cleanup already registered effects once | recipe |
| P05 | C-04 / C.1 | Retained handle must not keep whole owner/session tree alive after release; use documented weak-reference/GC facility only after SDK validation, no private reference scan | recipe; no deterministic GC assertion claimed |
| N01–03 | C-05 / C.2/C.7 / AC014 | Same SettingsPanel type, distinct instances/shared model; ordinary children unchanged; real handle content identity; resize keeps generation/build; close only layer invalidates | source pending_and_identity |
| N04 | C-05 / C.2 / runtime C | Owner has If/ForEach/manual children; open layer does not insert marker/child, key reorder retains refs, ordinary physical traversal unchanged | recipe |
| N05 | C-02/C-05 / C.2/C.6 | Move owner within same ordinary parent: owner/layer identities and local viewport offset retained, anchor geometry updates; no close of unrelated sibling | recipe |
| N06 | C-05 / C.2/C.7 | Capture PaintContext and layer NodeRef; context expires after draw with ExpiredPaintContext; NodeRef remains valid until actual close, then StaleReference | recipe |
| D01–02 | C-01 / C.3/A.5/I004 | modal→popup→confirm exact Cc;Tc;Tb;Cb;Td;Ca; base app/legacy0; explicit base dispatch FocusOutsideDomain before callbacks | source layer_domains |
| D03–04 | C-01 / C.3/A.5 | Escape after Target closes closest and consumes before Ancestor; unprevented modal interrupt exits entire Application, not just layer | source layer_domains |
| D05–06 | C-01 / C.3 | closeOnEscape=false closest blocks parent; capture preventDefault interrupt retains active session | source layer_domains |
| D07 | C-01 / C.3 | Target preventDefault Escape leaves layers open; stopPropagation alone still runs Escape; passive top layer skipped | recipe |
| D08 | C-01 / C.2/C.3 | Nonmodal event bubbles along owner chain to base app then legacy; host adds/replaces no logical parent edge (C.2 correction: an existing ancestor host appears once in owner order) | recipe |
| D09 | C-01 / C.3/A.4 | Lower-domain owner attempts open under highest modal: FocusOutsideDomain; ordinary requestFocus outside domain likewise | recipe |
| D10 | C-01 / C.3/A.4 | Modal Tab visits own ordinary preorder and dependent nonmodal layers in commit order only; base/sibling lower layer absent; backtab exact reverse | recipe |
| F01–07 | C-01/C-02 / I014/A.4/C.4 | Initial base first; empty takeFocus root reservation; new base candidate ignored; late layer first selected; nonmodal Tab can leave; background close and noTake/Passive keep focus | source layer_domains |
| F08–09 | C-02 / C.4/A.4 | Saved trigger disabled: layer enabled; close chooses nearest live owner ancestor first eligible before old physical fallback | source close_lifecycle |
| F10 | C-02 / C.4 | Saved trigger hidden (owner a different ancestor): ref valid but ineligible; choose first eligible of nearest surviving owner ancestor | recipe |
| F11 | C-02 / C.4 | Saved trigger unmounted (owner different surviving ancestor): old ref invalid, never revived/read as live; same deterministic fallback | recipe |
| F12 | C-02 / C.4/A.4 | Saved candidate and owner-chain candidates absent: old physical successor, then nearest old predecessor, then new-domain first; all empty None/domain root activeTarget | recipe; choose topology that reaches each branch |
| F13 | C-02 / C.4 | Close top modal restores previous still-valid lower-modal focus; dependent cascade restores once, never transient child/parent refocus callbacks | recipe |
| L01–04 | C-02/C-04 / C.2/C.4/R012 | owner disabled keeps layer; owner hidden closes dependent layer-of-layer; all tokens/subscriptions/owner queues gone before cleanup; deepest first once; unrelated top sibling survives/current focus retained | source close_lifecycle |
| L05 | C-04 / C.4/R017 | Child+parent cleanup throw: primary exact child exception object, parent in extras, order C;P;, all attempted once, resources0, second dispose no cleanup | source close_lifecycle |
| L06 | C-02 / C.4 | Ordinary descendant owns its own layer; remove ancestor closes ordinary+overlay full dependency closure including grandlayer; unrelated siblings survive | recipe |
| L07 | C-02 / C.4/C.6 | Owner explicit hidden closes OwnerHidden; merely offscreen/clip/zero viewport does not; owner remove wins OwnerGone over anchor invalid | recipe |
| L08 | C-04 / shared errors/R017 | Original callback/draw exception plus two cleanup throws: original object/type primary, extras in actual cleanup order, no finally error masking; native recovery separately | recipe |
| E01–09 | C-04 / C.1/C.6/shared errors | Conflicting focus flags, modal anchor, missing directional anchor IllegalArgumentException; bad host capability/ancestry InvalidOverlayHost; bad anchor relation InvalidOverlayAnchor; double mount AlreadyMounted; stale owner StaleReference | source entry_errors |
| E10–12 | C-04 / C.1/shared errors | Terminal handle same-thread readable after dispose; getter/closed-close under new active session WrongUIContext; foreign-session host WrongUIContext | source entry_errors |
| E13 | C-04 / shared errors | Wrong thread: handle getters/close/open owner all WrongUIContext; join worker, no thread-ID guess; closed no-op no exemption | recipe |
| E14 | C-04 / C.1/shared errors | Invisible host InvalidOverlayHost; stale/foreign anchor StaleReference/WrongUIContext consistent with common guard; wrong visible current-session relation InvalidOverlayAnchor | recipe; overlapping error precedence not invented |
| E15 | C-04 / shared errors | getter/measure/draw open/close rejects ReentrantEvaluation or existing structure-evaluation ReentrantStructure as applicable; lifecycle direct layer command LifecycleReentry; post-next-turn succeeds | recipe |
| E16 | C-04 / shared errors | Root-only mountedNodes limit1, open layer would be node2: CapacityExceeded; structuralOpsPerBatch1 with two opens: CapacityExceeded; treeDepth1 root0→ordinary owner1→Text layer2 exceeds: CapacityExceeded; root0→Text layer1 is legal with mountedNodes2; no second unbounded queue | recipe |
| E17 | C-04 / shared errors | dependenciesPerBinding1 and draw reads two Observable sources: CapacityExceeded; measure/draw track separate sets; close cancels both. No assertion of M2 call counts | recipe |
| E18 | C-04 / C.1/C.3 | Passive content with focusable/interacting descendants rejected IllegalArgumentException before exposing interactive passive target; exact actual accepted phase/source must be recorded | recipe |
| G01–06 | C-03 / C.5 / output delta | Fixed hand grids: modal box fill/no backdrop; explicit transparent; normal background fill still opaque; holes vs spaces; base updates covered then latest on close; mounted render and independent snapshots | source surface_grids + golden |
| G07–10 | C-03 / A.6/C.5 | Base caret visible; passive hole leaves visible; exact same-pixel opaque glyph hides; focus unchanged; close reveals latest logical caret | source surface_grids + golden |
| G11 | C-03 / C.2/C.5/I012/ThemeT015 | Owner named-style O vs host named-style H in one Application theme; inherited modal space style O; switch theme repaints, no local Default; ordinary disabled state does not cross owner edge | recipe; actual Theme088 public source unresolved |
| G12 | C-03 / C.2/C.6 | Explicit ancestor host clip permits escaping owner ordinary clip but never host/terminal; shadow likewise clipped; host affects geometry only | recipe + golden |
| G13 | C-03 / C.6/B.1 | Exact directional anchors/flip/tie/clamp/host-constrained natural size; each related scroll/resize layout repositions with same node identity/offset | recipe + golden |
| G14 | C-03 / C.6 | Partial clip uses intersection; fully invisible anchored nonmodal AnchorGone; hidden/unmounted anchor closes; disabled anchor stays; modal cannot anchor/zero clip doesn't close it | recipe + golden |
| G15 | C-03 / Frame/C.5/C.6 | Rounded border+shadow, move/shrink/close invalidate old/new and shadow ranges; clipped wide glyph never leaves half cluster; expected decoration fixture frozen manually from authority | recipe + golden |
| G16 | C-03 / A.6 | Opaque styled space/shadow occludes caret even if colors match; continuation/clip/zero axis hidden normal form None,0,0,false; no clamping | recipe + golden |
| H01 | C-01/C-04 / R010/R012/I015 | Real PTY actual run: modal blocks app handlers, unprevented Ctrl-C exits, prevent keeps active, termios exact restoration, partial/error aggregate paths. Actual host raw+original PNG per host, no re-rendered screenshot | recipe native-host |
| H02 | C-01 / later Keyboard117 | Cross-layer bracketed paste capture/routing integration uses actual accepted117 only; no EOF/target lock/decoder timing guesses added here | recipe only, expressly out of TASK108 implementation |

No Scrollbar, window manager, mouse, standard Modal/Menu wrapper, second tree,
second compositor, fake native writer, copied Unicode tables or second theme
resolver is part of these consumers.

## Final-preparation public-driver mapping

All C rows below remain **UNEXECUTED** because the actual C API is absent.
The historical `source`/`recipe` column above describes the original preparation,
not successful type compilation. The new mapping supersedes that form column;
original IDs and hand oracles are retained, except the documented D08 recipe
wording correction under C.2. Full type correctness awaits actual C declarations.

| IDs | Public consumer / driver |
|---|---|
| S01–03 | public_shapes.cj / publicShapes |
| P01–02 | pending_and_identity.cj / pendingCancellation |
| P03 | pending_failures.cj / duplicateReservation |
| P04 | pending_failures.cj / pendingFailure(false/true), broken_panel.cj |
| P05 | pending_failures.cj / releasedOwnerObservation: deterministic terminal/resource assertions; bounded public GC observation only; retention source audit TASK110 |
| N01–03 | pending_and_identity.cj / sharedTypeAndIdentity |
| N04 | ordinary_identity.cj / mixedOrdinaryIdentity: actual If/ForEach/manual physical sequence |
| N05–06 | ordinary_identity.cj / ownerMoveAndPaintLifetime |
| D01–04 | layer_domains.cj / modalDomains |
| D05–06 | layer_domains.cj / escapeBarrierAndPrevent |
| D07–08 | domain_edges.cj / escapeAndLogicalRouting; D08 correction in final-preparation.md |
| D09–10 | domain_edges.cj / modalTraversalAndDomainOpen |
| F01–07 | layer_domains.cj / emptyLayerReservation |
| F08–09 | close_lifecycle.cj / savedFocusFallback |
| F10–11 | focus_restoration.cj / hiddenOrUnmountedSaved(false/true) |
| F12 | focus_restoration.cj / physicalRestorationFallback(0..3), public final outcomes; no invented transient focus callback |
| F13 | focus_restoration.cj / stackedRestoration; merged internal focus restoration source audit TASK110 |
| L01–04 | close_lifecycle.cj / dependentClosure |
| L05 | close_lifecycle.cj / cleanupAggregation |
| L06–07 | lifecycle_edges.cj / ordinaryOwnedClosure, offscreenOwnerAndReason |
| L08 | lifecycle_edges.cj / primaryAndCleanup(false/true); native_fixture callback-error for real-run aggregation |
| E01–12 | entry_errors.cj / entryValidation, foreignAndOldHandles |
| E13–14 | context_and_limits.cj / threadAndAnchorValidation |
| E15 | context_and_limits.cj / evaluationAndLifecycleGuards(0..2), lifecycleLayerCommands |
| E16–18 | context_and_limits.cj / layerDepthBoundary(), layerCapacity(0..2), layerDependencyBudget(false/true), interactivePassiveRejection |
| G01–10 | surface_grids.cj / surfacesAndLatestBase, sourceBasedCaretOcclusion |
| G11–12 | theme_and_host.cj / ownerThemeSurface, explicitHostClip |
| G13–14 | anchor_geometry.cj / directionalAnchors, clippedAndLostAnchors |
| G15–16 | decorations_and_caret.cj / decoratedLayerTargets, caretSpacesShadowAndClip |
| H01 | native_fixture.cj + pty_driver.py; five real-process modes (interrupt/prevent/Escape/SIGINT/callback-error), existing B PTY primitives; native-host-recipe for original-host PNG and accepted close-fault infrastructure |
| H02 | Future accepted Keyboard117; explicitly not implemented or executed now |

No claim that a weak observer proves ownership, that a headless assertion proves
native restoration, or that a PTY on another TERM is another host is made.


## C109 targeted public regressions (post-freeze additions)

| IDs | Contract and public entry |
|---|---|
| X01 | R004/I009/C.6: pure0×0 mounted export preserves application4×2 committed anchored layer/ref/offset and subsequent ensure6; export_turn_regressions.cj / pure-export |
| X02 | C.1: ordinary top-level open rejects WrongUIContext without reserve/mount; same content opens in legal batch; export_turn_regressions.cj / open-turn |

These are independent targeted assertions, not changes to old oracle values.
Actual fixed-WIP executions and reached/unreached controls belong to their own
raw manifest; neither compile errors nor actor historical observations are
counted as this role's fresh behavioral RED.

## TASK110 finding regressions (append-only supplement)

| Selector | Public behavior / authority |
|---|---|
| C-I01 | C.4: ordinary owner remove revokes all owned generations/owner posts before deepest-first layer cleanup |
| C-I02 | C.2/C.4: both If and ForEach owner retirement terminate owned modal OwnerGone, cleanup once, restore base target |
| C-I03 | A.4/C.7: hidden content contributes no cells; hidden/disabled takeFocus layer root cannot remain activeTarget |
| C-I04 | B ensure/C.6: same frame uses offset3 geometry; offscreen anchor closes AnchorGone |
| C-I05 | T008/C.2: overlay effective layout overflow fails candidate before publication, retaining Old/session/refs/picture |
| C-I06 | T008/C.2: overlay ownership weight1 cannot overflow ordinary Row child weight Int64.Max |
| C-I07 | C.2: explicit root host uses built-in root capability without overlayHost(true) |
| C-I08 | Shared host error/C.2: pending host capability revoked in same batch fails InvalidOverlayHost; unified failure cleanup |
| C-I09 | C.3/A.4 plus diagnostic ruling: Passive dispatch InvalidProperty and no owner handler; NonModal positive control |
| C-I10 | R004/I009/C.6: first pure export and changed-size exports compose using current temporary geometry, preserving committed state |

All ten selectors run independently against one normally built actual consumer.
I05's callback preflight prohibition cannot be isolated from normal layout by a
cross-snapshot total counter and is left to source review, explicitly unclaimed.

## Round2 fix-delta boundaries

| Selector | Frozen public contract and independent assertion |
|---|---|
| R1-I01 | A.4 ordinary removal remains NEXT; C.4 removal of modal owner with invalid saved focus first selects FIRST from nearest surviving owner ancestor root |
| R1-I02 | C.2/C.6 actual5×1 built-in root host centers natural1×1 P at column2, both with None and explicit root host, despite ordinary root fixed1×1 |

Two standalone public selectors only; no prior ten-selector/full suite rerun
is implied by their fresh targeted execution.
