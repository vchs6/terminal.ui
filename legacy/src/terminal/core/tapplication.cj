package acnl.terminal.core

public class TApplication<T> where T <: Render {
    private let render: T
    private var size: TSize = TSize(200, 80)
    private var UnicodeVersion: String = "v17.0.0"  

    public init(render: T) {
        //这里需要探测控制台的尺寸
        this.render = render
        Character.UnicodeVersion = this.UnicodeVersion
    }

    public func run(): Unit {
        let mainWindow = TWindow(0, 0, width: size.width, height: size.height)
        mainWindow.onGetRender = { => render }
    }
}
