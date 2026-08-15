# MiniQuake BP-090–BP-094

This block closes the two external gates that remained open after the accepted
BP-085–BP-089R8 release candidate.  The original GLQuake executable and Quake
game data are supplied by the tester at runtime and are never redistributed in
the MiniQuake source or result archives.

## BP-090 – Verified original GLQuake reference

- Accepts either `OriginalQuakeSourceCode.zip` or an explicit `GLQUAKE.EXE`.
- Requires the exact reference SHA-256
  `04862c835c399bc9184f62101ae0390c2a758c21656ec06dcc0384e0f373d588`.
- Requires 435,712 bytes and PE machine `0x014c` (i386).
- Stages only the verified executable and tester-owned PAK files in `build`.
- Deliberately excludes the historical 3dfx `OPENGL32.DLL`; Windows system
  OpenGL is used.

## BP-091 – Original server → MiniQuake client

- Starts the original GLQuake binary as a real dedicated UDP server.
- Connects MiniQuake through its normal Protocol-3 discovery/connect and
  Protocol-15 gameplay paths.
- Requires complete signon 4, spawned client state, model/sound precaches and
  32 post-signon frames.
- Runs two independent process pairs and requires byte-identical normalized
  reports.

## BP-092 – MiniQuake server → original client

- Starts MiniQuake as a real dedicated UDP server.
- Connects original GLQuake as a separate windowed process.
- Requires `Connection accepted`, `Serverinfo packet received.` and
  `CL_SignonReply: 4` in the original qconsole log.
- Runs two independent process pairs and requires byte-identical normalized
  server reports.

## BP-093 – External visual reference

- Replays the same retail demos in both engines: `demo1`, `demo2`, `demo3`.
- Captures original GLQuake twice at logical frame 256 and requires the two
  original TGAs to be byte-identical.
- Captures MiniQuake at frames 254–258 and selects only the best temporal
  candidate; no crop, translation, gamma, color or scale normalization occurs.
- Requires raw full-frame SSIM ≥ 0.95 at 640×480 for every demo.

## BP-094 – External compatibility closure

- Inherits the accepted `compat_109_release_candidate_v1` matrix.
- Binds the exact original reference, bidirectional binary interoperability and
  the external raw visual-reference corpus.
- Candidate status: `compat_109_final_candidate_v1`.
- Candidate fingerprint: `0xe04a7727`.

The package does not claim Windows acceptance until the supplied
`TEST_BP-090-094.ps1` has completed successfully on the user's machine.

## Delivery and inherited-contract integrity

- Historical BP-084 and BP-085--BP-089 checkers retain strict original-package modes.
- The BP-094 build invokes their explicit downstream modes so frozen contracts are
  verified under the current delivery identity instead of requiring stale package IDs.
- The result collector retains historical BP-012 server-data evidence markers while
  continuing to exclude original binaries, Quake game data, screenshots and compiled
  executables.
- Test output remains live and line-flushed; no whole-process output buffering is used.
