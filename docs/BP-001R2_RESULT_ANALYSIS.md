# BP-001R2 – Auswertung des Windows-Ergebnisarchivs

Ausgewertetes Archiv:

```text
MiniQuake_BP-001R2_RESULTS_20260724-181843.zip
```

## Abnahmeergebnis

| Gate | Ergebnis |
|---|---:|
| Statische Paketprüfung | PASS |
| MiniQuake-Build | PASS |
| Core-Tests | 16/16 PASS |
| Milestone-Tests | 24/24 PASS |
| Diagnosefixtures | 9/9 PASS |
| `id1/start`-Validierung | PASS |
| 120 Headless-Frames | PASS |
| Trace A | 64/64 Frames, sauber beendet |
| Trace B | 64/64 Frames, sauber beendet |
| UDP-Loopback | noch nicht erreicht, weil der Tracevergleich vorher stoppte |
| Byteidentität A/B | FAIL |

Damit ist der in BP-001R1 beobachtete Sparse-Entity-Abbruch vollständig behoben.
Beide Prozesse erzeugten vollständige Traces, Snapshots, Kontexte und Summaries.
Die neue Abweichung ist eine echte Determinismusabweichung, kein Diagnosecrash.

## Erste Abweichung

Beide Dateien besitzen 65 Zeilen und 46.570 Bytes. Die ersten 15 Framezeilen sind
byteidentisch. Die erste Differenz liegt in Zeile 16 beziehungsweise Frame 15:

| Feld | Trace A | Trace B |
|---|---|---|
| `player_angles` | `c0340000,42b40000,00000000` | `00000000,42b40000,00000000` |
| `qc_globals` | `0cc355ba` | `88636c4a` |
| `qc_edicts` | `96de64b1` | `a8756b6a` |
| `server_edicts` | `d5fd74f4` | `1e32cbb3` |
| `state_hash` | `bbb1f0f8` | `1eed18f5` |

Das erste Pitch-Wort `c0340000` entspricht exakt `-2.8125` Grad. Danach läuft
Trace A wie folgt weiter, während Trace B bei `0` Grad bleibt:

| Frame | Pitch A | Pitch B |
|---:|---:|---:|
| 15 | -2,8125° | 0° |
| 16 | -5,6250° | 0° |
| 17 | -9,84375° | 0° |
| 18 | -12,65625° | 0° |
| 19 | -15,46875° | 0° |
| 20 | -18,28125° | 0° |
| 21 | -18,28125° | 0° |

Die Schrittweite entspricht dem originalen Blicktastenpfad:
`cl_pitchspeed=150` mal `0.02 s` ergibt 3 Grad pro Hostframe; das Protocol-15-
Winkelraster von `360/256 = 1.40625` Grad erklärt die beobachtete Quantisierung.
Die nachfolgenden QuakeC-, Edict- und RNG-Abweichungen sind Folgeeffekte der
abweichenden Spielerblickrichtung.

Die maschinenlesbare Erstdifferenz steht in
`docs/BP-001R2_TRACE_COMPARISON.json`.

## Quellseitige Ursache

Der stärkste kausale Pfad liegt in `host.sendClientIntentions`:

1. Ein Headless-Trace setzt `deviceActive=false`; Maus- und Joystickachsen werden
   dadurch bereits nicht ausgewertet.
2. `pollButtonBindings` blieb jedoch unabhängig von `session.headless` aktiv.
3. `input.buildOriginalMove` rief deshalb weiterhin
   `IN_PollButtonCommands()` auf.
4. Diese Portierungsschicht fragt mit der Win32-Bridge live Tastatur- und
   Maustasten ab und überführt sie in Quakes `kbutton_t`-Zustände.
5. Ein in einem anderen Fenster gedrückter beziehungsweise seit dem letzten
   Poll gemerkter Blicktasten-Impuls kann damit einen ansonsten identischen
   Headless-Lauf verändern.

Original-WinQuake erhält Tastaturereignisse über sein Spielfenster. Ein
fensterloser Referenzlauf darf daher nicht von global beobachtbaren
Desktop-Eingaben abhängen. MiniQuakes Polling aller Bindings ist eine nützliche
interaktive Adaptierung, gehört aber nicht in einen deterministischen Headless-
Oracle.

Die Winkelspur macht diese Ursache sehr wahrscheinlich. Ein nativer
Input-Event-Trace war in BP-001R2 noch nicht enthalten; BP-001R3 behandelt die
Abweichung deshalb als gezielten Hotfix mit eigenem Entscheidungstest und einer
erneuten Doppelprozess-Abnahme.

## Korrektur in BP-001R3

- Live-Buttonpolling ist für `session.headless` ausdrücklich deaktiviert.
- Interaktiver Fensterbetrieb, Menü- und Konsolenregeln bleiben unverändert.
- Kompatibilitätstraces starten zusätzlich mit `-nomouse -nojoy`.
- Eine zehnte assetfreie Fixture prüft die Entscheidungsmatrix.
- `tools/compare_traces.py` schreibt bei einem späteren Mismatch automatisch
  die erste abweichende Zeile, den Frame und alle abweichenden Felder.

Gameplay-, Protocol-15-, QuakeC-, Physik-, Render- und Audiosemantik werden in
diesem Hotfix nicht neu klassifiziert. Der Fix beschränkt sich auf die
Isolation externer Hardwareeingaben in Headless-/Diagnoseläufen.
