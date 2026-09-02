# `src/miniquake/client_effects.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.client_effects`](Package-miniquake-client-effects-1028668005.md)

Reachable from entry: **yes**

## Imports

- `miniquake/client.ml` as `clientRuntime` → [src/miniquake/client.ml](File-src-miniquake-client-ml-1164576599.md)
- `miniquake/cmd.ml` as `cmd` → [src/miniquake/cmd.ml](File-src-miniquake-cmd-ml-1014778996.md)
- `miniquake/console.ml` as `console` → [src/miniquake/console.ml](File-src-miniquake-console-ml-296415787.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/cvar.ml` as `cvar` → [src/miniquake/cvar.ml](File-src-miniquake-cvar-ml-171521436.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/particles.ml` as `particleSystem` → [src/miniquake/particles.ml](File-src-miniquake-particles-ml-1296519509.md)
- `miniquake/protocol_transients.ml` as `transients` → [src/miniquake/protocol_transients.ml](File-src-miniquake-protocol-transients-ml-999469098.md)
- `miniquake/sound/mixer.ml` as `sound` → [src/miniquake/sound/mixer.ml](File-src-miniquake-sound-mixer-ml-2037667391.md)
- `miniquake/view.ml` as `view` → [src/miniquake/view.ml](File-src-miniquake-view-ml-709264737.md)

## Declarations

<a id="function-function-miniquake-client-effects-appendparticles-function-appendparticles-current-spawned-src-miniquake-client-effects-ml-1355384608"></a>
### appendParticles

```ml
function appendParticles(current, spawned)
```

Add state for append particles.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `current` | `dynamic` | — | The current input consumed by `appendParticles`. |
| `spawned` | `dynamic` | — | The spawned input consumed by `appendParticles`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_effects.ml#L24)

<a id="function-function-miniquake-client-effects-precachetemporarysounds-function-precachetemporarysounds-mixer-src-miniquake-client-effects-ml-1351409760"></a>
### precacheTemporarySounds

```ml
function precacheTemporarySounds(mixer)
```

Load the client-owned temporary-entity sounds that are not necessarily named by a mod's QuakeC sound precache list.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `precacheTemporarySounds`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_effects.ml#L46)

<a id="function-function-miniquake-client-effects-process-function-process-events-client-player-mixer-viewstate-consolestate-commandsystem-currentparticles-currenttemporary-currenttime-registry-src-miniquake-client-effects-ml-1788758730"></a>
### process

```ml
function process(events, client, player, mixer, viewState, consoleState, commandSystem, currentParticles, currentTemporary, currentTime, registry)
```

Execute the requested value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `events` | `dynamic` | — | The events input consumed by `process`. |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `player` | `dynamic` | — | The player input consumed by `process`. |
| `mixer` | `dynamic` | — | The mixer input consumed by `process`. |
| `viewState` | `dynamic` | — | Mutable state used by `process`. |
| `consoleState` | `dynamic` | — | Mutable state used by `process`. |
| `commandSystem` | `dynamic` | — | The command system input consumed by `process`. |
| `currentParticles` | `dynamic` | — | The current particles input consumed by `process`. |
| `currentTemporary` | `dynamic` | — | The current temporary input consumed by `process`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `process`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_effects.ml#L166)

<a id="function-function-miniquake-client-effects-processtemporary-function-processtemporary-value-mixer-currentparticles-currenttemporary-currenttime-src-miniquake-client-effects-ml-1084080677"></a>
### processTemporary

```ml
function processTemporary(value, mixer, currentParticles, currentTemporary, currentTime)
```

Execute temporary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `processTemporary`. |
| `mixer` | `dynamic` | — | The mixer input consumed by `processTemporary`. |
| `currentParticles` | `dynamic` | — | The current particles input consumed by `processTemporary`. |
| `currentTemporary` | `dynamic` | — | The current temporary input consumed by `processTemporary`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_effects.ml#L76)

<a id="function-function-miniquake-client-effects-prunetemporary-function-prunetemporary-currenttemporary-currenttime-src-miniquake-client-effects-ml-1687592331"></a>
### pruneTemporary

```ml
function pruneTemporary(currentTemporary, currentTime)
```

Active view mirrors CL_UpdateTEnts: an expired beam is not rendered or exposed to callers, while the retained state above still remembers its slot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `currentTemporary` | `dynamic` | — | The current temporary input consumed by `pruneTemporary`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_effects.ml#L139)

<a id="function-function-miniquake-client-effects-retaintemporaryslots-function-retaintemporaryslots-currenttemporary-src-miniquake-client-effects-ml-1491171445"></a>
### retainTemporarySlots

```ml
function retainTemporarySlots(currentTemporary)
```

Retained state mirrors the original fixed cl_beams[MAX_BEAMS] array.  Expired entries are kept because CL_ParseBeam first searches by entity before it searches for a free or expired slot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `currentTemporary` | `dynamic` | — | The current temporary input consumed by `retainTemporarySlots`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_effects.ml#L131)

<a id="function-function-miniquake-client-effects-safesound-function-safesound-mixer-entitynumber-channelnumber-name-origin-volume-attenuation-src-miniquake-client-effects-ml-222687511"></a>
### safeSound

```ml
function safeSound(mixer, entityNumber, channelNumber, name, origin, volume, attenuation)
```

Return a validated safe sound value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `safeSound`. |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `safeSound`. |
| `channelNumber` | `dynamic` | — | The channel number input consumed by `safeSound`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `volume` | `dynamic` | — | The volume input consumed by `safeSound`. |
| `attenuation` | `dynamic` | — | The attenuation input consumed by `safeSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_effects.ml#L36)

<a id="function-function-miniquake-client-effects-serverinfoleveltext-function-serverinfoleveltext-levelname-src-miniquake-client-effects-ml-910953268"></a>
### serverInfoLevelText

```ml
function serverInfoLevelText(levelName)
```

Implements the `serverInfoLevelText` operation for `miniquake.client_effects` (server info level text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `levelName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_effects.ml#L150)

<a id="function-function-miniquake-client-effects-serverinforuletext-function-serverinforuletext-src-miniquake-client-effects-ml-2128857973"></a>
### serverInfoRuleText

```ml
function serverInfoRuleText()
```

Implements the `serverInfoRuleText` operation for `miniquake.client_effects` (server info rule text).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_effects.ml#L144)

<a id="function-function-miniquake-client-effects-spikeimpactsound-function-spikeimpactsound-src-miniquake-client-effects-ml-515813453"></a>
### spikeImpactSound

```ml
function spikeImpactSound()
```

TE_SPIKE and TE_SUPERSPIKE share the engine-wide C rand() stream with the particle and entity-effect code.  Four out of five impacts use tink1; the fifth consumes a second random value to select one of the three ricochets (with the original 0/3 fall-through both selecting ric3).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_effects.ml#L62)
