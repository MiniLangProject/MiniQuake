# MiniQuake BP-090–BP-094R12 – R11 result analysis

## R11 result

The cumulative build, all internal tests, original-reference staging, temporary firewall setup and Protocol-3 server-info readiness passed. The verified original GLQuake server answered on `127.0.0.1:34831` after 10 probes and remained alive.

The first external direction nevertheless failed: all six full MiniQuake client processes reported `UDP connect timed out`. Their subsequent local `start` fallback was correctly rejected by the R9 network-provenance gate.

## Boundary

The evidence proves that the original control socket is reachable and processes `CCREQ_SERVER_INFO`; it does not show any accepted `CCREQ_CONNECT` or received `CCREP_ACCEPT`. R11 did not record the MiniQuake source port or raw connect replies.

## R12 correction

R12 removes process-level connection churn from the handshake. A dedicated strict interop path keeps one bound UDP socket alive, sends the exact 12-byte `CCREQ_CONNECT` repeatedly every 500 ms and listens continuously for `CCREP_ACCEPT`/`CCREP_REJECT`. This interval is intentionally inside original Quake's two-second duplicate window. If the first accept is lost, the original server repeats it to the same source endpoint. If an old connection is closed after the window, the next resend from the same endpoint can establish a clean qsocket.

The strict command no longer queues `+connect` during `Host_Init`. It initializes the host, tears down the local fallback state, then invokes the persistent interop connector directly. Failure returns immediately and cannot continue into a local map/demo result.

This is both a targeted fix and a packet-level diagnostic. A remaining failure reports local source port, target, sends, receives, ignored packets and raw packet hex.
