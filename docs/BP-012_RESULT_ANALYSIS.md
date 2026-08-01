# BP-012 – Auswertung der Windows-Abnahme

Ergebnisarchiv: `MiniQuake_BP-012_RESULTS_20260725-002822.zip`  
SHA-256: `220c23189a70cb98df6aada652a4bdacf8586d99801019b98cc5e00868000a1a`  
Ausgewertetes Quellpaket: `MiniQuake_BP012_Protocol15ServerData_20260724.zip`  
SHA-256: `1a0a508afd4cdf327543d79208cac97151a4007080a285887b7236884d6deece`

## Ergebnisgrenze

| Schritt | Ergebnis |
|---|---:|
| Paket-, Manifest-, Package- und ABI-Prüfung | PASS |
| Protocol-15-Wirevektoren | 13/13 PASS |
| Protocol-15-Command-/Updatevektoren | 14/14 PASS |
| Protocol-15-Serverdatenvektoren | 11/11 PASS |
| MiniLang-Kompilierung aller sieben EXE-Ziele | PASS |
| Core-Tests | 16/16 PASS |
| Meilensteintests | FAIL bei 19/24 |
| Diagnose-, Wire-, Command- und Serverdaten-EXE-Läufe | nicht erreicht |
| `id1/start`, Headless-Lauf und Doppeltrace | nicht erreicht |
| UDP-Loopback | nicht erreicht |

Die erste und einzige Laufzeitdiagnose lautet:

```text
[19/24] client inventory/view weapon protocol
FAIL: clientdata onground: expected true, got false
```

## Technische Ursache

Die fehlschlagende Fixture setzt bewusst:

```ml
sourcePlayer.onGround = true
```

und serialisiert anschließend über `server.writeClientData`. In BP-012 reichte
dieser Adapter jedoch unverändert `player.flags` an den gemeinsamen
`ProtocolClientData`-Writer weiter. `movement.create` initialisiert `flags` mit
`FL_CLIENT`, nicht mit `FL_ONGROUND`; daher fehlte `SU_ONGROUND` im erzeugten
`svc_clientdata`.

Das C-Original entscheidet anhand von:

```c
if ((int)ent->v.flags & FL_ONGROUND)
    bits |= SU_ONGROUND;
```

Im vollständigen QuakeC-Serverzustand ist dieses Feld autoritativ. MiniQuakes
lokale PlayerState-Adapter besitzen jedoch eine zusätzliche Bool-Spiegelung,
die zwischen Synchronisationspunkten aktueller sein kann. Der Fehler liegt
somit an der Adaptergrenze, nicht am gemeinsamen BP-012-Wirewriter oder am
Clientparser.

## Klassifikation

`P15-A1`: Produktionsadapterfehler in neuem BP-012-Clientdata-Pfad.

- kein Compilerfehler,
- kein nativer ABI-Fehler,
- kein Hinweis auf QuakeC-, Physik-, Render- oder Netzwerkfehler,
- keine Abweichung der elf C-abgeleiteten Goldenpayloads,
- präzise reproduziert durch eine bestehende End-to-End-Fixture.

## Reparaturkriterium

Die Korrektur muss `FL_ONGROUND` aus `PlayerState.onGround` spiegeln, solange
kein autoritativer QuakeC-Edictwert vorliegt. Bei vorhandenem QuakeC-Kontext
muss weiterhin `ent->v.flags` gewinnen. Sowohl fehlende als auch veraltet
gesetzte Mirrorbits müssen geprüft werden.
