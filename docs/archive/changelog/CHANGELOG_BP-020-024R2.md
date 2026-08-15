# MiniQuake BP-020–BP-024R2

Datum: 2026-07-25  
Elternlieferung: BP-020–BP-024R1  
Engine-Paket: BP-024R2  
Protocol-Status: `protocol15_frozen_v1`  
QuakeC-Status: `quakec_109_frozen_v1`

## Anlass

Die R1-Windows-Abnahme kompilierte den vollständigen Block und bestätigte sämtliche
historischen Protocol-15-, Core-, Milestone-, VM-, Builtin- und Closure-Gates.
Zwei QuakeC-Restfehler blieben:

1. Das originale `id1/progs.dat` wurde wegen der falschen Zusatzregel
   `parameterWords <= locals` bei `SUB_AttackFinished` abgelehnt.
2. `ED_Write` erreichte beim schrittweisen Erzeugen eines Save-Text-Paars noch
   eine `void`-Stringkonkatenation.

Der Trace brach deshalb bereits vor Frame 0 ab.

## Änderungen

### BP-020 / `progs.dat`

- Produktionsladen und strikter Audit sind getrennt.
- `parse()` führt nur loaderrelevante Sicherheitsprüfungen aus.
- `validateProgram()` bleibt als expliziter strenger Audit erhalten.
- Die falsche Beziehung zwischen Parameterwörtern und `dfunction_t.locals`
  wurde entfernt.
- Parameterziele werden stattdessen gegen den tatsächlichen globalen
  Speicherbereich geprüft.
- Bytecodefunktionen mit Parametern und `locals == 0` sind zulässig.
- Builtin-Signaturen mit Parametern und `locals == 0` bleiben zulässig.
- Das echte Stock-`progs.dat` durchläuft zusätzlich den expliziten strikten Audit.
- Drei neue Randfälle sind in den bestehenden 18 Fixtures enthalten.

### BP-022 / Edict- und Save-Text

- QuakeC-Werte werden zuerst typisiert serialisiert.
- Feldname, Wert und Ausgabeprefix werden vor jeder Konkatenation auf
  `string` geprüft.
- `ED_Write`, `ED_WriteGlobals` und der Savegame-Writer verwenden denselben
  `appendQuotedPair`-Pfad.
- Edict- und Globaldefinitionen werden über eigene, schrittweise Helfer
  angehängt.
- Die bestehenden 22 Fixtures prüfen nun exakte Ausgabe, Savegame-Parität und
  die kontrollierte Ablehnung eines `void`-Werts.

### Diagnose und Lieferung

- Neue Paketkennung `BP-024R2` und Lieferrevision `BP-020-024R2`.
- Alle Test-, Build- und Ergebnislogs verwenden den Präfix `bp020-024r2`.
- Das R1-Ergebnis und seine erste Fehlergrenze sind im Paket dokumentiert.
- `patches/BP-024R2.diff` enthält ausschließlich die R2-Revision gegen R1.

## Unverändert

- Protocol-15-Fingerprint und sämtliche eingefrorenen Protocol-Dateien.
- QuakeC-Contract-Fingerprint `0xbc89cbf1`.
- Builtin-Fingerprint `0xb86a0245`.
- Anzahl der Blockfixtures: 98 plus ein echtes Stock-`progs.dat`-Gate.
- Quake-Spieldaten sind nicht Bestandteil der Lieferung.
