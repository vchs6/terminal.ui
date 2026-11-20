# Theme showcase

Run `cjpm build` in this directory, then run `target/release/bin/main` in a terminal. The gallery starts in Classic and keeps its editors and business state when themes change. `--smoke` prints finite headless snapshots; `--theme-file PATH` configures the file selected by F6.

F1–F4 select Classic, Dark, Light and High contrast; F5 opens the preview; F6 loads the configured file; F7 reloads the currently accepted file; F8 scrolls the records; F9 closes the preview; F10 quits. Tab moves focus and normal editing keys remain available. The preview Actions button opens a menu with a disabled entry. Run changes the sample to Pending; it does not start background work.

Theme loads are explicit. The footer names the accepted theme, and a failed load leaves the accepted theme and gallery data intact. Reload after selecting a preset fails because that preset has no file source.
