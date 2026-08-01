# MiniQuake BP-085–BP-089R3

Parent delivery: **BP-085–BP-089R2**.

- Separates the historical BP-022 raw-word formatter audit from the accepted
  downstream MSVCRT `%.6f` formatter contract.
- Adds `--allow-downstream-package` to `check_quakec_edict.py`.
- Makes `build.ps1` select the downstream BP-022 contract for BP-089.
- Requires the caller-owned `mqt_f32_to_fixed6` bridge, the native
  `sprintf("%.6f")` boundary and the absence of the old overflow-prone
  integer-scaled formatter.
- Keeps historical checker mode strict and reproducible.
- Adds R3 acceptance, collection and lineage metadata.
- Changes no MiniQuake engine source and no native binary.
