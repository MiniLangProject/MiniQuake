# BP-060–BP-064R4 Windows result analysis

The uploaded result archive `MiniQuake_BP-060-064R4_RESULTS_20260729-094748.zip`
has SHA-256 `b3cd0e6fc922d25352da8911b8c5d5a006c7896e5db93cc14b14926d84dd95af`.

## Confirmed PASS boundary

- all 65 Windows targets compiled;
- all inherited and BP-060..064 runtime groups passed;
- installed Quake data validation passed;
- 300 headless frames passed;
- retail audio evidence A/B was byte-identical (`896049a03f26b1db4ddc1550d35d1cacb5f7e0f0c900b0ee36393c8ab8bd0501`);
- compatibility traces A/B completed 128/128 frames and were byte-identical
  (`03656a0e9f3b13d4430014de3787053c204acdd1e7f2e33c292ee8ee2b47c8cc`, rolling hash `d905b042`);
- both 640×480 render captures completed and their TGA files are byte-identical
  (`9047f96e9bef8e06035119ff71ddfe7ad4dcad89b4740c66618252a13cd166fb`, SSIM 1.0 when compared with the corrected CLI).

## Failure

The runner invoked `compare_render_evidence.py` with `--json-output`, while the
utility exposed only `--json-out`. `argparse` rejected the unknown option before
cross-process network evidence and the final UDP smoke gate were reached.

This is a delivery/test-wrapper defect. No MiniQuake engine, renderer, network,
audio or native-bridge failure was observed in R4.
