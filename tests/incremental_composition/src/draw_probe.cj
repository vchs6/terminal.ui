package incremental_composition

import cjtui.*
import std.collection.ArrayList

class DrawProbe {
    let name: String
    let observations = ArrayList<DrawObservation>()
    var expected: DrawObservation
    init(name: String, width: Int64, height: Int64) {
        this.name = name; expected = DrawObservation(width,height,Rect(0,0,width,height))
    }
    func record(context: PaintContext): Unit {
        let size = context.size
        observations.add(DrawObservation(size.width,size.height,context.clip,style:context.defaultStyle))
    }
    func reset(): Unit { observations.clear() }
    func saved(): Array<DrawObservation> { observations.toArray() }
}
