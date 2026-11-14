package cjtui_theme_showcase
import cjtui.*

func runSmoke(): Unit {
    for (preset in [ThemePreset.Classic, ThemePreset.Dark, ThemePreset.Light, ThemePreset.HighContrast]) {
        let data = GalleryData()
        let commands = Commands(data, Option<String>.None)
        let app = Application(GalleryView(data, commands).viewport(ScrollAxes.Off).alignItems(Alignment.Stretch), theme: Theme.preset(preset))
        commands.app = Some(app)
        app.startHeadless()
        try {
            let info = app.themeInfo()
            for (size in [(80, 24), (40, 12), (16, 6)]) {
                println("BEGIN ${info.name} ${size[0]}x${size[1]}")
                println(app.snapshot(size[0], size[1]).toPlainText())
                println("END ${info.name}")
            }
            println("INFO ${info.name} revision=${info.revision} request=${info.requestId}")
        } finally { app.dispose() }
    }
    println("PASS theme showcase")
}
