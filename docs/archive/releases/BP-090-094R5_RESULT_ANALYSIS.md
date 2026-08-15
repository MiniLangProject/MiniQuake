# BP-090–BP-094R5 result analysis

## Reported infrastructure failure

The previous unattended run stopped with a timeout while Windows displayed an application network-access consent dialog for Quake. Because nobody was present to approve the dialog, the server/client pair never completed.

This is an infrastructure failure rather than evidence of a Protocol-3 or Protocol-15 incompatibility. The R4 harness launched the original executable without an explicit `-ip` argument. In the original `net_wins.c`, the absence of `-ip` selects `INADDR_ANY`; `WINS_OpenSocket` then binds sockets to that address. A newly extracted historical executable listening on all interfaces can trigger Windows Defender Firewall's interactive approval UI.

## R5 correction

R5 passes `-ip 127.0.0.1` to both original GLQuake interoperability roles and configures both MiniQuake interoperability-only modes to bind to the same loopback address. The visual reference process receives `-noudp -noipx` because demo playback and screenshots require no network stack.

The result is an unattended, local-only test topology:

```text
127.0.0.1 original GLQuake server <-> MiniQuake client 127.0.0.1
127.0.0.1 MiniQuake server        <-> original GLQuake client 127.0.0.1
original visual reference           network disabled
```

The test does not add persistent firewall rules and does not require elevation. Third-party endpoint-security products may still impose their own policy, but Windows sockets are no longer opened on LAN/WLAN/VPN interfaces by the R5 harness.
