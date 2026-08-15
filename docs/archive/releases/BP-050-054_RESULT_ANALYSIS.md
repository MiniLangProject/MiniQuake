# BP-050–BP-054 Windows result analysis

## Result archive

```text
MiniQuake_BP-050-054_RESULTS_20260728-083416.zip
SHA-256: 4e2afe7a4266486fd3b60c6ed5d5e5c4995c34fa96234979b3dd11c2733d61e9
```

## Boundary

The cumulative Windows build, installed-game validation, 300-frame runtime,
128-frame deterministic trace pair, framebuffer evidence, three-scenario render
corpus, and UDP loopback all completed successfully.  The only failing
independent group was the final BP-054 closure fixture.

```text
[21/24] special cvar defaults
FAIL: Cannot access member 'commandLine' on non-struct value
```

The test summary contained 131 steps: 129 PASS, one FAIL, and one optional
Original-GLQuake comparison SKIPPED because no external reference corpus was
supplied.

## Confirmed runtime evidence

```text
compat trace SHA-256: bbfb59d8d0225a9a0401f3beb59a0422a57f898aebc35f239440e8cece742ad0
rolling hash:          d905b042
single evidence TGA:   81c0f9148bf7284cb61551e787c646e58aecd0778821f181c4fb6fcf7e04facd
single evidence SSIM:  1.0
```

The three deterministic A/B evidence pairs were exact:

```text
start-064:  29e49f49ba13745381e5681315a930afae3913901c575b8468e01650993acba4
start-128:  81c0f9148bf7284cb61551e787c646e58aecd0778821f181c4fb6fcf7e04facd
e1m1-128:   d2ff291b9b53145758d3309fce541742c1053ade2b0b128e20d15a5f1308ffb0
```

## Root cause

`tests/render_special_closure_tests.ml` called:

```ml
bp054Host.createCvars("", true)
```

`host.createCvars(commandLine, registered)` expects a `CommandLine` struct.  If
`registered` is true it reads `commandLine.commandLine`.  The fixture passed a
plain string, so the runtime correctly rejected the member access.

The production host path already passes the canonical command-line object.  No
engine, renderer, protocol, QuakeC, physics, lifecycle, or native-bridge defect
was observed.

## R1 correction

The fixture now creates and passes the canonical value:

```ml
commandLine = bp054Common.create([])
registry = bp054Host.createCvars(commandLine, true)
```

`tools/check_render_special_054.py` also binds this adapter and rejects the old
string call during the static preflight.

## Classification

```text
classification: test-adapter defect
production source changed: no
native source changed: no
frozen contracts changed: no
engine package: BP-054
corrected delivery: BP-050-054R1
```
