# TASK119 preparation
- Contract: `openspec/changes/implement-linux-input-editing/design.md` E001–E005/F003–F005; `tasks.md` 119.S1–S5.
- Dispatch: `src/application.cj:403` snapshots handlers; target default at 444 follows capture/bubble/app/legacy, ahead of framework/viewport defaults. `src/component.cj:234` supplies the public hook.
- Canvas/viewport: `src/canvas.cj`, `src/paint_context.cj`, `src/constraints.cj`, `src/node_ref.cj:46,62,90`; `src/layout.cj:104` owns geometry and `src/viewport_state.cj` offset.
- Lifecycle/theme: `src/component.cj:126,222,274`, `src/runtime_session.cj:460,1059,1283`; `src/theme/theme_role.cj`; mount effects run during stabilization and `onMount` is a single replaceable slot.
- Source authority: `src/observable.cj` and `src/observable_source.cj` own the lock/version; internal atomic snapshot/conditional commit must preserve public background access and emit outside the lock.
- Session/unicode: `src/application.cj:126`, `src/node_ref.cj:46`, `src/text/unicode.cj`, `src/exports.cj`; no separate renderer, clipboard adapter, or version authority.
- No concrete missing accepted default-stage, Canvas, viewport, or application prerequisite found. Await frozen TASK118 tests and root ACTUALGO before source/build work.
