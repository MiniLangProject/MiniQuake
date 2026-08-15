# MiniQuake BP-070–BP-074R5

- Corrects the BP-073 animation fixture: texture names live on `BspTexture`, while `sequenceTextureAnimations` returns numeric animation metadata.
- Binds `+0fixture` separately from `anim_total=4`, `anim_next=1`, and `alternate=2`.
- Extends the model-asset golden data and C oracle with the animation contract.
- Replaces the collector generic skipped-artifact list with a Windows PowerShell 5.1-safe object array.
- Preserves synthetic-workspace filtering and strict rejection of source-tree Quake game data.
- Adds R5 acceptance, analysis, ledger, manifest, patch, and collection metadata.
- Changes no file below `src/` or `native/`; frozen contracts and fixture counts remain unchanged.
