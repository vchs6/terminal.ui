package cjtui_theme_showcase
import cjtui.*

class Commands {
    let data: GalleryData
    let editor = TextEditController()
    let notesEditor = TextEditController()
    let request = Observable<?ThemeRequest>(Option<ThemeRequest>.None)
    let noFile = Observable<Bool>(false)
    let file: ?String
    var app: ?Application = None
    var owner: ?NodeRef = None
    var log: ?NodeRef = None
    var modal: ?OverlayHandle = None
    var actions: ?NodeRef = None
    init(data: GalleryData, file: ?String) { this.data = data; this.file = file }
    func status(): String { "Gallery | ${app.getOrThrow().themeInfo().name} | ${data.progress()}/2" }
    func phase(): String {
        if (noFile.get()) { return "No theme file" }
        if (let Some(r) <- request.get()) {
            if (let Some(result) <- r.result()) {
                match (result) { case ThemeResult.Failed(_) => return "Load failed"; case _ => () }
            }
        }
        data.phase()
    }
    func preset(value: ThemePreset): Unit { noFile.set(false); request.set(Some(app.getOrThrow().loadTheme(ThemeSource.Preset(value)))) }
    func load(): Unit {
        if (let Some(path) <- file) { noFile.set(false); request.set(Some(app.getOrThrow().loadTheme(ThemeSource.File(path)))) }
        else { noFile.set(true) }
    }
    func reload(): Unit { noFile.set(false); request.set(Some(app.getOrThrow().reloadTheme())) }
    func preview(): Unit {
        if (let Some(handle) <- modal) { if (handle.isOpen()) { return } }
        modal = Some(owner.getOrThrow().openOverlay(Preview(this).width(32).height(9).themeRole(ThemeRole.Modal), options: OverlayOptions(mode: OverlayMode.Modal)))
    }
    func popup(owner: NodeRef): Unit {
        let handle = Array<?OverlayHandle>(1, repeat: Option<OverlayHandle>.None)
        let menu = PopupMenu([MenuEntry("inspect", "Inspect"), MenuEntry("delete", "Delete", enabled: false),
            MenuEntry("confirm", "Confirm")], {_ => handle[0].getOrThrow().close()})
            .onKey({event => modalKey(event)})
        handle[0] = Some(owner.openOverlay(menu))
    }
    func close(): Unit { if (let Some(handle) <- modal) { handle.close() } }
    func action(key: String): Unit {
        match (key) {
            case "classic" | "f1" => preset(ThemePreset.Classic)
            case "dark" | "f2" => preset(ThemePreset.Dark)
            case "light" | "f3" => preset(ThemePreset.Light)
            case "contrast" | "f4" => preset(ThemePreset.HighContrast)
            case "preview" | "f5" => preview()
            case "file" | "f6" => load()
            case "reload" | "f7" => reload()
            case "f8" => if (let Some(ref) <- log) { ref.scrollBy(0, 12) }
            case "f9" => close()
            case "quit" | "f10" => app.getOrThrow().stop()
            case _ => ()
        }
    }
    func modalKey(event: UIKeyEvent): Unit {
        if (event.key.code == "f9" || event.key.code == "f10") { action(event.key.code); event.consume() }
    }
}
