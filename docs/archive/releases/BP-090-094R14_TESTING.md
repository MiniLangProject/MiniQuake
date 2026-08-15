# MiniQuake BP-090–BP-094R14 – Windows acceptance

The harness passes `--min-reference-ssim 0.98` and `--min-ssim 0.95` to the raw full-frame comparator. Candidate aggregation is `minimum_ssim` across two independent Original GLQuake captures.

```powershell
.\TEST_BP-090-094R14.ps1 `
  -Compiler "$CompilerRoot\mlc_win64.py" `
  -StdLib $CompilerRoot `
  -QuakeBase $QuakeBase `
  -OriginalQuakeSourceArchive $OriginalSource `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -BlackPortCorpusFrames 64 `
  -SoakFrames 5000 `
  -ListenSoakFrames 5000 `
  -OriginalInteropFrames 10000 `
  -OriginalServerReadyTimeoutMs 180000 `
  -OriginalVisualFrame 256 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

Capture reports must contain `capture_completion=validated_tga_size_hash_stability`, exact expected/actual TGA bytes and at least three stable polls. Each visual comparison must report `reference_min_ssim>=0.98`, `reference_aggregation=minimum_ssim`, and worst-case MiniQuake `ssim>=0.95`. Expected end: `MiniQuake BP-090-094R14 acceptance test: PASS`.
