# MiniQuake BP-014R1 – Changelog

Datum: 2026-07-25  
Elternpaket: `BP-014`  
Zielprofil: `compat_109`

## Anlass

Die Windows-Abnahme von BP-014 bestand die statische Paketprüfung, alle fünf
Protocol-15-Oracle-/Checkerstufen, die Kompilierung sämtlicher neun EXE-Ziele
und 16/16 Core-Tests. Sie stoppte im bestehenden Meilensteintest 12 mit:

```text
[12/24] client effects
FAIL: beam expiry: expected 0, got 1
```

Die nachfolgenden Diagnose-, Wire-, Command-, Serverdaten-, Event- und
Runtime-Event-Testprogramme sowie Echtdatenlauf, Doppeltrace und UDP-Loopback
wurden wegen des frühen Meilensteinabbruchs nicht mehr ausgeführt.

## Ursache

Das Original verwendet den festen Zustand `cl_beams[MAX_BEAMS]` für zwei
unterschiedliche Aufgaben:

1. `CL_ParseBeam` behält auch abgelaufene Einträge, weil die erste Suche stets
   eine vorhandene Entityzuordnung ersetzt.
2. `CL_UpdateTEnts` überspringt abgelaufene Einträge und stellt sie weder dar
   noch als aktive Effekte bereit.

BP-014 bewahrte abgelaufene kompakte Beamdatensätze korrekt für die
Same-Entity-Priorität auf, lieferte diese gespeicherte Tabelle jedoch zugleich
als aktive Effektliste zurück. Dadurch blieb bei `currentTime > endTime` ein
Beam für den Meilensteintest sichtbar.

## Korrektur

- `protocol_transients.activeCompactBeamList` erzeugt eine gefilterte aktive
  Sicht über dem erhaltenen 24-Slot-Zustand.
- `client_effects.retainTemporarySlots` normalisiert und erhält die Slotbelegung
  einschließlich abgelaufener Entityzuordnungen.
- `client_effects.pruneTemporary` bildet ausschließlich die
  `CL_UpdateTEnts`-Sicht und entfernt strikt abgelaufene Beams.
- `client_effects.process` arbeitet weiterhin mit dem erhaltenen Zustand und
  zerstört die Same-Entity-Slotzuordnung nicht.
- Die bestehende Meilensteinfixture bleibt unverändert.

## Regressionsevidenz

Die Runtime-Event-Suite wurde von 27 auf 28 Fixtures erweitert. Die neue
Fixture prüft getrennt:

- aktiv bei `endTime == currentTime`,
- unsichtbar bei `endTime < currentTime`,
- weiterhin vorhandene Slotbelegung nach Ablauf,
- Ersetzung desselben Entitybeams im ursprünglichen Slot.

Der Verifier besitzt zusätzlich den Vertrag
`protocol15_beam_state_view_contract`, der diese Trennung und die unveränderte
Meilensteinreproduktion bindet.

## Unverändert

BP-014R1 ändert keine Protocol-15-Wirebytes, keine Goldenvektoren, keine
Sound-, QuakeC-, Physik-, Renderer-, Demo-, Savegame- oder Netzwerksemantik.
Die 10 BP-014-Wirevektoren und 49 semantischen Oraclefälle bleiben unverändert.
