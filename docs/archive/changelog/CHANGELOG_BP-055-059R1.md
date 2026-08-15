# MiniQuake BP-055–BP-059R1

## Zweck

R1 korrigiert ausschließlich die Verifikation eines geerbten, bereits
Windows-bestätigten Vertrags. Die erste BP-055–BP-059-Lieferung stoppte vor dem
Build, weil `tools/check_render_special_054.py` im aktuellen BP-059-Baum noch
die historische Paketidentität `BP-054 / BP-053 / BP-050-054` verlangte.

## Änderungen

- `check_render_special_054.py` unterstützt nun explizit
  `--allow-downstream-package`.
- Ohne diese Option bleibt die strikte historische BP-054-Identitätsprüfung
  erhalten.
- Mit dieser Option werden der unveränderte Status
  `render_special_109_frozen_v1` und der Fingerprint `0x2a3d8081` im aktuellen
  Paket geprüft; die aktuelle Paketidentität wird weiterhin unabhängig durch
  `tools/verify.py` gebunden.
- `build.ps1` und der neue R1-Akzeptanzlauf verwenden den Downstream-Modus nur
  für den geerbten BP-054-Abschlusschecker.
- Der allgemeine Verifier führt denselben Check ebenfalls aus und schützt die
  neue Trennung gegen Regressionen.
- Test-, Collector-, Ledger- und Diagnoseartefakte tragen die Lieferrevision
  `BP-055-059R1`.

## Nicht geändert

- keine Datei unter `src/`
- keine Datei unter `native/`
- keine Audiofixture und kein Golden-Vektor
- keine Runtime-, Netzwerk-, QuakeC-, Physik- oder Rendersemantik
- keine Fingerprints eingefrorener Verträge

## Fehlergrenze der Vorgängerl Lieferung

- statischer Gesamt-Preflight: PASS
- erster Fehler: BP-054 render-special closure verification
- Build erreicht: nein
- Runtime erreicht: nein
- Ergebnisarchiv SHA-256:
  `889f140434415275b149f68a484993d4bf1ca4aa1fe4083ffcc264032163916a`
