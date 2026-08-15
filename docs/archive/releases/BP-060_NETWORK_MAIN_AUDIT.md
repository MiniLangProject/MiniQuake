# BP-060 – NET main, qsocket and active-port audit

BP-060 compares the public `NET_*` lifecycle against WinQuake `net_main.c` and
keeps driver-specific framing in the existing loop/datagram modules.  The
functional correction is that `NET_Connect` now forwards the active
`net_hostport` to the datagram resolver; the historical 26000 wrapper remains
available for callers that deliberately request the default.

Bound observations include the qsocket free/active pool, maximum-client gate,
poll-procedure replacement and chronological order, port range 1..65534,
host-cache lookup and explicit-port precedence.
