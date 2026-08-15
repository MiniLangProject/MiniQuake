# BP-090–BP-094R9

R9 rejects false-positive original-server interoperability caused by a failed UDP attempt falling through to MiniQuake's local demo/start path. A successful BP-091 result now requires a live UDP socket to the requested peer, no active local server, no local-authoritative client and no demo playback. The PowerShell harness independently requires the same provenance markers before accepting a signon-4 summary.

No renderer, gameplay, QuakeC, audio or native-bridge semantics were changed.
