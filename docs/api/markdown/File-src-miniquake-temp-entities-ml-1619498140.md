# `src/miniquake/temp_entities.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.temp_entities`](Package-miniquake-temp-entities-1085118901.md)

Reachable from entry: **yes**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/message.ml` as `msg` → [src/miniquake/message.ml](File-src-miniquake-message-ml-238261765.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/protocol_transients.ml` as `transients` → [src/miniquake/protocol_transients.ml](File-src-miniquake-protocol-transients-ml-999469098.md)
- `miniquake/sound/mixer.ml` as `sound` → [src/miniquake/sound/mixer.ml](File-src-miniquake-sound-mixer-ml-2037667391.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-temp-entities-allocatetempdlight-function-allocatetempdlight-state-currenttime-src-miniquake-temp-entities-ml-808624332"></a>
### allocateTempDlight

```ml
function allocateTempDlight(state, currentTime)
```

Allocate and initialize temp dlight.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.temp_entities` state used by `allocateTempDlight`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L270)

<a id="function-function-miniquake-temp-entities-appendexplosionlight-function-appendexplosionlight-state-origin-currenttime-src-miniquake-temp-entities-ml-1769747874"></a>
### appendExplosionLight

```ml
function appendExplosionLight(state, origin, currentTime)
```

Add state for append explosion light.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.temp_entities` state used by `appendExplosionLight`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L292)

<a id="function-function-miniquake-temp-entities-appendparticleevent-function-appendparticleevent-state-name-origin-color-count-extra-src-miniquake-temp-entities-ml-1451872051"></a>
### appendParticleEvent

```ml
function appendParticleEvent(state, name, origin, color, count, extra)
```

Add state for append particle event.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.temp_entities` state used by `appendParticleEvent`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `color` | `dynamic` | — | Color value used by the operation. |
| `count` | `dynamic` | — | Number of entries or units to process. |
| `extra` | `dynamic` | — | The extra input consumed by `appendParticleEvent`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L263)

<a id="function-function-miniquake-temp-entities-appendsoundevent-function-appendsoundevent-state-name-origin-src-miniquake-temp-entities-ml-403170685"></a>
### appendSoundEvent

```ml
function appendSoundEvent(state, name, origin)
```

Add state for append sound event.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.temp_entities` state used by `appendSoundEvent`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `origin` | `dynamic` | — | World-space origin of the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L252)

<a id="function-function-miniquake-temp-entities-appendspikesound-function-appendspikesound-state-origin-src-miniquake-temp-entities-ml-525411166"></a>
### appendSpikeSound

```ml
function appendSpikeSound(state, origin)
```

Add state for append spike sound.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.temp_entities` state used by `appendSpikeSound`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L304)

<a id="function-function-miniquake-temp-entities-appendunique-function-appendunique-values-value-src-miniquake-temp-entities-ml-1595519138"></a>
### appendUnique

```ml
function appendUnique(values, value)
```

Add state for append unique.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `appendUnique`. |
| `value` | `dynamic` | — | Value consumed by `appendUnique`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L171)

<a id="function-function-miniquake-temp-entities-beammodelfortype-function-beammodelfortype-type-src-miniquake-temp-entities-ml-401864339"></a>
### beamModelForType

```ml
function beamModelForType(type)
```

Return beam model for type derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `type` | `dynamic` | — | The type input consumed by `beamModelForType`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L189)

<a id="function-function-miniquake-temp-entities-beamtypeformodel-function-beamtypeformodel-model-src-miniquake-temp-entities-ml-107964020"></a>
### beamTypeForModel

```ml
function beamTypeForModel(model)
```

Implements the `beamTypeForModel` operation for `miniquake.temp_entities` (beam type for model).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `model` | `dynamic` | — | Model resource processed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L180)

<a id="function-function-miniquake-temp-entities-cl-inittents-function-cl-inittents-mixer-src-miniquake-temp-entities-ml-1054716680"></a>
### CL_InitTEnts

```ml
function CL_InitTEnts(mixer)
```

Apply the Quake-compatible cl init tents behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `CL_InitTEnts`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L127)

<a id="function-function-miniquake-temp-entities-cl-newtempentity-function-cl-newtempentity-state-src-miniquake-temp-entities-ml-2131818288"></a>
### CL_NewTempEntity

```ml
function CL_NewTempEntity(state)
```

Apply the Quake-compatible cl new temp entity behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.temp_entities` state used by `CL_NewTempEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L366)

<a id="function-function-miniquake-temp-entities-cl-parsebeam-function-cl-parsebeam-state-reader-model-currenttime-src-miniquake-temp-entities-ml-845303672"></a>
### CL_ParseBeam

```ml
function CL_ParseBeam(state, reader, model, currentTime)
```

Apply the Quake-compatible cl parse beam behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.temp_entities` state used by `CL_ParseBeam`. |
| `reader` | `dynamic` | — | The reader input consumed by `CL_ParseBeam`. |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L218)

