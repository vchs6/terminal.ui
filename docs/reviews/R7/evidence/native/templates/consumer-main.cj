package native_probe
import unicode.GraphemeIterator
import unicode.Codepoint
import unicode.types.NormalizationForm
main(): Int64 {
 let it = GraphemeIterator("中é👩‍💻❤️🇨🇳")
 var count: Int64 = 0
 while (true) {
  match(it.next()) {
   case None => break
   case Some(g) => count++
  }
 }
 if (count != 5) { return 1 }
 let normalized = Codepoint.normalize(UInt32(r'é'.position()), form: NormalizationForm.NFD)
 if (normalized.size != 2 || normalized[0] != UInt32(r'e'.position()) || normalized[1] != 0x301) { return 1 }
 println("PASS native segmentation and NFD; five clusters")
 return 0
}
