package cjtui

public func Progress(fraction: Float64): Component {
    Progress({=> fraction})
}

public func Progress(fraction: () -> Float64): Component {
    Canvas(
        {constraints => constraints.constrain(Size(20, 1))},
        {
            context =>
                let value = fraction()
                if (value.isNaN() || value.isInf() || value < 0.0 || value > 1.0) {
                    throw UIException("InvalidProperty", "progress fraction must be finite and between zero and one")
                }
                let width = context.size.width
                let height = context.size.height
                if (width > 0 && height > 0) {
                    let filled = Int64(value * Float64(width))
                    for (x in 0..width) {
                        context.put(x, 0, if (x < filled) {
                            "="
                        } else {
                            "-"
                        })
                    }
                }
        }
    ).themeRole(ThemeRole.Progress)
}
