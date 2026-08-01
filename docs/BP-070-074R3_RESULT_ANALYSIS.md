# BP-070–BP-074R2 Windows result analysis

The R2 package passed its full static preflight, compiled all **76/76** MiniLang targets and completed BP-070 with **24/24 PASS**. The first runtime failure occurred in BP-071 fixture 10:

```text
[10/24] shareware loose restriction
FAIL: shareware loose subdirectory: expected true
```

Result archive:

```text
MiniQuake_BP-070-074R2_RESULTS_20260729-210721.zip
SHA-256: e0206af9dd6775f6e302d697ea3db05ea55e8e902e96f47b3f1e83cf6d0c703b
```

## Failure boundary

- The production filesystem restriction exists and is source-bound:
  `if not system.staticRegistered and containsDirectorySeparator(normalized) then ... continue`.
- `qfs.create(...)` initializes `staticRegistered=true`, matching `common.c`'s startup global `static_registered = 1`.
- In real startup, `COM_CheckRegistered` changes this to `false` when `gfx/pop.lmp` is absent.
- The synthetic fixture called `qfs.create` and `addDirectory` directly, bypassed `checkRegistered`, and therefore never entered the shareware state it intended to test.

The lookup was consequently allowed, and the fixture—not the production filesystem—was wrong. An older independent filesystem fixture already used the correct setup: `system.staticRegistered=false`.

## R3 correction

BP-071 fixture 10 now explicitly sets:

```ml
system.staticRegistered = false
```

before resolving `sub/loose.bin`. The test still requires `qfs.readFile(...)` to return an error. The PACK checker, golden metadata and C oracle now bind this state transition explicitly.

No production file under `src/` and no native file under `native/` is changed by R3. The contract remains:

```text
core_assets_memory_109_frozen_v1
fingerprint=0x6c8d974d
```
