# Storage addendum: C runtime evidence

This later storage record preserves the failure and success history without changing any original sealed index/report or earlier public A/B storage files. Exact ELF bytes can live in local lossless gzip witnesses while old absolute executable paths remain historical logical references. This publication includes only small receipt indices, mapping/report metadata and the three candidate source packages; it does not publish huge ELF witness payloads.

| Local receipt | Index SHA-256 | Mapped ELF payloads |
| --- | --- | --- |
| `validation/accepted-unit-b-elf-witnesses-20261114/index.json` | `ea52638741d81701f0f20eb7593c2b92877529546995bedac075841301ae817d` | 6 |
| `validation/failed-c-candidate-elf-witnesses-20261114/index.json` | `d1536e030ae7e8020486a473cc72bf355e95da4f601aea26e4e6d48fc4ccec67` | 4 |
| `validation/ended-cache-counterexample-headroom-20261114/index.json` | `526c50977e24c82e668f0c9f598ac6a4d47adf14daa3b02a2dd8504ffba48f95` | 1 |
| `validation/round1-cache-fix-headroom-20261114/index.json` | `aa25c43f3aa46140c35fc142de8f2ee190c5d10c1ef720956cdd6b6885656bf8` | 4 |

The public gzip manifest retains each original logical executable path, SHA-256/byte/mode identity, compressed witness path/SHA-256/byte count and original source-index binding. Original small mapping files reside under `work/validation/<receipt>/` inside the raw archive. The failed-f89 receipt also supplies its original `transitive-restoration-map.json`; the earlier `ended-134-development-intermediates` duplicate-alias map preserves the old BIN→artifact→gzip chain. Large compiler/invariant inventories remain external local receipt support, explicitly excluded by path/hash.

T133 pre-organization executable SHA-256 `a8ef5dad87e843e1bd7e1e4fcd6fe39fba4a5d430d66728d0130a490f030b18e` was replaced before final d901 organization; its original bytes were not retained and no exact witness is asserted. Its original failure/raw checksum records and fixed historical test/source versions remain preserved. The organized T133 executable SHA-256 `9e4780ec8f094e62ef6eb303e784957b43883da912d062d44ac4c05512f2bea3` and round-1 counterexample executable SHA-256 `0c6c20ffe4251a39eea78865f398a5b4f88bb04c6a93263822a3949dc72d4c22` are separate artifacts; their publication-time physical state is recorded in this manifest.

The current R2 three consumer ELFs and TASK136 own ELF are checked at publication time and excluded from public raw bytes. Any later local migration needs its own later receipt; this snapshot does not predict future physical paths. Ordinary reproduction follows the fixed source/tests/dependencies and recorded builds. Exact local restoration follows the witness receipt and checks original payload SHA/size/mode; no restoration was performed for publication. Developer compiler cleanup is limited to rebuildable unindexed objects with preserved pins.
