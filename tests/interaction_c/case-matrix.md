# TASK108 preparation coverage and remaining barriers

All rows are **BLOCKED for actual overlay execution**. `source` means a prepared
Cangjie assertion; it does not mean compiled or run. `recipe` is a hand-authored
test vector requiring the actual public signature/source barrier before source
can be frozen. No recipe is counted as executable coverage or task acceptance.

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
| D08 | C-01 / C.2/C.3 | Nonmodal event bubbles along owner chain to base app then legacy; explicit host is absent from logical event path | recipe |
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
| E16 | C-04 / shared errors | Root-only mountedNodes limit1, open layer would be node2: CapacityExceeded; structuralOpsPerBatch1 with two opens: CapacityExceeded; treeDepth1 root→layer exceeds: CapacityExceeded; no second unbounded queue | recipe |
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
