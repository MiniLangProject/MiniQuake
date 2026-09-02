# `src/miniquake/particles.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.particles`](Package-miniquake-particles-200286334.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrays` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/message.ml` as `msg` → [src/miniquake/message.ml](File-src-miniquake-message-ml-238261765.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/render/alias_normals.ml` as `aliasNormals` → [src/miniquake/render/alias_normals.ml](File-src-miniquake-render-alias-normals-ml-1036618994.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="constant-constant-miniquake-particles-absolute-min-particles-const-absolute-min-particles-512-src-miniquake-particles-ml-792393190"></a>
### ABSOLUTE_MIN_PARTICLES

```ml
const ABSOLUTE_MIN_PARTICLES = 512
```

Defines the absolute min particles value used by `miniquake.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L39)

<a id="function-function-miniquake-particles-appendlimited-function-appendlimited-target-source-src-miniquake-particles-ml-231426545"></a>
### appendLimited

```ml
function appendLimited(target, source)
```

Add state for append limited.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `dynamic` | — | The target input consumed by `appendLimited`. |
| `source` | `dynamic` | — | Source value or collection to read. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L749)

<a id="function-function-miniquake-particles-blobexplosion-function-blobexplosion-origin-currenttime-src-miniquake-particles-ml-917162155"></a>
### blobExplosion

```ml
function blobExplosion(origin, currentTime)
```

Implements the `blobExplosion` operation for `miniquake.particles` (blob explosion).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L867)

<a id="function-function-miniquake-particles-canonicalentitynormals-function-canonicalentitynormals-src-miniquake-particles-ml-1221304005"></a>
### canonicalEntityNormals

```ml
function canonicalEntityNormals()
```

Returns whether `miniquake.particles` can onical entity normals.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L706)

<a id="global-global-miniquake-particles-canonicalvertexnormals-canonicalvertexnormals-src-miniquake-particles-ml-1210767821"></a>
### canonicalVertexNormals

```ml
canonicalVertexNormals
```

Tracks the module-level canonical vertex normals state owned by `miniquake.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L77)

<a id="global-global-miniquake-particles-compatangularvelocities-compatangularvelocities-src-miniquake-particles-ml-928314505"></a>
### compatAngularVelocities

```ml
compatAngularVelocities
```

Tracks the module-level compat angular velocities state owned by `miniquake.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L75)

<a id="function-function-miniquake-particles-compatibilitysystem-function-compatibilitysystem-src-miniquake-particles-ml-1053679599"></a>
### compatibilitySystem

```ml
function compatibilitySystem()
```

Implements the `compatibilitySystem` operation for `miniquake.particles` (compatibility system).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L693)

<a id="function-function-miniquake-particles-compatibilitysystemwithactive-function-compatibilitysystemwithactive-active-src-miniquake-particles-ml-1795285869"></a>
### compatibilitySystemWithActive

```ml
function compatibilitySystemWithActive(active)
```

Report whether compatibility system with active holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `active` | `dynamic` | — | The active input consumed by `compatibilitySystemWithActive`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L700)

<a id="function-function-miniquake-particles-compatrand-function-compatrand-src-miniquake-particles-ml-174080945"></a>
### compatRand

```ml
function compatRand()
```

Implements the `compatRand` operation for `miniquake.particles` (compat rand).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L740)

<a id="global-global-miniquake-particles-compatrandomseed-compatrandomseed-src-miniquake-particles-ml-1785611837"></a>
### compatRandomSeed

```ml
compatRandomSeed
```

Tracks the module-level compat random seed state owned by `miniquake.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L71)

<a id="global-global-miniquake-particles-compattracercount-compattracercount-src-miniquake-particles-ml-261255661"></a>
### compatTracerCount

```ml
compatTracerCount
```

