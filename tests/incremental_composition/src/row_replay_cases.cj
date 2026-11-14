package incremental_composition

import cjtui.*

func rowReplay(): Unit {
    let epoch = [Int64(0)]; let value = Observable<String>("ABC")
    let left = DrawProbe("dirty-left",3,1); let middle = DrawProbe("clean-middle",2,1)
    let right = DrawProbe("clean-right",3,1); let other = DrawProbe("unrelated-row",8,1)
    let root = Column {
        Row {
            Canvas({_ => Size(3,1)},{p => left.record(p); p.put(0,0,value.get())}).width(3).height(1)
            Canvas({_ => Size(2,1)},{p => middle.record(p); p.put(0,0,"pq")}).width(2).height(1)
            Canvas({_ => Size(3,1)},{p => right.record(p); p.put(0,0,"RST")}).width(3).height(1)
        }.height(1)
        Canvas({_ => Size(8,1)},{p => other.record(p); p.put(0,0,"12345678")}).height(1)
    }.viewport(ScrollAxes.Off)
    let probes = [left,middle,right,other]
    let app = Application(root,theme:plainTheme()); app.startHeadless()
    try {
        paired(app,root,epoch,8,2,[row(["A","B","C","p","q","R","S","T"]),row(["1","2","3","4","5","6","7","8"])],probes,[1,1,1,1],"row initial")
        advance(app,epoch,{ => value.set("A") })
        paired(app,root,epoch,8,2,[row(["A"," "," ","p","q","R","S","T"]),row(["1","2","3","4","5","6","7","8"])],probes,[1,1,1,0],"short text replays clean same-row siblings")
        advance(app,epoch,{ => value.set("") })
        paired(app,root,epoch,8,2,[row([" "," "," ","p","q","R","S","T"]),row(["1","2","3","4","5","6","7","8"])],probes,[1,1,1,0],"empty text clears old paint")
        paired(app,root,epoch,8,2,[row([" "," "," ","p","q","R","S","T"]),row(["1","2","3","4","5","6","7","8"])],probes,[0,0,0,0],"stable target after M1")
    } finally { app.dispose() }
}

func movesAndRemoval(): Unit {
    let epoch = [Int64(0)]; let p = DrawProbe("moving-two-rows",4,2)
    let q = DrawProbe("middle",4,1); let r = DrawProbe("last",4,1)
    let holder = [Option<Component>.None]
    let root = Column {
        holder[0] = Some(Canvas({_ => Size(4,2)},{c => p.record(c); c.put(0,0,"AAAA"); c.put(0,1,"aaaa")}).height(2))
        Canvas({_ => Size(4,1)},{c => q.record(c); c.put(0,0,"BBBB")}).height(1)
        Canvas({_ => Size(4,1)},{c => r.record(c); c.put(0,0,"CCCC")}).height(1)
    }.viewport(ScrollAxes.Off)
    let moving = holder[0].getOrThrow()
    let app = Application(root,theme:plainTheme()); app.startHeadless()
    try {
        paired(app,root,epoch,4,4,[row(["A","A","A","A"]),row(["a","a","a","a"]),row(["B","B","B","B"]),row(["C","C","C","C"])],[p,q,r],[1,1,1],"move initial")
        let identity = node(moving)
        advance(app,epoch,{ => node(root).moveToEnd(identity) })
        paired(app,root,epoch,4,4,[row(["B","B","B","B"]),row(["C","C","C","C"]),row(["A","A","A","A"]),row(["a","a","a","a"])],[p,q,r],[1,1,1],"move uses old and new rows")
        Checks.equal(node(moving).sameNode(identity),"move retains identity")
        advance(app,epoch,{ => moving.visible(false) })
        paired(app,root,epoch,4,4,[row(["B","B","B","B"]),row(["C","C","C","C"]),row([" "," "," "," "]),row([" "," "," "," "])],[p,q,r],[0,0,0],"hidden old rows cleared")
        advance(app,epoch,{ => moving.visible(true) })
        paired(app,root,epoch,4,4,[row(["B","B","B","B"]),row(["C","C","C","C"]),row(["A","A","A","A"]),row(["a","a","a","a"])],[p,q,r],[1,0,0],"show restores current paint")
        advance(app,epoch,{ => node(root).remove(identity) })
        paired(app,root,epoch,4,4,[row(["B","B","B","B"]),row(["C","C","C","C"]),row([" "," "," "," "]),row([" "," "," "," "])],[p,q,r],[0,0,0],"unmount clears old rows")
        Checks.equal(!identity.isValid(),"damage tombstone does not keep removed identity alive")
    } finally { app.dispose() }
}
