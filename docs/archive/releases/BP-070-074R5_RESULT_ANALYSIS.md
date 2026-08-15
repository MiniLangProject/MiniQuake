# BP-070–BP-074R5 result analysis

## Observed Windows failures

The R4 Windows run reached BP-073 and stopped at:

```text
FAIL: animation base: expected +0fixture, got 4
```

The value `4` is correct. `sequenceTextureAnimations` returns per-texture numeric metadata:

```text
[anim_total, anim_min, anim_max, anim_next, alternate_anims]
```

For `+0fixture`, `+1fixture`, `+Afixture`, and `+Bfixture`, the regular animation has two frames and GLQuake uses `ANIM_CYCLE = 2`; therefore `anim_total = 4`. The name remains in `brush.textures[0].name`. R5 checks these independently and changes no model-loader code.

The subsequent collector run failed with:

```text
Die Argumenttypen stimmen nicht überein.
```

R4 stored skipped artifacts in `System.Collections.Generic.List[object]` and converted that collection through `@($SkippedBuildArtifacts)` while building JSON metadata. Windows PowerShell 5.1 can raise `ArgumentException` for this conversion. R5 uses a normal PowerShell object array from insertion through JSON serialization.

## Classification

- BP-073: fixture error; production and native source unchanged.
- Collector: PowerShell 5.1 result-infrastructure error.
- Frozen contracts and fixture counts: unchanged.
- R5 runtime and collection must be revalidated because BP-073 and all later gates were not completed.
