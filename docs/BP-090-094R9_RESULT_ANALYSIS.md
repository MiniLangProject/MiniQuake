# BP-090–BP-094R8 result analysis

The R8 package passed all internal tests but failed while comparing the two normalized original-server/MiniQuake-client reports. Pair A printed `UDP connect timed out`, then entered MiniQuake's local demo/start fallback and reached local signon 4. Pair B connected to the original GLQuake server over UDP.

The old acceptance condition checked only `connected=true`, `spawned=true`, `signon=4` and `protocol=15`. That allowed the local fallback to masquerade as external interoperability. The resulting states were therefore legitimately different:

- Pair A: `view_entity=1`, `models=86`, `sounds=86`
- Pair B: `view_entity=2`, `models=102`, `sounds=81`

R9 requires target-UDP provenance in both MiniQuake and the PowerShell harness. A failed first attempt is rejected and retried while the original GLQuake listen server finishes initialization.
