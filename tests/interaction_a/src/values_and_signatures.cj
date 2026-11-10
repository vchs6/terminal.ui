package interaction_a_contract
import cjtui.*
func valuesAndSignatures(): Unit {
    let c = Constraints(minWidth: 2, minHeight: 1, maxWidth: Some(4), maxHeight: Some(3), ambiguousWide: false)
    check(c.minWidth == 2 && c.minHeight == 1 && c.maxWidth == Some(4) && c.maxHeight == Some(3) && !c.ambiguousWide,
        "immutable constraint fields")
    let s = c.constrain(Size(8,0))
    check(s.width == 4 && s.height == 1, "constrain each axis")
    let unbounded = Constraints()
    check(unbounded.maxWidth.isNone() && unbounded.maxHeight.isNone(), "None is measurement-only unbounded")
    check(c.textWidth("é界") == 3 && Constraints(ambiguousWide: true).textWidth("·") == 2,
        "same Unicode width policy")
    illegal({ => Size(-1,0); () }); illegal({ => Size(0,-1); () })
    illegal({ => Constraints(minWidth: -1); () }); illegal({ => Constraints(minHeight: -1); () })
    illegal({ => Constraints(maxWidth: Some(-1)); () }); illegal({ => Constraints(maxHeight: Some(-1)); () })
    illegal({ => Constraints(minWidth: 2,maxWidth: Some(1)); () })
    illegal({ => Constraints(minHeight: 2,maxHeight: Some(1)); () })
    for (build in [
        { => Canvas({ _ => Size(1,1) },{ _ => }).gap(1) },
        { => Canvas({ _ => Size(1,1) },{ _ => }).alignItems(Alignment.Start) },
        { => Canvas({ _ => Size(1,1) },{ _ => }).justifyContent(Alignment.Start) },
        { => Canvas({ _ => Size(1,1) },{ _ => }).wrap(TextWrap.Grapheme) },
        { => Canvas({ _ => Size(1,1) },{ _ => }).overflow(TextOverflow.Ellipsis) },
        { => Canvas({ _ => Size(1,1) },{ _ => }).textAlign(Alignment.Start) }
    ]) { code("InvalidProperty", { => render(build(),2,1); () }) }
}
