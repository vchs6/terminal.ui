package cjtui

import std.collection.ArrayList
import std.sync.Mutex

public open class Component {
    let mountLock = Mutex()
    var mounting = false
    var constructionFinished = false
    var everMounted = false
    var built = false
    var failed = false
    var mounted: ?RuntimeNode = None
    var explicitKey: ?String = None
    let bindings = ArrayList<Binding>()
    var mountEffect: ?(NodeRef) -> (() -> Unit) = None
    var keyHandler: ?(UIKeyEvent) -> Unit = None
    var captureHandler: ?(UIKeyEvent) -> Unit = None
    var isVisible = true
    let kind: Int64
    var value: String
    let children = ArrayList<Component>()
    var fg: ?Color = None
    var bg: ?Color = None
    var isBold: ?Bool = None
    var isDim: ?Bool = None
    var isItalic: ?Bool = None
    var isUnderline: ?Bool = None
    var isInverse: ?Bool = None
    var isStrikethrough: ?Bool = None
    var fixedW: ?Int64 = None
    var fixedH: ?Int64 = None
    var minW: Int64 = 0
    var minH: Int64 = 0
    var weight: Int64 = 0
    var borderStyle: BorderStyle = BorderStyle.None
    var borderFg: ?Color = None
    var shadowEnabled = false
    var shadowX: Int64 = 1
    var shadowY: Int64 = 1
    var shadowStyle = Style()
    var pad: Int64 = 0
    var spacing: Int64 = 0
    var align: Alignment = Alignment.Start
    var justify: Alignment = Alignment.Start
    var textAlignment: Alignment = Alignment.Start
    func nonnegative(v: Int64): Unit {
        if (v < 0) {
            throw IllegalArgumentException("negative layout value")
        }
    }
    public func width(v: Int64): Component {
        checkDefinitionChange()
        nonnegative(v)
        removeBinding("width")
        markChanged()
        fixedW = v
        this
    }
    public func height(v: Int64): Component {
        checkDefinitionChange()
        nonnegative(v)
        removeBinding("height")
        markChanged()
        fixedH = v
        this
    }
    public func widthAuto(): Component {
        removeBinding("width"); markChanged()
        fixedW = None
        this
    }
    public func heightAuto(): Component {
        removeBinding("height"); markChanged()
        fixedH = None
        this
    }
    public func minWidth(v: Int64): Component {
        checkDefinitionChange()
        nonnegative(v)
        removeBinding("minWidth")
        markChanged()
        minW = v
        this
    }
    public func minHeight(v: Int64): Component {
        checkDefinitionChange()
        nonnegative(v)
        removeBinding("minHeight")
        markChanged()
        minH = v
        this
    }
    public func layoutWeight(v: Int64): Component {
        checkDefinitionChange()
        nonnegative(v)
        removeBinding("layoutWeight")
        markChanged()
        weight = v
        this
    }
    public func padding(v: Int64): Component {
        checkDefinitionChange()
        nonnegative(v)
        removeBinding("padding")
        markChanged()
        pad = v
        this
    }
    public func gap(v: Int64): Component {
        checkDefinitionChange()
        nonnegative(v);
        if (kind == 0) {
            throw IllegalArgumentException("gap on text")
        };
        removeBinding("gap")
        markChanged()
        spacing = v
        this
    }
    public func alignItems(v: Alignment): Component {
        checkDefinitionChange()
        if (kind == 0) {
            throw IllegalArgumentException("alignment on text")
        };
        removeBinding("alignItems")
        markChanged()
        align = v
        this
    }
    public func justifyContent(v: Alignment): Component {
        checkDefinitionChange()
        if (kind == 0 || v == Alignment.Stretch) {
            throw IllegalArgumentException("invalid justification")
        };
        removeBinding("justifyContent")
        markChanged()
        justify = v
        this
    }
    public func textAlign(v: Alignment): Component {
        checkDefinitionChange()
        if (kind != 0 || v == Alignment.Stretch) {
            throw IllegalArgumentException("invalid text alignment")
        };
        removeBinding("textAlign")
        markChanged()
        textAlignment = v
        this
    }
    public init() { this.kind = 1; this.value = "" }
    public open func build(): Unit {}
    protected func finishConstruction(): Unit {
        if (constructionFinished) { throw UIException("ConstructionAlreadyFinished", "construction already finished") }
        constructionFinished = true
        attach(this)
    }
    func readMount(): ?RuntimeNode {
        mountLock.lock()
        try { mounted } finally { mountLock.unlock() }
    }
    public func reference(): ?NodeRef {
        match (readMount()) {
            case Some(node) =>
                if (node.session.temporary) { None } else { node.session.requireContext(); Some(node.reference()) }
            case None => None
        }
    }
    public func key(value: String): Component {
        checkDefinitionChange()
        if (value.isEmpty()) { throw UIException("InvalidKey", "key cannot be empty") }
        mountLock.lock()
        try {
            if (everMounted || mounted.isSome() || mounting) { throw UIException("InvalidKey", "key is immutable after mounting") }
            explicitKey = Some(value)
        } finally { mountLock.unlock() }
        this
    }
    func reserveMount(): Unit {
        mountLock.lock()
        try {
            if (mounted.isSome() || mounting) { throw UIException("AlreadyMounted", "component already mounted") }
            if (failed) { throw UIException("ConstructionFailed", "component construction failed") }
            mounting = true
        } finally { mountLock.unlock() }
    }
    func publishMount(node: RuntimeNode, temporary: Bool): Unit {
        mountLock.lock()
        try { mounted = Some(node); if (!temporary) { everMounted = true } } finally { mountLock.unlock() }
    }
    func releaseMount(): Unit { mountLock.lock(); try { mounting = false } finally { mountLock.unlock() } }
    func clearMount(): Unit { mountLock.lock(); try { mounted = None; mounting = true } finally { mountLock.unlock() } }
    func checkDefinitionChange(): Unit {
        if (evaluating.get().isSome()) { throw UIException("ReentrantEvaluation", "component mutation during evaluation") }
        if (let Some(node) <- readMount()) { node.session.requireContext() }
    }
    public func onMount(effect: (NodeRef) -> (() -> Unit)): Component { checkDefinitionChange(); mountEffect = Some(effect); this }
    public func onKey(handler: (UIKeyEvent) -> Unit): Component { checkDefinitionChange(); keyHandler = Some(handler); this }
    public func onKeyCapture(handler: (UIKeyEvent) -> Unit): Component { checkDefinitionChange(); captureHandler = Some(handler); this }
    init(kind: Int64, value: String) {
        this.kind = kind
        this.value = value
    }
    public func border(value: BorderStyle): Component {
        removeBinding("border")
        markChanged()
        borderStyle = value
        this
    }
    public func borderColor(value: Color): Component {
        removeBinding("borderColor")
        markChanged()
        borderFg = value
        this
    }
    public func shadow(offsetX!: Int64 = 1, offsetY!: Int64 = 1, style!: Style = Style(), enabled!: Bool = true): Component {
        removeBinding("shadow"); markChanged()
        shadowX = offsetX
        shadowY = offsetY
        shadowStyle = style
        shadowEnabled = enabled
        this
    }
    public func foreground(value: Color): Component {
        removeBinding("foreground")
        markChanged()
        fg = value
        this
    }
    public func background(value: Color): Component {
        removeBinding("background")
        markChanged()
        bg = value
        this
    }
    public func bold(): Component {
        bold(true)
    }
    public func bold(value: Bool): Component {
        removeBinding("bold")
        markChanged()
        isBold = value
        this
    }
    public func dim(): Component {
        dim(true)
    }
    public func dim(value: Bool): Component {
        removeBinding("dim")
        markChanged()
        isDim = value
        this
    }
    public func italic(): Component {
        italic(true)
    }
    public func italic(value: Bool): Component {
        removeBinding("italic")
        markChanged()
        isItalic = value
        this
    }
    public func underline(): Component {
        underline(true)
    }
    public func underline(value: Bool): Component {
        removeBinding("underline")
        markChanged()
        isUnderline = value
        this
    }
    public func inverse(): Component {
        inverse(true)
    }
    public func inverse(value: Bool): Component {
        removeBinding("inverse")
        markChanged()
        isInverse = value
        this
    }
    public func strikethrough(): Component {
        strikethrough(true)
    }
    public func strikethrough(value: Bool): Component {
        removeBinding("strikethrough")
        markChanged()
        isStrikethrough = value
        this
    }
    func removeBinding(name: String): Unit {
        checkDefinitionChange()
        var index: Int64 = 0
        while (index < bindings.size) {
            if (bindings[index].name == name) {
                let old = bindings[index]
                if (let Some(node) <- readMount()) { node.session.removeBinding(old) } else { old.dispose() }
                if (let Some(node) <- readMount()) {
                    node.session.lock.lock()
                    try { bindings.remove(at: index) } finally { node.session.lock.unlock() }
                } else { bindings.remove(at: index) }
            } else { index++ }
        }
    }
    func markChanged(): Unit { if (let Some(node) <- readMount()) { node.session.markChanged() } }
    func bind(name: String, category: ChangeKind, getter: () -> Unit): Component {
        checkDefinitionChange()
        if (let Some(node) <- readMount()) {
            var replacing = false
            for (existing in bindings) { if (existing.name == name) { replacing = true } }
            if (!replacing && bindings.size >= node.session.limits.bindingsPerNode) {
                throw UIException("CapacityExceeded", "binding limit exceeded")
            }
        }
        removeBinding(name)
        let binding = Binding(this, name, category, getter)
        if (let Some(node) <- readMount()) {
            node.session.lock.lock()
            try { bindings.add(binding) } finally { node.session.lock.unlock() }
            node.session.addBinding(binding)
        } else { bindings.add(binding) }
        this
    }
    public func visible(value: Bool): Component { removeBinding("visible"); isVisible = value; markChanged(); this }
    public func visible(value: () -> Bool): Component {
        bind("visible", ChangeKind.Layout, { => let next = value(); if (isVisible != next) { isVisible = next; markChanged() } })
    }
    public func text(value: String): Component {
        if (kind != 0) { throw UIException("InvalidProperty", "text applies only to Text") }
        removeBinding("text"); this.value = value; markChanged(); this
    }
    public func text(value: () -> String): Component {
        if (kind != 0) { throw UIException("InvalidProperty", "text applies only to Text") }
        bind("text", ChangeKind.Content, { => let next = value(); if (this.value != next) { this.value = next; markChanged() } })
    }
    public func width(value: () -> Int64): Component {
        bind("width", ChangeKind.Layout, { => let next = value(); nonnegative(next); if (fixedW != next) { fixedW = next; markChanged() } })
    }
    public func height(value: () -> Int64): Component {
        bind("height", ChangeKind.Layout, { => let next = value(); nonnegative(next); if (fixedH != next) { fixedH = next; markChanged() } })
    }
    public func minWidth(value: () -> Int64): Component {
        bind("minWidth", ChangeKind.Layout, { => let next = value(); nonnegative(next); if (minW != next) { minW = next; markChanged() } })
    }
    public func minHeight(value: () -> Int64): Component {
        bind("minHeight", ChangeKind.Layout, { => let next = value(); nonnegative(next); if (minH != next) { minH = next; markChanged() } })
    }
    public func layoutWeight(value: () -> Int64): Component {
        bind("layoutWeight", ChangeKind.Layout, { => let next = value(); nonnegative(next); if (weight != next) { weight = next; markChanged() } })
    }
    public func padding(value: () -> Int64): Component {
        bind("padding", ChangeKind.Layout, { => let next = value(); nonnegative(next); if (pad != next) { pad = next; markChanged() } })
    }
    public func gap(value: () -> Int64): Component {
        bind("gap", ChangeKind.Layout, { => let next = value(); nonnegative(next); if (kind == 0) { throw IllegalArgumentException("gap on text") }; if (spacing != next) { spacing = next; markChanged() } })
    }
    public func alignItems(value: () -> Alignment): Component {
        bind("alignItems", ChangeKind.Layout, { => let next = value(); if (kind == 0) { throw IllegalArgumentException("alignment on text") }; if (align != next) { align = next; markChanged() } })
    }
    public func justifyContent(value: () -> Alignment): Component {
        bind("justifyContent", ChangeKind.Layout, { => let next = value(); if (kind == 0 || next == Alignment.Stretch) { throw IllegalArgumentException("invalid justification") }; if (justify != next) { justify = next; markChanged() } })
    }
    public func textAlign(value: () -> Alignment): Component {
        bind("textAlign", ChangeKind.Layout, { => let next = value(); if (kind != 0 || next == Alignment.Stretch) { throw IllegalArgumentException("invalid text alignment") }; if (textAlignment != next) { textAlignment = next; markChanged() } })
    }
    public func border(value: () -> BorderStyle): Component {
        bind("border", ChangeKind.Layout, { => let next = value(); if (borderStyle != next) { borderStyle = next; markChanged() } })
    }
    public func borderColor(value: () -> Color): Component {
        bind("borderColor", ChangeKind.Style, { => let next = value(); if (borderFg != next) { borderFg = next; markChanged() } })
    }
    public func foreground(value: () -> Color): Component {
        bind("foreground", ChangeKind.Style, { => let next = value(); if (fg != next) { fg = next; markChanged() } })
    }
    public func background(value: () -> Color): Component {
        bind("background", ChangeKind.Style, { => let next = value(); if (bg != next) { bg = next; markChanged() } })
    }
    public func bold(value: () -> Bool): Component {
        bind("bold", ChangeKind.Style, { => let next = value(); if (isBold != next) { isBold = next; markChanged() } })
    }
    public func dim(value: () -> Bool): Component {
        bind("dim", ChangeKind.Style, { => let next = value(); if (isDim != next) { isDim = next; markChanged() } })
    }
    public func italic(value: () -> Bool): Component {
        bind("italic", ChangeKind.Style, { => let next = value(); if (isItalic != next) { isItalic = next; markChanged() } })
    }
    public func underline(value: () -> Bool): Component {
        bind("underline", ChangeKind.Style, { => let next = value(); if (isUnderline != next) { isUnderline = next; markChanged() } })
    }
    public func inverse(value: () -> Bool): Component {
        bind("inverse", ChangeKind.Style, { => let next = value(); if (isInverse != next) { isInverse = next; markChanged() } })
    }
    public func strikethrough(value: () -> Bool): Component {
        bind("strikethrough", ChangeKind.Style, { => let next = value(); if (isStrikethrough != next) { isStrikethrough = next; markChanged() } })
    }
}

public func Text(value: String): Component {
    let c = Component(0, value); attach(c); c
}
public func Text(value: () -> String): Component {
    let c = Component(0, ""); c.text(value); attach(c); c
}
func container(kind: Int64, body: () -> Unit): Component {
    let c = Component(kind, "")
    collectChildren(c, body)
    attach(c)
    c
}
public func Column(body: () -> Unit): Component { container(1, body) }
public func Row(body: () -> Unit): Component { container(2, body) }
