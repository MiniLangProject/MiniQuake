# BP-060–BP-064R6 Windows acceptance

The uploaded result archive `MiniQuake_BP-060-064R6_RESULTS_20260729-134030.zip`
completed the network/platform block successfully.

```text
result archive SHA-256:
5f9812a0527ea426889b4ae0d08e6e40bb2b715e32e232ebe215dd3ab99674a1

compatibility trace SHA-256:
03656a0e9f3b13d4430014de3787053c204acdd1e7f2e33c292ee8ee2b47c8cc

trace rolling hash:
d905b042

retail audio evidence SHA-256:
896049a03f26b1db4ddc1550d35d1cacb5f7e0f0c900b0ee36393c8ab8bd0501

render TGA SHA-256:
9047f96e9bef8e06035119ff71ddfe7ad4dcad89b4740c66618252a13cd166fb

network client report SHA-256:
50534266c750fa20058c82ce48baca953b0107106dc24fd69c5854fc3364ba96
```

Both Protocol-3 server/client pairs reported exit code 0, PASS markers on both
sides and empty server stderr. Installed-game validation, 300 headless frames,
two byte-identical 128-frame traces, exact framebuffer evidence and Winsock UDP
loopback also passed. `network_platform_109_frozen_v1` / `0xb3ec7589` is therefore
an accepted parent contract for BP-065–BP-069.