Tracks the module-level compat tracer count state owned by `miniquake.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L73)

<a id="function-function-miniquake-particles-createsystem-function-createsystem-capacity-src-miniquake-particles-ml-341527213"></a>
### createSystem

```ml
function createSystem(capacity)
```

Create and initialize system.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `capacity` | `dynamic` | — | Maximum number of entries the destination can hold. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L98)

<a id="function-function-miniquake-particles-entityparticlesinto-function-entityparticlesinto-active-entityorigin-currenttime-src-miniquake-particles-ml-1390977028"></a>
### entityParticlesInto

```ml
function entityParticlesInto(active, entityOrigin, currentTime)
```

CL_RelinkEntities shares r_part.c's single active/free particle pool with temp entities.  These integration helpers operate on that existing pool so saturation stops allocation (and random-number consumption) at the same particle as the original linked-list implementation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `active` | `dynamic` | — | The active input consumed by `entityParticlesInto`. |
| `entityOrigin` | `dynamic` | — | The entity origin input consumed by `entityParticlesInto`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L909)

<a id="function-function-miniquake-particles-explosion-function-explosion-origin-currenttime-src-miniquake-particles-ml-1555420881"></a>
### explosion

```ml
function explosion(origin, currentTime)
```

Implements the `explosion` operation for `miniquake.particles` (explosion).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L846)

<a id="function-function-miniquake-particles-explosion2-function-explosion2-origin-colorstart-colorlength-currenttime-src-miniquake-particles-ml-920574587"></a>
### explosion2

```ml
function explosion2(origin, colorStart, colorLength, currentTime)
```

Implements the `explosion2` operation for `miniquake.particles` (explosion2).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `colorStart` | `dynamic` | — | The color start input consumed by `explosion2`. |
| `colorLength` | `dynamic` | — | Length of the requested data in units appropriate to the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L857)

<a id="function-function-miniquake-particles-finishcompatibility-function-finishcompatibility-system-src-miniquake-particles-ml-797318046"></a>
### finishCompatibility

```ml
function finishCompatibility(system)
```

Finalize state for finish compatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `finishCompatibility`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L721)

<a id="function-function-miniquake-particles-initializeangularvelocities-function-initializeangularvelocities-system-count-src-miniquake-particles-ml-1619760091"></a>
### initializeAngularVelocities

```ml
function initializeAngularVelocities(system, count)
```

Initialize state for initialize angular velocities.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `initializeAngularVelocities`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L201)

<a id="function-function-miniquake-particles-lavasplash-function-lavasplash-origin-currenttime-src-miniquake-particles-ml-408207343"></a>
### lavaSplash

```ml
function lavaSplash(origin, currentTime)
```

Implements the `lavaSplash` operation for `miniquake.particles` (lava splash).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L876)

<a id="constant-constant-miniquake-particles-max-particles-const-max-particles-2048-src-miniquake-particles-ml-540114654"></a>
### MAX_PARTICLES

```ml
const MAX_PARTICLES = 2048
```

Defines the max particles value used by `miniquake.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L37)

<a id="constant-constant-miniquake-particles-num-vertex-normals-const-num-vertex-normals-162-src-miniquake-particles-ml-1192459875"></a>
### NUM_VERTEX_NORMALS

```ml
const NUM_VERTEX_NORMALS = 162
```

Defines the num vertex normals value used by `miniquake.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L41)

<a id="function-function-miniquake-particles-particledrawcommand-function-particledrawcommand-particle-vieworigin-viewforward-scaledup-scaledright-src-miniquake-particles-ml-993170913"></a>
### particleDrawCommand

```ml
function particleDrawCommand(particle, viewOrigin, viewForward, scaledUp, scaledRight)
```

Implements the `particleDrawCommand` operation for `miniquake.particles` (particle draw command).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `particle` | `dynamic` | — | The particle input consumed by `particleDrawCommand`. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `particleDrawCommand`. |
| `viewForward` | `dynamic` | — | The view forward input consumed by `particleDrawCommand`. |
| `scaledUp` | `dynamic` | — | The scaled up input consumed by `particleDrawCommand`. |
| `scaledRight` | `dynamic` | — | The scaled right input consumed by `particleDrawCommand`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L576)

<a id="function-function-miniquake-particles-particlefloat-function-particlefloat-value-src-miniquake-particles-ml-652426080"></a>
### particleFloat

```ml
function particleFloat(value)
```

Implements the `particleFloat` operation for `miniquake.particles` (particle float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `particleFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L45)

- [miniquake.particles.ParticleSystem](Type-miniquake-particles-particlesystem-1233661907.md) — struct
<a id="function-function-miniquake-particles-pointeffect-function-pointeffect-origin-count-color-currenttime-src-miniquake-particles-ml-624224043"></a>
### pointEffect

