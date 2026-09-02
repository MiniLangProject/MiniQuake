# `src/miniquake/mathlib.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.mathlib`](Package-miniquake-mathlib-2103480336.md)

Reachable from entry: **yes**

## Imports

- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `std/math.ml` as `smath` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/math.ml` — external dependency

## Declarations

<a id="function-function-miniquake-mathlib-dotproduct-function-dotproduct-first-second-src-miniquake-mathlib-ml-1320942893"></a>
### _DotProduct

```ml
function _DotProduct(first, second)
```

Implements the `_DotProduct` operation for `miniquake.mathlib` (dot product).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `_DotProduct`. |
| `second` | `dynamic` | — | The second input consumed by `_DotProduct`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L451)

<a id="function-function-miniquake-mathlib-vectoradd-function-vectoradd-first-second-src-miniquake-mathlib-ml-1300920847"></a>
### _VectorAdd

```ml
function _VectorAdd(first, second)
```

Implements the `_VectorAdd` operation for `miniquake.mathlib` (vector add).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `_VectorAdd`. |
| `second` | `dynamic` | — | The second input consumed by `_VectorAdd`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L465)

<a id="function-function-miniquake-mathlib-vectorcopy-function-vectorcopy-value-src-miniquake-mathlib-ml-1491107774"></a>
### _VectorCopy

```ml
function _VectorCopy(value)
```

Implements the `_VectorCopy` operation for `miniquake.mathlib` (vector copy).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `_VectorCopy`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L471)

<a id="function-function-miniquake-mathlib-vectorsubtract-function-vectorsubtract-first-second-src-miniquake-mathlib-ml-1703462175"></a>
### _VectorSubtract

```ml
function _VectorSubtract(first, second)
```

Implements the `_VectorSubtract` operation for `miniquake.mathlib` (vector subtract).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `_VectorSubtract`. |
| `second` | `dynamic` | — | The second input consumed by `_VectorSubtract`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L458)

<a id="function-function-miniquake-mathlib-add-function-add-a-b-src-miniquake-mathlib-ml-1907688836"></a>
### add

```ml
function add(a, b)
```

Add state for add.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — | The a input consumed by `add`. |
| `b` | `dynamic` | — | The b input consumed by `add`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L78)

<a id="function-function-miniquake-mathlib-anglemod-function-anglemod-angle-src-miniquake-mathlib-ml-232498266"></a>
### angleMod

```ml
function angleMod(angle)
```

Implements the `angleMod` operation for `miniquake.mathlib` (angle mod).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `angle` | `dynamic` | — | The angle input consumed by `angleMod`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L304)

<a id="function-function-miniquake-mathlib-anglemod-function-anglemod-angle-src-miniquake-mathlib-ml-281183898"></a>
### anglemod

```ml
function anglemod(angle)
```

Implements the `anglemod` operation for `miniquake.mathlib` (anglemod).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `angle` | `dynamic` | — | The angle input consumed by `anglemod`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L297)

<a id="function-function-miniquake-mathlib-anglevectors-function-anglevectors-angles-src-miniquake-mathlib-ml-1839610929"></a>
### AngleVectors

```ml
function AngleVectors(angles)
```

Implements the `AngleVectors` operation for `miniquake.mathlib` (angle vectors).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L388)

<a id="function-function-miniquake-mathlib-anglevectors-function-anglevectors-angles-src-miniquake-mathlib-ml-949719985"></a>
### angleVectors

```ml
function angleVectors(angles)
```

Implements the `angleVectors` operation for `miniquake.mathlib` (angle vectors).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L420)

<a id="function-function-miniquake-mathlib-atan2-function-atan2-y-x-src-miniquake-mathlib-ml-742100412"></a>
### atan2

```ml
function atan2(y, x)
```

Implements the `atan2` operation for `miniquake.mathlib` (atan2).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `y` | `dynamic` | — | The y input consumed by `atan2`. |
| `x` | `dynamic` | — | The x input consumed by `atan2`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L157)

<a id="function-function-miniquake-mathlib-bops-error-function-bops-error-src-miniquake-mathlib-ml-1569669301"></a>
### BOPS_Error

```ml
function BOPS_Error()
```

Mirror Quake's BOPS_Error routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L309)

<a id="function-function-miniquake-mathlib-box-on-plane-side-function-box-on-plane-side-emins-emaxs-plane-src-miniquake-mathlib-ml-792459401"></a>
### BOX_ON_PLANE_SIDE

```ml
function BOX_ON_PLANE_SIDE(emins, emaxs, plane)
```

Mirror Quake's BOX_ON_PLANE_SIDE routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `emins` | `dynamic` | — | The emins input consumed by `BOX_ON_PLANE_SIDE`. |
| `emaxs` | `dynamic` | — | The emaxs input consumed by `BOX_ON_PLANE_SIDE`. |
| `plane` | `dynamic` | — | The plane input consumed by `BOX_ON_PLANE_SIDE`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L359)

<a id="function-function-miniquake-mathlib-boxonplaneside-function-boxonplaneside-emins-emaxs-plane-src-miniquake-mathlib-ml-306453441"></a>
### BoxOnPlaneSide

```ml
function BoxOnPlaneSide(emins, emaxs, plane)
```

Implements the `BoxOnPlaneSide` operation for `miniquake.mathlib` (box on plane side).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `emins` | `dynamic` | — | The emins input consumed by `BoxOnPlaneSide`. |
| `emaxs` | `dynamic` | — | The emaxs input consumed by `BoxOnPlaneSide`. |
| `plane` | `dynamic` | — | The plane input consumed by `BoxOnPlaneSide`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L317)

<a id="function-function-miniquake-mathlib-boxonplaneside-function-boxonplaneside-emins-emaxs-plane-src-miniquake-mathlib-ml-1721878913"></a>
### boxOnPlaneSide

```ml
function boxOnPlaneSide(emins, emaxs, plane)
```

Implements the `boxOnPlaneSide` operation for `miniquake.mathlib` (box on plane side).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `emins` | `dynamic` | — | The emins input consumed by `boxOnPlaneSide`. |
| `emaxs` | `dynamic` | — | The emaxs input consumed by `boxOnPlaneSide`. |
| `plane` | `dynamic` | — | The plane input consumed by `boxOnPlaneSide`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L382)

<a id="function-function-miniquake-mathlib-clamp-function-clamp-value-minimum-maximum-src-miniquake-mathlib-ml-1836591716"></a>
### clamp

```ml
function clamp(value, minimum, maximum)
```

Return a validated clamp value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `clamp`. |
| `minimum` | `dynamic` | — | Smallest accepted value. |
| `maximum` | `dynamic` | — | Largest accepted value. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L142)

<a id="function-function-miniquake-mathlib-copy-function-copy-value-src-miniquake-mathlib-ml-562701640"></a>
### copy

```ml
function copy(value)
```

Existing MiniQuake convenience spellings preserve value semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `copy`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L71)

<a id="function-function-miniquake-mathlib-cos-function-cos-value-src-miniquake-mathlib-ml-1827210002"></a>
### cos

```ml
function cos(value)
```

Implements the `cos` operation for `miniquake.mathlib` (cos).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `cos`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L169)

<a id="function-function-miniquake-mathlib-cross-function-cross-a-b-src-miniquake-mathlib-ml-1399706298"></a>
### cross

```ml
function cross(a, b)
```

Implements the `cross` operation for `miniquake.mathlib` (cross).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — | The a input consumed by `cross`. |
| `b` | `dynamic` | — | The b input consumed by `cross`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L114)

<a id="function-function-miniquake-mathlib-crossproduct-function-crossproduct-first-second-src-miniquake-mathlib-ml-2055623047"></a>
### CrossProduct

```ml
function CrossProduct(first, second)
```

Implements the `CrossProduct` operation for `miniquake.mathlib` (cross product).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `CrossProduct`. |
| `second` | `dynamic` | — | The second input consumed by `CrossProduct`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L478)

<a id="constant-constant-miniquake-mathlib-deg-to-rad-const-deg-to-rad-1-74532925199433e-002-src-miniquake-mathlib-ml-275817851"></a>
### DEG_TO_RAD

```ml
const DEG_TO_RAD = 1.74532925199433e-002
```

Defines the deg to rad value used by `miniquake.mathlib`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L19)

<a id="function-function-miniquake-mathlib-dot-function-dot-a-b-src-miniquake-mathlib-ml-237070884"></a>
### dot

```ml
function dot(a, b)
```

Implements the `dot` operation for `miniquake.mathlib` (dot).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — | The a input consumed by `dot`. |
| `b` | `dynamic` | — | The b input consumed by `dot`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L107)

<a id="function-function-miniquake-mathlib-dotproduct-inline-function-dotproduct-a-b-src-miniquake-mathlib-ml-2141282997"></a>
### DotProduct

```ml
inline function DotProduct(a, b)
```

mathlib.h macro counterparts.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — | The a input consumed by `DotProduct`. |
| `b` | `dynamic` | — | The b input consumed by `DotProduct`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L39)

<a id="function-function-miniquake-mathlib-floordivmod-function-floordivmod-numerator-denominator-src-miniquake-mathlib-ml-4650898"></a>
### FloorDivMod

```ml
function FloorDivMod(numerator, denominator)
```

Implements the `FloorDivMod` operation for `miniquake.mathlib` (floor div mod).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `numerator` | `dynamic` | — | The numerator input consumed by `FloorDivMod`. |
| `denominator` | `dynamic` | — | The denominator input consumed by `FloorDivMod`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L564)

<a id="function-function-miniquake-mathlib-greatestcommondivisor-function-greatestcommondivisor-first-second-src-miniquake-mathlib-ml-684677379"></a>
### GreatestCommonDivisor

```ml
function GreatestCommonDivisor(first, second)
```

Implements the `GreatestCommonDivisor` operation for `miniquake.mathlib` (greatest common divisor).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `GreatestCommonDivisor`. |
| `second` | `dynamic` | — | The second input consumed by `GreatestCommonDivisor`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L587)

<a id="function-function-miniquake-mathlib-greatestcommondivisor-function-greatestcommondivisor-first-second-src-miniquake-mathlib-ml-783590979"></a>
### greatestCommonDivisor

```ml
function greatestCommonDivisor(first, second)
```

Implements the `greatestCommonDivisor` operation for `miniquake.mathlib` (greatest common divisor).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `greatestCommonDivisor`. |
| `second` | `dynamic` | — | The second input consumed by `greatestCommonDivisor`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L599)

<a id="function-function-miniquake-mathlib-invert24to16-function-invert24to16-value-src-miniquake-mathlib-ml-1209255516"></a>
### Invert24To16

```ml
function Invert24To16(value)
```

Implements the `Invert24To16` operation for `miniquake.mathlib` (invert24 to16).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `Invert24To16`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L605)

<a id="function-function-miniquake-mathlib-is-nan-function-is-nan-value-src-miniquake-mathlib-ml-549679608"></a>
### IS_NAN

```ml
function IS_NAN(value)
```

Report whether is nan.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `IS_NAN`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L65)

<a id="function-function-miniquake-mathlib-length-function-length-value-src-miniquake-mathlib-ml-1637395844"></a>
### Length

```ml
function Length(value)
```

Return length derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `Length`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L488)

<a id="function-function-miniquake-mathlib-length-function-length-value-src-miniquake-mathlib-ml-1465820932"></a>
### length

```ml
function length(value)
```

Return length derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `length`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L126)

<a id="function-function-miniquake-mathlib-lengthsquared-function-lengthsquared-value-src-miniquake-mathlib-ml-1856985618"></a>
### lengthSquared

```ml
function lengthSquared(value)
```

Return length squared for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `lengthSquared`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L120)

<a id="function-function-miniquake-mathlib-multiplyadd-function-multiplyadd-a-scalar-b-src-miniquake-mathlib-ml-1015180336"></a>
### multiplyAdd

```ml
function multiplyAdd(a, scalar, b)
```

Implements the `multiplyAdd` operation for `miniquake.mathlib` (multiply add).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — | The a input consumed by `multiplyAdd`. |
| `scalar` | `dynamic` | — | The scalar input consumed by `multiplyAdd`. |
| `b` | `dynamic` | — | The b input consumed by `multiplyAdd`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L100)

<a id="constant-constant-miniquake-mathlib-nan-mask-const-nan-mask-2139095040-src-miniquake-mathlib-ml-1962562075"></a>
### NAN_MASK

```ml
const NAN_MASK = 2139095040
```

Defines the nan mask value used by `miniquake.mathlib`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L21)

<a id="function-function-miniquake-mathlib-normalize-function-normalize-value-src-miniquake-mathlib-ml-1421931866"></a>
### normalize

```ml
function normalize(value)
```

Convert the requested value into its canonical representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `normalize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L132)

