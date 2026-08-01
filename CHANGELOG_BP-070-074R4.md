# MiniQuake BP-070–BP-074R4

Collector-only delivery hotfix.

- Distinguishes source-package inputs from ephemeral runtime artifacts.
- Skips BP-071/BP-072 synthetic filesystem/WAD workspaces during collection.
- Skips any build artifact shaped like Quake game data rather than aborting.
- Records every skipped path and reason in `collection.json`.
- Preserves strict refusal for source/document inputs.
- Adds `TEST_BP-070-074R4.ps1` and R4 result metadata.
- Changes no file below `src/` or `native/` and changes no runtime fixture.
