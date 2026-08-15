# BP-075–BP-079R1 result analysis

The Windows acceptance stopped in the inherited BP-036 source preflight before any MiniLang target was compiled. The failure occurred before compilation.

```text
MiniQuake BP-036 client/render verification: FAIL
ERROR: src/miniquake/view.ml: missing marker: common.atoi(arguments[index + 1])
```

The current BP-076 source correctly uses `common.cAtoi(...)` because `view.c::V_cshift_f` calls the C runtime `atoi`, while `common.atoi(...)` implements Quake's extended `Q_atoi` syntax. The dedicated BP-076 checker already required `common.cAtoi`; only the older inherited BP-036 checker retained its historical marker.

## Classification

Infrastructure/lineage false positive. No MiniLang compile, runtime, gameplay, renderer or native-bridge failure was observed in this run.

## R2 correction

The shared BP-035..BP-039 checker now has two modes:

- **strict historical BP-036 mode:** still requires the original `common.atoi(...)` marker;
- **downstream mode:** requires `common.cAtoi(...)` and rejects the stale historical marker.

`build.ps1` enables downstream mode only for `tools\check_client_render_036.py`. Package identity remains independently checked by `tools/verify.py`.

Result archive analysed:

```text
MiniQuake_BP-075-079R1_RESULTS_20260730-153422.zip
SHA-256: de4b5325fe5e4506cf812f0775047afcb1927971f7ee9ffad1cc5f2a688919fb
```
