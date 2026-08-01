# BP-030–BP-034 result analysis and R1 correction

## Windows result

The initial BP-030–BP-034 delivery compiled and executed successfully. Of all
independent groups, only the BP-030 host-timing fixture failed. All remaining
new groups, installed-game validation, 300 headless frames, two independent
128-frame traces, trace byte identity, artifact schema validation and UDP
loopback passed.

```text
Failure: BP-030 host timing and frame clock
Fixture: [3/18] filtered accumulation
Message: second filtered: expected false
```

The accepted runtime evidence from this otherwise successful run is:

```text
Trace SHA-256: 31647a08ecb3204cd58b71b4fc6f441f5ed814d6c27aa6813ac3e566bf1c4769
Rolling hash:  0658dd48
```

Result archive SHA-256:

```text
1bf865b23206b74dc6ad0f3785bf7171cd9ffac3193bd86d3af6b674f4e1d4c9
```

## Root cause

The production implementation follows `Host_FilterTime` correctly. WinQuake
accumulates the platform delta in the double `realtime` clock and filters while

```text
realtime - oldrealtime < 1 / 72
```

The original fixture called `0.007` twice and expected both calls to be
filtered. That expectation is mathematically wrong:

```text
0.007 + 0.007 = 0.014
1 / 72           = 0.013888...
```

Therefore the second call must already be accepted. The independent C oracle
had always encoded the correct accumulated sequence: `0.001`, `0.007`,
`0.007`, producing an accepted frame time of `0.015`.

## R1 correction

The runtime fixture now mirrors the C oracle exactly:

1. `0.001` is filtered.
2. `0.007` is filtered; the accumulated clock is `0.008`.
3. another `0.007` is accepted; the accumulated frame time is `0.015`.

It additionally checks two filtered frames, one accepted frame, and the
`oldRealtime == realtime` update after acceptance. The component checker binds
this exact order so the stale threshold assumption is rejected before a future
Windows build.

No file below `src/` or `native/` changed. The engine remains BP-034; the
delivery and acceptance revision is BP-030–BP-034R1.
