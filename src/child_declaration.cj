package cjtui

// Immutable construction descriptions. Live ordering belongs to RuntimeNode.sequence.
enum ChildDeclaration {
    | DeclaredComponent(Component)
    | DeclaredGroup(DynamicDeclaration)
}
