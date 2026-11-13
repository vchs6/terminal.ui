package cjtui

enum ChildEntry {
    | MountedChild(RuntimeNode)
    | GroupMarker(DynamicGroup)
}
