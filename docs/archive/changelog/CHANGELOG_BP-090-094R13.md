# MiniQuake BP-090–BP-094R13

Delivery-only/runtime interop correction on top of BP-090–BP-094R12.

## Changes

- The private original-server interoperability target is passed into `Host_Init`.
- The external UDP connect is attempted before the normal standalone map/demo fallback.
- A successful connection established during `Host_Init` is reused; no second control handshake is opened.
- The Protocol-3 connect path rejects partial 12-byte request sends.
- The original-server readiness UDP socket is bound to loopback and remains open during Protocol-15 signon.
- The readiness guard is closed only after the original GLQuake process has stopped.
- R13 reports guard endpoint, lifetime and close order in JSON.
- Normal launches without `-original-interop-target` retain the previous startup behavior.

Engine package remains `BP-094`; delivery revision is `BP-090-094R13`.
