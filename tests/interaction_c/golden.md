# Hand-authored geometry, grids, traces and identity

Authority: `design.md` C.1–C.7, A.4–A.6, I003/I004/I009/I012/I014;
`specs/terminal-output/spec.md` Theme-aware opaque surface and Session-owned
logical caret. No grid, expected coordinate or trace is computed by product
layout, a cloned layout algorithm, or a second business implementation.

All coordinates start at zero. Grid rows below are exact strings; each shown
8-column row has length 8. No final LF. ASCII permits manual column counting.

## Centered three-column layer in 8 × 3 host

The host is `(0,0,8,3)`, layer is `3 × 1`. Integer center remainder rounds down:
`x=2,y=1`. The 3 cells are terminal `(2,1),(3,1),(4,1)`. The modal opaque box
does not fill a backdrop around itself. Base:

```text
abcdefgh
ijklmnop
qrstuvwx
```

| Vector | Exact three rows, separated here by ` / ` | Source at `(3,1)` |
|---|---|---|
| G01 default Modal Text X width3 height1 | `abcdefgh / ijX  nop / qrstuvwx` | modal filled space |
| G02 explicit surface Transparent, no background | `abcdefgh / ijXlmnop / qrstuvwx` | base l through hole |
| G03 Transparent plus explicit background Default | `abcdefgh / ijX  nop / qrstuvwx` | modal normal background fill |
| G04 covered base changes to IJKLMNOP | `abcdefgh / IJX  NOP / qrstuvwx` | modal filled space |
| G04 close | `abcdefgh / IJKLMNOP / qrstuvwx` | current base L |
| G05 Canvas X at local0, written space at local1, local2 untouched | `abcdefgh / IJX MNOP / qrstuvwx` | layer written space; local2 reveals base M |
| G06 mounted full render and snapshot | same G05 | committed layer; no new session |
| G06 snapshot object after close | same G05 | independent saved Frame |

SettingsPanel (same public custom class, two instances, shared Observable) uses
a normal width3 height1 instance at row0 and a transparent width3 height1 layer
at `(2,1)`, with base row1 `tailtail`:

| Model | Exact rows |
|---|---|
| A | `A       \ntaAltail\n        ` |
| BC | `BC      \ntaBCtail\n        ` |

The ordinary child sequence remains `[normalPanel, tailText]` before/after open.
`handle.content().sameNode(layer.reference()) == true`. Ordinary and layer refs
remain identical across resize; layer close invalidates only its ref. The same
Component instance cannot serve both positions; AlreadyMounted is required.

## Actual draw sources, not pixel comparison

Base Canvas has caret `(3,1)` on `l`. Passive width3 height1 layer is centered as
above; its local `(1,0)` maps to the caret. A hole leaves caret visible. Writing
the same `l` with the same Style keeps all final cells identical while hiding
caret. A written styled space or shadow contribution also hides caret; final
pixel equality cannot infer which node supplied a cell. The passive layer never
changes focusedNode. After close, a completed target shows the base caret again.
Hidden caret normal form is owner=None, x=0, y=0, visible=false.

## Exact event trace

Owner dependency chain is `base → modal M → nonmodal P → modal C`. Highest modal
C is the current domain. C root has capture/bubble/Ancestor, its focusable child
T has capture/bubble/Target. A text event must give exactly:

```text
Cc;Tc;Tb;Cb;Td;Ca;
```

M/P/base handlers and both base app/legacy are absent. A domain-outside dispatch
reports FocusOutsideDomain before callbacks. Escape runs after Target, closes C
and consumes before Ancestor. P is then target and M/P remain open. Unprevented
interrupt in P stops the whole Application; base handlers remain absent. A
capture preventDefault keeps the session active. A closest interactive layer
with closeOnEscape=false blocks cancelling its parent; passive layers are skipped.

## Focus/restoration order

I014 initial base order `[previous,saved,next]` chooses previous. Explicit focus
saved, then takeFocus modal opened by saved, then saved disabled: closing modal
cannot restore saved. C.4 first chooses the closest surviving owner ancestor's
first eligible candidate, previous. A's original physical successor/predecessor
comes later in the precedence and must not override this candidate.