```ml
function pointEffect(origin, count, color, currentTime)
```

Implements the `pointEffect` operation for `miniquake.particles` (point effect).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `count` | `dynamic` | — | Number of entries or units to process. |
| `color` | `dynamic` | — | Color value used by the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L839)

<a id="constant-constant-miniquake-particles-pt-blob-const-pt-blob-6-src-miniquake-particles-ml-1669079790"></a>
### PT_BLOB

```ml
const PT_BLOB = 6
```

Defines the pt blob value used by `miniquake.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L32)

<a id="constant-constant-miniquake-particles-pt-blob2-const-pt-blob2-7-src-miniquake-particles-ml-477667129"></a>
### PT_BLOB2

```ml
const PT_BLOB2 = 7
```

Defines the pt blob2 value used by `miniquake.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L34)

<a id="constant-constant-miniquake-particles-pt-explode-const-pt-explode-4-src-miniquake-particles-ml-833746022"></a>
### PT_EXPLODE

```ml
const PT_EXPLODE = 4
```

Defines the pt explode value used by `miniquake.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L28)

<a id="constant-constant-miniquake-particles-pt-explode2-const-pt-explode2-5-src-miniquake-particles-ml-794128921"></a>
### PT_EXPLODE2

```ml
const PT_EXPLODE2 = 5
```

Defines the pt explode2 value used by `miniquake.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L30)

<a id="constant-constant-miniquake-particles-pt-fire-const-pt-fire-3-src-miniquake-particles-ml-1582004523"></a>
### PT_FIRE

```ml
const PT_FIRE = 3
```

Defines the pt fire value used by `miniquake.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L26)

<a id="constant-constant-miniquake-particles-pt-gravity-const-pt-gravity-1-src-miniquake-particles-ml-901734749"></a>
### PT_GRAVITY

```ml
const PT_GRAVITY = 1
```

Defines the pt gravity value used by `miniquake.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L22)

<a id="constant-constant-miniquake-particles-pt-slow-gravity-const-pt-slow-gravity-2-src-miniquake-particles-ml-1624471514"></a>
### PT_SLOW_GRAVITY

```ml
const PT_SLOW_GRAVITY = 2
```

Defines the pt slow gravity value used by `miniquake.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L24)

<a id="constant-constant-miniquake-particles-pt-static-const-pt-static-0-src-miniquake-particles-ml-744013024"></a>
### PT_STATIC

```ml
const PT_STATIC = 0
```

Defines the pt static value used by `miniquake.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L20)

<a id="function-function-miniquake-particles-r-allocparticle-function-r-allocparticle-system-src-miniquake-particles-ml-1138055096"></a>
### R_AllocParticle

```ml
function R_AllocParticle(system)
```

