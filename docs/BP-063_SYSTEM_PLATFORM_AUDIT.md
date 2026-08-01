# BP-063 – sys_win, conproc and platform lifecycle audit

BP-063 freezes the observed WinQuake command-line parser, memory selection,
performance-counter timer, dedicated-console editor, QHOST request protocol,
message sleeps and WinMain lifecycle.  Native x64 wrappers remain implementation
details; the observable state and protocol stay compatible.
