# BP-019 – Protocol-15-Abschlussaudit

## Freeze-Contract

| Bestandteil | Wert |
|---|---:|
| Protocol-Version | 15 |
| gültige `svc_*`-Kommandos | 33 |
| gültige `clc_*`-Kommandos | 4 |
| Fast-Update-Maske | `0x7fff` |
| Clientdata-Maske | `0x7eff` |
| Soundmaske | `0x0007` |
| Temporary-Entity-Typen | 14 |
| Contract-Fingerprint | `0x0cf1e12a` |
| Status | `protocol15_frozen_v1` |

`audit/protocol15_freeze.json` enthält zusätzlich SHA-256-Werte der 15
autoritativen MiniLang-Dateien. Eine unbeabsichtigte Änderung dieser Schicht
wird dadurch im Closure-Checker sichtbar.

## Cross-Layer-Test

Eine Nachricht größer als `MAX_DATAGRAM` wird:

1. aus `svc_time`, langem `svc_print` und Fast Entity Update aufgebaut,
2. zuverlässig in zwei Datagrammfragmente zerlegt,
3. per ACK vollständig rekonstruiert,
4. als Quake-Demoframe serialisiert,
5. wieder gelesen und durch den Clientparser ausgewertet.

Der Test verlangt Byteidentität an der Datagrammgrenze und die erwartete
Ereignisreihenfolge nach Demo- und Parserroundtrip. Weitere Fixtures binden
Signon, reservierte Befehle, Sequence-Wrap, NOP/Disconnect, Wiederholungs-
Determinismus und die relevanten Größenlimits.

## Bedeutung des Freeze

Nach einer grünen Windows-Abnahme wird Protocol 15 im definierten
`compat_109`-Profil nur noch geändert, wenn ein reproduzierbarer
Kompatibilitätsfehler oder eine fehlende Originalsemantik nachgewiesen wird.
Der Freeze ist source-guided. Ein Original-Quake-Binärinterop über mehrere
Prozesse ist als späteres externes Gate ausdrücklich noch nicht behauptet.
