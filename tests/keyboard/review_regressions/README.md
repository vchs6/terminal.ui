# K115 round1 independent regression consumers

Use normal SDK1.2/stdx/UCD and the configured package cache. Set `CJTUI_K115_CASE`
to one finding ID and run `bash tests/keyboard/review_regressions/run.sh`.
For K115-05 also set `CJTUI_K115_ARTIFACTS` to a new absolute artifact directory.
Every selector has its own final assertion; all literal-vector observations are
printed before that assertion. No old test or oracle is changed.

Manual expected normalized traces, directly from K001–004/F002/F003/F007:

| Selector | Literal input / budget | Expected |
|---|---|---|
| K115-01 | ESC ] ESC C3 9C q BEL Z; ESC ] ESC raw9C Z | text Z; only UnsupportedSequence@0 (Ü is one scalar, raw ST terminates) |
| K115-02 | ESC [ SP 1 C2 A0 2 A B; ESC [ E4 B8 9B A B | text B; only MalformedSequence@0, drain through final A, no NBSP/up |
| K115-03 | ESC raw9B A; ESC C2 9B A | up; no issue from cancelled ESC |
| K115-03 | ESC raw9D q BEL Z; ESC C2 9D q BEL Z | text Z; only UnsupportedSequence@1 at new OSC introducer |
| K115-04 | ESC x B exact2/over1; ESC C3 9C B exact3/over2 | exact: Alt x/Ü then plain B, no issue; over: only plain B and SequenceTooLong@0 |
| K115-05 | actual native E4 x, InvalidUtf8 callback calls stop | one InvalidUtf8@0; no x callback; run normal; cleanup1/resources0/TTY restored |

Pure vectors exercise all two-chunk splits and bytewise feeds, with finish.
Flags are explicitly checked: only exact Alt text sets alt, every other flag is
false. The K115-05 harness waits for real first frame/raw mode before real PTY
input, records the true child exit and actual bin pre/post, and distinguishes
watchdog/setup failures from the named product assertion. No explicit dispatch,
synthetic read or decoder mock substitutes for the native retry path.

K115-06 has no runtime selector: public decoder has no storage-capacity query;
the independent review's fixed-source/SDK disassembly proof is its evidence.
No memory-hook, synthetic measurement, RSS claim, or large input is added here.
Old issue-throws regression and all prior suites remain unchanged; this scope
does not claim those suites were rerun or validate real terminal hosts.
