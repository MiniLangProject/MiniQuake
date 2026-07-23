# MiniQuake – interaktiver Paritäts-Testplan

## Build

```powershell
.\build.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy
```

Erwartet: 15 Kern- und 22 Meilensteintests.

## A. Boden-/Treppenstabilität (`start`)

1. Spiel starten und 60 Sekunden ohne Eingabe stehen bleiben.
2. Spieler-Z darf nicht periodisch abfallen und zurückspringen.
3. Vorwärts über flachen Boden; keine 1/8-Einheiten-Netzwerkoszillation.
4. Mehrfach Treppen hoch und herunter; nur die originale `oldz`-Glättung.
5. Testweise `cl_bob 0`: verbleibende vertikale Bewegung ist ein Fehler.

## B. Türen, Lifte und Trigger

1. Jede Episodentür im Start-Hub berühren/aktivieren.
2. Tür muss QuakeC-Think ausführen, Sound spielen und als BSP-Pusher bewegen.
3. Vor die Tür stellen: blockierte Tür muss zurückrollen bzw. Blocked-Callback
   auslösen; Spieler darf nicht in Geometrie bleiben.
4. Auf Lift/Plattform stehen; Spieler muss mitgeführt werden.
5. Teleporter/Trigger dürfen den Spieler nicht physisch blockieren.

## C. Viewmodel und Statusbar

1. Shotgun direkt nach Spawn sichtbar.
2. Schießen: Weaponframe ändert sich, Muzzle-/Sound-/Ammozustand plausibel.
3. Waffen 1–8 wechseln; Model und Statusbar-Waffenmarkierung folgen.
4. Health, Armor, Ammo, Keys, Powerups und Sigils verwenden Original-qpic-Art.
5. `r_drawviewmodel 0/1` und `r_drawentities 0/1` getrennt prüfen.

## D. Menü/Bindings

1. Optionen → Customize controls.
2. Enter auf „attack“, neue Taste drücken; Anzeige und Gameplay ändern sich.
3. Backspace/Delete löscht alle Bindings dieser Aktion.
4. Escape während Key-Grab bricht ab; zweites Escape kehrt zu Optionen zurück.
5. Load/Save/Setup/Video-Seiten navigieren korrekt; Funktionen, die im Audit
   als offen markiert sind, dürfen nicht als abgeschlossen gewertet werden.

## E. `e1m1`

- Monster laufen/chase/step und greifen an.
- Türen und Lifte bewegen und tragen/blockieren korrekt.
- Items, Damage, Death/Respawn und Exit funktionieren.
- Keine stetig wachsenden Edicts, Sounds, Partikel oder Nachrichten.

## F. Diagnosebefehle

```powershell
$Q = "C:\Program Files (x86)\Steam\steamapps\common\Quake"
.\build\MiniQuake.exe --validate-runtime $Q start 720 -game id1
.\build\MiniQuake.exe --render-smoke $Q start 1200 -game id1
.\build\MiniQuake.exe --soak $Q start 10000 -game id1
```