<a id="function-function-miniquake-mathlib-perpendicularvector-function-perpendicularvector-source-src-miniquake-mathlib-ml-1724995374"></a>
### PerpendicularVector

```ml
function PerpendicularVector(source)
```

Return perpendicular vector derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value or collection to read. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L200)

<a id="function-function-miniquake-mathlib-perpendicularvector-function-perpendicularvector-source-src-miniquake-mathlib-ml-6192558"></a>
### perpendicularVector

```ml
function perpendicularVector(source)
```

Return perpendicular vector derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value or collection to read. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L225)

<a id="constant-constant-miniquake-mathlib-pi-const-pi-3-14159265358979-src-miniquake-mathlib-ml-1608139889"></a>
### PI

```ml
const PI = 3.14159265358979
```

Defines the pi value used by `miniquake.mathlib`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L15)

<a id="function-function-miniquake-mathlib-projectpointonplane-function-projectpointonplane-point-normal-src-miniquake-mathlib-ml-1682500392"></a>
### ProjectPointOnPlane

```ml
function ProjectPointOnPlane(point, normal)
```

Implements the `ProjectPointOnPlane` operation for `miniquake.mathlib` (project point on plane).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `point` | `dynamic` | — | The point input consumed by `ProjectPointOnPlane`. |
| `normal` | `dynamic` | — | The normal input consumed by `ProjectPointOnPlane`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L176)

