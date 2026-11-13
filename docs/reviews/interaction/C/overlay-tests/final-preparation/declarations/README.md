# NOT_EXECUTED LANGUAGE_ONLY declaration microcompile

This isolated package imports the real fixed620 cjtui NodeRef/Component.
The language_only namespace is never cjtui, never imported by interaction_c,
and never added to product dependencies. The separate static consumer checks
cross-package visibility, the exact enums/fields/defaults/overload signatures
and return types. It has no main or executable invocation.

Component/NodeRef members are declaration projections on abstract receivers;
OverlayHandle is abstract solely to express body-free member declarations.
This is not a concrete public product class or proof that C is implemented.
OverlayOptions needs an initializer body to assign its public immutable
value fields; it is NOT_EXECUTED. SDK1.2 rejected a default parameter on the
abstract openOverlay member, so only that signature has a throw-only sentinel
body on its still-abstract receiver. It defines no overlay behavior and is
NOT_EXECUTED. Other overlay methods remain body-free declarations. All public class/struct/enum entities have their own files.

Source SDK1.2 environment, then `bash declarations/run.sh` (normal cjpm build,
static outputs only). The own target reuses compiled fixed620 dependencies
in this preparation's existing target; no SDK/cache/target copy is made.
The original prep manifest/report and missing-C126 evidence are unchanged.
