# Minimal application

With Cangjie SDK 1.2.0 and the cjtui dependencies available, run `cjpm build` in this directory, then `target/release/bin/main` in a terminal. Press `q` to quit. The application uses the default automatic terminal capability policy.

`target/release/bin/main --smoke` runs a finite headless snapshot check and prints a plain-text frame. It does not test interactive input or terminal rendering. Unrecognized arguments return a nonzero exit.
