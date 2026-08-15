# BP-013 Protocol-15-Event-Audit

Referenz: WinQuake/GLQuake 1.09  
Paket: BP-013  
Elternpaket: BP-012R1

## Abgedeckte Originalfunktionen

| Original | MiniLang-Ziel | Abgleich |
|---|---|---|
| `sv_main.c:SV_StartParticle` | `protocol_events.writeParticle`, `sv_main.SV_StartParticle`, `server.writeQueuedParticle` | Coord-Reihenfolge, Binary32-Richtungsskalierung, signed-Char-Klammerung, Count/Color, 16-Byte-Gate |
| `r_part.c:R_ParseParticleEffect` | `client_protocol.readParticle` | Wirecount 255 wird zu 1024 |
| `pr_cmds.c:PF_makestatic` | `protocol_events.writeSpawnStatic`, `quakec.builtins.makeStaticBuiltin` | Modell/Frame/Colormap/Skin und interleaved Coord/Angle |
| `pr_cmds.c:PF_ambientsound` | `protocol_events.writeStaticSound`, `quakec.builtins.ambientSoundBuiltin` | Binary32-Multiplikation, int-Abschneiden, keine zusätzliche Klammerung |
| `host_cmd.c:Host_Name_f` | `protocol_events.truncatePlayerName`, `server.setClientName` | 15 Quake-Einbytezeichen und `svc_updatename` |
| `host_cmd.c:Host_Color_f` | `server.setClientColors`, `protocol_events.writeUpdateColors` | `&15`, Clamp auf 13, Team und Wirefarbe |
| `sv_main.c:SV_UpdateToReliableMessages` | `protocol_events.fragChanged/storedFrag`, Serverfanout | int→float-Vergleich, float→int-Speicherung, Reliable-Verteilung |
| `host_cmd.c:Host_Spawn_f` | `server.writeSpawn` | Scoreboard verwendet `client.old_frags` |
| `host.c:SV_DropClient` | `server.dropClient`, `sv_main.SV_DropClient` | pending Reliable + Disconnect, Close, Sentinel, Scoreboard-Reset |

## Wire-Reihenfolgen

### `svc_spawnstatic`

```text
opcode
modelindex
frame
colormap
skin
origin[0], angle[0]
origin[1], angle[1]
origin[2], angle[2]
```

### `svc_spawnstaticsound`

```text
opcode
origin[0..2]
soundindex
(int)(volume * 255.0f)
(int)(attenuation * 64.0f)
```

### `svc_particle`

```text
opcode
origin[0..2]
clamp((int)(dir[0] * 16.0f), -128, 127)
clamp((int)(dir[1] * 16.0f), -128, 127)
clamp((int)(dir[2] * 16.0f), -128, 127)
count
color
```

### Scoreboard-Reset

```text
svc_updatename, index, ""
svc_updatefrags, index, 0
svc_updatecolors, index, 0
```

## C-/Python-Golden-Evidenz

`tools/oracle/protocol15_events_oracle.c` erzeugt 15 vollständige Payloads.
`tools/check_protocol15_events.py` reproduziert sie unabhängig und prüft 13
zusätzliche semantische Fälle:

- drei Partikelcount-Fälle,
- zwei Datagramm-Gates,
- drei Fragvergleichsfälle,
- zwei Frag-Speicherfälle,
- drei Farbnormalisierungen.

Der Oracle wird mit `-std=c11 -Wall -Wextra -Werror -O2` gebaut. GCC und Clang
erzeugen byteidentische Resultate.

## Bewusste sichere Abgrenzung

Gültige Protocol-15-Pakete sind bytegleich. Fatale oder speicherunsichere
Originalpfade werden als kontrollierte MiniLang-Fehler propagiert. Diese
Abgrenzung betrifft keine gültige Nachricht und keine beobachtbare
Client-/Server-Semantik.
