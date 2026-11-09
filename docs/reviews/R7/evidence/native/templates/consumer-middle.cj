package native_probe
import native_adapter.countGraphemes
main(): Int64 {
 if (countGraphemes("中é👩‍💻❤️🇨🇳") != 5) { return 1 }
 println("PASS transitive FFI through intermediate static adapter")
 return 0
}

// Recompile consumer to verify adapter-owned ffi flags.
