# MiniQuake BP-011 – Protocol-15-Signon, Kommandoströme und Fast Updates

Datum: 2026-07-24  
Elternpaket: `BP-010R1`  
Zielprofil: `compat_109` gegen WinQuake/GLQuake 1.09

## Umfang

- exakte Client-Signonantworten für Stufen 1–3; Stufe 4 erzeugt wie im
  Original keinen zusätzlichen Wirebefehl,
- Server-Signonmarker ausschließlich 1, 2 und 3,
- Signonabschluss beim ersten Fast-Entity-Update,
- `SV_ReadClientMessage` mit signiertem `MSG_ReadChar` und `0xff == -1`,
- gemeinsamer produktiver Writer für baseline-relative Fast Updates,
- `U_MOREBITS`, `U_LONGENTITY`, `U_NOLERP` und `U_EFFECTS` in originaler
  Bitwahl und Feldreihenfolge,
- vollständiger Parserkatalog aller 33 gültigen `svc_*`-Kommandos plus Fast
  Update,
- unabhängiges C-Oracle, Pythonprüfung und 14 MiniLang-Laufzeitfixtures.

## Produktionsänderungen

`protocol_signon.ml` kapselt `CL_SignonReply`; `protocol_update.ml` kapselt die
Bitwahl und Serialisierung aus `SV_WriteEntitiesToClient`. Sowohl der normale
Serverpfad als auch das `sv_main`-Pendant verwenden denselben Writer.
`EntityBaseline` trägt nun auch das im Original vorhandene `effects`-Feld; beim
Erzeugen einer Baseline bleibt es wie beim nullinitialisierten C-Zustand null.

Der lokale Host wartet nach `begin` auf das erste normale Serverdatagramm,
statt ein nicht existentes `svc_signonnum 4` zu erwarten.

## Evidenz

- 14 C-Goldenvektoren,
- 57 geprüfte Protocol-Konstanten,
- 34 geordnete Parserereignisse,
- 14 neue MiniLang-Fixtures,
- alle 15 BP-010R1-Wirefixtures bleiben Regressionstore.

## Noch offen

Die Windows-Kompilierung und Runtime-Abnahme dieses Pakets erfolgt über
`TEST_BP-011.ps1`. Das nächste Paket erweitert nach grüner Abnahme die
produktionsnahen Serverdatagramme (`svc_clientdata`, Sound, Baselines,
Serverinfo und Overflowgrenzen).
