# BP-085–BP-089R4 Windows result analysis

Result archive:

```text
MiniQuake_BP-085-089R4_RESULTS_20260801-030559.zip
SHA-256: 407953ec4856166f9717620b9cbc8feaab00fab01b5f83f8544798c253c368fb
```

## Confirmed successful areas

The complete Windows build and all MiniLang test executables passed. `id1`,
`rogue`, `hipnotic`, the retail demos, core-asset evidence and audio evidence
also passed. The run stopped only in the first retail savegame evidence
process.

## First failing savegame comparison

```text
source_bytes=35047
normalized_bytes=35037
first_pass_exact=false
semantic=false
stable_exact=true
stable_semantic=true

save_first_diff=1299 left=45 right=48
semantic_diff=globals pair 31 value for v_forward_x
```

Byte `45` is `'-'`; byte `48` is `'0'`. The source save is exactly ten bytes
longer than the first normalized save, and the next B→C roundtrip is fully
stable. This is the characteristic signature of ten `-0.000000` values losing
their sign during the first parse.

The first semantic difference (`v_forward_x`) confirms the same issue at the
QuakeC-word level: IEEE-754 `0x80000000` became `0x00000000`.

## Cause

The original `pr_edict.c` parses saved scalar and vector components with the C
runtime `atof`, which preserves signed zero when the result is stored as a
`float`. MiniQuake used the general MiniLang `toNumber` conversion and then
narrowed the result to Binary32. That path had already normalized negative
zero to positive zero before the Binary32 boundary.

## R5 correction

R5 introduces a shared `common.cAtof` adapter using the existing native
`mq_f32_from_text` (`strtod` followed by a C-`float` cast). It is used for:

- QuakeC global `EV_FLOAT` values;
- QuakeC entity `EV_FLOAT` fields;
- every component parsed by the BSP/edict vector parser;
- scalar Quake-v5 savegame lines such as spawn parms, skill and server time.

The evidence test now prints and requires:

```text
save_float_parse=-0.000000:80000000
first_pass_exact=true
semantic=true
stable_exact=true
stable_semantic=true
```

The artifact fingerprint remains unchanged because exact byte and semantic
roundtrip were already mandatory; R5 fixes the implementation to satisfy that
existing contract.