Apply the Quake-compatible r alloc particle behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `R_AllocParticle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L144)

<a id="function-function-miniquake-particles-r-blobexplosion-function-r-blobexplosion-system-origin-currenttime-src-miniquake-particles-ml-1258129602"></a>
### R_BlobExplosion

```ml
function R_BlobExplosion(system, origin, currentTime)
```

Apply the Quake-compatible r blob explosion behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `R_BlobExplosion`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L367)

<a id="function-function-miniquake-particles-r-clearparticles-function-r-clearparticles-system-src-miniquake-particles-ml-518709780"></a>
### R_ClearParticles

```ml
function R_ClearParticles(system)
```

Apply the Quake-compatible r clear particles behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `R_ClearParticles`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L122)

<a id="function-function-miniquake-particles-r-darkfieldparticles-function-r-darkfieldparticles-system-entityorigin-currenttime-src-miniquake-particles-ml-141387201"></a>
### R_DarkFieldParticles

```ml
function R_DarkFieldParticles(system, entityOrigin, currentTime)
```

Apply the Quake-compatible r dark field particles behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `R_DarkFieldParticles`. |
| `entityOrigin` | `dynamic` | — | The entity origin input consumed by `R_DarkFieldParticles`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L169)

<a id="function-function-miniquake-particles-r-drawparticles-function-r-drawparticles-system-currenttime-oldtime-gravity-vieworigin-viewforward-viewup-viewright-src-miniquake-particles-ml-231460176"></a>
### R_DrawParticles

```ml
function R_DrawParticles(system, currentTime, oldTime, gravity, viewOrigin, viewForward, viewUp, viewRight)
```

Produces the fixed-function MiniQuake command trace and advances particles in the same draw-before-simulate order as R_DrawParticles.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `R_DrawParticles`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `oldTime` | `dynamic` | — | Time value used by the operation. |
| `gravity` | `dynamic` | — | The gravity input consumed by `R_DrawParticles`. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `R_DrawParticles`. |
| `viewForward` | `dynamic` | — | The view forward input consumed by `R_DrawParticles`. |
| `viewUp` | `dynamic` | — | The view up input consumed by `R_DrawParticles`. |
| `viewRight` | `dynamic` | — | The view right input consumed by `R_DrawParticles`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L651)

<a id="function-function-miniquake-particles-r-entityparticles-function-r-entityparticles-system-entityorigin-currenttime-vertexnormals-src-miniquake-particles-ml-1443605177"></a>
### R_EntityParticles

```ml
function R_EntityParticles(system, entityOrigin, currentTime, vertexNormals)
```

r_avertexnormals belongs to the renderer rather than r_part.c, so callers provide that canonical 162-vector table as the explicit dependency.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `R_EntityParticles`. |
| `entityOrigin` | `dynamic` | — | The entity origin input consumed by `R_EntityParticles`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `vertexNormals` | `dynamic` | — | The vertex normals input consumed by `R_EntityParticles`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L224)

<a id="function-function-miniquake-particles-r-initparticles-function-r-initparticles-arguments-src-miniquake-particles-ml-2036189761"></a>
### R_InitParticles

```ml
function R_InitParticles(arguments)
```

Apply the Quake-compatible r init particles behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L105)

<a id="function-function-miniquake-particles-r-lavasplash-function-r-lavasplash-system-origin-currenttime-src-miniquake-particles-ml-439173264"></a>
### R_LavaSplash

```ml
function R_LavaSplash(system, origin, currentTime)
```

Apply the Quake-compatible r lava splash behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `R_LavaSplash`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L425)

<a id="function-function-miniquake-particles-r-parseparticleeffect-function-r-parseparticleeffect-system-reader-currenttime-src-miniquake-particles-ml-646320589"></a>
### R_ParseParticleEffect

```ml
function R_ParseParticleEffect(system, reader, currentTime)
```

Apply the Quake-compatible r parse particle effect behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `R_ParseParticleEffect`. |
| `reader` | `dynamic` | — | The reader input consumed by `R_ParseParticleEffect`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L291)

<a id="function-function-miniquake-particles-r-particleexplosion-function-r-particleexplosion-system-origin-currenttime-src-miniquake-particles-ml-1848252792"></a>
### R_ParticleExplosion

```ml
function R_ParticleExplosion(system, origin, currentTime)
```

Apply the Quake-compatible r particle explosion behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `R_ParticleExplosion`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L324)

<a id="function-function-miniquake-particles-r-particleexplosion2-function-r-particleexplosion2-system-origin-colorstart-colorlength-currenttime-src-miniquake-particles-ml-1606889474"></a>
### R_ParticleExplosion2

```ml
function R_ParticleExplosion2(system, origin, colorStart, colorLength, currentTime)
```

Apply the Quake-compatible r particle explosion2 behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `R_ParticleExplosion2`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `colorStart` | `dynamic` | — | The color start input consumed by `R_ParticleExplosion2`. |
| `colorLength` | `dynamic` | — | Length of the requested data in units appropriate to the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L346)

<a id="function-function-miniquake-particles-r-rand-function-r-rand-system-src-miniquake-particles-ml-317288068"></a>
### R_Rand

```ml
function R_Rand(system)
```

MiniQuake's Win32 build uses the Microsoft C runtime rand() sequence.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `R_Rand`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L137)

<a id="function-function-miniquake-particles-r-readpointfile-f-function-r-readpointfile-f-system-text-src-miniquake-particles-ml-2054069767"></a>
### R_ReadPointFile_f

```ml
function R_ReadPointFile_f(system, text)
```

Apply the Quake-compatible r read point file f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `R_ReadPointFile_f`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L263)

<a id="function-function-miniquake-particles-r-rockettrail-function-r-rockettrail-system-start-finish-trailtype-currenttime-src-miniquake-particles-ml-1933190483"></a>
### R_RocketTrail

```ml
function R_RocketTrail(system, start, finish, trailType, currentTime)
```

Apply the Quake-compatible r rocket trail behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `R_RocketTrail`. |
| `start` | `dynamic` | — | The start input consumed by `R_RocketTrail`. |
| `finish` | `dynamic` | — | The finish input consumed by `R_RocketTrail`. |
| `trailType` | `dynamic` | — | The trail type input consumed by `R_RocketTrail`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L491)

<a id="function-function-miniquake-particles-r-runparticleeffect-function-r-runparticleeffect-system-origin-direction-color-count-currenttime-src-miniquake-particles-ml-921016685"></a>
### R_RunParticleEffect

```ml
function R_RunParticleEffect(system, origin, direction, color, count, currentTime)
```

Apply the Quake-compatible r run particle effect behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `R_RunParticleEffect`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `direction` | `dynamic` | — | The direction input consumed by `R_RunParticleEffect`. |
| `color` | `dynamic` | — | Color value used by the operation. |
| `count` | `dynamic` | — | Number of entries or units to process. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L393)

<a id="function-function-miniquake-particles-r-setrandomseed-function-r-setrandomseed-system-seed-src-miniquake-particles-ml-966937287"></a>
### R_SetRandomSeed

```ml
function R_SetRandomSeed(system, seed)
```

Apply the Quake-compatible r set random seed behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `R_SetRandomSeed`. |
| `seed` | `dynamic` | — | The seed input consumed by `R_SetRandomSeed`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L130)

<a id="function-function-miniquake-particles-r-teleportsplash-function-r-teleportsplash-system-origin-currenttime-src-miniquake-particles-ml-254360092"></a>
### R_TeleportSplash

```ml
function R_TeleportSplash(system, origin, currentTime)
```

Apply the Quake-compatible r teleport splash behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `R_TeleportSplash`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L455)

<a id="global-global-miniquake-particles-ramp1-ramp1-src-miniquake-particles-ml-99958601"></a>
### ramp1

```ml
ramp1
```

Tracks the module-level ramp1 state owned by `miniquake.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L50)

