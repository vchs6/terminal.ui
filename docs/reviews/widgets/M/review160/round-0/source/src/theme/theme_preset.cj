package cjtui.theme

public enum ThemePreset <: Equatable<ThemePreset> {
    | Dark | Light | HighContrast | Classic
    public operator func ==(other: ThemePreset): Bool {
        match ((this, other)) {
            case (Dark, Dark) | (Light, Light) | (HighContrast, HighContrast) | (Classic, Classic) => true
            case _ => false
        }
    }
}
