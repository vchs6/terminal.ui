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
    var value: RichText
    let descriptionId = uniqueRuntimeId()
    let declarations = ArrayList<ChildDeclaration>()
    func nonnegative(v: Int64): Unit {
        if (v < 0) {
            throw IllegalArgumentException("negative layout value")
        }
    }
    var styleDeclaration = StyleRule()
    var styleUses = Array<StyleUse>()
    var styleStates = VisualStates()
    var styleRole = ThemeRole.Generic
    var paddingBindLeft = false
    var paddingBindTop = false
    var paddingBindRight = false
    var paddingBindBottom = false
    func detachPaddingSlot(name: String, state: VisualState): Unit {
        if (state != VisualState.Normal) { return }
        match (name) {
            case "paddingLeft" => paddingBindLeft = false
            case "paddingTop" => paddingBindTop = false
            case "paddingRight" => paddingBindRight = false
            case "paddingBottom" => paddingBindBottom = false
            case _ => return
        }
        if (!paddingBindLeft && !paddingBindTop && !paddingBindRight && !paddingBindBottom) { removeBinding("padding") }
    }
    func slotName<T>(key: StyleKey<T>, state: VisualState): String {
        let suffix = match (state) { case VisualState.Normal => "normal"; case VisualState.Focused => "focused"; case VisualState.Selected => "selected"; case VisualState.Disabled => "disabled" }
        "style:" + key.name + ":" + suffix
    }
    func styleChange(name: String): ChangeKind {
        if (name == "width" || name == "height" || name == "minWidth" || name == "minHeight" ||
            name == "layoutWeight" || name == "paddingLeft" || name == "paddingTop" || name == "paddingRight" ||
            name == "paddingBottom" || name == "gap" || name == "alignItems" || name == "justifyContent" ||
            name == "border" || name == "textWrap") { ChangeKind.Layout } else { ChangeKind.Style }
    }
    func declarationChange(name: String, old: StyleRule, next: StyleRule, state: VisualState): ChangeKind {
        if (name == "border") {
            let before = old.value(StyleKeys.border,state:state)
            let after = next.value(StyleKeys.border,state:state)
            match ((before,after)) {
                case (StyleValue.Value(a),StyleValue.Value(b)) =>
                    if ((a == BorderStyle.None) == (b == BorderStyle.None)) { return ChangeKind.Style }
                case _ => ()
            }
        }
        styleChange(name)
    }
    func checkStyleTarget(name: String): Unit {
        let textOnly = name == "textAlign" || name == "textWrap" || name == "textOverflow"
        let containerOnly = name == "gap" || name == "alignItems" || name == "justifyContent"
        if ((textOnly && kind != 0) || (containerOnly && kind == 0)) {
            throw UIException("InvalidProperty", "style key is not supported by this primitive")
        }
    }
    func applyStyle<T>(key: StyleKey<T>, value: StyleValue<T>, state: VisualState): Unit {
        let next = styleDeclaration.withValue(key,value,state:state)
        if (next != styleDeclaration) {
            let change = declarationChange(key.name,styleDeclaration,next,state)
            styleDeclaration = next; markChanged(change)
        }
    }
    public func setStyle<T>(key: StyleKey<T>, value: StyleValue<T>, state!: VisualState = VisualState.Normal): Component {
        checkStyleTarget(key.name)
        let next = styleDeclaration.withValue(key,value,state:state)
        detachPaddingSlot(key.name,state); removeBinding(slotName(key,state))
        if (next != styleDeclaration) {
            let change = declarationChange(key.name,styleDeclaration,next,state)
            styleDeclaration = next; markChanged(change)
        }
        this
    }
    public func setStyle<T>(key: StyleKey<T>, value: () -> StyleValue<T>, state!: VisualState = VisualState.Normal): Component {
        checkStyleTarget(key.name); detachPaddingSlot(key.name,state)
        bind(slotName(key,state),styleChange(key.name),{=> applyStyle(key,value(),state)})
    }
    public func styles(value: Array<StyleUse>): Component {
        removeBinding("styles"); applyStyles(value); this
    }
    func applyStyles(value: Array<StyleUse>): Unit {
        var same = value.size == styleUses.size
        if (same) { for (i in 0..value.size) { if (value[i] != styleUses[i]) { same = false; break } } }
        if (!same) { styleUses = value.clone(); markChanged(ChangeKind.Layout) }
    }
    public func styles(value: () -> Array<StyleUse>): Component { bind("styles",ChangeKind.Layout,{=>applyStyles(value())}) }
    public func visualStates(value: VisualStates): Component {
        removeBinding("visualStates"); applyStates(value); this
    }
    func applyStates(value: VisualStates): Unit {
        if (styleStates != value) { styleStates = value; markChanged(ChangeKind.Layout) }
    }
    public func visualStates(value: () -> VisualStates): Component { bind("visualStates",ChangeKind.Layout,{=>applyStates(value())}) }
    public func themeRole(value: ThemeRole): Component {
        checkDefinitionChange()
        mountLock.lock()
        try {
            if (everMounted || mounted.isSome() || mounting) { throw UIException("InvalidProperty","role is immutable after mounting") }
            styleRole = value
        } finally { mountLock.unlock() }
        this
    }
    public func width(v: Int64): Component { setStyle(StyleKeys.width,StyleValue<Dimension>.Value(Dimension.Cells(v))) }
    public func height(v: Int64): Component { setStyle(StyleKeys.height,StyleValue<Dimension>.Value(Dimension.Cells(v))) }
    public func widthAuto(): Component { setStyle(StyleKeys.width,StyleValue<Dimension>.Unset) }
    public func heightAuto(): Component { setStyle(StyleKeys.height,StyleValue<Dimension>.Unset) }
    public func minWidth(v: Int64): Component { setStyle(StyleKeys.minWidth,StyleValue<Int64>.Value(v)) }
    public func minHeight(v: Int64): Component { setStyle(StyleKeys.minHeight,StyleValue<Int64>.Value(v)) }
    public func layoutWeight(v: Int64): Component { setStyle(StyleKeys.layoutWeight,StyleValue<Int64>.Value(v)) }
    public func padding(v: Int64): Component { padding(left:v,top:v,right:v,bottom:v) }
    public func padding(left!: Int64 = 0,top!: Int64 = 0,right!: Int64 = 0,bottom!: Int64 = 0): Component {
        nonnegative(left); nonnegative(top); nonnegative(right); nonnegative(bottom)
        removeBinding("padding")
        setStyle(StyleKeys.paddingLeft,StyleValue<Int64>.Value(left))
        setStyle(StyleKeys.paddingTop,StyleValue<Int64>.Value(top))
        setStyle(StyleKeys.paddingRight,StyleValue<Int64>.Value(right))
        setStyle(StyleKeys.paddingBottom,StyleValue<Int64>.Value(bottom)); this
    }
    public func gap(v: Int64): Component {
        if (kind == 0) { throw IllegalArgumentException("gap on text") }
        setStyle(StyleKeys.gap,StyleValue<Int64>.Value(v))
    }
    public func alignItems(v: Alignment): Component {
        if (kind == 0) { throw IllegalArgumentException("alignment on text") }
        setStyle(StyleKeys.alignItems,StyleValue<Alignment>.Value(v))
    }
    public func justifyContent(v: Alignment): Component {
        if (kind == 0) { throw IllegalArgumentException("justification on text") }
        setStyle(StyleKeys.justifyContent,StyleValue<Alignment>.Value(v))
    }
    public func textAlign(v: Alignment): Component {
        if (kind != 0) { throw IllegalArgumentException("invalid text alignment") }
        setStyle(StyleKeys.textAlign,StyleValue<Alignment>.Value(v))
    }
    public func wrap(value: TextWrap): Component { setStyle(StyleKeys.textWrap,StyleValue<TextWrap>.Value(value)) }
    public func wrap(value: () -> TextWrap): Component { setStyle(StyleKeys.textWrap,{=> StyleValue<TextWrap>.Value(value())}) }
    public func overflow(value: TextOverflow): Component { setStyle(StyleKeys.textOverflow,StyleValue<TextOverflow>.Value(value)) }
    public func overflow(value: () -> TextOverflow): Component { setStyle(StyleKeys.textOverflow,{=> StyleValue<TextOverflow>.Value(value())}) }
    public init() { this.kind = 1; this.value = RichText("") }
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
        this.styleRole = if (kind == 0) { ThemeRole.Text } else if (kind == 1) { ThemeRole.Column } else { ThemeRole.Row }
        this.value = RichText(value)
    }
    public func border(value: BorderStyle): Component { setStyle(StyleKeys.border,StyleValue<BorderStyle>.Value(value)) }
    public func borderColor(value: Color): Component { setStyle(StyleKeys.borderForeground,StyleValue<Color>.Value(value)) }
    public func shadow(offsetX!: Int64 = 1, offsetY!: Int64 = 1, style!: Style = Style(), enabled!: Bool = true): Component {
        setStyle(StyleKeys.shadowOffsetX,StyleValue<Int64>.Value(offsetX))
        setStyle(StyleKeys.shadowOffsetY,StyleValue<Int64>.Value(offsetY))
        setStyle(StyleKeys.shadowEnabled,StyleValue<Bool>.Value(enabled))
        setStyle(StyleKeys.shadowForeground,StyleValue<Color>.Value(style.foreground))
        setStyle(StyleKeys.shadowBackground,StyleValue<Color>.Value(style.background))
        setStyle(StyleKeys.shadowBold,StyleValue<Bool>.Value(style.bold))
        setStyle(StyleKeys.shadowDim,StyleValue<Bool>.Value(style.dim))
        setStyle(StyleKeys.shadowItalic,StyleValue<Bool>.Value(style.italic))
        setStyle(StyleKeys.shadowUnderline,StyleValue<Bool>.Value(style.underline))
        setStyle(StyleKeys.shadowInverse,StyleValue<Bool>.Value(style.inverse))
        setStyle(StyleKeys.shadowStrikethrough,StyleValue<Bool>.Value(style.strikethrough))
        this
    }
    public func foreground(value: Color): Component { setStyle(StyleKeys.foreground,StyleValue<Color>.Value(value)) }
    public func background(value: Color): Component { setStyle(StyleKeys.background,StyleValue<Color>.Value(value)) }
    public func bold(): Component { bold(true) }
    public func bold(value: Bool): Component { setStyle(StyleKeys.bold,StyleValue<Bool>.Value(value)) }
    public func dim(): Component { dim(true) }
    public func dim(value: Bool): Component { setStyle(StyleKeys.dim,StyleValue<Bool>.Value(value)) }
    public func italic(): Component { italic(true) }
    public func italic(value: Bool): Component { setStyle(StyleKeys.italic,StyleValue<Bool>.Value(value)) }
    public func underline(): Component { underline(true) }
    public func underline(value: Bool): Component { setStyle(StyleKeys.underline,StyleValue<Bool>.Value(value)) }
    public func inverse(): Component { inverse(true) }
    public func inverse(value: Bool): Component { setStyle(StyleKeys.inverse,StyleValue<Bool>.Value(value)) }
    public func strikethrough(): Component { strikethrough(true) }
    public func strikethrough(value: Bool): Component { setStyle(StyleKeys.strikethrough,StyleValue<Bool>.Value(value)) }
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
    func markChanged(change: ChangeKind): Unit {
        if (let Some(node) <- readMount()) { node.session.markChanged(node, change) }
    }
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
    public func visible(value: Bool): Component { removeBinding("visible"); isVisible = value; markChanged(ChangeKind.Layout); this }
    public func visible(value: () -> Bool): Component {
        bind("visible", ChangeKind.Layout, { => let next = value(); if (isVisible != next) { isVisible = next; markChanged(ChangeKind.Layout) } })
    }
    public func text(value: String): Component {
        text(RichText(value))
    }
    public func text(value: () -> String): Component {
        if (kind != 0) {
            throw UIException("InvalidProperty", "text applies only to Text")
        }
        bind("text", ChangeKind.Content, {=> updateText(RichText(value()))})
    }
    public func text(value: RichText): Component {
        if (kind != 0) {
            throw UIException("InvalidProperty", "text applies only to Text")
        }
        removeBinding("text")
        updateText(value)
        this
    }
    public func text(value: () -> RichText): Component {
        if (kind != 0) {
            throw UIException("InvalidProperty", "text applies only to Text")
        }
        bind("text", ChangeKind.Content, {=> updateText(value())})
    }
    private func updateText(next: RichText): Unit {
        if (this.value == next) {
            return
        }
        let change = if (this.value.toPlainText() == next.toPlainText()) {
            ChangeKind.Style
        } else {
            ChangeKind.Content
        }
        this.value = next
        markChanged(change)
    }
    public func width(value: () -> Int64): Component { setStyle(StyleKeys.width,{=> StyleValue<Dimension>.Value(Dimension.Cells(value()))}) }
    public func height(value: () -> Int64): Component { setStyle(StyleKeys.height,{=> StyleValue<Dimension>.Value(Dimension.Cells(value()))}) }
    public func minWidth(value: () -> Int64): Component { setStyle(StyleKeys.minWidth,{=> StyleValue<Int64>.Value(value())}) }
    public func minHeight(value: () -> Int64): Component { setStyle(StyleKeys.minHeight,{=> StyleValue<Int64>.Value(value())}) }
    public func layoutWeight(value: () -> Int64): Component { setStyle(StyleKeys.layoutWeight,{=> StyleValue<Int64>.Value(value())}) }
    public func gap(value: () -> Int64): Component { setStyle(StyleKeys.gap,{=> StyleValue<Int64>.Value(value())}) }
    public func alignItems(value: () -> Alignment): Component { setStyle(StyleKeys.alignItems,{=> StyleValue<Alignment>.Value(value())}) }
    public func justifyContent(value: () -> Alignment): Component { setStyle(StyleKeys.justifyContent,{=> StyleValue<Alignment>.Value(value())}) }
    public func textAlign(value: () -> Alignment): Component { setStyle(StyleKeys.textAlign,{=> StyleValue<Alignment>.Value(value())}) }
    public func border(value: () -> BorderStyle): Component { setStyle(StyleKeys.border,{=> StyleValue<BorderStyle>.Value(value())}) }
    public func borderColor(value: () -> Color): Component { setStyle(StyleKeys.borderForeground,{=> StyleValue<Color>.Value(value())}) }
    public func foreground(value: () -> Color): Component { setStyle(StyleKeys.foreground,{=> StyleValue<Color>.Value(value())}) }
    public func background(value: () -> Color): Component { setStyle(StyleKeys.background,{=> StyleValue<Color>.Value(value())}) }
    public func bold(value: () -> Bool): Component { setStyle(StyleKeys.bold,{=> StyleValue<Bool>.Value(value())}) }
    public func dim(value: () -> Bool): Component { setStyle(StyleKeys.dim,{=> StyleValue<Bool>.Value(value())}) }
    public func italic(value: () -> Bool): Component { setStyle(StyleKeys.italic,{=> StyleValue<Bool>.Value(value())}) }
    public func underline(value: () -> Bool): Component { setStyle(StyleKeys.underline,{=> StyleValue<Bool>.Value(value())}) }
    public func inverse(value: () -> Bool): Component { setStyle(StyleKeys.inverse,{=> StyleValue<Bool>.Value(value())}) }
    public func strikethrough(value: () -> Bool): Component { setStyle(StyleKeys.strikethrough,{=> StyleValue<Bool>.Value(value())}) }
    public func padding(value: () -> Int64): Component {
        checkDefinitionChange()
        removeBinding(slotName(StyleKeys.paddingLeft,VisualState.Normal))
        removeBinding(slotName(StyleKeys.paddingTop,VisualState.Normal))
        removeBinding(slotName(StyleKeys.paddingRight,VisualState.Normal))
        removeBinding(slotName(StyleKeys.paddingBottom,VisualState.Normal))
        paddingBindLeft = true; paddingBindTop = true; paddingBindRight = true; paddingBindBottom = true
        bind("padding",ChangeKind.Layout,{=>
            let next = value(); nonnegative(next)
            if (paddingBindLeft) { applyStyle(StyleKeys.paddingLeft,StyleValue<Int64>.Value(next),VisualState.Normal) }
            if (paddingBindTop) { applyStyle(StyleKeys.paddingTop,StyleValue<Int64>.Value(next),VisualState.Normal) }
            if (paddingBindRight) { applyStyle(StyleKeys.paddingRight,StyleValue<Int64>.Value(next),VisualState.Normal) }
            if (paddingBindBottom) { applyStyle(StyleKeys.paddingBottom,StyleValue<Int64>.Value(next),VisualState.Normal) }
        })
    }

}

public func Text(value: String): Component {
    let c = Component(0, value);
    attach(c);
    c
}

public func Text(value: () -> String): Component {
    let c = Component(0, "");
    c.text(value);
    attach(c);
    c
}

public func Text(value: RichText): Component {
    let c = Component(0, "");
    c.text(value);
    attach(c);
    c
}

public func Text(value: () -> RichText): Component {
    let c = Component(0, "");
    c.text(value);
    attach(c);
    c
}

func container(kind: Int64, body: () -> Unit): Component {
    let c = Component(kind, "")
    collectChildren(c, body)
    attach(c)
    c
}
public func Column(body: () -> Unit): Component { container(1, body) }
public func Row(body: () -> Unit): Component { container(2, body) }
