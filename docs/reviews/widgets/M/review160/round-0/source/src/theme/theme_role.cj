package cjtui.theme

public enum ThemeRole <: Equatable<ThemeRole> {
    | Generic | Text | Row | Column | Label | Button | Radio | Checkbox | Progress | TextInput | TextArea | HorizontalMenu | PopupMenu | MenuItem | StatusBar | Modal | SplitPane
    public operator func ==(other: ThemeRole): Bool {
        match ((this, other)) {
            case (Generic, Generic) | (Text, Text) | (Row, Row) | (Column, Column) | (Label, Label) | (Button, Button) | (Radio, Radio) | (Checkbox, Checkbox) | (Progress, Progress) | (TextInput, TextInput) | (TextArea, TextArea) | (HorizontalMenu, HorizontalMenu) | (PopupMenu, PopupMenu) | (MenuItem, MenuItem) | (StatusBar, StatusBar) | (Modal, Modal) | (SplitPane, SplitPane) => true
            case _ => false
        }
    }
}

internal func themeRoleIndex(role: ThemeRole): Int64 {
    match (role) {
        case ThemeRole.Generic => 0
        case ThemeRole.Text => 1
        case ThemeRole.Row => 2
        case ThemeRole.Column => 3
        case ThemeRole.Label => 4
        case ThemeRole.Button => 5
        case ThemeRole.Radio => 6
        case ThemeRole.Checkbox => 7
        case ThemeRole.Progress => 8
        case ThemeRole.TextInput => 9
        case ThemeRole.TextArea => 10
        case ThemeRole.HorizontalMenu => 11
        case ThemeRole.PopupMenu => 12
        case ThemeRole.MenuItem => 13
        case ThemeRole.StatusBar => 14
        case ThemeRole.Modal => 15
        case ThemeRole.SplitPane => 16
    }
}
