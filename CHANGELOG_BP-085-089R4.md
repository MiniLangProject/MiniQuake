# MiniQuake BP-085–BP-089R4

Parent delivery: **BP-085–BP-089R3**.

- Separates the historical BP-031 command/cvar fixed-six source audit from the
  accepted downstream MSVCRT `%.6f` formatter contract.
- Adds `--allow-downstream-package` to `tools/check_command_cvar.py`.
- Keeps strict historical BP-031 mode reproducible and verifies it against the
  accepted BP-030–BP-034R1 source baseline.
- Makes `build.ps1` select downstream BP-031 mode for BP-089.
- Adds a package-level lineage check requiring the caller-owned
  `mqt_f32_to_fixed6` bridge and rejecting the old i32-scaled formatter.
- Adds R4 acceptance, collection, result-analysis and block-ledger metadata.
- Changes no MiniQuake engine source and no native binary relative to R3.
