package cjtui

public class SessionOptions {
    let route: SessionRoute
    let clipboard: SessionPolicy
    let title: SessionPolicy
    let titleStack: SessionPolicy

    public init(route!: SessionRoute = SessionRoute.Direct, clipboard!: SessionPolicy = SessionPolicy.Auto,
        title!: SessionPolicy = SessionPolicy.Auto, titleStack!: SessionPolicy = SessionPolicy.Auto) {
        this.route = route
        this.clipboard = clipboard
        this.title = title
        this.titleStack = titleStack
    }
}
