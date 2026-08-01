# BP-052 envmap and timerefresh audit

Source-guided against `gl_rmisc.c:R_Envmap_f` and `R_TimeRefresh_f`.

Bound behavior:
- six 256x256 RGBA views;
- orientations yaw 0/90/180/270 and pitch -90/+90;
- raw files `env0.rgb` through `env5.rgb`;
- exactly 262144 bytes per face;
- timerefresh renders 128 yaw steps and computes `128 / elapsed`;
- relevant arithmetic is stored at Binary32 boundaries.

Asset-free fixtures: 20.
