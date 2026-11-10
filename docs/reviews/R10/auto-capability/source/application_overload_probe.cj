enum ColorMode {
    | Automatic | Basic16 | RichSnapshot
}

class Root {}

class Application {
    public init(root: Root) {}
    public init(root: Root, colorMode!: ColorMode) {}
}

class Frame {
    public func toAnsi(colorMode!: ColorMode = ColorMode.RichSnapshot): String {
        "rich snapshot"
    }
}

main() {
    let root = Root()
    let automatic = Application(root)
    let explicit = Application(root, colorMode: ColorMode.Basic16)
    let snapshot = Frame().toAnsi()
    let explicitSnapshot = Frame().toAnsi(colorMode: ColorMode.Basic16)
    println("automatic and explicit overloads compile; ${snapshot}; ${explicitSnapshot}")
}
