# BP-065–BP-069 initial Windows result analysis

Result archive:

```text
MiniQuake_BP-065-069_RESULTS_20260729-154632.zip
SHA-256: 96934acd755555383271141db651f1304561366aec73c540b943e296ec9a2f39
```

## Failure boundary

The cumulative Windows build and every inherited test through BP-067 passed.
The run stopped in BP-068 before BP-069, installed-game validation, headless
runtime, traces and external evidence.

| Group | Result |
|---|---:|
| BP-065 key/focus | 20/20 PASS |
| BP-066 input device | 23 actual checks PASS; output incorrectly said 22 |
| BP-067 console/screen | 22/22 PASS |
| BP-068 menu lifecycle | 22/24 PASS |
| BP-069 frontend closure | not reached |

The two BP-068 failures were:

```text
sound volume tenth-step
invert mouse
```

## Cause

WinQuake stores Cvar numeric values as C `float` and `Cvar_SetValue` formats
those values with `%f`. The production MiniQuake path deliberately keeps this
Binary32 boundary. The initial fixture instead compared the returned values
with higher-precision MiniLang literals:

```text
0.8
-0.022
```

The exact original results are:

| Case | C float word | Cvar string |
|---|---:|---|
| `0.7f + 0.1`, stored as float | `0x3f4ccccd` | `0.800000` |
| negated `0.022f` | `0xbcb43958` | `-0.022000` |

The runtime failures were therefore false negatives in the test fixture, not
observed production defects.

## Additional metadata defect

The source contains 23 BP-066 checks and 24 BP-068 checks, but both suites were
labelled `/22`. R1 corrects these counters and the block total from 110 to 113.

## R1 scope

R1 changes tests, C oracles, audit metadata, documentation and delivery scripts
only. `src/` and `native/` are byte-identical to the initial BP-065–BP-069
package.

For the machine-readable acceptance record: BP-066 has 23 checks and BP-068
has 24 checks; the corrected block total is 113.
