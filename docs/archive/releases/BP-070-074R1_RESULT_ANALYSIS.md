# BP-070–BP-074 Windows result analysis

## Result boundary

The first BP-070–BP-074 Windows run stopped in the inherited BP-069 frontend checker before MiniLang compilation.

```text
MiniQuake BP-069 frontend closure verification: FAIL
build_info.ml missing marker: const PACKAGE_ID = "BP-069"
build_info.ml missing marker: const BLOCK_ID = "BP-065-069"
```

Result archive SHA-256:

```text
c1ef8340e2f58904e583f2c85a81a7b3f1d37a7b316f8905297a4f2bbd6bef8c
```

The general BP-074 verifier and all current BP-070 through BP-074 component checkers passed. The failure was a checker-lineage defect: `check_frontend_069.py` mixed the historical BP-069 delivery identity with the frozen frontend semantic contract carried by the downstream BP-074 package. No game, asset, memory, native, or runtime path had started.

## R1 correction

`check_frontend_069.py` now has two explicit modes:

- strict historical mode still requires `BP-069 / BP-068 / BP-065-069`;
- `--allow-downstream-package` verifies the unchanged `frontend_109_frozen_v1` status and fingerprint inside the current downstream package while `tools/verify.py` independently binds the BP-074 identity.

`build.ps1` uses downstream mode only for the inherited BP-069 checker. The strict mode is retained and is expected to reject BP-074. No file under `src/` or `native/` was modified.
