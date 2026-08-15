# MiniQuake BP-090–BP-094R1

R1 is a delivery/test-infrastructure hotfix for the external compatibility
closure. The engine and native bridges are unchanged.

## Fixed

- Corrected a Windows PowerShell parser error in the visual-reference failure
  message. In an expandable string, `$Scenario:` was parsed as a drive- or
  scope-qualified variable. The runner now uses `${Scenario}:`.
- Patched both the historical `TEST_BP-090-094.ps1` entry and the explicit
  `TEST_BP-090-094R1.ps1` entry.
- Added a package-verifier gate that rejects ambiguous `$Variable:`
  interpolation in all PowerShell scripts while allowing valid scope/provider
  variables such as `$env:NAME`.
- Updated the result collector, launcher, manifest and delivery metadata for
  revision `BP-090-094R1`.

## Unchanged

- No file below `src/` or `native/` changed.
- Package identity remains `BP-094`; block identity remains `BP-090-094`.
- All BP-090 through BP-094 fixtures, provenance hashes, interoperability
  requirements, raw-image policy and compatibility fingerprints are unchanged.
