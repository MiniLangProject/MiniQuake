# BP-032 demo lifecycle audit

Reference: `cl_demo.c` from GLQuake/WinQuake 1.09. The audit binds the 16-byte
per-message header, little-endian payload length, three binary32 view angles,
record-before-connect rules, final `svc_disconnect`, keepalive filtering,
message pacing and second-frame timedemo clock capture.
