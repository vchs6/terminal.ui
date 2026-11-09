package native_adapter
import unicode.GraphemeIterator
public func countGraphemes(text: String): Int64 {
 let it = GraphemeIterator(text)
 var count: Int64 = 0
 while (true) {
  match(it.next()) {
   case None => break
   case Some(g) => count++
  }
 }
 return count
}
