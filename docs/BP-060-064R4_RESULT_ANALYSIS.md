# BP-060–BP-064R3 Windows result analysis

## Result boundary

The uploaded archive `MiniQuake_BP-060-064R3_RESULTS_20260729-082542.zip`
has SHA-256:

```text
a382fdf0ed5faeefbc636e5623bfaa819829b3da0a78e1f038002e96ef2d7033
```

The static preflight passed, all 65 Windows executables were compiled, and the
legacy core and milestone suites passed.  The cumulative build then stopped in
the inherited BP-001R3 diagnostics suite:

```text
MiniQuake BP-001R3 diagnostics tests failed: 5/10
```

Every failure had the same form:

```text
player origin expected Vec3, got miniquake.types.Vec3
diagnostic vector expected Vec3, got miniquake.types.Vec3
client entity slot 1 origin expected Vec3, got miniquake.types.Vec3
```

No installed-game, compatibility-trace, framebuffer, audio-evidence or
network-evidence run was reached.

## Root cause

The native MiniLang backend returns package-qualified concrete struct names for
packaged types.  A `miniquake.types.Vec3` therefore reports:

```text
miniquake.types.Vec3
```

R3's newly added safety guards compared `typeName(value)` only with the short
spelling `Vec3`.  Valid vectors were rejected before the forced-GC regression
could exercise the R3 rooting correction.  This was a type-name normalization
bug in the new diagnostics, not evidence of an invalid vector or gameplay
divergence.

The R2 trace-B GC-rooting hypothesis therefore remains unconfirmed until the R4
Windows run reaches both full traces.

## R4 correction

R4 introduces one canonical concrete-type matcher that accepts both the short
and package-qualified spellings.  All Vec3 guards and the GC-stress fixture use
that matcher.  The same known-bad short-name comparison pattern is also removed
from the single-surface sky-chain and direct Efrag-reference compatibility
paths.

The network/platform fingerprint and every previously frozen contract remain
unchanged.
