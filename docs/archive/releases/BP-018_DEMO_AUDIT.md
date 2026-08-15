# BP-018 – Demo-Audit

## Originalpfade

- `cl_demo.c`
- `cl_main.c:CL_GetMessage`
- `host.c` – Record-Commandintegration

## Gebundene Semantik

- erste Zeile: C-`atoi`-kompatibler CD-Track,
- pro Frame: little-endian 32-Bit-Länge, drei Binary32-Viewangles, Payload,
- Payload bis einschließlich `MAX_MSGLEN`,
- isoliertes `svc_nop` wird vor Parser und Recorder verworfen,
- compound NOP-Payload bleibt erhalten,
- `CL_Stop_f` schreibt `svc_disconnect`,
- optionaler Mapwechsel erfolgt vor dem Öffnen der Demodatei,
- Timedemo schließt den ersten Startframe aus,
- abgeschnittene und übergroße Frames werden kontrolliert abgelehnt.

Das Oracle bindet elf Semantikzeilen und einen vollständigen Framevektor;
19 MiniLang-Fixtures prüfen Roundtrip und Fehlergrenzen.