<a id="global-global-miniquake-particles-ramp2-ramp2-src-miniquake-particles-ml-1690751789"></a>
### ramp2

```ml
ramp2
```

Tracks the module-level ramp2 state owned by `miniquake.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L52)

<a id="global-global-miniquake-particles-ramp3-ramp3-src-miniquake-particles-ml-1222566189"></a>
### ramp3

```ml
ramp3
```

Tracks the module-level ramp3 state owned by `miniquake.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L54)

<a id="function-function-miniquake-particles-rampcolor-function-rampcolor-values-ramp-src-miniquake-particles-ml-1178138045"></a>
### rampColor

```ml
function rampColor(values, ramp)
```

Implements the `rampColor` operation for `miniquake.particles` (ramp color).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `rampColor`. |
| `ramp` | `dynamic` | — | The ramp input consumed by `rampColor`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L158)

<a id="function-function-miniquake-particles-randomexplosionvector-function-randomexplosionvector-system-origin-particle-src-miniquake-particles-ml-1045472926"></a>
### randomExplosionVector

```ml
function randomExplosionVector(system, origin, particle)
```

Return random explosion vector derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `randomExplosionVector`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `particle` | `dynamic` | — | The particle input consumed by `randomExplosionVector`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L309)

<a id="function-function-miniquake-particles-resetrandom-function-resetrandom-seed-src-miniquake-particles-ml-1647049492"></a>
### resetRandom

```ml
function resetRandom(seed)
```

Update module state for random.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `seed` | `dynamic` | — | The seed input consumed by `resetRandom`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L731)

<a id="function-function-miniquake-particles-rockettrail-function-rockettrail-start-finish-trailtype-currenttime-src-miniquake-particles-ml-1154992090"></a>
### rocketTrail

```ml
function rocketTrail(start, finish, trailType, currentTime)
```