<a id="function-function-miniquake-mathlib-projectpointonplane-function-projectpointonplane-point-normal-src-miniquake-mathlib-ml-1562139688"></a>
### projectPointOnPlane

```ml
function projectPointOnPlane(point, normal)
```

Implements the `projectPointOnPlane` operation for `miniquake.mathlib` (project point on plane).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `point` | `dynamic` | — | The point input consumed by `projectPointOnPlane`. |
| `normal` | `dynamic` | — | The normal input consumed by `projectPointOnPlane`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L194)

<a id="function-function-miniquake-mathlib-q-log2-function-q-log2-value-src-miniquake-mathlib-ml-2118270180"></a>
### Q_log2

```ml
function Q_log2(value)
```

Provide the Quake-compatible log2 entry point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `Q_log2`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L524)

<a id="function-function-miniquake-mathlib-r-concatrotations-function-r-concatrotations-first-second-src-miniquake-mathlib-ml-1402284223"></a>
### R_ConcatRotations

```ml
function R_ConcatRotations(first, second)
```

Apply the Quake-compatible r concat rotations behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `R_ConcatRotations`. |
| `second` | `dynamic` | — | The second input consumed by `R_ConcatRotations`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L232)

<a id="function-function-miniquake-mathlib-r-concattransforms-function-r-concattransforms-first-second-src-miniquake-mathlib-ml-299601839"></a>
### R_ConcatTransforms

