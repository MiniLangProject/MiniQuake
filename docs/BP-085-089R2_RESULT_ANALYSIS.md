# BP-085–BP-089R2 result analysis

## Observed R1 result

The Windows build and all component tests through BP-089 passed. Retail demos
`demo1.dem`, `demo2.dem` and `demo3.dem` parsed successfully. The only failure
was the Quake-v5 save evidence:

```text
error=normalized save parse: invalid savegame spawn parm 0: --2147.516352
result=FAIL
```

## Root cause

The prior fixed-six formatter converted a complete Binary32 magnitude to
integer micro-units:

```text
trunc(abs(value) * 1000000 + 0.5)
```

For the ordinary stock Quake spawn parameter/item mask `4097.0`, the scaled
value is `4,097,000,000`, which is outside signed 32-bit range. The Win64
float-to-int conversion produced `INT_MIN`; the formatter emitted
`-2147.516352`. Re-parsing made the value negative, and the next serialization
added a second sign, yielding `--2147.516352`.

WinQuake writes these fields with C `printf("%f")`, so the correct boundary is
MSVCRT six-decimal float formatting, not integer scaling.

## R2 correction

R2 adds the backward-compatible text-bridge export `mqt_f32_to_fixed6`. It
resolves MSVCRT `sprintf` and formats the exact Binary32 value with `%.6f` into
caller-owned MiniLang bytes. `ED_Write`, Cvar serialization and Quake-v5
savegames share this path.

Bound regressions include:

```text
4097.0       -> 4097.000000
-4097.0      -> -4097.000000
16777215.0   -> 16777215.000000
negative zero -> -0.000000
```

The sequential-session and edict-high-water fixes from R1 remain unchanged.

R1 result archive SHA-256: `169be14543a5defb984fb52e3390b8eb1b0c546d72d17cc24c74085f5104ed2a`.
