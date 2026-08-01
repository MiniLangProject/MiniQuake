# MiniQuake BP-060–BP-064

This block closes the observable WinQuake 1.09 network and Windows-platform
layer.

- **BP-060:** public NET lifecycle, qsocket pool, poll queue and active host port.
- **BP-061:** Protocol 3 control messages, discovery cache, server rules and connect classification.
- **BP-062:** WinSock byte order, partial IP syntax, address comparison and landriver state.
- **BP-063:** `sys_win.c`, QHOST/conproc and dedicated WinMain lifecycle.
- **BP-064:** frozen cross-layer contract and independent-process UDP handshake evidence.

Candidate contract:

```text
network_platform_109_frozen_v1
fingerprint=0xb3ec7589
```
