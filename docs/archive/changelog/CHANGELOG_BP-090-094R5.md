# MiniQuake BP-090–BP-094R5

## Unattended loopback isolation for original-binary gates

R4 correctly removed the unsafe `-condebug` path, but the external interoperability processes still opened UDP sockets on all local interfaces. On a machine where `GLQUAKE.EXE` or the newly built `MiniQuake.exe` was not yet approved by Windows Defender Firewall, the test could stop behind an interactive network-access dialog and later time out.

R5 makes all mandatory external network evidence strictly local:

- original GLQuake listen server: `-ip 127.0.0.1`
- original GLQuake client: `-ip 127.0.0.1`
- MiniQuake original-interop server: `-ip 127.0.0.1`
- MiniQuake original-interop client: `-ip 127.0.0.1`
- original visual-reference runs: `-noudp -noipx`

The test still uses two independent process pairs in both Protocol-15 directions, but no process needs to expose a listener on LAN, WLAN, VPN or public interfaces. The visual gate initializes no network transport at all.

Process reports now record:

```text
network_scope=loopback_only
bind_address=127.0.0.1
firewall_prompt_expected=false
```

No gameplay, Protocol-15, rendering, QuakeC, audio or native-bridge semantics were changed. The only MiniQuake source change is limited to the dedicated `--original-interop-server` and `--original-interop-client` command modes.
