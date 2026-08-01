# MiniQuake BP-012R1 – Changelog

Datum: 2026-07-25  
Elternpaket: `BP-012`  
Zielprofil: `compat_109`

## Anlass

Die Windows-Abnahme von BP-012 bestand Paketprüfung, alle drei Protocol-15-
Oracle-/Checkerstufen, den vollständigen Build und 16/16 Core-Tests. Sie stoppte
im Meilensteintest 19 mit:

```text
FAIL: clientdata onground: expected true, got false
```

Alle sieben MiniLang-Zielprogramme waren zu diesem Zeitpunkt erfolgreich
kompiliert. Diagnose-, Wire-, Command- und Serverdaten-Testprogramme wurden
wegen des frühen Meilensteinabbruchs nicht mehr ausgeführt; Echtdatenlauf,
Doppeltrace und UDP-Loopback wurden ebenfalls nicht erreicht.

## Ursache

Das originale `SV_WriteClientdataToMessage` bildet `SU_ONGROUND` aus
`ent->v.flags & FL_ONGROUND`. MiniQuake besitzt für den lokalen Adapterzustand
sowohl `PlayerState.onGround` als auch `PlayerState.flags`. Die BP-012-
Produktionswriter lasen in PlayerState-only-Pfaden nur `flags`. War die
Bool-Mirrorvariable bereits aktuell, das Flag aber noch nicht synchronisiert,
wurde `SU_ONGROUND` ausgelassen.

## Korrektur

- `server.playerProtocolFlags(player)` rekonstruiert ausschließlich das
  gespiegelte `FL_ONGROUND`-Bit aus `PlayerState.onGround` und erhält alle
  übrigen Flagbits.
- `server.protocolClientData` und `server.writeClientDataWithFlags` verwenden
  diesen Adapter in Pfaden ohne autoritativen QuakeC-Edict.
- `sv_main.SV_WriteClientdataToMessage` verwendet denselben Wert als Fallback.
- Existiert ein QuakeC-Kontext, gewinnt weiterhin das echte QuakeC-Feld
  `ent->v.flags`, entsprechend dem C-Original.
- Der inverse Fall wird ebenfalls korrigiert: ein veraltetes gesetztes
  `FL_ONGROUND` wird bei `onGround == false` nicht gesendet.

## Regressionsevidenz

Die Serverdaten-Laufzeitsuite wurde von 16 auf 17 Fixtures erweitert. Sie prüft:

- Setzen des Bits bei `onGround=true` und fehlendem Flag,
- Löschen des Bits bei `onGround=false` und veraltet gesetztem Flag,
- den integrierten Writer,
- das direkte `sv_main`-Pendant,
- den vollständigen Client-Roundtrip bis `ClientState.player.onGround`.

Die bestehende Meilensteinfixture, die den Windows-Fehler ausgelöst hat, bleibt
unverändert und dient als zusätzliches End-to-End-Gate.

## Unverändert

BP-012R1 ändert keine Golden-Wirebytes, keine Protocol-15-Konstanten, keine
QuakeC-, Physik-, Renderer-, Audio-, Demo- oder Savegame-Semantik. Die elf
BP-012-Serverpayloadvektoren und 25 Planungs-/Grenzfälle bleiben byteidentisch.