Empty takeFocus nonmodal reserves `focusedNode=None,activeTarget=layerRoot`, even
when the base gains a candidate. Its later first eligible child becomes focused.
Tab can leave this nonmodal and wraps from its last candidate to base first.
Closing it once it is in the background does not restore over current base focus.
Nonmodal/takeFocus=false and Passive keep the existing focus/target selection.

## Manual anchor recipes (prepared, not executed)

Use a public host content clip `(0,0,10,6)`, anchor committed box `(4,2,2,1)`,
natural popup size `3 × 2`. BelowStart is `(4,3)`; AboveStart `(4,0)`;
RightStart `(6,2)`; LeftStart `(1,2)`. For anchor `(4,5,2,1)`, BelowStart flips to
AboveStart `(4,3)`. For clip height3, anchor `(4,1,2,1)` and natural popup height2,
above/below each have one row: retain preferred BelowStart and constrain to
available host geometry; exact resulting content extent must be observed through
actual accepted B API, not guessed. Cross start for anchor x9 clamps popup x to7.

Partially scroll-clipped anchor uses its nonempty host intersection, not original
offscreen coordinates. Fully empty intersection closes anchored NonModal with
AnchorGone; disabled does not close. Owner invalid beats anchor invalid with
OwnerGone. Modal forbids anchors; zero host clip does not close unanchored Modal.

## Decorations/move/shrink recipes (prepared, not executed)

Use default single rounded border, explicit `shadow(offsetX:1,offsetY:1)` and
public host clipping. Record each cell's grapheme/style/continuation/source by
public Frame observations plus focused caret snapshot. Compare full target
Frames after move, shrink and close; old and new boxes including shadow must be
cleared/repainted. Keep a wide cluster crossing a clip boundary: no half cluster
or orphan continuation can survive. Expected border glyphs and shadow cells must
be frozen from the existing decoration formal contract when this recipe is made
executable; do not derive them by calling product drawBorder/drawShadow.

Theme088 recipe: owner effective text Style O differs from host H, within the
same Application theme (there is no invented per-node Theme API). Use the
formally declared `.styles([StyleUse.Named("owner")])` and a distinct host named
style, with Theme.parse/accepted actual Application theme entry. Modal has no
local background. Space cells in its layout box inherit O's resolved background;
surrounding base stays visible. Switch the Application theme through the actual
accepted public entry and observe the owner named style and modal spaces change,
without writing local Default. Disable owner and verify that layer enabled stays
separate from owner-derived text/style inheritance. T015's root seed fill uses
its independent fillStyle, while C modal surface uses the content root's full
effective Style; inverse/underline on the modal must affect its filled spaces.

## Final-preparation frozen recipe details

The original grids/traces above are retained. New literal expectations appear
in `anchor_geometry.cj` and `decorations_and_caret.cj`; none are generated by a
renderer. For the original G13 equal-side recipe, a height2 popup in host height3
with anchor y1 has one free row on each side: choose Below, desired y2, then
host-clamp y to1 (popup retains height2, host is its size constraint). Assert
rows1/2, not a guessed one-row popup. Four directional, flip and cross-clamp
vectors use the original coordinates. Resize keeps the published generation.

G12 host is6×3, owner1×1; a9×6 P-canvas is host-constrained6×3, so three rows
are `PPPPPP  ` and the base's fourth row remains `TTTTTTTT`. Its shadow cannot
escape host clip. This explicitly separates owner clip from geometry host clip.

G15 at8×5: layer4×3 centered `(2,1)`, Rounded `╭──╮/│界│/╰──╯`, shadow(1,1)
uses `░` only in the shifted outer rectangle outside the original box, exactly
as the existing decoration design states. Row2 shadow is x6, bottom shadow
row4 is x3..6. Resizing host to10 moves x to3; shrinking to width3 clips the
2-column cluster entirely and clears its continuation. Every expected row is a
literal. Shadow Style(dim=true) and continuation are checked via Frame.cellAt.

D08 correction under C.2: `L;O;H;R;APP;LEGACY;` includes H once because H is
already the owner's ordinary ancestor. Geometry hosting adds no new event edge.
P05 GC observations and future H02 are explicitly limited in final-preparation.


## X01 pure mounted export / X02 active-turn entry regressions

