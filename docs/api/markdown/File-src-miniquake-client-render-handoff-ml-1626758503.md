# `src/miniquake/client_render_handoff.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.client_render_handoff`](Package-miniquake-client-render-handoff-389407000.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrays` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/client.ml` as `clientRuntime` → [src/miniquake/client.ml](File-src-miniquake-client-ml-1164576599.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/particles.ml` as `particles` → [src/miniquake/particles.ml](File-src-miniquake-particles-ml-1296519509.md)
- `miniquake/protocol_transients.ml` as `transients` → [src/miniquake/protocol_transients.ml](File-src-miniquake-protocol-transients-ml-999469098.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="constant-constant-miniquake-client-render-handoff-beam-step-const-beam-step-30-src-miniquake-client-render-handoff-ml-1786599625"></a>
### BEAM_STEP

```ml
const BEAM_STEP = 30.
```

Defines the beam step value used by `miniquake.client_render_handoff`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_render_handoff.ml#L26)

<a id="function-function-miniquake-client-render-handoff-beamangles-function-beamangles-startposition-endposition-src-miniquake-client-render-handoff-ml-258097350"></a>
### beamAngles

```ml
function beamAngles(startPosition, endPosition)
```

Return beam angles derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `startPosition` | `dynamic` | — | The start position input consumed by `beamAngles`. |
| `endPosition` | `dynamic` | — | The end position input consumed by `beamAngles`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_render_handoff.ml#L42)

<a id="function-function-miniquake-client-render-handoff-beammodelname-function-beammodelname-type-src-miniquake-client-render-handoff-ml-1901316591"></a>
### beamModelName

```ml
function beamModelName(type)
```

Return beam model name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `type` | `dynamic` | — | The type input consumed by `beamModelName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_render_handoff.ml#L92)

<a id="function-function-miniquake-client-render-handoff-beamsegmentorigins-function-beamsegmentorigins-startposition-endposition-limit-src-miniquake-client-render-handoff-ml-1240886591"></a>
### beamSegmentOrigins

```ml
function beamSegmentOrigins(startPosition, endPosition, limit)
```

Return beam segment origins derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `startPosition` | `dynamic` | — | The start position input consumed by `beamSegmentOrigins`. |
| `endPosition` | `dynamic` | — | The end position input consumed by `beamSegmentOrigins`. |
| `limit` | `dynamic` | — | The limit input consumed by `beamSegmentOrigins`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_render_handoff.ml#L62)

<a id="function-function-miniquake-client-render-handoff-buildtemporaryentities-function-buildtemporaryentities-compactbeams-client-currenttime-visiblecount-src-miniquake-client-render-handoff-ml-363037968"></a>
### buildTemporaryEntities

```ml
function buildTemporaryEntities(compactBeams, client, currentTime, visibleCount)
```

Mirrors CL_UpdateTEnts: reset per-frame temp storage, update player-owned beam starts, append 30-unit model segments, and stop at either shared cap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `compactBeams` | `dynamic` | — | The compact beams input consumed by `buildTemporaryEntities`. |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `visibleCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_render_handoff.ml#L165)

<a id="function-function-miniquake-client-render-handoff-cleartemporaryentities-function-cleartemporaryentities-src-miniquake-client-render-handoff-ml-45986869"></a>
### clearTemporaryEntities

```ml
function clearTemporaryEntities()
```

Update module state for temporary entities.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_render_handoff.ml#L216)

<a id="function-function-miniquake-client-render-handoff-compactbeamstart-function-compactbeamstart-value-viewentity-vieworigin-src-miniquake-client-render-handoff-ml-1766276165"></a>
### compactBeamStart

```ml
function compactBeamStart(value, viewEntity, viewOrigin)
```

Implements the `compactBeamStart` operation for `miniquake.client_render_handoff` (compact beam start).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `compactBeamStart`. |
| `viewEntity` | `dynamic` | — | The view entity input consumed by `compactBeamStart`. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `compactBeamStart`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_render_handoff.ml#L85)

<a id="global-global-miniquake-client-render-handoff-currenttemporary-currenttemporary-src-miniquake-client-render-handoff-ml-1358232317"></a>
### currentTemporary

```ml
currentTemporary
```

Tracks the module-level current temporary state owned by `miniquake.client_render_handoff`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_render_handoff.ml#L31)

<a id="function-function-miniquake-client-render-handoff-currenttemporaryentities-function-currenttemporaryentities-src-miniquake-client-render-handoff-ml-268933629"></a>
### currentTemporaryEntities

```ml
function currentTemporaryEntities()
```

Return temporary entities.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_render_handoff.ml#L210)

<a id="global-global-miniquake-client-render-handoff-emptytemporary-emptytemporary-src-miniquake-client-render-handoff-ml-1854533173"></a>
### emptyTemporary

```ml
emptyTemporary
```

Tracks the module-level empty temporary state owned by `miniquake.client_render_handoff`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_render_handoff.ml#L29)

<a id="function-function-miniquake-client-render-handoff-makebeamentity-function-makebeamentity-number-modelindex-origin-angles-currenttime-src-miniquake-client-render-handoff-ml-295467185"></a>
### makeBeamEntity

```ml
function makeBeamEntity(number, modelIndex, origin, angles, currentTime)
```

Create and initialize beam entity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `number` | `dynamic` | — | The number input consumed by `makeBeamEntity`. |
| `modelIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_render_handoff.ml#L132)

<a id="constant-constant-miniquake-client-render-handoff-max-beams-const-max-beams-24-src-miniquake-client-render-handoff-ml-1659206718"></a>
### MAX_BEAMS

```ml
const MAX_BEAMS = 24
```

Defines the max beams value used by `miniquake.client_render_handoff`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_render_handoff.ml#L22)

<a id="constant-constant-miniquake-client-render-handoff-max-temp-entities-const-max-temp-entities-64-src-miniquake-client-render-handoff-ml-2047839986"></a>
### MAX_TEMP_ENTITIES

```ml
const MAX_TEMP_ENTITIES = 64
```

Defines the max temp entities value used by `miniquake.client_render_handoff`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_render_handoff.ml#L24)

<a id="function-function-miniquake-client-render-handoff-modelindexforname-function-modelindexforname-client-name-src-miniquake-client-render-handoff-ml-1948639223"></a>
### modelIndexForName

```ml
function modelIndexForName(client, name)
```

Return model index for name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_render_handoff.ml#L103)

<a id="function-function-miniquake-client-render-handoff-precachebeammodels-function-precachebeammodels-client-src-miniquake-client-render-handoff-ml-1724167242"></a>
### precacheBeamModels

```ml
function precacheBeamModels(client)
```

CL_InitTEnts owns the lightning models rather than receiving them in the server model list. Register them during signon so the first beam does not parse and upload a model while gameplay is already visible.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_render_handoff.ml#L118)

<a id="function-function-miniquake-client-render-handoff-renderfloat-function-renderfloat-value-src-miniquake-client-render-handoff-ml-565438000"></a>
### renderFloat

```ml
function renderFloat(value)
```

Render float.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `renderFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_render_handoff.ml#L35)

<a id="function-function-miniquake-client-render-handoff-submitentities-function-submitentities-visibleentities-temporaryentities-src-miniquake-client-render-handoff-ml-1558586638"></a>
### submitEntities

```ml
function submitEntities(visibleEntities, temporaryEntities)
```

Submit state for submit entities.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `visibleEntities` | `dynamic` | — | The visible entities input consumed by `submitEntities`. |
| `temporaryEntities` | `dynamic` | — | The temporary entities input consumed by `submitEntities`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_render_handoff.ml#L239)

<a id="function-function-miniquake-client-render-handoff-submitmirrorentities-function-submitmirrorentities-visibleentities-temporaryentities-viewentity-src-miniquake-client-render-handoff-ml-1920966108"></a>
### submitMirrorEntities

```ml
function submitMirrorEntities(visibleEntities, temporaryEntities, viewEntity)
```

Submit state for submit mirror entities.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `visibleEntities` | `dynamic` | — | The visible entities input consumed by `submitMirrorEntities`. |
| `temporaryEntities` | `dynamic` | — | The temporary entities input consumed by `submitMirrorEntities`. |
| `viewEntity` | `dynamic` | — | The view entity input consumed by `submitMirrorEntities`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_render_handoff.ml#L226)
