# MiniQuake BP-000R1 – Runtime-Baseline-Reparatur

Datum: 24. Juli 2026  
Ausgangspaket: `BP-000`

## Anlass

Die erste Windows-Abnahme bestätigte, dass Paketprüfung, MiniLang-Kompilierung,
Paketidentität und Testkompilierung funktionieren. Der Core-Test brach jedoch
bei `02.15 native C string return` mit der Windows Access Violation
`0xC0000005` ab.

## Eingegrenzte Fehlergrenze

Der Lauf belegt den Fehler im direkten externen Win64-Rückweg `returns cstr`:
Der aufgerufene C-Export liefert laut Quelle einen statischen Zwei-Byte-Puffer,
während die vorherigen Integer- und Floatbit-Rückgaben funktionieren. Eine
Zeigerverkürzung vor der MiniLang-seitigen Stringkopie ist die wahrscheinlichste
Erklärung, aber ohne nativen Debuggertrace noch keine formale Compilerdiagnose.
Die Quake-Logik ist an dieser Stelle nicht beteiligt.

## Änderungen

- Neue Zusatzbridge `native/miniquake_text.dll` mit elf sicheren Stringexporten.
- Jeder Export schreibt in einen von MiniLang bereitgestellten `bytes`-Puffer
  und gibt nur die Byteanzahl als `u32` zurück.
- Betroffene Bereiche:
  - Floatformatierung,
  - ASCII-Zeichen,
  - ConProc-Text,
  - UDP-Adressen und Hostnamen,
  - OpenGL-`glGetString`.
- Sämtliche direkten nativen `returns cstr` wurden aus `native.ml` entfernt.
- Der ursprüngliche `miniquake_native.dll`-Binärstand bleibt unverändert.
- Neuer reproduzierbarer Builder `native/build_text_bridge.py`.
- `build.ps1` kopiert beide DLLs und kann die Textbridge mit
  `-RebuildNative` neu erzeugen.
- Der Verifier prüft jetzt:
  - 160 Hauptbridge-Symbole,
  - 11 Textbridge-Symbole,
  - beide PE32+/AMD64-DLLs samt tatsächlichen Exporttabellen,
  - das Verbot direkter nativer `cstr`-Rückgaben.
- Core-Testgruppe 02 prüft ASCII, NUL und Floattext über den neuen Pufferpfad.
- Ergebnisarchiv enthält zusätzlich den Hash von `miniquake_text.dll`.

## Nicht geändert

- Protocol 15,
- QuakeC,
- Physik und Kollision,
- Rendererlogik,
- Mixer-/OGG-Logik,
- Savegames und Demos.

## Bekannte Einschränkung des Ausgangsbaums

`native/miniquake_ogg.c` referenziert `third_party/stb/stb_vorbis.c`, diese Datei
war im gelieferten Quellarchiv nicht enthalten. Die Hauptbridge kann deshalb aus
diesem Paket allein noch nicht vollständig neu gelinkt werden. Die geprüfte
vorgefertigte Hauptbridge wird weiter ausgeliefert; die neue Textbridge ist
vollständig reproduzierbar.

## Abnahme

```powershell
.\TEST_BP-000R1.ps1 `
  -Compiler C:\Pfad\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Pfad\MiniLangCompilerPy `
  -QuakeBase "C:\Pfad\zu\Quake" `
  -Map start `
  -Frames 120 `
  -NetworkTests
```

Danach unabhängig vom Ergebnis:

```powershell
.\COLLECT_RESULTS.ps1
```
