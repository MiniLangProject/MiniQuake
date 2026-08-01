# BP-036 audit — `view.c` and `chase.c`

The block binds Quake command-number parsing, refdef input/output, chase camera
trace destination, pitch replacement and preservation of the already computed
view yaw/roll. It does not change accepted gameplay or protocol state.
