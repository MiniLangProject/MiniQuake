# MiniQuake BP-090–BP-094R12

Targeted original-server interoperability correction on top of R11.

- Uses one persistent MiniQuake UDP control socket for the Protocol-3 connect handshake.
- Resends `CCREQ_CONNECT` every 500 ms inside the original server's two-second duplicate window.
- Keeps the source endpoint stable across retries.
- Bypasses the startup `+connect`/local-map fallback in the strict interop command.
- Emits the exact control request, local source port, received packet endpoints, packet hex, accept/reject result and returned game port.
- Does not change normal menu/network connection semantics.
- Keeps R8 visual-parity fixes, R9 provenance checks, R10 readiness, R11 reference handoff and temporary loopback firewall rules.

Engine package remains `BP-094`; delivery revision is `BP-090-094R12`.
