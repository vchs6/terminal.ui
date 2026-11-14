package cjtui_theme_showcase
import cjtui.*

class GalleryData {
    let query = Observable<String>("Query")
    let notes = Observable<String>("Check input")
    let pin = Observable<Bool>(false)
    let byName = Observable<Bool>(false)
    let pending = Observable<Bool>(false)
    func phase(): String { if (pending.get()) { "Pending" } else { "Idle" } }
    func progress(): Int64 { if (pending.get()) { 1 } else { 0 } }
}
