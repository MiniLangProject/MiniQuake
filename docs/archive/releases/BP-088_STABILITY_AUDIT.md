# BP-088 stability audit

The acceptance runs two independent 5,000-frame paths:

- a normal host/runtime soak;
- a listen-server long soak on a random local port.

The diagnostics bind heap live blocks/bytes, server Edict high-water, sparse
client-entity topology, sockets, queues, UDP endpoints, audio resources,
process handles and clean shutdown.

## Client-entity rule

WinQuake allocates fixed dynamic/static client arrays and advances
`cl_num_entities` as higher dynamic entity numbers are first observed.
MiniQuake stores only the reached prefix. Therefore the sparse client table may
catch up to an already existing server Edict high-water during the measured
window. It may not create a new static offset or grow beyond the static offset
that already existed at the baseline.

```text
limit = max(server_before, server_after)
      + max(0, client_before - server_before)
```

The idle listen soak still rejects any server Edict high-water growth. Heap,
socket, queue, endpoint, audio and handle limits are unchanged.

Contract: `stability_109_frozen_v1`, fingerprint `0xd0e3c03f`.
