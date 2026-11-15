package rendering_workloads

import cjtui.*

public class ReactiveScene {
    public let root: Component
    public let app: Application
    public let name: String
    private let target: Component
    private let left: Observable<String>
    private let right: Observable<String>
    private let selectRight: Observable<Bool>
    private let payload: TextPayload

    public init(name: String, width: Int64, height: Int64) {
        this.name = name
        let payload = TextPayload()
        this.payload = payload
        let left = Observable<String>("A中é👩‍💻🇨🇳")
        let right = Observable<String>("A中é👩‍💻🇨🇳")
        let selectRight = Observable<Bool>(false)
        this.left = left; this.right = right; this.selectRight = selectRight
        let targetRef: Array<?Component> = [None]
        let root = Column {
            for (i in 0..height) {
                if (i == height - 1) {
                    let target = if (name == "explicit_notify") {
                        Text({=> payload.value}).width(width).height(1)
                    } else { Text({=> if (selectRight.get()) { right.get() } else { left.get() }}).width(width).height(1) }
                    targetRef[0] = Some(target)
                } else { Text("A中é👩‍💻🇨🇳").width(width).height(1) }
            }
        }.width(width).height(height)
        this.target = targetRef[0].getOrThrow(); this.root = root
        this.app = Application(root, glyphMode: GlyphMode.Unicode,
            theme: Theme.parse("schema_version = 1\nname = \"benchmark\"\n"))
    }

    public func replaceWithEqual(): Unit { selectRight.set(true) }
    public func changeOldSource(): Unit { left.set("old source changed") }
    public func restoreSource(): Unit { left.set("A中é👩‍💻🇨🇳"); selectRight.set(false) }

    public func action(epoch: Int64): Unit {
        if (name == "typed_equal") {
            if (epoch % 2 == 1) { selectRight.set(true); left.set("old source changed") }
            else { left.set("A中é👩‍💻🇨🇳"); selectRight.set(false) }
        } else if (name == "explicit_notify") {
            payload.value = if (epoch % 2 == 1) { "A文é👩‍💻🇨🇳" } else { "A中é👩‍💻🇨🇳" }
            target.reference().getOrThrow().notify(ChangeKind.Content)
        } else { throw Exception("unknown reactive scene ${name}") }
    }
}
