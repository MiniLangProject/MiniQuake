# MiniQuake BP-090–BP-094R13 – R12 result analysis

R12 completed the cumulative build and internal test suite. The verified original GLQuake process answered a Protocol-3 `CCREQ_SERVER_INFO` request, proving that the requested loopback UDP endpoint and map were active. The subsequent strict MiniQuake connect nevertheless received no `CCREP_ACCEPT` or `CCREP_REJECT` packets.

Two harness/runtime sequencing risks remained:

1. `Host_Init` ran without an external target and could therefore create the normal local `start` fallback before the strict connect was attempted.
2. The readiness UDP source endpoint was closed immediately after the server-info response, directly before the real control socket was opened.

R13 removes both transitions. The private target is consumed by `Host_Init` before the fallback, and the readiness guard remains open until after the original process stops. The actual persistent Protocol-3 socket still performs the real connect and Protocol-15 signon; the guard is not accepted as interoperability evidence.

The Windows run of R13 remains required to confirm the behavior against the original binary.

R13 therefore implements an explicit pre-fallback external connect path.
