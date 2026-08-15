# BP-035–BP-039 Windows result analysis

## Result

The initial cumulative delivery completed the full Windows build and all
end-to-end runtime gates. Exactly one independent group failed:

```text
[18/20] rotate flag
FAIL: binary object rotation: expected 100., got 199.9951171875
```

All other BP-035 fixtures passed. BP-036, BP-037, BP-038 and BP-039 passed in
full. Installed `id1/start` validation, 300 headless frames, two independent
128-frame compatibility traces, byte-identical trace comparison and Winsock UDP
loopback also passed.

```text
Trace SHA-256: e4c5334bf6aa4205b3a8d6c0c408a398a16bf042852703ea0bf29ba31c1919a1
Rolling hash:  0658dd48
```

Result archive SHA-256:

```text
96a612797e6e59a09642600d91fd6ab4bce0bf2aa236aeb510169767809a4919
```

## Root cause

The fixture created a client with `noLerp = true`, packet times `2.0` and `1.9`,
then set `client.time = 1.0`. The original `CL_RelinkEntities` order is:

```text
CL_LerpPoint
    -> when no-lerp is active: cl.time = cl.mtime[0]
    -> return 1
anglemod(100 * cl.time)
```

Consequently the authoritative time is `2.0` before rotating objects are
updated. WinQuake's `anglemod(float)` quantizes through 65536 angular steps:

```text
anglemod(200.0) = 199.9951171875
Binary32 word   = 0x4347fec0
```

The MiniQuake runtime followed the original ordering. The test expectation was
wrong; production code was not.

## R1 correction

R1 asserts both:

```text
client.time     == 2.0
entity.angles.y == 199.9951171875
```

The independent C oracle and Python model now bind the same values. A verifier
contract rejects the old `100.0` expectation before compilation.

No production or native source changed.
