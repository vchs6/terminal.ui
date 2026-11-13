# Bounded S02/S05 setup boundary inventory

Accepted Interaction A.4 requires requestFocus in an event/post/batch and validates/commits at the boundary; explicit dispatch never changes focus. W003 activates only a focused target. Therefore a positive activation test must establish and assert focus before dispatch.

| Site or assumption | Audit disposition |
|---|---|
| event_boundaries.cj duplicateRadioLabels, old line90 | Wrap second Radio setup request in app.batch, then assert children[1].isFocused before the unchanged Space dispatch and unchanged model/callback/frame assertions. |
| remount_cases.cj, old line42 | Wrap remounted node request in app.batch, then assert current.isFocused before unchanged Enter dispatch/model assertion. |
| Other S requestFocus calls | Inventory of all tracked S Cangjie sources finds no other requestFocus calls. No outside-batch behavior is asserted by the fix. |
| S02 single-control positive activation | startHeadless initial eligible-focus guarantee (Interaction A.15) supplies focused target; no queued setup request exists. Preserve. |
| S02 unfocused negative and declared-focused appearance cases | Explicit dispatch intentionally targets a real unfocused node; no setup focus should be added. event_cases/theme_cases source remains byte-equal. |
| S02 model/eligibility changes within onKey | Occur inside dispatch's automatic event batch; latest business checked reads and committed eligibility distinctions remain the frozen W003 oracle. Preserve. |
| S05 owner removal and queued post | Removal is in explicit batch, spawn Future.get establishes queue admission, batch commits removal, following snapshot processes/cancels the old generation. Preserve. |
| S05 append and live worker post | append is followed by snapshot; accepted worker post is joined and followed by snapshot. Runtime §3.2 explicitly makes snapshot a pump/stabilization boundary. Preserve. |
| S05 cleanup/error/multiview setup | Existing public start/snapshot/dispose boundaries and exact resource/error assertions remain unchanged. |

The primitive control uses actual public focusable Text children, app.batch and isFocused/focusedNode. It is not a Radio substitute and supplies no widget callback oracle. This inventory is contract/source verification, not a claim that unexecuted widget behavior passes.
