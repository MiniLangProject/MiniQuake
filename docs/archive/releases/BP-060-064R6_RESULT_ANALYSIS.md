# BP-060–BP-064R5 Windows result analysis

The uploaded result archive `MiniQuake_BP-060-064R5_RESULTS_20260729-103523.zip`
has SHA-256 `24dc4cdf88b654944f78b2aefaab7437609e1614b3c2eccb54f16b93218c1fcb`.

## Confirmed PASS boundary

- all 65 Windows targets compiled;
- all inherited and BP-060..064 runtime groups passed;
- installed Quake data validation and 300 headless frames passed;
- retail audio evidence A/B was byte-identical (`896049a03f26b1db4ddc1550d35d1cacb5f7e0f0c900b0ee36393c8ab8bd0501`);
- compatibility traces A/B completed 128/128 frames and were byte-identical
  (`03656a0e9f3b13d4430014de3787053c204acdd1e7f2e33c292ee8ee2b47c8cc`);
- both 640×480 render captures were byte-identical (`9047f96e9bef8e06035119ff71ddfe7ad4dcad89b4740c66618252a13cd166fb`, SSIM 1.0);
- the first real UDP Protocol-3 server process printed
  `MiniQuake BP-064 network platform evidence server: PASS`;
- its client received `host=MiniQuake Evidence`, `map=start`, `users=1/4`,
  `protocol=3`, `connect=accepted` and printed PASS.

Server stdout SHA-256: `ce65b367cf2296d913e3691916d5c27926c040c7456e6bd39dd0ac8a53af3874`. Client report SHA-256: `50534266c750fa20058c82ce48baca953b0107106dc24fd69c5854fc3364ba96`.
Server stderr was empty.

## Failure

The R5 wrapper used `Start-Process -PassThru` and read `$Server.ExitCode` after
`WaitForExit(7000)`. On the tested Windows PowerShell 5.1 environment that
property was blank even though the process had exited and both logs reported
PASS. PowerShell compared the resulting `$null` with zero and emitted:

```text
network evidence pair a failed: server= client=0
```

This is a process-wrapper defect, not a MiniQuake network or Protocol-3 failure.
R6 removes `Start-Process` from this evidence path and owns the server through
`System.Diagnostics.Process` directly.
