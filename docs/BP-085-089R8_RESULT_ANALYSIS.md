# BP-085–BP-089R7 result analysis

## Result boundary

R7 passed the complete Windows build, every unit/regression suite, `id1`,
`rogue`, `hipnotic`, retail demo/save evidence, both 128-frame traces, all four
64-frame black-port map pairs and the normal 5,000-frame host soak.

Only the 5,000-frame listen-server resource soak was classified as failed.

```text
heap live blocks:      113916 -> 113928   (+12; allowance +512)
heap live bytes:    115647808 -> 115648656 (+848; allowance +65536)
server Edicts:              67 -> 67
client entity slots:        66 -> 67
active clients:              1 -> 1
active QSockets:             2 -> 2
free QSockets:               7 -> 7
queued messages:             1 -> 1
UDP endpoints:               1 -> 1
process handles:           279 -> 279
```

Every leak-sensitive resource gate passed. The old predicate failed only
because it required the sparse client table never to increase.

## Why 66 -> 67 is valid

Original WinQuake owns a fixed `cl_entities[MAX_EDICTS]` array and tracks the
highest observed dynamic entity number in monotonic `cl_num_entities`.
MiniQuake materializes only the reached prefix. During the measured window the
server high-water already remained at 67 while the client first observed the
last existing dynamic slot and caught up from 66 to 67.

This is bounded topology discovery, not unbounded resource accumulation.

## R8 correction

R8 permits only this bounded catch-up:

```text
max(server Edict high-water before/after)
+ static-entity offset already present at the baseline
```

It continues to reject:

- any server Edict high-water growth during the idle soak;
- client-table growth beyond that derived limit;
- values beyond `MAX_EDICTS + MAX_STATIC_ENTITIES`;
- heap growth beyond the existing allowances;
- socket, queue, endpoint, audio, client or handle growth.

The observed R7 case is a bound golden fixture:

```text
server: 67 -> 67
client: 66 -> 67
limit:  67
result: stable
```

The revised stability contract fingerprint is `0xd0e3c03f`.
