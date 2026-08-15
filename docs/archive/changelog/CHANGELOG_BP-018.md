# Changelog BP-018 – Demo-Framing und Wiedergabe

Elternstand: **BP-017**

## Änderungen

- `record <name> <map> <track>` verwendet für den Track die originale
  C-`atoi`-Semantik statt `toNumber`.
- Isolierte `svc_nop`-Keepalives werden wie in `CL_GetMessage` intern
  übersprungen und weder geparst noch in Demos geschrieben.
- Mehrbyte-Payloads, die mit `svc_nop` beginnen, bleiben vollständig erhalten.
- Beim Record-Befehl erfolgt der optionale Mapwechsel vor dem Öffnen der
  Demodatei, entsprechend `CL_Record_f`.
- Demoheader, little-endian Framegröße, drei Viewangles, `MAX_MSGLEN`,
  `svc_disconnect` beim Stoppen und Timedemo-Grenzen sind gebunden.

## Evidenz

- C-Oracle: `tools/oracle/protocol15_demo_oracle.c`
- Goldenmodell: `audit/protocol15_demo_golden.json`
- MiniLang-Laufzeitfixtures: **19**
- Teilpatch: `patches/BP-018.diff`
