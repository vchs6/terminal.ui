package rendering_workloads

import cjtui.*

// Uniform lifecycle adapter around public business fixtures. Scene-specific
// preparation and barriers are part of the normal snapshot path.
public class Workload {
    public let app: Application
    public let sceneWidth: Int64
    public let sceneHeight: Int64
    public let root: Component
    public let action: (Int64) -> Unit
    public let setup: () -> Unit
    public let afterSnapshot: (Int64) -> Unit
    public let assertCorrectness: (Int64) -> Unit
    public let glyph: (Int64) -> GlyphMode
    public let caretRecord: (CaretSnapshot, Int64, Int64, String) -> String
    public let viewportState: () -> ?ViewportSnapshot
    public let liveLayers: () -> Int64
    public let terminalAfterSetup: () -> Unit
    public let terminalAfterAction: (Int64) -> Unit
    private let terminalFlag: Array<Bool>

    public init(options: Options) {
        let name = options.scenario; let w = options.width; let h = options.height
        this.sceneWidth = w; this.sceneHeight = h
        var app: ?Application = None
        let terminalFlag = [false]
        var terminalAfterSetup: () -> Unit = {=> ()}
        var terminalAfterAction: (Int64) -> Unit = {_ => ()}
        var root: ?Component = None
        var action: (Int64) -> Unit = {_ => ()}
        var setup: () -> Unit = {=> ()}
        var barrier: (Int64) -> Unit = {_ => ()}
        var correctness: (Int64) -> Unit = {_ => ()}
        var glyph: (Int64) -> GlyphMode = {_ => GlyphMode.Unicode}
        var viewportState: () -> ?ViewportSnapshot = {=> None}
        var liveLayers: () -> Int64 = {=> 0}
        var caretRecord: (CaretSnapshot, Int64, Int64, String) -> String = {caret, epoch, seed, stage =>
            if (caret.visible || caret.owner.isSome() || caret.x != 0 || caret.y != 0) {
                throw Exception("unexpected caret in ${name} epoch ${epoch}")
            }
            "${name},${seed},${epoch},${stage},none,false,0,0,false\n"
        }
        if (name == "initial" || name == "idle" || name == "resize_pair") {
            let scene = TextScene("vertical_panels", w, h)
            app = Some(scene.app); root = Some(scene.root)
        } else if (supportsTextScene(name)) {
            let scene = TextScene(name, w, h)
            app = Some(scene.app); root = Some(scene.root); action = {epoch => scene.app.batch({=> scene.action(epoch)})}
        } else if (["same_row_columns", "row_flex_width", "column_wrap_height", "batch_properties"].contains(name)) {
            let scene = LayoutScene(name, w, h)
            app = Some(scene.app); root = Some(scene.root); action = {epoch => scene.app.batch({=> scene.action(epoch)})}
        } else if (["typed_equal", "explicit_notify"].contains(name)) {
            let scene = ReactiveScene(name, w, h)
            app = Some(scene.app); root = Some(scene.root)
            action = {epoch =>
                if (name == "typed_equal") {
                    if (epoch % 2 == 1) {
                        scene.app.batch({=> scene.replaceWithEqual()})
                        if (!terminalFlag[0]) { scene.app.batch({=> scene.changeOldSource()}) }
                    } else { scene.app.batch({=> scene.restoreSource()}) }
                } else { scene.app.batch({=> scene.action(epoch)}) }
            }
            terminalAfterAction = {epoch =>
                if (name == "typed_equal" && epoch % 2 == 1) { scene.app.batch({=> scene.changeOldSource()}) }
            }
        } else if (["scroll_step", "scroll_multistep", "root_fallback", "large_mounted_viewport"].contains(name)) {
            let scene = ViewportScene(name, w, h)
            app = Some(scene.app); root = Some(scene.root); action = {epoch => scene.app.batch({=> scene.action(epoch)})}
            correctness = {epoch => scene.assertCommitted(epoch)}
            viewportState = {=> Some(scene.viewport.reference().getOrThrow().viewportSnapshot())}
        } else if (["caret_only", "readonly_focus_caret", "viewport_caret"].contains(name)) {
            let scene = CaretScene(name, w, h)
            app = Some(scene.app); root = Some(scene.root); setup = {=> scene.app.batch({=> scene.focusInitial()})}
            action = {epoch => scene.app.batch({=> scene.action(epoch)})}
            correctness = {epoch => scene.assertCommitted(epoch)}
            caretRecord = {caret, epoch, seed, stage => scene.describeCaret(caret, epoch, seed, stage)}
            if (name == "viewport_caret") {
                viewportState = {=> Some(scene.viewport.reference().getOrThrow().viewportSnapshot())}
            }
        } else if (["ellipsis_policy", "glyph_projection"].contains(name)) {
            let scene = GlyphScene(name, w, h)
            app = Some(scene.app); root = Some(scene.root); action = {epoch => scene.app.batch({=> scene.action(epoch)})}
            glyph = {epoch => scene.glyphMode(epoch)}
        } else if (["overlay_holes", "overlay_move", "overlay_shrink", "overlay_nested_close", "large_fill_shadows"].contains(name)) {
            let scene = OverlayScene(name, w, h)
            app = Some(scene.app); root = Some(scene.root)
            liveLayers = {=> scene.liveLayers()}
            setup = {=>
                scene.app.batch({=> scene.open()})
                if (name == "overlay_nested_close" && !terminalFlag[0]) { scene.app.batch({=> scene.openChild()}) }
            }
            action = {epoch =>
                scene.app.batch({=> scene.action(epoch)})
                if (name == "overlay_nested_close" && !terminalFlag[0]) {
                    if (epoch % 3 == 2) { scene.assertChildClosed() }
                    if (epoch % 3 == 0) { scene.app.batch({=> scene.openChild()}) }
                }
            }
            terminalAfterSetup = {=> if (name == "overlay_nested_close") { scene.app.batch({=> scene.openChild()}) }}
            terminalAfterAction = {epoch =>
                if (name == "overlay_nested_close" && epoch % 3 == 2) { scene.assertChildClosed() }
                if (name == "overlay_nested_close" && epoch % 3 == 0) { scene.app.batch({=> scene.openChild()}) }
            }
        } else if (["theme_color", "theme_spacing", "theme_four_sides", "theme_wrap"].contains(name)) {
            let scene = ThemeScene(name, w, h)
            let request: Array<?ThemeRequest> = [None]
            app = Some(scene.app); root = Some(scene.root)
            action = {epoch => request[0] = Some(scene.action(epoch))}
            barrier = {_ => if (let Some(value) <- request[0]) { scene.assertApplied(value) }}
        } else if (name == "keyed_manual") {
            let scene = KeyedScene(w, h)
            app = Some(scene.app); root = Some(scene.root); setup = {=> scene.app.batch({=> scene.insertSeparators()})}
            action = {epoch => scene.app.batch({=> scene.action(epoch)})}
        } else if (name == "posted_epoch") {
            let scene = PostedScene(w, h)
            app = Some(scene.app); root = Some(scene.root); action = {epoch => scene.enqueue(epoch)}
            barrier = {epoch => if (epoch > 0) { scene.assertCommitted(epoch) }}
        } else { throw Exception("workload ${name} is unsupported") }
        this.app = app.getOrThrow(); this.root = root.getOrThrow()
        this.action = action; this.setup = setup; this.afterSnapshot = barrier; this.assertCorrectness = correctness; this.glyph = glyph
        this.caretRecord = caretRecord; this.viewportState = viewportState; this.liveLayers = liveLayers
        this.terminalFlag = terminalFlag; this.terminalAfterSetup = terminalAfterSetup; this.terminalAfterAction = terminalAfterAction
    }

    public func enableTerminal(): Unit { terminalFlag[0] = true }
}