X01 actual application is4×2, Text A root with viewport Off, root-anchored
BelowStart nonmodal Canvas viewport2×1/content8×1. Host clamps its y to1.
At offset3 the literal application rows are `A   ` / `de  `; ensure cell6
Nearest on a2-column viewport produces offset5 and `A   ` / `fg  `.
A pure `render(root,0,0)` has an empty exported grid but cannot close the
application's valid anchor/layer, replace refs, mutate its committed offset or
consume the ensure. Batch may apply ensure now or leave it pending: preserve
its observed committed offset, then assert the independently counted final5.
No Application.snapshot(0,0) is substituted for the pure export.

X02 top-level open on the owner thread after startHeadless is outside the C.1
allowed event/post/batch domain: WrongUIContext before reservation/mount. The
same content must subsequently open in batch and mount/clean exactly once.
This does not replace existing pure/lifecycle/stale/foreign guard priorities.

## C-I01–C-I10 manual expectations

C-I01: ordinary root -> owner owns outer layer -> nested layer. Removing owner
first invalidates all three saved generations. Both cleanups observe invalid
refs and rejected owner posts; cleanup order is literal `N;L;`, once each; only
root remains mounted. Both layer handles terminate OwnerGone.
C-I02: If true / ForEach one key each create one owner and one modal. Retiring
that owner leaves root only, with activeTarget=root, modal OwnerGone and one
cleanup. Observations are taken before session disposal in both variants.
C-I03: base `BBB`, centered one-cell P gives `BPB`. Hidden layer yields `BBB`;
disabled but visible layer yields `BPB`. A returned activeTarget is always
visible and enabled (absence is permitted when no eligible domain root exists).
C-I04: five rows A/1/2/3/4 in viewport3×2 initially `A  ` / `1  `; root-anchored
BelowStart one-cell layer replaces row1 with `P  `. Ensuring logical row4
Nearest gives offset3: literal rows `3  ` / `4  `. Anchor A is wholly clipped,
so same target frame closes the layer AnchorGone and contains no P.
C-I05: width Int64.Max × height0 is a legal empty frame. Old grow weight0/min0
is valid. Next gives both Row children weight1/minWidth Int64.Max: the sum
cannot fit, so transaction is Failed before publication, Old info remains,
original refs/session remain valid and the empty old picture is reusable.
C-I06: ordinary Row has one max-weight B child, with P in an independent layer.
At3×1 the literal is `BP `; an equivalent named Next theme must Applied. The
layer weight is outside the ordinary flow sum, and children().size is1.
C-I07: explicit built-in root host needs no explicit host flag. Text B plus
centered P at3×1 yields `BP ` and a committed open handle.
C-I08: pending open reserves content, then explicit non-root host loses its
capability before commit: InvalidOverlayHost, no mount/cleanup of pending
content, closed handle/no ref, and the structural failure releases session.
C-I09: normal NonModal target calls owner handler once. Passive target rejects
InvalidProperty before routing and owner calls remain zero.
C-I10: root Text A viewport Off is the whole temporary viewport anchor. P has
natural1×1. Both below/above spaces are exhausted; clamp gives bottom row.
Fresh pure3×2 is `A  ` / `P  `; fresh or resized5×3 is `A    ` / `     ` /
`P    `;1×1 is `P`. Fresh exports preserve initial0×0 committed viewports;
after real3×2 snapshot, resized pure exports preserve both committed viewport
snapshots and original open handle/root/content generations.

## Round2 R1-I01 / R1-I02 manual expectations

R1-I01: ordinary root order FIRST/OWNER/NEXT, each focusable. Explicitly focus
OWNER. Without an owned layer, removal follows A's physical successor NEXT.
With OWNER owning modal focusable P, removal closes that modal OwnerGone and
invalidates saved OWNER. C.4 next considers nearest surviving owner ancestor
root, whose first eligible candidate is FIRST, before A's NEXT fallback.
R1-I02: terminal5×1, ordinary Text B root explicitly1×1 and viewport Off.
Built-in root host is the actual five columns; P is natural1×1 Center, so
x=floor((5-1)/2)=2. Both default None host and explicit root host must give
literal `B P  `; `P    ` incorrectly centers in the ordinary root's1×1 box.
