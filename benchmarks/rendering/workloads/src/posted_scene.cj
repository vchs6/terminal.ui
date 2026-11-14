package rendering_workloads

import cjtui.*

public class PostedScene {
    public let root: Component
    public let app: Application
    private let text: Observable<String>
    private let committedEpoch: Observable<Int64>

    public init(width: Int64, height: Int64) {
        let text = Observable<String>("A中é👩‍💻🇨🇳")
        let committedEpoch = Observable<Int64>(0)
        this.text = text; this.committedEpoch = committedEpoch
        let root = Column {
            Text({=> text.get()}).width(width).height(1)
            for (_ in 1..height) { Text("A中é👩‍💻🇨🇳").width(width).height(1) }
        }.width(width).height(height)
        this.root = root
        this.app = Application(root, glyphMode: GlyphMode.Unicode,
            theme: Theme.parse("schema_version = 1\nname = \"benchmark\"\n"))
    }

    // A producer completes one accepted enqueue before the caller pumps the
    // public snapshot. The next producer is never started before verification.
    public func enqueue(epoch: Int64): Unit {
        let app = this.app; let text = this.text; let committed = this.committedEpoch
        let producer = spawn {
            app.post({=>
                text.set(if (epoch % 2 == 1) { "A文é👩‍💻🇨🇳" } else { "A中é👩‍💻🇨🇳" })
                committed.set(epoch)
            })
        }
        if (!producer.get()) { throw Exception("post rejected at epoch ${epoch}") }
    }

    public func assertCommitted(epoch: Int64): Unit {
        if (committedEpoch.get() != epoch) { throw Exception("post epoch was not committed") }
    }
}