<a id="function-function-miniquake-temp-entities-cl-parsetent-function-cl-parsetent-state-reader-currenttime-src-miniquake-temp-entities-ml-1192329665"></a>
### CL_ParseTEnt

```ml
function CL_ParseTEnt(state, reader, currentTime)
```

Apply the Quake-compatible cl parse tent behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.temp_entities` state used by `CL_ParseTEnt`. |
| `reader` | `dynamic` | — | The reader input consumed by `CL_ParseTEnt`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L320)

<a id="function-function-miniquake-temp-entities-cl-rand-function-cl-rand-state-src-miniquake-temp-entities-ml-1863097282"></a>
### CL_Rand

```ml
function CL_Rand(state)
```

Apply the Quake-compatible cl rand behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.temp_entities` state used by `CL_Rand`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L163)

<a id="function-function-miniquake-temp-entities-cl-setrandomseed-function-cl-setrandomseed-state-seed-src-miniquake-temp-entities-ml-1727497093"></a>
### CL_SetRandomSeed

```ml
function CL_SetRandomSeed(state, seed)
```

Apply the Quake-compatible cl set random seed behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.temp_entities` state used by `CL_SetRandomSeed`. |
| `seed` | `dynamic` | — | The seed input consumed by `CL_SetRandomSeed`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L156)

<a id="function-function-miniquake-temp-entities-cl-updatetents-function-cl-updatetents-state-currenttime-viewentity-vieworigin-src-miniquake-temp-entities-ml-708442909"></a>
### CL_UpdateTEnts

```ml
function CL_UpdateTEnts(state, currentTime, viewEntity, viewOrigin)
```

Apply the Quake-compatible cl update tents behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.temp_entities` state used by `CL_UpdateTEnts`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `viewEntity` | `dynamic` | — | The view entity input consumed by `CL_UpdateTEnts`. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `CL_UpdateTEnts`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L386)

<a id="function-function-miniquake-temp-entities-emptybeam-function-emptybeam-src-miniquake-temp-entities-ml-2091904923"></a>
### emptyBeam

```ml
function emptyBeam()
```

Implements the `emptyBeam` operation for `miniquake.temp_entities` (empty beam).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L116)

<a id="function-function-miniquake-temp-entities-emptydynamiclight-function-emptydynamiclight-src-miniquake-temp-entities-ml-2016977083"></a>
### emptyDynamicLight

```ml
function emptyDynamicLight()
```

Implements the `emptyDynamicLight` operation for `miniquake.temp_entities` (empty dynamic light).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L121)

<a id="constant-constant-miniquake-temp-entities-max-beams-const-max-beams-24-src-miniquake-temp-entities-ml-1526472060"></a>
### MAX_BEAMS

```ml
const MAX_BEAMS = 24
```

Defines the max beams value used by `miniquake.temp_entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L19)

<a id="function-function-miniquake-temp-entities-parse-function-parse-reader-src-miniquake-temp-entities-ml-411753430"></a>
### parse

```ml
function parse(reader)
```

Implements the `parse` operation for `miniquake.temp_entities` (parse).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `parse`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L111)

<a id="function-function-miniquake-temp-entities-parsetype-function-parsetype-reader-type-src-miniquake-temp-entities-ml-263926026"></a>
### parseType

```ml
function parseType(reader, type)
```

Mirrors CL_ParseTEnt's wire consumption.  Keeping this in the protocol layer is important: treating svc_temp_entity as a one-byte payload desynchronizes every command that follows it in the same server message.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `parseType`. |
| `type` | `dynamic` | — | The type input consumed by `parseType`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L86)

<a id="function-function-miniquake-temp-entities-readposition-function-readposition-reader-src-miniquake-temp-entities-ml-2050881460"></a>
### readPosition

```ml
function readPosition(reader)
```

Read and validate position.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readPosition`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L77)

<a id="function-function-miniquake-temp-entities-setbeam-function-setbeam-beam-entity-model-start-finish-currenttime-src-miniquake-temp-entities-ml-2125646267"></a>
### setBeam

```ml
function setBeam(beam, entity, model, start, finish, currentTime)
```

Update module state for beam.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `beam` | `dynamic` | — | The beam input consumed by `setBeam`. |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `start` | `dynamic` | — | The start input consumed by `setBeam`. |
| `finish` | `dynamic` | — | The finish input consumed by `setBeam`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/temp_entities.ml#L204)

- [miniquake.temp_entities.TempBeam](Type-miniquake-temp-entities-tempbeam-1243876356.md) — struct
- [miniquake.temp_entities.TempEntityState](Type-miniquake-temp-entities-tempentitystate-955846713.md) — struct
- [miniquake.temp_entities.TempRenderEntity](Type-miniquake-temp-entities-temprenderentity-271450872.md) — struct
