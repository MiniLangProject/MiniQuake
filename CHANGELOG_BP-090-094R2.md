# MiniQuake BP-090–BP-094R2

R2 is a delivery/preflight compatibility hotfix. No MiniQuake engine or native
bridge code changed.

## Fixed

- `build.ps1` now invokes the current package verifier through its canonical
  option form: `tools\verify.py --root <project>`.
- `tools/verify.py` again accepts the historical positional root form
  (`verify.py .`) as a backwards-compatible alias. This keeps older project
  documentation and historical scripts usable while new scripts use `--root`.
- Added a verifier CLI contract that rejects a canonical build invocation
  without `--root` and confirms both supported command-line forms.
- Updated the acceptance entrypoint, collector, package manifest, ledger and
  delivery metadata for revision `BP-090-094R2`.

## Unchanged

- No file under `src/` or `native/` changed.
- BP-090 through BP-094 fixtures, original-reference hashes, bidirectional
  interop requirements, visual SSIM threshold and compatibility fingerprints
  are unchanged.
