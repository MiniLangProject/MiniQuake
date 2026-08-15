# Changelog BP-019 – Protocol-15-Abschluss und Freeze

Elternstand: **BP-018**

## Änderungen

- Neue kanonische Metadaten in `protocol15_freeze.ml`:
  33 gültige SVC-Kommandos, vier CLC-Kommandos, 14 Temporary-Entity-Typen,
  Fast-Update-, Clientdata- und Soundmasken.
- Der geprüfte Contract besitzt den Fingerprint `0x0cf1e12a` und den Status
  `protocol15_frozen_v1`.
- Eine Cross-Layer-Fixture transportiert eine mehrfragmentige Nachricht durch
  Datagramm, Demo-Serialisierung und Clientparser.
- Weitere Fixtures binden Signon, reservierte Befehle, Sequence-Wrap,
  Keepalive/Disconnect, deterministische Wiederholung und Größenlimits.
- `tools/check_protocol15_closure.py` führt alle neun Protocol-Komponenten-
  Checker zusammen und bindet Hashes der 15 autoritativen Dateien.
- Historische Komponentenchecker wurden paketunabhängig wiederverwendbar
  gemacht; die finale Paketidentität bleibt Aufgabe des Gesamtverifiers.

## Evidenz

- C-Oracle: `tools/oracle/protocol15_closure_oracle.c`
- Goldenmodell: `audit/protocol15_closure_golden.json`
- Freeze-Dokument: `audit/protocol15_freeze.json`
- MiniLang-Laufzeitfixtures: **15**
- Teilpatch: `patches/BP-019.diff`
