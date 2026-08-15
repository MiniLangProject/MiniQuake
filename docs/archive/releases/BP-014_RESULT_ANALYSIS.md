# BP-014 – Auswertung der Windows-Abnahme

Ergebnisarchiv: `MiniQuake_BP-014_RESULTS_20260725-103243.zip`  
SHA-256: `b4e2c262fd6c433a1bff6fd705e914b0ab50af078002a851a11cae390771b1a1`  
Ausgewertetes Quellpaket: `MiniQuake_BP014_Protocol15RuntimeEvents_20260725.zip`  
SHA-256: `0dc6a82f4d08b94f4d348615c32a33e4a1717e52f88a62821f8e8df02b06d149`

## Ergebnisgrenze

| Schritt | Ergebnis |
|---|---:|
| Paket-, Manifest-, Package- und ABI-Prüfung | PASS |
| Protocol-15-Wirevektoren | 13/13 PASS |
| Command-/Fast-Update-Vektoren | 14/14 PASS |
| Serverdaten-Vektoren | 11/11 PASS |
| Event-Vektoren und Semantikfälle | PASS |
| Runtime-Event-Vektoren und Semantikfälle | 10/10 und 49/49 PASS |
| MiniLang-Kompilierung aller neun EXE-Ziele | PASS |
| Core-Tests | 16/16 PASS |
| Meilensteintests | FAIL bei 12/24 |
| spätere MiniLang-Testprogramme | nicht erreicht |
| `id1/start`, Headless-Lauf und Doppeltrace | nicht erreicht |
| UDP-Loopback | nicht erreicht |

Die erste Laufzeitabweichung lautet:

```text
[12/24] client effects
FAIL: beam expiry: expected 0, got 1
```

## Technische Ursache

Die Fixture erzeugt einen Beam bei `currentTime=1.0`. Seine originale
Ablaufzeit ist `1.2f`; bei `currentTime=2.0` darf er nicht mehr in der aktiven
Effektliste erscheinen.

Das C-Original trennt dabei implizit zwei Sichten:

```c
/* CL_ParseBeam: entity replacement precedes free/expired-slot search */
if (b->entity == ent) { ... return; }

/* CL_UpdateTEnts: expired slots are not rendered */
if (!b->model || b->endtime < cl.time)
    continue;
```

BP-014 änderte `client_effects.pruneTemporary` so, dass die kompakte Liste nur
normalisiert, aber nicht mehr nach Ablaufzeit gefiltert wurde. Diese Änderung
war für die Same-Entity-Priorität des gespeicherten 24-Slot-Zustands gedacht,
vermischte jedoch den Speicherzustand mit der aktiven Render-/API-Sicht.

## Klassifikation

`P15-B1`: Adapter- und Zustandsmodellfehler im neu geänderten Beam-Pfad.

- kein Compilerfehler,
- kein nativer ABI-Fehler,
- kein Fehler der 10 Wirevektoren oder 49 Oraclefälle,
- kein Hinweis auf QuakeC-, Physik-, allgemeine Renderer- oder Netzwerkfehler,
- präzise durch eine bestehende End-to-End-Meilensteinfixture reproduziert.

## Reparaturkriterium

Der Port muss den festen Beamzustand einschließlich abgelaufener Slots für
`CL_ParseBeam` erhalten, aber eine getrennte aktive Sicht für `CL_UpdateTEnts`
und `pruneTemporary` liefern. Gleichheit bleibt aktiv; nur
`endTime < currentTime` gilt als abgelaufen. Die bestehende Meilensteinfixture
darf nicht angepasst werden.
