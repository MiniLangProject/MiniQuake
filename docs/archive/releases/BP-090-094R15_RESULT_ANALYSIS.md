# BP-090–BP-094R15 – Analyse des R14-demo3-Bildfehlers

## R14-Ergebnis

Die beiden unabhängigen Original-GLQuake-Referenzen sind konsistent:

- Original A/B SSIM: `0.9999947891783205`
- geänderte Pixel zwischen den Referenzen: `668 / 307200`

MiniQuakes bester Kandidat war Frame `255`:

- Worst-reference SSIM: `0.871158394398681`
- MAE: `4.468786892361111`
- PSNR: `30.192584754777872 dB`
- geänderte Pixel: `307169 / 307200`

## Bildbefund

Original und MiniQuake zeigen dieselbe Szene, dasselbe Viewmodel, dieselbe HUD-Struktur und denselben Textzustand. Die Abweichung konzentriert sich auf zwei zeitabhängige View-Effekte:

1. Das Originalbild besitzt einen stärkeren roten Damage-/Bonus-Cshift.
2. Die 3D-Szene ist gegenüber MiniQuake vertikal um ungefähr vier Pixel versetzt; HUD und Text bleiben ausgerichtet.

Eine Kantenkorrelation im 3D-Viewport erreicht ihr Maximum bei einer vertikalen Verschiebung von vier Pixeln. Der HUD-Bereich weist nur ungefähr `0.998` mittlere absolute RGB-Abweichung auf, der 3D-Viewport dagegen ungefähr `4.408`.

## Ursache

Der Originalcapture startete GLQuake mit `timedemo`, setzte aber kein `host_framerate`. In `Host_FilterTime` wird bei Timedemo die 72-Hz-Grenze umgangen. `host_frametime` entsprach daher der sehr kleinen realen Renderzeit des jeweiligen Originalframes, mindestens `0.001` Sekunden.

MiniQuakes `--render-demo-evidence` führt dagegen jeden Frame mit exakt `0.02` Sekunden aus.

Diese Differenz wirkt direkt auf den Originalcode:

- `V_CalcViewRoll`: `v_dmg_time -= host_frametime`
- `V_UpdatePalette`: Damage-Cshift `-= host_frametime * 150`
- `V_UpdatePalette`: Bonus-Cshift `-= host_frametime * 100`

Daher verglich R14 zwar denselben Demo-/Paketbereich, aber nicht denselben zeitabhängigen Viewzustand. `demo1` und `demo2` bestanden, weil der gewählte Zustand dort weniger empfindlich war; `demo3` enthielt im Vergleichsfenster aktive View-/Cshift-Effekte.

## R15-Korrektur

Der Original-GLQuake-Capture erhält vor `timedemo`:

```text
host_framerate 0.02
```

Damit verwenden Original und MiniQuake dieselbe feste Simulationsschrittweite. Nicht verändert werden:

- MiniQuake-Engine- oder native Quellen,
- Bilddaten oder Comparator,
- Mindest-SSIM `0.95`,
- Originalreferenz-Konsistenz `0.98`,
- Suchfenster Frames `254..258`,
- Gamma, Crop, Skalierung, Verschiebung oder andere Nachbearbeitung.

R15 korrigiert ausschließlich die zeitliche Versuchsbedingung des externen visuellen Nachweises.

Vertragsgrenze: keine Änderung unter `src/` oder `native/`.
