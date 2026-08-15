# BP-045–BP-049 Ergebnisanalyse und R1-Korrektur

## Ergebnisgrenze

Der Windows-Lauf der ersten BP-045–BP-049-Lieferung brach in der statischen
Protocol-15-Serverdatenprüfung ab. Bis zu dieser Stelle waren die allgemeine
Paketprüfung, der Runtime-Logchecker, die Wire-Goldenvektoren und die
Command-/Fast-Update-Prüfung erfolgreich. Eine MiniLang-Kompilierung oder
Runtime-Abnahme des neuen Rendererblocks wurde noch nicht erreicht.

Das hochgeladene Ergebnisarchiv lautet:

```text
MiniQuake_BP-045-049_RESULTS_20260727-211658.zip
SHA-256: 0461fa3e618a3aa53824806a7225b58c63235ca3d3e537ee744f629840e4e6e5
```

Die fehlschlagende Prüfung war:

```text
minilang_serverdata_contract
```

Sie meldete ausschließlich drei fehlende Marker in `COLLECT_RESULTS.ps1`:

```text
MiniQuakeProtocol15ServerDataTests.exe
BP-012_PROTOCOL15_SERVERDATA_AUDIT.md
protocol15_serverdata_golden.json
```

## Ursache

Der Collector der neuen BP-045–BP-049-Lieferung sammelte nur die Artefakte des
aktuellen Rendererblocks. Der historische BP-012R1-Quellvertrag verlangt jedoch,
dass auch die Serverdaten-Testidentität, das Audit und die Goldenvektoren im
Rückkanal erhalten bleiben. Produktionscode, Protocol-15-Writer und die 17
BP-012R1-Laufzeitfixtures waren nicht fehlerhaft.

## R1-Korrektur

`COLLECT_RESULTS.ps1` enthält und sammelt nun wieder:

- den Metadateneintrag für `MiniQuakeProtocol15ServerDataTests.exe`,
- `docs/BP-012_PROTOCOL15_SERVERDATA_AUDIT.md`,
- `audit/protocol15_serverdata_golden.json`.

Zusätzlich besitzt BP-045–BP-049R1 einen eigenen Testeinstieg, eindeutige
R1-Artefaktnamen und einen Verifier-Vertrag, der den vollständigen
BP-012R1-Serverdatenchecker bereits während der allgemeinen Paketprüfung
startet. Damit kann dieselbe Regression nicht mehr erst im nachgelagerten
Akzeptanzskript auftreten.

## Klassifikation

Dies ist ein Collector-/Lieferfehler. Unter `src/` und `native/` wurde kein
Produktionscode verändert. Alle eingefrorenen Engineverträge und der
Model-/UI-/Render-Fingerprint `0x0a62f5b1` bleiben unverändert.