```ml
function R_ConcatTransforms(first, second)
```

Apply the Quake-compatible r concat transforms behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `R_ConcatTransforms`. |
| `second` | `dynamic` | — | The second input consumed by `R_ConcatTransforms`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L538)

<a id="constant-constant-miniquake-mathlib-rad-to-deg-const-rad-to-deg-57-2957795130823-src-miniquake-mathlib-ml-1170490865"></a>
### RAD_TO_DEG

```ml
const RAD_TO_DEG = 57.2957795130823
```

Defines the rad to deg value used by `miniquake.mathlib`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L17)

<a id="function-function-miniquake-mathlib-rotatepointaroundvector-function-rotatepointaroundvector-direction-point-degrees-src-miniquake-mathlib-ml-2111479733"></a>
### RotatePointAroundVector

```ml
function RotatePointAroundVector(direction, point, degrees)
```

Return rotate point around vector derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `direction` | `dynamic` | — | The direction input consumed by `RotatePointAroundVector`. |
| `point` | `dynamic` | — | The point input consumed by `RotatePointAroundVector`. |
| `degrees` | `dynamic` | — | The degrees input consumed by `RotatePointAroundVector`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L256)

<a id="function-function-miniquake-mathlib-rotatepointaroundvector-function-rotatepointaroundvector-direction-point-degrees-src-miniquake-mathlib-ml-1215560501"></a>
### rotatePointAroundVector

```ml
function rotatePointAroundVector(direction, point, degrees)
```

Return rotate point around vector derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `direction` | `dynamic` | — | The direction input consumed by `rotatePointAroundVector`. |
| `point` | `dynamic` | — | The point input consumed by `rotatePointAroundVector`. |
| `degrees` | `dynamic` | — | The degrees input consumed by `rotatePointAroundVector`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L291)

<a id="function-function-miniquake-mathlib-scale-function-scale-value-scalar-src-miniquake-mathlib-ml-52087908"></a>
### scale

```ml
function scale(value, scalar)
```

Implements the `scale` operation for `miniquake.mathlib` (scale).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `scale`. |
| `scalar` | `dynamic` | — | The scalar input consumed by `scale`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L92)

<a id="function-function-miniquake-mathlib-sin-function-sin-value-src-miniquake-mathlib-ml-956314256"></a>
### sin

```ml
function sin(value)
```

