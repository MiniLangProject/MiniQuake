# MiniQuake BP-035–BP-039R1

Delivery revision: `BP-035-039R1`  
Parent delivery: `BP-035-039`  
Engine package: `BP-039`

## Reason

The first Windows acceptance run compiled and executed the complete block. All
legacy groups, BP-036 through BP-039, installed-game validation, 300 headless
frames, two byte-identical 128-frame traces and UDP loopback passed. Only BP-035
fixture 18/20 used a stale expectation for rotating brush/object models.

`CL_RelinkEntities` calls `CL_LerpPoint` before calculating `bobjrotate`. With
`noLerp` enabled, `CL_LerpPoint` first snaps `client.time` to `messageTimes[0]`.
The fixture therefore must evaluate `anglemod(100 * 2.0)`, yielding the exact
Binary32 value `199.9951171875`, not `100.0`.

## Changes

- Correct the BP-035 rotate fixture and explicitly assert the no-lerp time snap.
- Extend the independent C oracle and Python model with the snapped time and
  `bobjrotate` Binary32 words.
- Add a stale-expectation preflight contract.
- Add an R1 acceptance script, collector metadata, result analysis and block
  ledger.

## Scope

No file under `src/` or `native/` changes in this delivery revision. Fixture
counts and the client/render contract fingerprint remain unchanged.
