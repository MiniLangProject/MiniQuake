# BP-045–BP-049R2 Windows result analysis

## Result

The R2 archive completed 110 of 111 acceptance steps successfully. Build,
all inherited runtime suites, installed `id1/start`, 300 headless frames, two
byte-identical 128-frame compatibility traces and UDP loopback passed.

The only failing step was the exact comparison of two independent visible
render-evidence runs.

```text
trace_sha256=b2589f2712b0aed42f31b1a35ebb4837c211391ba3e8d8888c422242d051af28
trace_rolling_hash=d905b042
render_a_pixel_hash=3a409255
render_b_pixel_hash=6dc1f987
render_a_non_black=305306
render_b_non_black=305187
render_ssim=0.7532948781615113
render_mae=7.378901909722222
render_psnr=26.517591731300723
```

Result archive:

```text
MiniQuake_BP-045-049R2_RESULTS_20260727-231227.zip
e1feebede5c28fed87dc673c8d3b05363da230fe18afdb174fcb212861b8ad27
```

## First useful distinction

The compatibility traces were exactly equal, so the deterministic engine path
was stable. The visible evidence images were not merely subject to a few GPU
rounding differences: the captures showed different player/weapon states and
HUD ammunition (22 in one process, 24 in the other), together with broad scene
motion. This establishes a simulation-input difference before rasterization.

## Root cause

`--render-evidence` needs a real OpenGL window, so its session was not marked
headless. The interactive port intentionally offers asynchronous desktop input
polling (`IN_PollButtonCommands`, mouse and joystick movement). That convenience
path can observe input while the two evidence windows run. Original WinQuake
only consumes input events delivered to its game window, and deterministic
capture must not inherit ambient desktop state.

R2 launched the evidence session without `-nomouse`, `-nojoy` or a dedicated
input-suppression flag. This is the only code path that explains both the
identical headless traces and the visibly different ammunition/view state.
The exact physical key or mouse button was not recorded, but the captured HUD
and weapon state make live input the strongly supported cause.

## R3 correction

R3 keeps the visible window but launches with `-nolan -nomouse -nojoy -noinput`.
The host clears input state before capture and on every evidence frame, and it
disables both live button polling and device movement when `-noinput` is set.
