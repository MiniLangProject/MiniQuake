# MiniQuake BP-060–BP-064R2

Delivery parent: `BP-060-064R1`  
Engine package: `BP-064`

## Changes

- Carry forward the R1 live-output PowerShell runner; child-process output is no longer buffered until completion.
- Add the explicit `TEST_BP-060-064R2.ps1` entry and R2 log/result names.
- Fix Protocol-3 rule enumeration:
  - return an empty name/value pair for the command-only end marker;
  - silently ignore an unknown previous rule, as `net_dgrm.c` does;
  - prevent indexing `void` in the BP-061 runtime fixture.
- Extend the BP-061 C oracle, golden metadata and static checker with end-marker and no-reply cases.
- Update collector, ledger, manifest and result-analysis metadata for R2.

## Compatibility status

No native ABI changes. The candidate contract remains:

```text
network_platform_109_frozen_v1
fingerprint=0xb3ec7589
```
