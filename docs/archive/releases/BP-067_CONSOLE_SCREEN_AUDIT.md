# BP-067 console/screen audit

Compared paths: `console.c::Con_NotifyBox` and `gl_screen.c::SCR_ModalMessage`.
The blocking C loop is represented as a nonblocking two-edge state machine: one key down arms acknowledgement and the following key up dismisses the notice.
