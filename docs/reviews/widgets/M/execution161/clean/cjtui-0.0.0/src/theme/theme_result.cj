package cjtui.theme

public enum ThemeResult { | Applied(UInt64) | Failed(ThemeDiagnostic) | Superseded(UInt64) | SessionClosed }
