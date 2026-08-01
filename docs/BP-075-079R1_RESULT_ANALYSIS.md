# BP-075–BP-079 result analysis

The Windows acceptance stopped in the inherited BP-029 preflight before any MiniLang target was compiled.

```text
MiniQuake BP-029 world/physics closure verification: FAIL
ERROR: closure golden differs from authoritative sources
```

The complete BP-079 package verifier and all BP-075..BP-079 source-derived component checkers had already passed. The mismatch was limited to the historical `authoritative_files` hash for `src/miniquake/server.ml`.

BP-075..BP-079 legitimately changed only host-command parsing in that shared module:

- imported `miniquake.host_command_numbers`;
- routed `color` through the C-`atoi` compatible adapter;
- routed numeric kick targets through the Quake-compatible player-index adapter;
- routed `give` values through the correct integer adapter.

The frozen world/physics functions remained byte-identical to the Windows-accepted BP-025..BP-029R3 baseline:

| Function | Accepted SHA-256 |
|---|---|
| `runWorldPhysicsWithRetouch` | `5b082bf6147659c213fe46e84679d44a73f11dcd2aac070ef51eaf66dd0ecc8b` |
| `runNonClientPhysicsWithRetouch` | `24a05fed078529237192653250631835a9d22d6d6c9054abb0ea5121f13095a6` |
| `frameMode` | `09549e467d9a73e0802fda2c71552348fe7470dd6a84766098d02c90cbf87921` |

## Classification

Infrastructure/lineage false positive. No gameplay, physics, native bridge or runtime failure was observed.

## R1 correction

The checker now has two modes. The masked downstream server hash is `181db4de0fc6db19d9f067aea9d8ebd654c8e14a37c477be1640958c0cff3781`:

- **strict historical mode:** unchanged exact BP-029 whole-file hash comparison;
- **downstream mode:** eight unchanged authoritative files remain fully hashed. `server.ml` is checked twice: by the three accepted world/physics function slices listed above and by the complete source after masking only the added host-command import and the three documented host-command bodies.

`build.ps1` uses downstream mode in BP-079. Package identity is still checked independently by `tools/verify.py`.

Result archive analysed:

```text
MiniQuake_BP-075-079_RESULTS_20260730-143415.zip
SHA-256: 78963a812a05fe9d4951eef1d1cb425757c3a63513c9a956481b36f5033a0384
```
