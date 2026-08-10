# BP-090–BP-094R1 result analysis

## Observed failure

The R1 Windows acceptance run stopped in the first build preflight before any
MiniLang target was compiled:

```text
usage: verify.py [-h] [--root ROOT] [--json JSON]
```

The result summary contains no completed steps because `build.ps1` called the
new verifier with a positional project root:

```powershell
& $PythonExe @PythonPrefixArgs $Verifier $Root
```

The BP-094 verifier only declared `--root`; `argparse` therefore treated the
project path as an unknown positional argument and returned exit code 2.

## Classification

This is a delivery/preflight CLI mismatch. It is not an engine, compiler,
original-reference, interop or visual-comparison failure. None of those stages
were reached.

## R2 correction

The build uses the canonical form:

```powershell
& $PythonExe @PythonPrefixArgs $Verifier --root $Root
```

The verifier also accepts the historic positional form (`verify.py .`) as a
compatibility alias so old documentation and historical helper scripts remain
usable. Supplying both forms simultaneously is rejected as ambiguous.