Implements the `rocketTrail` operation for `miniquake.particles` (rocket trail).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start` | `dynamic` | — | The start input consumed by `rocketTrail`. |
| `finish` | `dynamic` | — | The finish input consumed by `rocketTrail`. |
| `trailType` | `dynamic` | — | The trail type input consumed by `rocketTrail`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L896)

<a id="function-function-miniquake-particles-rockettrailinto-function-rockettrailinto-active-start-finish-trailtype-currenttime-src-miniquake-particles-ml-1512496936"></a>
### rocketTrailInto

```ml
function rocketTrailInto(active, start, finish, trailType, currentTime)
```

Implements the `rocketTrailInto` operation for `miniquake.particles` (rocket trail into).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `active` | `dynamic` | — | The active input consumed by `rocketTrailInto`. |
| `start` | `dynamic` | — | The start input consumed by `rocketTrailInto`. |
| `finish` | `dynamic` | — | The finish input consumed by `rocketTrailInto`. |
| `trailType` | `dynamic` | — | The trail type input consumed by `rocketTrailInto`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L921)

<a id="function-function-miniquake-particles-runeffect-function-runeffect-origin-direction-count-color-currenttime-src-miniquake-particles-ml-1630418702"></a>
### runEffect

```ml
function runEffect(origin, direction, count, color, currentTime)
```

Execute effect.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `direction` | `dynamic` | — | The direction input consumed by `runEffect`. |
| `count` | `dynamic` | — | Number of entries or units to process. |
| `color` | `dynamic` | — | Color value used by the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L828)

<a id="function-function-miniquake-particles-spawn-function-spawn-origin-velocity-dietime-color-type-src-miniquake-particles-ml-935417636"></a>
### spawn

```ml
function spawn(origin, velocity, dieTime, color, type)
```

Implements the `spawn` operation for `miniquake.particles` (spawn).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `velocity` | `dynamic` | — | Velocity applied by the operation. |
| `dieTime` | `dynamic` | — | Time value used by the operation. |
| `color` | `dynamic` | — | Color value used by the operation. |
| `type` | `dynamic` | — | The type input consumed by `spawn`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L85)

<a id="function-function-miniquake-particles-teleportsplash-function-teleportsplash-origin-currenttime-src-miniquake-particles-ml-886954935"></a>
### teleportSplash

```ml
function teleportSplash(origin, currentTime)
```

Implements the `teleportSplash` operation for `miniquake.particles` (teleport splash).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L885)

<a id="function-function-miniquake-particles-update-function-update-particles-currenttime-deltatime-src-miniquake-particles-ml-1054691029"></a>
### update

```ml
function update(particles, currentTime, deltaTime)
```

Compatibility wrapper for callers that do not own the server cvar table. The integrated Host_Frame path uses updateWithGravity and passes the current sv_gravity value, matching R_DrawParticles' extern cvar dependency.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `particles` | `dynamic` | — | The particles input consumed by `update`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `deltaTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L818)

<a id="function-function-miniquake-particles-updateparticlephysics-function-updateparticlephysics-particle-frametime-gravity-src-miniquake-particles-ml-1500576705"></a>
### updateParticlePhysics

```ml
function updateParticlePhysics(particle, frameTime, gravity)
```

Update module state for particle physics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `particle` | `dynamic` | — | The particle input consumed by `updateParticlePhysics`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `gravity` | `dynamic` | — | The gravity input consumed by `updateParticlePhysics`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L589)

<a id="function-function-miniquake-particles-updatewithgravity-function-updatewithgravity-particles-currenttime-deltatime-gravity-src-miniquake-particles-ml-2096296289"></a>
### updateWithGravity

```ml
function updateWithGravity(particles, currentTime, deltaTime, gravity)
```

Update module state for with gravity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `particles` | `dynamic` | — | The particles input consumed by `updateWithGravity`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `deltaTime` | `dynamic` | — | Time value used by the operation. |
| `gravity` | `dynamic` | — | The gravity input consumed by `updateWithGravity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L769)

<a id="function-function-miniquake-particles-zerovector-function-zerovector-src-miniquake-particles-ml-1575379469"></a>
### zeroVector

```ml
function zeroVector()
```

Implements the `zeroVector` operation for `miniquake.particles` (zero vector).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/particles.ml#L92)
