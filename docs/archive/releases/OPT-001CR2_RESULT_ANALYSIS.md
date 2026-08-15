# MiniQuake OPT-001CR1 result analysis

The uploaded result archive was `MiniQuake_OPT-001CR1_RESULTS_20260807-212403.zip`
with SHA-256
`d362d3f02385916cbff55dd854f3e2eb28a5d66b6ebae2098a0d5832e0090e01`.

## Runtime result

Every product and correctness step passed:

- package verification and full Windows build;
- OPT-001C allocation contract;
- `e1m1` and `e1m2` parser, runtime and render smoke tests;
- byte-identical A/B traces for both maps;
- four 3,000-frame performance measurements;
- 1,000 visible and 10,000 headless `e1m2` frames;
- `e1m1 -> e1m2 -> e1m1` transition.

The overall result was incorrectly marked as FAIL because the analyzers looked
for `opt001a-*` and `opt001c-*`, while the R1 runner correctly generated
`opt001cr1-*` artifacts.

## Reconstructed performance comparison

| Map | Mode | Median | Median improvement | P99 | P99 improvement | Throughput |
|---|---|---:|---:|---:|---:|---:|
| e1m1 | headless | 46 -> 16 ms | 65.217% | 63 -> 32 ms | 49.206% | 1.8633x |
| e1m1 | render | 109 -> 63 ms | 42.202% | 141 -> 94 ms | 33.333% | 1.5774x |
| e1m2 | headless | 31 -> 31 ms | 0.000% | 188 -> 32 ms | 82.979% | 1.3064x |
| e1m2 | render | 125 -> 63 ms | 49.600% | 203 -> 79 ms | 61.084% | 1.8917x |

The aggregate render median improvement is 45.901%, the aggregate render P99
improvement is 47.209%, and the average render throughput ratio is 1.7345x.
The configured OPT-001C targets are therefore met.

## Handle result

The measured sequence was `275,275,275,276`.  The additional handle appeared
at frame 10,200 and then remained stable through frame 15,000.  The existing
three-window test cannot prove that it remains stable in a later window, so it
correctly classified the sequence as INCONCLUSIVE.  OPT-001CR2 adds one
confirmation window; no tolerance is broadened.
