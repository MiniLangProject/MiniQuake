# Auswertung BP-020–BP-024

## Ergebnisarchiv

```text
MiniQuake_BP-020-024_RESULTS_20260725-201735.zip
SHA-256 91797f541fbcbe83bd304bcb1d3fcc02551ac6d2c51dce451abda5cc6ac1d5b8
```

## Erfolgreiche Bereiche

- statische Paket-, Manifest-, Import- und ABI-Prüfung,
- vollständige Kompilierung des Spiels und aller 19 Testprogramme,
- BASE-Meilensteine und deterministische Diagnosen,
- sämtliche Protocol-15-Gruppen BP-010R1 bis BP-019,
- BP-020 `progs.dat`-Fixtures,
- BP-023 Builtin-Fixtures,
- BP-024 Closure-Fixtures.

## Beobachtete Abweichungen

### 1. BASE Core: großer synthetischer `progs.dat`-Korpus

```text
FAIL: large-synthetic.dat: progs.dat string table does not begin with NUL
```

Die neue Formatprüfung war korrekt. Der ältere Skalierungstest erzeugte jedoch
`numstrings == 0`, obwohl das v6-Format die erste Zeichenkette als leere
NUL-Zeichenkette definiert. R1 ergänzt dieses eine Byte, ohne den
15760-Statement-Skalierungstest abzuschwächen.

### 2. BP-021: Builtin-Slot im Trace-Test

```text
Program error: missing QuakeC builtin 1
```

Ein `first_statement` von `-1` bezeichnet Builtin-Index 1. Der Test installierte
seinen Callback als einziges Element und damit an Index 0. Die VM-Abbildung war
korrekt; R1 korrigiert ausschließlich die Tabellenfixture.

### 3. BP-022: Negative Zero

```text
negative zero: expected -0.000000, got 0.000000
```

Das MiniLang-Quellliteral `-0.0` erreichte den Test nicht mit dem originalen
QuakeC-Rohwort. Runtimewerte stammen dagegen aus 32-Bit-Wörtern. R1 verwendet
`0x80000000` als Eingabe und formatiert direkt anhand dieses Rohworts.

### 4. BP-022: `ED_Write`

```text
Cannot stringify void for string concatenation
```

Die tiefe Inline-Konkatenation vermischte Feldzugriff, Wertformatierung und
Ausgabeaufbau in einem Ausdruck. R1 isoliert jeden Schritt, prüft den
serialisierten Wert und verwendet denselben Quoted-Pair-Helfer auch im
Savegame-Writer.

### 5. Installierte Quake-Daten

`--validate-game` endete mit Code 2. Die erste Testrevision leitete die native
Ausgabe nicht in ein eigenes Log um, daher ist der konkrete Report nicht im
Archiv enthalten. Der anschließende Source-Audit fand jedoch eine klare
Stock-Inkompatibilität: qcc-Builtins können eine deklarierte Parametersignatur,
einen negativen `first_statement` und gleichzeitig null lokale Wörter besitzen.
Die BP-020-Prüfung hatte Parameterwörter irrtümlich für alle Funktionen gegen
`locals` geprüft. R1 begrenzt diese Prüfung auf echte Bytecodefunktionen.

Stock-`progs.dat`, `--validate-game` und `--validate-runtime` werden in R1
getrennt und vollständig protokolliert. Ein eventuell verbleibender
Echtdatenfehler ist dadurch ohne weitere Diagnosezwischenrevision sichtbar.
