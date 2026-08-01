# BP-020–BP-024R2 Windows result analysis

## Result

The uploaded result archive `MiniQuake_BP-020-024R2_RESULTS_20260725-224602.zip`
has SHA-256:

```text
fec22c41880ff1d34a66f0e254281e5d72777db5a19f0feb60f077deeedae060
```

The cumulative build and 51 of 52 acceptance groups succeeded. The sole
failure was the BP-022 edict/save-text runtime group:

```text
[16/22] ED_Write
FAIL: Cannot stringify void for string concatenation
```

Everything after that group was still executed because the block runner used
independent-test continuation.

## Confirmed green gates

- game plus all 19 test executables compiled;
- base core and milestone tests passed;
- all Protocol-15 gates BP-010R1 through BP-019 passed;
- BP-020 progs.dat tests passed 18/18;
- BP-021 VM tests passed 16/16;
- BP-023 builtin tests passed 22/22;
- BP-024 closure tests passed 20/20;
- the installed stock `id1/progs.dat` gate passed;
- installed game-data validation passed;
- 300 headless frames passed;
- two independent 128-frame traces were byte-identical;
- trace SHA-256 was
  `2efa7130b9dacabb1c463d35c903f1e8f8b3e24feeca27b649d1211a6fc62c17`;
- rolling hash was `58a7d245`;
- direct snapshot and all report schemas passed;
- Winsock UDP loopback passed.

This confirms that the R2 qcc parameter-storage correction is correct and that
stock QuakeC, map loading, runtime initialization, Protocol 15 and deterministic
execution are healthy.

## Failure classification

The failure is isolated to the synthetic BP-022 serialization fixture. It does
not occur while loading the stock program or running the game. The old R2
serializer constructed a progressively growing MiniLang string and passed that
string through multiple helper-call boundaries. The observed error proves that
a `void` reached a subsequent concatenation, but it does not identify which
compiler/runtime micro-step produced that value.

The result archive does not contain a native stack trace that proves the exact
compiler/runtime micro-step at which the value became `void`. BP-024R3 therefore
does not merely add another null check. It removes the failing construction
strategy completely.

## R3 correction

`ED_Write`, `ED_WriteGlobals` and the savegame writer now share a two-pass,
exact-size byte serializer:

1. select definitions using the original Quake rules;
2. format each value using the existing QuakeC word formatter;
3. convert field names and values through `quake_latin1_cstring_v1`;
4. calculate the exact output byte count;
5. fill one caller-owned `bytes` buffer with the literal Quake save-text layout;
6. convert that completed byte document back to a MiniLang string once.

The serializer no longer concatenates an ever-growing prefix. It also preserves
all Quake one-byte characters from `0x01` through `0xff` in the in-memory text
representation. Savegame and direct ED_* writers use the same implementation.
Entity fields whose QuakeC words are all zero remain omitted, while `ED_WriteGlobals` preserves the original rule of writing every eligible `DEF_SAVEGLOBAL` string, float and entity value, including zero and empty-string values.

The existing 22-fixture BP-022 test program remains the acceptance gate. Its
ED_Write fixture now also checks an extended Quake byte and reports a direct
return-type error instead of masking a `void` result while constructing the test
failure message.
