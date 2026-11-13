package cjtui

import std.collection.HashMap

// Read only mounted nodes and their already-evaluated declarations. No user
// getter, build, mount or drawing callback is invoked while preparing a theme.
func validateThemeCandidate(session: RuntimeSession, theme: Theme): (?ThemeDiagnostic, Bool) {
    let oldStyles = HashMap<Int64, Style>()
    var layoutChanged = false
    let styles = HashMap<Int64, Style>()
    let weights = HashMap<Int64, Int64>()
    try {
        for (node in session.nodes) {
            if (!node.valid || !node.committed) { continue }
            let inherited = match (node.parent) {
                case Some(parent) => styles.get(parent.id).getOrThrow()
                case None => themeSeed(theme)
            }
            let oldInherited = match (node.parent) {
                case Some(parent) => oldStyles.get(parent.id).getOrThrow()
                case None => themeSeed(session.theme)
            }
            let old = resolveStyle(node.component,session.theme,oldInherited,node.parent.isNone())
            oldStyles[node.id] = old.style
            let resolved = resolveStyle(node.component,theme,inherited,node.parent.isNone())
            if (layoutStyleDiff(old,resolved)) { layoutChanged = true }
            styles[node.id] = resolved.style
            if (let Some(parent) <- node.parent) {
                if (!node.overlayRoot && node.component.isVisible && resolved.weight > 0) {
                    let previous = weights.get(parent.id) ?? 0
                    if (previous > Int64.Max - resolved.weight) {
                        return (Some(ThemeDiagnostic("InvalidCandidate",theme.sourceName,"","layout weight sum overflow",Option<ThemeLocation>.None,"unavailable")), false)
                    }
                    weights[parent.id] = previous + resolved.weight
                }
            }
        }
        validateCandidateLayout(session,theme)
    } catch (_: UIException) {
        return (Some(ThemeDiagnostic("InvalidCandidate",theme.sourceName,"","style cannot be applied to the current tree",Option<ThemeLocation>.None,"unavailable")), false)
    } catch (_: IllegalArgumentException) {
        return (Some(ThemeDiagnostic("InvalidCandidate",theme.sourceName,"","invalid layout value in current tree",Option<ThemeLocation>.None,"unavailable")), false)
    }
    (None, layoutChanged)
}
