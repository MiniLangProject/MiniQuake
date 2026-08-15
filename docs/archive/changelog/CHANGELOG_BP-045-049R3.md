# Changelog BP-045–BP-049R3

Engine-Paket: `BP-049`
Lieferrevision: `BP-045-049R3`
Elternrevision: `BP-045-049R2`

## Anlass

Der vollständige R2-Windows-Lauf bestand 110 von 111 Abnahmeschritten. Zwei
unabhängige 128-Frame-Kompatibilitätstraces waren byteidentisch, aber die beiden
sichtbaren 640×480-Framebuffer-Captures unterschieden sich deutlich
(`SSIM=0.7532948782`). Die Captures zeigten außerdem unterschiedliche Munition
(22 gegenüber 24) und unterschiedliche View-/Weapon-Zustände. Der gerenderte
Evidence-Pfad lief mit einem echten Fenster und übernahm dadurch asynchronen
Desktop-Input, während der deterministische Headless-Pfad Input bereits
isolierte.

## Korrektur

- `--render-evidence` startet nun zusätzlich mit `-nolan`, `-nomouse`,
  `-nojoy` und `-noinput`.
- `host.sendClientIntentions` erkennt `-noinput`, leert die globalen
  Inputzustände und den Bewegungsbefehl und deaktiviert sowohl Live-Button-
  Polling als auch Maus-/Joystickbewegung.
- `host.runRenderEvidence` beginnt nach der Initialisierung mit geleerten Key-,
  Button- und Commandzuständen.
- Der BP-048-Checker bindet diese Input-Isolation statisch.
- R3-spezifische Test-, Collector-, Analyse- und Ledgerdateien wurden ergänzt.

## Unverändert

Protocol 15, QuakeC, Welt/Physik, Host/Lifecycle, Client-/Renderer- und
World-Renderer-Verträge sowie der Model-/UI-/Render-Fingerprint bleiben
unverändert. Die Native Bridges wurden nicht geändert.

## Änderungsklassifikation

Diese Revision ändert bewusst **Produktionsquellcode** in `src/main.ml` und
`src/miniquake/host.ml`, aber keinen nativen Code unter `native/`. Die
eingefrorenen Engineverträge bleiben unverändert; insbesondere bleibt der
Model-/UI-/Render-Fingerprint `0x0a62f5b1`.

Classification markers: production source changed; native source unchanged.
