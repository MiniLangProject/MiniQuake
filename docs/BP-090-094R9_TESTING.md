# BP-090–BP-094R9 Windows test

Use the same prerequisites and command-line arguments as R8, but run `TEST_BP-090-094R9.ps1`. The original-server direction may show one rejected attempt while GLQuake initializes. An accepted attempt must print:

```text
transport=udp
local_server_active=false local_authoritative=false demo_playback=false
network_provenance=target_udp
```

The two accepted normalized reports must then be byte-identical. All existing bidirectional interop, visual SSIM, soak, retail-asset and regression gates remain enabled.