Implements the `sin` operation for `miniquake.mathlib` (sin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `sin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L163)

<a id="function-function-miniquake-mathlib-sqrt-function-sqrt-value-src-miniquake-mathlib-ml-1302837480"></a>
### sqrt

```ml
function sqrt(value)
```

Implements the `sqrt` operation for `miniquake.mathlib` (sqrt).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `sqrt`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L150)

<a id="function-function-miniquake-mathlib-subtract-function-subtract-a-b-src-miniquake-mathlib-ml-759770234"></a>
### subtract

```ml
function subtract(a, b)
```

Implements the `subtract` operation for `miniquake.mathlib` (subtract).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — | The a input consumed by `subtract`. |
| `b` | `dynamic` | — | The b input consumed by `subtract`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L85)

<a id="function-function-miniquake-mathlib-vec3-function-vec3-x-y-z-src-miniquake-mathlib-ml-1452465926"></a>
### vec3

```ml
function vec3(x, y, z)
```

Implements the `vec3` operation for `miniquake.mathlib` (vec3).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `vec3`. |
| `y` | `dynamic` | — | The y input consumed by `vec3`. |
| `z` | `dynamic` | — | The z input consumed by `vec3`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L27)

<a id="function-function-miniquake-mathlib-vec3origin-function-vec3origin-src-miniquake-mathlib-ml-203931317"></a>
### vec3Origin

```ml
function vec3Origin()
```

Return vec3 origin derived from the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L32)

<a id="function-function-miniquake-mathlib-vectoradd-function-vectoradd-a-b-src-miniquake-mathlib-ml-1285158734"></a>
### VectorAdd

```ml
function VectorAdd(a, b)
```

Implements the `VectorAdd` operation for `miniquake.mathlib` (vector add).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — | The a input consumed by `VectorAdd`. |
| `b` | `dynamic` | — | The b input consumed by `VectorAdd`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L53)

<a id="function-function-miniquake-mathlib-vectorcompare-function-vectorcompare-first-second-src-miniquake-mathlib-ml-684191895"></a>
### VectorCompare

```ml
function VectorCompare(first, second)
```

Implements the `VectorCompare` operation for `miniquake.mathlib` (vector compare).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `VectorCompare`. |
| `second` | `dynamic` | — | The second input consumed by `VectorCompare`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L427)

<a id="function-function-miniquake-mathlib-vectorcopy-function-vectorcopy-value-src-miniquake-mathlib-ml-1105691528"></a>
### VectorCopy

```ml
function VectorCopy(value)
```

Implements the `VectorCopy` operation for `miniquake.mathlib` (vector copy).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `VectorCopy`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L59)

<a id="function-function-miniquake-mathlib-vectorinverse-function-vectorinverse-value-src-miniquake-mathlib-ml-208965562"></a>
### VectorInverse

```ml
function VectorInverse(value)
```

Implements the `VectorInverse` operation for `miniquake.mathlib` (vector inverse).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `VectorInverse`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L508)

<a id="function-function-miniquake-mathlib-vectorma-function-vectorma-first-scalar-second-src-miniquake-mathlib-ml-463427171"></a>
### VectorMA

```ml
function VectorMA(first, scalar, second)
```

Implements the `VectorMA` operation for `miniquake.mathlib` (vector ma).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `VectorMA`. |
| `scalar` | `dynamic` | — | The scalar input consumed by `VectorMA`. |
| `second` | `dynamic` | — | The second input consumed by `VectorMA`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L438)

<a id="function-function-miniquake-mathlib-vectornormalize-function-vectornormalize-value-src-miniquake-mathlib-ml-1277424304"></a>
### VectorNormalize

```ml
function VectorNormalize(value)
```

Implements the `VectorNormalize` operation for `miniquake.mathlib` (vector normalize).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `VectorNormalize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L495)

<a id="function-function-miniquake-mathlib-vectorscale-function-vectorscale-value-scalar-src-miniquake-mathlib-ml-2079855658"></a>
### VectorScale

```ml
function VectorScale(value, scalar)
```

Implements the `VectorScale` operation for `miniquake.mathlib` (vector scale).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `VectorScale`. |
| `scalar` | `dynamic` | — | The scalar input consumed by `VectorScale`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L518)

<a id="function-function-miniquake-mathlib-vectorsubtract-function-vectorsubtract-a-b-src-miniquake-mathlib-ml-1339038246"></a>
### VectorSubtract

```ml
function VectorSubtract(a, b)
```

Implements the `VectorSubtract` operation for `miniquake.mathlib` (vector subtract).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — | The a input consumed by `VectorSubtract`. |
| `b` | `dynamic` | — | The b input consumed by `VectorSubtract`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mathlib.ml#L46)
