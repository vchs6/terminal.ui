package incremental_invalidation_cache

import cjtui.*

func describeCell(value: Cell): String {
    let s = value.style
    "[grapheme=${value.grapheme};width=${value.width};continuation=${value.continuation};transparent=${value.isTransparent};foreground=${describeColor(s.foreground)};background=${describeColor(s.background)};bold=${s.bold};dim=${s.dim};italic=${s.italic};underline=${s.underline};inverse=${s.inverse};strikethrough=${s.strikethrough}]"
}
