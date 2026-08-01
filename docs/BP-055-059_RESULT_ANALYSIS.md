# Analyse des BP-055–BP-059-Windows-Laufs

## Ergebnis

Der Lauf scheiterte vor der MiniLang-Kompilierung. Die allgemeine Paketprüfung
und sämtliche vor dem Fehler ausgeführten Elternverträge waren erfolgreich.

Die erste fehlerhafte Gruppe war:

```text
BP-054 render-special closure verification
```

Die gemeldeten Abweichungen waren:

```text
build info missing const PACKAGE_ID = "BP-054"
build info missing const PARENT_PACKAGE_ID = "BP-053"
build info missing const BLOCK_ID = "BP-050-054"
```

Das aktuelle `build_info.ml` trägt korrekt die Identität des neuen Audioblocks:

```text
PACKAGE_ID = BP-059
PARENT_PACKAGE_ID = BP-058
BLOCK_ID = BP-055-059
```

Gleichzeitig enthält es weiterhin den bereits akzeptierten Vertrag:

```text
RENDER_SPECIAL_STATUS = render_special_109_frozen_v1
RENDER_SPECIAL_FINGERPRINT = 0x2a3d8081
```

## Klassifikation

Pre-Build-Verifikationsfehler in einer geerbten historischen Prüfung. Kein
Hinweis auf einen Fehler im Audiocode oder in einer anderen Enginekomponente.

## Ursache

Der BP-054-Checker vermischte zwei unabhängige Aufgaben:

1. die historische Identität der ursprünglichen BP-054-Lieferung;
2. die semantische Unverändertheit des eingefrorenen Render-Special-Vertrags.

Eine spätere Lieferung muss ihre eigene Paketidentität besitzen, darf aber den
älteren Vertrag weiterführen. Genau diese Downstream-Verwendung war im Checker
noch nicht modelliert.

## R1-Korrektur

Der Checker besitzt nun einen expliziten Downstream-Modus. Im historischen
Modus bleibt die exakte BP-054-Identität verpflichtend. Im Downstream-Modus
werden Status und Fingerprint des eingefrorenen Vertrags gebunden, während die
aktuelle BP-059-Identität durch den allgemeinen Paketverifier geprüft wird.

## Evidenz

Ergebnisarchiv:

```text
MiniQuake_BP-055-059_RESULTS_20260728-123401.zip
SHA-256: 889f140434415275b149f68a484993d4bf1ca4aa1fe4083ffcc264032163916a
```

Build und Runtime wurden im fehlgeschlagenen Lauf noch nicht erreicht. Deshalb
ist eine vollständige R1-Windows-Abnahme erforderlich.
