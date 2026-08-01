# Auswertung der BP-000R1-Abnahme

Ausgewertetes Ergebnisarchiv:

```text
MiniQuake_BP-000R1_RESULTS_20260724-122402.zip
SHA-256 c7dd4963d21145c51ae839558032f51663b7a1dabd6a45ebd554b283b4006abc
```

## Ergebnis

| Schritt | Status |
|---|---:|
| Statische Paketprüfung | PASS |
| Spiel- und Testkompilierung | PASS |
| 16 Core-Tests | PASS |
| 24 Milestone-Tests | PASS |
| Haupt- und Textbridge-Hashprüfung | PASS |
| Paketkennung und Text-ABI | PASS |
| Installierte Quake-Daten, `id1/start` | PASS |
| Headless-Runtime, 120 Frames | PASS |
| Winsock-UDP-Loopback | PASS |

Die Abnahme lief unter Windows NT `10.0.26200.0`, AMD64 und Windows PowerShell
`5.1.26100.8894`. Die erzeugte `MiniQuake.exe` hatte den SHA-256-Wert
`a69a835fcf091482906f48e6eff25b4f57d73a897a973dab4207974bada8bdce`.

Die native Hauptbridge und die gepufferte Textbridge entsprachen exakt den
Paketdateien:

```text
miniquake_native.dll
3e7a6f09aa4836875b243530908b309f3245ffc267ecef06b2adbc33b02c0588

miniquake_text.dll
cfc90c71cb63ef3aeff17322d23e85bc85557dd536a42432260be0d23eb374ae
```

## Schlussfolgerung

Die in BP-000 festgestellte Zugriffsverletzung im direkten `cstr`-Rückgabepfad
ist durch die caller-owned Textbridge behoben. BP-000R1 ist damit die bestätigte
Runtime-Baseline und entsperrt BP-001.
