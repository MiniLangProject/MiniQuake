# `src/miniquake/server.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.server`](Package-miniquake-server-1293912780.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/cmd.ml` as `cmd` → [src/miniquake/cmd.ml](File-src-miniquake-cmd-ml-1014778996.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/cvar.ml` as `cvar` → [src/miniquake/cvar.ml](File-src-miniquake-cvar-ml-171521436.md)
- `miniquake/edict.ml` as `edict` → [src/miniquake/edict.ml](File-src-miniquake-edict-ml-279284209.md)
- `miniquake/filesystem.ml` as `qfs` → [src/miniquake/filesystem.ml](File-src-miniquake-filesystem-ml-1964591079.md)
- `miniquake/format/bsp.ml` as `bsp` → [src/miniquake/format/bsp.ml](File-src-miniquake-format-bsp-ml-22292029.md)
- `miniquake/format/progs.ml` as `progs` → [src/miniquake/format/progs.ml](File-src-miniquake-format-progs-ml-1508573313.md)
- `miniquake/host_command_numbers.ml` as `hostNumbers` → [src/miniquake/host_command_numbers.ml](File-src-miniquake-host-command-numbers-ml-2052828249.md)
- `miniquake/input.ml` as `input` → [src/miniquake/input.ml](File-src-miniquake-input-ml-1422374844.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/message.ml` as `msg` → [src/miniquake/message.ml](File-src-miniquake-message-ml-238261765.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/net_main.ml` as `netmain` → [src/miniquake/net_main.ml](File-src-miniquake-net-main-ml-940970693.md)
- `miniquake/physics.ml` as `physics` → [src/miniquake/physics.ml](File-src-miniquake-physics-ml-1999958331.md)
- `miniquake/platform/win32.ml` as `win` → [src/miniquake/platform/win32.ml](File-src-miniquake-platform-win32-ml-1233303091.md)
- `miniquake/player_move.ml` as `movement` → [src/miniquake/player_move.ml](File-src-miniquake-player-move-ml-856575161.md)
- `miniquake/protocol_delivery.ml` as `delivery` → [src/miniquake/protocol_delivery.ml](File-src-miniquake-protocol-delivery-ml-1050507123.md)
- `miniquake/protocol_events.ml` as `protocolEvents` → [src/miniquake/protocol_events.ml](File-src-miniquake-protocol-events-ml-1275855860.md)
- `miniquake/protocol_serverdata.ml` as `serverData` → [src/miniquake/protocol_serverdata.ml](File-src-miniquake-protocol-serverdata-ml-1434825110.md)
- `miniquake/protocol_transients.ml` as `transients` → [src/miniquake/protocol_transients.ml](File-src-miniquake-protocol-transients-ml-999469098.md)
- `miniquake/protocol_update.ml` as `protocolUpdate` → [src/miniquake/protocol_update.ml](File-src-miniquake-protocol-update-ml-1546315700.md)
- `miniquake/quakec/builtins.ml` as `qcbuiltins` → [src/miniquake/quakec/builtins.ml](File-src-miniquake-quakec-builtins-ml-1596628905.md)
- `miniquake/quakec/edict.ml` as `qcedict` → [src/miniquake/quakec/edict.ml](File-src-miniquake-quakec-edict-ml-1018045152.md)
- `miniquake/quakec/vm.ml` as `vm` → [src/miniquake/quakec/vm.ml](File-src-miniquake-quakec-vm-ml-1211659018.md)
- `miniquake/server_collision.ml` as `collision` → [src/miniquake/server_collision.ml](File-src-miniquake-server-collision-ml-849122018.md)
- `miniquake/sizebuf.ml` as `sz` → [src/miniquake/sizebuf.ml](File-src-miniquake-sizebuf-ml-252484438.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/world_bsp.ml` as `world` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)

## Declarations

<a id="function-function-miniquake-server-acceptlocal-function-acceptlocal-server-socket-src-miniquake-server-ml-1583112353"></a>
### acceptLocal

```ml
function acceptLocal(server, socket)
```

Implements the `acceptLocal` operation for `miniquake.server` (accept local).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L558)

<a id="function-function-miniquake-server-appendbaselines-function-appendbaselines-server-src-miniquake-server-ml-913684328"></a>
### appendBaselines

```ml
function appendBaselines(server)
```

Add state for append baselines.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L308)

<a id="function-function-miniquake-server-appenddatagram-function-appenddatagram-destination-source-src-miniquake-server-ml-1494106230"></a>
### appendDatagram

```ml
function appendDatagram(destination, source)
```

Add state for append datagram.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `source` | `dynamic` | — | Source value or collection to read. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1908)

<a id="function-function-miniquake-server-appendquakecsignon-function-appendquakecsignon-server-contextvalue-src-miniquake-server-ml-1290755048"></a>
### appendQuakeCSignon

```ml
function appendQuakeCSignon(server, contextValue)
```

Add state for append quake csignon.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `contextValue` | `dynamic` | — | The context value input consumed by `appendQuakeCSignon`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L344)

<a id="function-function-miniquake-server-assignmodelindexes-function-assignmodelindexes-server-src-miniquake-server-ml-500483940"></a>
### assignModelIndexes

```ml
function assignModelIndexes(server)
```

Implements the `assignModelIndexes` operation for `miniquake.server` (assign model indexes).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L248)

<a id="function-function-miniquake-server-beginchangelevel-function-beginchangelevel-server-src-miniquake-server-ml-1822295940"></a>
### beginChangeLevel

```ml
function beginChangeLevel(server)
```

Initialize state for begin change level.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L652)

<a id="function-function-miniquake-server-boolarray-function-boolarray-count-defaultvalue-src-miniquake-server-ml-2132053596"></a>
### boolArray

```ml
function boolArray(count, defaultValue)
```

----------------------------------------------------------------------------- QuakeC-backed server spawning and per-frame execution. -----------------------------------------------------------------------------

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `dynamic` | — | Number of entries or units to process. |
| `defaultValue` | `dynamic` | — | The default value input consumed by `boolArray`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2918)

<a id="function-function-miniquake-server-boundsoverlap-function-boundsoverlap-origina-minsa-maxsa-originb-minsb-maxsb-src-miniquake-server-ml-1141649646"></a>
### boundsOverlap

```ml
function boundsOverlap(originA, minsA, maxsA, originB, minsB, maxsB)
```

Implements the `boundsOverlap` operation for `miniquake.server` (bounds overlap).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `originA` | `dynamic` | — | The origin a input consumed by `boundsOverlap`. |
| `minsA` | `dynamic` | — | The mins a input consumed by `boundsOverlap`. |
| `maxsA` | `dynamic` | — | The maxs a input consumed by `boundsOverlap`. |
| `originB` | `dynamic` | — | The origin b input consumed by `boundsOverlap`. |
| `minsB` | `dynamic` | — | The mins b input consumed by `boundsOverlap`. |
| `maxsB` | `dynamic` | — | The maxs b input consumed by `boundsOverlap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2114)

<a id="function-function-miniquake-server-broadcastprint-function-broadcastprint-server-text-src-miniquake-server-ml-641264529"></a>
### broadcastPrint

```ml
function broadcastPrint(server, text)
```

Implements the `broadcastPrint` operation for `miniquake.server` (broadcast print).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2560)

<a id="function-function-miniquake-server-buildmodelprecache-function-buildmodelprecache-server-src-miniquake-server-ml-441387116"></a>
### buildModelPrecache

```ml
function buildModelPrecache(server)
```

Create and initialize model precache.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L256)

<a id="function-function-miniquake-server-buildsignon-function-buildsignon-server-src-miniquake-server-ml-614853060"></a>
### buildSignon

```ml
function buildSignon(server)
```

Create and initialize signon.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L324)

<a id="function-function-miniquake-server-cleanmapname-function-cleanmapname-name-src-miniquake-server-ml-157522764"></a>
### cleanMapName

```ml
function cleanMapName(name)
```

Return clean map name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L183)

<a id="function-function-miniquake-server-cleanupmuzzleflashes-function-cleanupmuzzleflashes-server-src-miniquake-server-ml-1496566452"></a>
### cleanupMuzzleFlashes

```ml
function cleanupMuzzleFlashes(server)
```

Implements the `cleanupMuzzleFlashes` operation for `miniquake.server` (cleanup muzzle flashes).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2715)

<a id="function-function-miniquake-server-clearinvisibleclienttargets-function-clearinvisibleclienttargets-server-clientvalue-src-miniquake-server-ml-225692672"></a>
### clearInvisibleClientTargets

```ml
function clearInvisibleClientTargets(server, clientValue)
```

Drop references from active monsters to a player who has become invisible. FL_NOTARGET prevents new checkclient acquisitions; clearing existing enemy state makes the custom command take effect immediately for alerted monsters.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `clearInvisibleClientTargets`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1023)

<a id="function-function-miniquake-server-clientfloat-function-clientfloat-server-clientvalue-fieldname-fallback-src-miniquake-server-ml-1801292397"></a>
### clientFloat

```ml
function clientFloat(server, clientValue, fieldName, fallback)
```

Implements the `clientFloat` operation for `miniquake.server` (client float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `clientFloat`. |
| `fieldName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L898)

<a id="function-function-miniquake-server-clientitems-function-clientitems-server-entityindex-player-src-miniquake-server-ml-1370083076"></a>
### clientItems

```ml
function clientItems(server, entityIndex, player)
```

Implements the `clientItems` operation for `miniquake.server` (client items).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `player` | `dynamic` | — | The player input consumed by `clientItems`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1681)

<a id="function-function-miniquake-server-clientmessagebuffers-function-clientmessagebuffers-server-src-miniquake-server-ml-783134100"></a>
### clientMessageBuffers

```ml
function clientMessageBuffers(server)
```

Implements the `clientMessageBuffers` operation for `miniquake.server` (client message buffers).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2945)

<a id="function-function-miniquake-server-clientprint-function-clientprint-clientvalue-text-src-miniquake-server-ml-940295792"></a>
### clientPrint

```ml
function clientPrint(clientValue, text)
```

Implements the `clientPrint` operation for `miniquake.server` (client print).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `clientValue` | `dynamic` | — | The client value input consumed by `clientPrint`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L862)

<a id="function-function-miniquake-server-clientspawnparmbuffers-function-clientspawnparmbuffers-server-src-miniquake-server-ml-1894926688"></a>
### clientSpawnParmBuffers

```ml
function clientSpawnParmBuffers(server)
```

Implements the `clientSpawnParmBuffers` operation for `miniquake.server` (client spawn parm buffers).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2957)

<a id="function-function-miniquake-server-clientweaponmodelindex-function-clientweaponmodelindex-server-entityindex-fallback-src-miniquake-server-ml-1814930343"></a>
### clientWeaponModelIndex

```ml
function clientWeaponModelIndex(server, entityIndex, fallback)
```

Return client weapon model index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1697)

<a id="function-function-miniquake-server-colorcomponent-function-colorcomponent-value-src-miniquake-server-ml-920074122"></a>
### colorComponent

```ml
function colorComponent(value)
```

Implements the `colorComponent` operation for `miniquake.server` (color component).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `colorComponent`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L931)

<a id="function-function-miniquake-server-commandtext-function-commandtext-args-first-src-miniquake-server-ml-1537979414"></a>
### commandText

```ml
function commandText(args, first)
```

Implements the `commandText` operation for `miniquake.server` (command text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |
| `first` | `dynamic` | — | The first input consumed by `commandText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L872)

<a id="function-function-miniquake-server-copyglobalstospawnparms-function-copyglobalstospawnparms-server-clientvalue-src-miniquake-server-ml-1884329138"></a>
### copyGlobalsToSpawnParms

```ml
function copyGlobalsToSpawnParms(server, clientValue)
```

Transfer data for copy globals to spawn parms.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `copyGlobalsToSpawnParms`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L518)

<a id="function-function-miniquake-server-copynumberarray-function-copynumberarray-values-src-miniquake-server-ml-574880413"></a>
### copyNumberArray

```ml
function copyNumberArray(values)
```

Transfer data for copy number array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `copyNumberArray`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L595)

<a id="function-function-miniquake-server-copyspawnparmstoglobals-function-copyspawnparmstoglobals-server-clientvalue-src-miniquake-server-ml-1648507282"></a>
### copySpawnParmsToGlobals

```ml
function copySpawnParmsToGlobals(server, clientValue)
```

Transfer data for copy spawn parms to globals.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `copySpawnParmsToGlobals`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L532)

<a id="function-function-miniquake-server-create-function-create-maxclients-src-miniquake-server-ml-926360495"></a>
### create

```ml
function create(maxClients)
```

Implements the `create` operation for `miniquake.server` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `maxClients` | `dynamic` | — | The max clients input consumed by `create`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L106)

<a id="function-function-miniquake-server-createedictruntime-function-createedictruntime-maxedicts-reservedclients-src-miniquake-server-ml-319035651"></a>
### createEdictRuntime

```ml
function createEdictRuntime(maxEdicts, reservedClients)
```

Create and initialize edict runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `maxEdicts` | `dynamic` | — | The max edicts input consumed by `createEdictRuntime`. |
| `reservedClients` | `dynamic` | — | The reserved clients input consumed by `createEdictRuntime`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2932)

<a id="function-function-miniquake-server-createquakeccontext-function-createquakeccontext-server-filesystem-registry-commandsystem-runtime-src-miniquake-server-ml-1233553158"></a>
### createQuakeCContext

```ml
function createQuakeCContext(server, filesystem, registry, commandSystem, runtime)
```

Create and initialize quake ccontext.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `createQuakeCContext`. |
| `registry` | `dynamic` | — | The registry input consumed by `createQuakeCContext`. |
| `commandSystem` | `dynamic` | — | The command system input consumed by `createQuakeCContext`. |
| `runtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2975)

<a id="function-function-miniquake-server-createserverclient-function-createserverclient-index-src-miniquake-server-ml-515004521"></a>
### createServerClient

```ml
function createServerClient(index)
```

Create and initialize server client.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L53)

<a id="function-function-miniquake-server-defaultlightstyles-function-defaultlightstyles-src-miniquake-server-ml-2080007237"></a>
### defaultLightStyles

```ml
function defaultLightStyles()
```

Implements the `defaultLightStyles` operation for `miniquake.server` (default light styles).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L100)

<a id="function-function-miniquake-server-distributereliabledatagram-function-distributereliabledatagram-server-src-miniquake-server-ml-1077469876"></a>
### distributeReliableDatagram

```ml
function distributeReliableDatagram(server)
```

Implements the `distributeReliableDatagram` operation for `miniquake.server` (distribute reliable datagram).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2600)

<a id="function-function-miniquake-server-dropclient-function-dropclient-server-client-crashed-src-miniquake-server-ml-1361862407"></a>
### dropClient

```ml
function dropClient(server, client, crashed)
```

Release state for drop client.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `crashed` | `dynamic` | — | The crashed input consumed by `dropClient`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1436)

<a id="function-function-miniquake-server-droptimedoutclients-function-droptimedoutclients-server-timeoutseconds-src-miniquake-server-ml-1920553320"></a>
### dropTimedOutClients

```ml
function dropTimedOutClients(server, timeoutSeconds)
```

Release state for drop timed out clients.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `timeoutSeconds` | `dynamic` | — | The timeout seconds input consumed by `dropTimedOutClients`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1469)

<a id="function-function-miniquake-server-ensuresynchronizedbaseline-function-ensuresynchronizedbaseline-item-entityindex-src-miniquake-server-ml-1847509397"></a>
### ensureSynchronizedBaseline

```ml
function ensureSynchronizedBaseline(item, entityIndex)
```

Ensure sufficient storage or state for synchronized baseline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `item` | `dynamic` | — | The item input consumed by `ensureSynchronizedBaseline`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3267)

<a id="function-function-miniquake-server-ensuresynchronizededict-function-ensuresynchronizededict-server-entityindex-src-miniquake-server-ml-1561451631"></a>
### ensureSynchronizedEdict

```ml
function ensureSynchronizedEdict(server, entityIndex)
```

Ensure sufficient storage or state for synchronized edict.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3287)

<a id="function-function-miniquake-server-entitycenter-function-entitycenter-item-src-miniquake-server-ml-399024600"></a>
### entityCenter

```ml
function entityCenter(item)
```

Implements the `entityCenter` operation for `miniquake.server` (entity center).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `item` | `dynamic` | — | The item input consumed by `entityCenter`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1551)

<a id="function-function-miniquake-server-entityfloatvalue-function-entityfloatvalue-server-item-fieldname-fallback-src-miniquake-server-ml-1391387226"></a>
### entityFloatValue

```ml
function entityFloatValue(server, item, fieldName, fallback)
```

Return entity float value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `item` | `dynamic` | — | The item input consumed by `entityFloatValue`. |
| `fieldName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1826)

<a id="function-function-miniquake-server-entityispriorityprojectile-function-entityispriorityprojectile-item-src-miniquake-server-ml-1028613336"></a>
### entityIsPriorityProjectile

```ml
function entityIsPriorityProjectile(item)
```

Report whether an entity is a latency-sensitive projectile that must be scheduled before ordinary snapshot entities. Rockets and expansion-pack missiles use MOVETYPE_FLYMISSILE; the stock grenade is a bouncing entity and therefore also needs its model-name discriminator.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `item` | `dynamic` | — | The item input consumed by `entityIsPriorityProjectile`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1952)

<a id="function-function-miniquake-server-entityupdatebits-function-entityupdatebits-server-item-src-miniquake-server-ml-1164802529"></a>
### entityUpdateBits

```ml
function entityUpdateBits(server, item)
```

Return entity update bits derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `item` | `dynamic` | — | The item input consumed by `entityUpdateBits`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1849)

<a id="function-function-miniquake-server-entityupdatevalues-function-entityupdatevalues-server-item-src-miniquake-server-ml-1016732473"></a>
### entityUpdateValues

```ml
function entityUpdateValues(server, item)
```

Return entity update values derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `item` | `dynamic` | — | The item input consumed by `entityUpdateValues`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1836)

<a id="function-function-miniquake-server-entityvisible-function-entityvisible-server-pvs-item-clientedict-src-miniquake-server-ml-1294965960"></a>
### entityVisible

```ml
function entityVisible(server, pvs, item, clientEdict)
```

Report whether entity visible holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `pvs` | `dynamic` | — | The pvs input consumed by `entityVisible`. |
| `item` | `dynamic` | — | The item input consumed by `entityVisible`. |
| `clientEdict` | `dynamic` | — | The client edict input consumed by `entityVisible`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1886)

<a id="function-function-miniquake-server-executepusherthink-function-executepusherthink-server-pusherindex-src-miniquake-server-ml-208459405"></a>
### executePusherThink

```ml
function executePusherThink(server, pusherIndex)
```

Execute pusher think.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `pusherIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2162)

<a id="function-function-miniquake-server-executeqcfunction-function-executeqcfunction-server-functionname-selfindex-otherindex-src-miniquake-server-ml-1723411703"></a>
### executeQcFunction

```ml
function executeQcFunction(server, functionName, selfIndex, otherIndex)
```

Execute qc function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `functionName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `selfIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `otherIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3847)

<a id="function-function-miniquake-server-executestringcommand-function-executestringcommand-server-client-text-player-src-miniquake-server-ml-806889559"></a>
### executeStringCommand

```ml
function executeStringCommand(server, client, text, player)
```

Execute string command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `text` | `dynamic` | — | Text to parse or process. |
| `player` | `dynamic` | — | The player input consumed by `executeStringCommand`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1379)

<a id="function-function-miniquake-server-failspawn-function-failspawn-server-result-src-miniquake-server-ml-1312673941"></a>
### failSpawn

```ml
function failSpawn(server, result)
```

Report spawn and return the corresponding failure status.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `result` | `dynamic` | — | Result value to report or translate into a status code. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L374)

<a id="function-function-miniquake-server-finishchangelevel-function-finishchangelevel-server-snapshot-src-miniquake-server-ml-530242922"></a>
### finishChangeLevel

```ml
function finishChangeLevel(server, snapshot)
```

Finalize state for finish change level.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `snapshot` | `dynamic` | — | The snapshot input consumed by `finishChangeLevel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L662)

<a id="function-function-miniquake-server-flushquakecevents-function-flushquakecevents-server-src-miniquake-server-ml-2002651350"></a>
### flushQuakeCEvents

```ml
function flushQuakeCEvents(server)
```

Implements the `flushQuakeCEvents` operation for `miniquake.server` (flush quake c events).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2542)

<a id="function-function-miniquake-server-frame-function-frame-server-player-frametime-registry-src-miniquake-server-ml-1046608976"></a>
### frame

```ml
function frame(server, player, frameTime, registry)
```

Implements the `frame` operation for `miniquake.server` (frame).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `player` | `dynamic` | — | The player input consumed by `frame`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `frame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2891)

<a id="function-function-miniquake-server-framemode-function-framemode-server-player-frametime-registry-simulate-src-miniquake-server-ml-1363001700"></a>
### frameMode

```ml
function frameMode(server, player, frameTime, registry, simulate)
```

Advance mode by one processing step.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `player` | `dynamic` | — | The player input consumed by `frameMode`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `frameMode`. |
| `simulate` | `dynamic` | — | The simulate input consumed by `frameMode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2800)

<a id="function-function-miniquake-server-globalspawnparmoffset-function-globalspawnparmoffset-machine-index-src-miniquake-server-ml-1777970094"></a>
### globalSpawnParmOffset

```ml
function globalSpawnParmOffset(machine, index)
```

Return global spawn parm offset derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `globalSpawnParmOffset`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L511)

<a id="function-function-miniquake-server-hasbspsuffix-function-hasbspsuffix-name-src-miniquake-server-ml-80851984"></a>
### hasBspSuffix

```ml
function hasBspSuffix(name)
```

Report whether bsp suffix.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L174)

<a id="function-function-miniquake-server-host-begin-f-function-host-begin-f-clientvalue-src-miniquake-server-ml-1289761821"></a>
### Host_Begin_f

```ml
function Host_Begin_f(clientValue)
```

Apply the Quake-compatible host begin f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `clientValue` | `dynamic` | — | The client value input consumed by `Host_Begin_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1262)

<a id="function-function-miniquake-server-host-color-f-function-host-color-f-server-clientvalue-args-src-miniquake-server-ml-148070261"></a>
### Host_Color_f

```ml
function Host_Color_f(server, clientValue, args)
```

Apply the Quake-compatible host color f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `Host_Color_f`. |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1203)

<a id="function-function-miniquake-server-host-fly-f-function-host-fly-f-server-clientvalue-src-miniquake-server-ml-1492909978"></a>
### Host_Fly_f

```ml
function Host_Fly_f(server, clientValue)
```

Apply the Quake-compatible host fly f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `Host_Fly_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1096)

<a id="function-function-miniquake-server-host-give-f-function-host-give-f-server-clientvalue-args-src-miniquake-server-ml-2003278599"></a>
### Host_Give_f

```ml
function Host_Give_f(server, clientValue, args)
```

Apply the Quake-compatible host give f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `Host_Give_f`. |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1311)

<a id="function-function-miniquake-server-host-god-f-function-host-god-f-server-clientvalue-src-miniquake-server-ml-593923506"></a>
### Host_God_f

```ml
function Host_God_f(server, clientValue)
```

Apply the Quake-compatible host god f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `Host_God_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L999)

<a id="function-function-miniquake-server-host-invisible-f-function-host-invisible-f-server-clientvalue-src-miniquake-server-ml-124422638"></a>
### Host_Invisible_f

```ml
function Host_Invisible_f(server, clientValue)
```

Toggle the MiniQuake AI-invisibility cheat. The stock FL_NOTARGET bit keeps standard QuakeC and compatible mods on their original target-selection path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `Host_Invisible_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1064)

<a id="function-function-miniquake-server-host-kick-f-function-host-kick-f-server-sourceclient-args-src-miniquake-server-ml-414833509"></a>
### Host_Kick_f

```ml
function Host_Kick_f(server, sourceClient, args)
```

Apply the Quake-compatible host kick f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `sourceClient` | `dynamic` | — | The source client input consumed by `Host_Kick_f`. |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1270)

<a id="function-function-miniquake-server-host-kill-f-function-host-kill-f-server-clientvalue-src-miniquake-server-ml-1345095754"></a>
### Host_Kill_f

```ml
function Host_Kill_f(server, clientValue)
```

Apply the Quake-compatible host kill f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `Host_Kill_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1217)

<a id="function-function-miniquake-server-host-name-f-function-host-name-f-server-clientvalue-args-src-miniquake-server-ml-716319987"></a>
### Host_Name_f

```ml
function Host_Name_f(server, clientValue, args)
```

Apply the Quake-compatible host name f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `Host_Name_f`. |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1131)

<a id="function-function-miniquake-server-host-noclip-f-function-host-noclip-f-server-clientvalue-src-miniquake-server-ml-2030499748"></a>
### Host_Noclip_f

```ml
function Host_Noclip_f(server, clientValue)
```

Apply the Quake-compatible host noclip f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `Host_Noclip_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1080)

<a id="function-function-miniquake-server-host-notarget-f-function-host-notarget-f-server-clientvalue-src-miniquake-server-ml-1248237814"></a>
### Host_Notarget_f

```ml
function Host_Notarget_f(server, clientValue)
```

Apply the Quake-compatible host notarget f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `Host_Notarget_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1010)

<a id="function-function-miniquake-server-host-pause-f-function-host-pause-f-server-clientvalue-src-miniquake-server-ml-1360488610"></a>
### Host_Pause_f

```ml
function Host_Pause_f(server, clientValue)
```

Apply the Quake-compatible host pause f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `Host_Pause_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1229)

<a id="function-function-miniquake-server-host-ping-f-function-host-ping-f-server-requester-src-miniquake-server-ml-1618135928"></a>
### Host_Ping_f

```ml
function Host_Ping_f(server, requester)
```

Apply the Quake-compatible host ping f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `requester` | `dynamic` | — | The requester input consumed by `Host_Ping_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1112)

<a id="function-function-miniquake-server-host-prespawn-f-function-host-prespawn-f-server-clientvalue-src-miniquake-server-ml-377004930"></a>
### Host_PreSpawn_f

```ml
function Host_PreSpawn_f(server, clientValue)
```

Apply the Quake-compatible host pre spawn f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `Host_PreSpawn_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1246)

<a id="function-function-miniquake-server-host-say-function-host-say-server-sender-args-teamonly-src-miniquake-server-ml-1565877133"></a>
### Host_Say

```ml
function Host_Say(server, sender, args, teamOnly)
```

Apply the Quake-compatible host say behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `sender` | `dynamic` | — | The sender input consumed by `Host_Say`. |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |
| `teamOnly` | `dynamic` | — | The team only input consumed by `Host_Say`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1141)

<a id="function-function-miniquake-server-host-say-f-function-host-say-f-server-sender-args-src-miniquake-server-ml-1603297592"></a>
### Host_Say_f

```ml
function Host_Say_f(server, sender, args)
```

Apply the Quake-compatible host say f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `sender` | `dynamic` | — | The sender input consumed by `Host_Say_f`. |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1166)

<a id="function-function-miniquake-server-host-say-team-f-function-host-say-team-f-server-sender-args-src-miniquake-server-ml-926217826"></a>
### Host_Say_Team_f

```ml
function Host_Say_Team_f(server, sender, args)
```

Apply the Quake-compatible host say team f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `sender` | `dynamic` | — | The sender input consumed by `Host_Say_Team_f`. |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1174)

<a id="function-function-miniquake-server-host-spawn-f-function-host-spawn-f-server-clientvalue-player-src-miniquake-server-ml-1232478509"></a>
### Host_Spawn_f

```ml
function Host_Spawn_f(server, clientValue, player)
```

Apply the Quake-compatible host spawn f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `Host_Spawn_f`. |
| `player` | `dynamic` | — | The player input consumed by `Host_Spawn_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1255)

<a id="function-function-miniquake-server-host-status-f-function-host-status-f-server-requester-src-miniquake-server-ml-1020291180"></a>
### Host_Status_f

```ml
function Host_Status_f(server, requester)
```

Apply the Quake-compatible host status f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `requester` | `dynamic` | — | The requester input consumed by `Host_Status_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L962)

<a id="function-function-miniquake-server-host-tell-f-function-host-tell-f-server-sender-args-src-miniquake-server-ml-1476888982"></a>
### Host_Tell_f

```ml
function Host_Tell_f(server, sender, args)
```

Apply the Quake-compatible host tell f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `sender` | `dynamic` | — | The sender input consumed by `Host_Tell_f`. |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1182)

<a id="function-function-miniquake-server-loadedicts-function-loadedicts-server-map-src-miniquake-server-ml-205529800"></a>
### loadEdicts

```ml
function loadEdicts(server, map)
```

Read and validate edicts.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `map` | `dynamic` | — | The map input consumed by `loadEdicts`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L208)

<a id="function-function-miniquake-server-makeplayeredict-function-makeplayeredict-number-src-miniquake-server-ml-1136071026"></a>
### makePlayerEdict

```ml
function makePlayerEdict(number)
```

Create and initialize player edict.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `number` | `dynamic` | — | The number input consumed by `makePlayerEdict`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L192)

<a id="function-function-miniquake-server-modelindex-function-modelindex-server-name-src-miniquake-server-ml-409253485"></a>
### modelIndex

```ml
function modelIndex(server, name)
```

Return model index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L237)

<a id="function-function-miniquake-server-movepusher-function-movepusher-server-pusherindex-movetime-src-miniquake-server-ml-1930520933"></a>
### movePusher

```ml
function movePusher(server, pusherIndex, moveTime)
```

SV_PushMove. The pusher is moved first, every affected entity is carried by the same delta, and the complete operation is rolled back when one entity cannot be displaced. This is the stock Quake door/platform/train contract.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `pusherIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `moveTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2179)

<a id="function-function-miniquake-server-moveqcentity-function-moveqcentity-server-entityindex-frametime-gravity-src-miniquake-server-ml-657454231"></a>
### moveQcEntity

```ml
function moveQcEntity(server, entityIndex, frameTime, gravity)
```

Transfer data for move qc entity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `gravity` | `dynamic` | — | The gravity input consumed by `moveQcEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2359)

<a id="function-function-miniquake-server-numberarray-function-numberarray-count-defaultvalue-src-miniquake-server-ml-438794374"></a>
### numberArray

```ml
function numberArray(count, defaultValue)
```

Implements the `numberArray` operation for `miniquake.server` (number array).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `dynamic` | — | Number of entries or units to process. |
| `defaultValue` | `dynamic` | — | The default value input consumed by `numberArray`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2925)

<a id="function-function-miniquake-server-physicsframeparameters-function-physicsframeparameters-registry-src-miniquake-server-ml-684152920"></a>
### physicsFrameParameters

```ml
function physicsFrameParameters(registry)
```

Apply server-physics frame parameters semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `physicsFrameParameters`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2420)

<a id="function-function-miniquake-server-physicspusher-function-physicspusher-server-entityindex-frametime-src-miniquake-server-ml-19523965"></a>
### physicsPusher

```ml
function physicsPusher(server, entityIndex, frameTime)
```

Apply server-physics pusher semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2285)

<a id="function-function-miniquake-server-placeclient-function-placeclient-server-client-player-src-miniquake-server-ml-1445973374"></a>
### placeClient

```ml
function placeClient(server, client, player)
```

Place one client at the new level's selected spawn point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `player` | `dynamic` | — | The player input consumed by `placeClient`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L755)

<a id="function-function-miniquake-server-playerprotocolflags-function-playerprotocolflags-player-src-miniquake-server-ml-980837906"></a>
### playerProtocolFlags

```ml
function playerProtocolFlags(player)
```

PlayerState keeps groundedness in `onGround`, while the original network writer consumes FL_ONGROUND from ent->v.flags. Rebuild this mirrored bit for PlayerState-only adapter paths so stale flags cannot drop or invent SU_ONGROUND. QuakeC-backed paths still replace the value with QC flags.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `playerProtocolFlags`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1711)

<a id="function-function-miniquake-server-playerstateforclient-function-playerstateforclient-server-clientvalue-hostplayer-src-miniquake-server-ml-487055863"></a>
### playerStateForClient

```ml
function playerStateForClient(server, clientValue, hostPlayer)
```

The listen-server loopback client shares the host's render/input PlayerState. Every remote client needs an independent mirror of its own QuakeC edict. Socketless single-client fixtures predate ServerClient.playerState and keep using the supplied host state so their public frameMode contract is stable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `playerStateForClient`. |
| `hostPlayer` | `dynamic` | — | The host player input consumed by `playerStateForClient`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L84)

<a id="function-function-miniquake-server-precacheclientframelookups-function-precacheclientframelookups-server-fallbackplayer-src-miniquake-server-ml-1439256209"></a>
### precacheClientFrameLookups

```ml
function precacheClientFrameLookups(server, fallbackPlayer)
```

Warm the pure field/function lookup paths used by the first client physics frame. No QuakeC code is executed and no game time advances; authoritative player values are written and read back unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `fallbackPlayer` | `dynamic` | — | The fallback player input consumed by `precacheClientFrameLookups`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3744)

<a id="function-function-miniquake-server-preparereliablemessages-function-preparereliablemessages-server-src-miniquake-server-ml-122194794"></a>
### prepareReliableMessages

```ml
function prepareReliableMessages(server)
```

Implements the `prepareReliableMessages` operation for `miniquake.server` (prepare reliable messages).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2619)

<a id="function-function-miniquake-server-preserveclientconnections-function-preserveclientconnections-server-src-miniquake-server-ml-307082124"></a>
### preserveClientConnections

```ml
function preserveClientConnections(server)
```

Implements the `preserveClientConnections` operation for `miniquake.server` (preserve client connections).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L620)

<a id="function-function-miniquake-server-privilegedcommandallowed-inline-function-privilegedcommandallowed-server-clientvalue-src-miniquake-server-ml-532355373"></a>
### privilegedCommandAllowed

```ml
inline function privilegedCommandAllowed(server, clientValue)
```

Implements the `privilegedCommandAllowed` operation for `miniquake.server` (privileged command allowed).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `privilegedCommandAllowed`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L955)

<a id="function-function-miniquake-server-processreliableclientat-function-processreliableclientat-server-clientvalue-realtime-src-miniquake-server-ml-813120327"></a>
### processReliableClientAt

```ml
function processReliableClientAt(server, clientValue, realtime)
```

Execute reliable client at.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `processReliableClientAt`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2642)

<a id="function-function-miniquake-server-protocolbaseline-function-protocolbaseline-server-item-src-miniquake-server-ml-30272317"></a>
### protocolBaseline

```ml
function protocolBaseline(server, item)
```

Implements the `protocolBaseline` operation for `miniquake.server` (protocol baseline).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `item` | `dynamic` | — | The item input consumed by `protocolBaseline`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L273)

<a id="function-function-miniquake-server-protocolclientdata-function-protocolclientdata-server-client-player-src-miniquake-server-ml-878902010"></a>
### protocolClientData

```ml
function protocolClientData(server, client, player)
```

Return protocol client data derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `player` | `dynamic` | — | The player input consumed by `protocolClientData`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1721)

<a id="function-function-miniquake-server-pumpclientmessages-function-pumpclientmessages-server-player-src-miniquake-server-ml-2001928871"></a>
### pumpClientMessages

```ml
function pumpClientMessages(server, player)
```

Advance client messages by one processing step.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `player` | `dynamic` | — | The player input consumed by `pumpClientMessages`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1523)

<a id="function-function-miniquake-server-qcentityvector-function-qcentityvector-server-entityindex-name-src-miniquake-server-ml-304695648"></a>
### qcEntityVector

```ml
function qcEntityVector(server, entityIndex, name)
```

Return qc entity vector derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2079)

<a id="function-function-miniquake-server-qcfloat-function-qcfloat-machine-entityindex-fieldname-fallback-src-miniquake-server-ml-1136783508"></a>
### qcFloat

```ml
function qcFloat(machine, entityIndex, fieldName, fallback)
```

Implements the `qcFloat` operation for `miniquake.server` (qc float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `qcFloat`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3012)

<a id="function-function-miniquake-server-qcfloatat-function-qcfloatat-machine-entityindex-offset-fallback-src-miniquake-server-ml-818279310"></a>
### qcFloatAt

```ml
function qcFloatAt(machine, entityIndex, offset, fallback)
```

Implements the `qcFloatAt` operation for `miniquake.server` (qc float at).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `qcFloatAt`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3058)

<a id="function-function-miniquake-server-qcsetflags-function-qcsetflags-server-entityindex-flags-src-miniquake-server-ml-1215169936"></a>
### qcSetFlags

```ml
function qcSetFlags(server, entityIndex, flags)
```

Implements the `qcSetFlags` operation for `miniquake.server` (qc set flags).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `flags` | `dynamic` | — | The flags input consumed by `qcSetFlags`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2087)

<a id="function-function-miniquake-server-qcstring-function-qcstring-machine-entityindex-fieldname-fallback-src-miniquake-server-ml-1477658112"></a>
### qcString

```ml
function qcString(machine, entityIndex, fieldName, fallback)
```

Implements the `qcString` operation for `miniquake.server` (qc string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `qcString`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3045)

<a id="function-function-miniquake-server-qcstringat-function-qcstringat-machine-entityindex-offset-fallback-src-miniquake-server-ml-376603476"></a>
### qcStringAt

```ml
function qcStringAt(machine, entityIndex, offset, fallback)
```

Implements the `qcStringAt` operation for `miniquake.server` (qc string at).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `qcStringAt`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3078)

<a id="function-function-miniquake-server-qcvector-function-qcvector-machine-entityindex-fieldname-fallback-src-miniquake-server-ml-306595828"></a>
### qcVector

```ml
function qcVector(machine, entityIndex, fieldName, fallback)
```

Return qc vector derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `qcVector`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3034)

<a id="function-function-miniquake-server-qcword-function-qcword-machine-entityindex-fieldname-fallback-src-miniquake-server-ml-672321248"></a>
### qcWord

```ml
function qcWord(machine, entityIndex, fieldName, fallback)
```

Implements the `qcWord` operation for `miniquake.server` (qc word).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `qcWord`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3023)

<a id="function-function-miniquake-server-qcwordat-function-qcwordat-machine-entityindex-offset-fallback-src-miniquake-server-ml-1579134704"></a>
### qcWordAt

```ml
function qcWordAt(machine, entityIndex, offset, fallback)
```

Implements the `qcWordAt` operation for `miniquake.server` (qc word at).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `qcWordAt`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3068)

<a id="function-function-miniquake-server-queuedsoundorigin-function-queuedsoundorigin-server-entityindex-src-miniquake-server-ml-1564074173"></a>
### queuedSoundOrigin

```ml
function queuedSoundOrigin(server, entityIndex)
```

Add state for queued sound origin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2501)

<a id="function-function-miniquake-server-readclientmessage-function-readclientmessage-server-client-data-player-src-miniquake-server-ml-864463326"></a>
### readClientMessage

```ml
function readClientMessage(server, client, data, player)
```

Read and validate client message.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `player` | `dynamic` | — | The player input consumed by `readClientMessage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1485)

<a id="function-function-miniquake-server-readmove-function-readmove-server-reader-client-src-miniquake-server-ml-1581304292"></a>
### readMove

```ml
function readMove(server, reader, client)
```

Read and validate move.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `reader` | `dynamic` | — | The reader input consumed by `readMove`. |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1410)

<a id="function-function-miniquake-server-recomputeedictcount-function-recomputeedictcount-server-src-miniquake-server-ml-1821910880"></a>
### recomputeEdictCount

```ml
function recomputeEdictCount(server)
```

Return recompute edict count derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3467)

<a id="function-function-miniquake-server-requiresynchronizedvector-function-requiresynchronizedvector-value-entityindex-fieldname-src-miniquake-server-ml-357826894"></a>
### requireSynchronizedVector

```ml
function requireSynchronizedVector(value, entityIndex, fieldName)
```

Validate synchronized vector and report any invalid state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `requireSynchronizedVector`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3128)

<a id="function-function-miniquake-server-resetclientmessageforconnect-function-resetclientmessageforconnect-clientvalue-src-miniquake-server-ml-1309820501"></a>
### resetClientMessageForConnect

```ml
function resetClientMessageForConnect(clientValue)
```

Update module state for client message for connect.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `clientValue` | `dynamic` | — | The client value input consumed by `resetClientMessageForConnect`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L545)

<a id="function-function-miniquake-server-resetplayerforspawn-function-resetplayerforspawn-player-origin-angles-src-miniquake-server-ml-1725451988"></a>
### resetPlayerForSpawn

```ml
function resetPlayerForSpawn(player, origin, angles)
```

Reset the detached PlayerState mirror like SV_SpawnServer's cleared client edict before ClientConnect and PutClientInServer initialize the new level.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `resetPlayerForSpawn`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L714)

<a id="function-function-miniquake-server-resizeclients-function-resizeclients-server-requested-src-miniquake-server-ml-2126317154"></a>
### resizeClients

```ml
function resizeClients(server, requested)
```

Implements the `resizeClients` operation for `miniquake.server` (resize clients).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `requested` | `dynamic` | — | The requested input consumed by `resizeClients`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L155)

<a id="function-function-miniquake-server-resizesynchronizededictarray-function-resizesynchronizededictarray-server-requiredcount-src-miniquake-server-ml-2027985170"></a>
### resizeSynchronizedEdictArray

```ml
function resizeSynchronizedEdictArray(server, requiredCount)
```

Implements the `resizeSynchronizedEdictArray` operation for `miniquake.server` (resize synchronized edict array).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `requiredCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3247)

<a id="function-function-miniquake-server-resolveplayerentitycollision-function-resolveplayerentitycollision-server-clientvalue-player-oldorigin-src-miniquake-server-ml-1300126484"></a>
### resolvePlayerEntityCollision

```ml
function resolvePlayerEntityCollision(server, clientValue, player, oldOrigin)
```

Implements the `resolvePlayerEntityCollision` operation for `miniquake.server` (resolve player entity collision).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `resolvePlayerEntityCollision`. |
| `player` | `dynamic` | — | The player input consumed by `resolvePlayerEntityCollision`. |
| `oldOrigin` | `dynamic` | — | The old origin input consumed by `resolvePlayerEntityCollision`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2329)

<a id="function-function-miniquake-server-runentitythink-function-runentitythink-server-entityindex-frametime-src-miniquake-server-ml-866718909"></a>
### runEntityThink

```ml
function runEntityThink(server, entityIndex, frameTime)
```

Execute entity think.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2144)

<a id="function-function-miniquake-server-runnonclientphysics-function-runnonclientphysics-server-frametime-registry-src-miniquake-server-ml-1274003539"></a>
### runNonClientPhysics

```ml
function runNonClientPhysics(server, frameTime, registry)
```

Execute non client physics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `runNonClientPhysics`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2490)

<a id="function-function-miniquake-server-runnonclientphysicswithretouch-function-runnonclientphysicswithretouch-server-frametime-registry-forceretouch-src-miniquake-server-ml-1599526356"></a>
### runNonClientPhysicsWithRetouch

```ml
function runNonClientPhysicsWithRetouch(server, frameTime, registry, forceRetouch)
```

Execute non client physics with retouch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `runNonClientPhysicsWithRetouch`. |
| `forceRetouch` | `dynamic` | — | The force retouch input consumed by `runNonClientPhysicsWithRetouch`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2448)

<a id="function-function-miniquake-server-runqcblocked-function-runqcblocked-server-pusherindex-otherindex-src-miniquake-server-ml-320647643"></a>
### runQcBlocked

```ml
function runQcBlocked(server, pusherIndex, otherIndex)
```

Execute qc blocked.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `pusherIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `otherIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2128)

<a id="function-function-miniquake-server-runqctouch-function-runqctouch-server-entityindex-otherindex-src-miniquake-server-ml-1011527567"></a>
### runQcTouch

```ml
function runQcTouch(server, entityIndex, otherIndex)
```

Execute qc touch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `otherIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2095)

<a id="function-function-miniquake-server-runquakecframe-function-runquakecframe-server-frametime-src-miniquake-server-ml-535221058"></a>
### runQuakeCFrame

```ml
function runQuakeCFrame(server, frameTime)
```

Execute quake cframe.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3861)

<a id="function-function-miniquake-server-runworldphysicswithretouch-function-runworldphysicswithretouch-server-frametime-registry-forceretouch-src-miniquake-server-ml-1305120956"></a>
### runWorldPhysicsWithRetouch

```ml
function runWorldPhysicsWithRetouch(server, frameTime, registry, forceRetouch)
```

Execute world physics with retouch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `runWorldPhysicsWithRetouch`. |
| `forceRetouch` | `dynamic` | — | The force retouch input consumed by `runWorldPhysicsWithRetouch`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2433)

<a id="function-function-miniquake-server-savespawnparmsforchange-function-savespawnparmsforchange-server-src-miniquake-server-ml-133361028"></a>
### saveSpawnParmsForChange

```ml
function saveSpawnParmsForChange(server)
```

Encode and write spawn parms for change.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L605)

<a id="function-function-miniquake-server-sendbuffer-function-sendbuffer-client-buffer-src-miniquake-server-ml-1612669566"></a>
### sendBuffer

```ml
function sendBuffer(client, buffer)
```

Send buffer through the active connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `buffer` | `dynamic` | — | The buffer input consumed by `sendBuffer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L472)

<a id="global-global-miniquake-server-sendclienteye-sendclienteye-src-miniquake-server-ml-1551488635"></a>
### sendClientEye

```ml
sendClientEye
```

SV_WriteEntitiesToClient uses one stack vec3 for the client eye position in the C engine. Keep the MiniLang equivalent as a stable scratch value rather than allocating two temporary Vec3 objects for every client snapshot.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L44)

<a id="function-function-miniquake-server-sendclientframe-function-sendclientframe-server-client-player-src-miniquake-server-ml-1325233954"></a>
### sendClientFrame

```ml
function sendClientFrame(server, client, player)
```

Send client frame through the active connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `player` | `dynamic` | — | The player input consumed by `sendClientFrame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2034)

<a id="function-function-miniquake-server-sendclientmessages-function-sendclientmessages-server-player-src-miniquake-server-ml-826488967"></a>
### sendClientMessages

```ml
function sendClientMessages(server, player)
```

Send client messages through the active connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `player` | `dynamic` | — | The player input consumed by `sendClientMessages`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2790)

<a id="function-function-miniquake-server-sendclientmessagesat-function-sendclientmessagesat-server-player-realtime-src-miniquake-server-ml-18974376"></a>
### sendClientMessagesAt

```ml
function sendClientMessagesAt(server, player, realtime)
```

Send client messages at through the active connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `player` | `dynamic` | — | The player input consumed by `sendClientMessagesAt`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2739)

<a id="function-function-miniquake-server-sendnopat-function-sendnopat-server-clientvalue-realtime-src-miniquake-server-ml-249143389"></a>
### sendNopAt

```ml
function sendNopAt(server, clientValue, realtime)
```

Send nop at through the active connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `sendNopAt`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2629)

<a id="function-function-miniquake-server-sendreconnect-function-sendreconnect-server-src-miniquake-server-ml-1954800354"></a>
### sendReconnect

```ml
function sendReconnect(server)
```

Send reconnect through the active connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L644)

<a id="function-function-miniquake-server-sendreliablemessages-function-sendreliablemessages-server-src-miniquake-server-ml-1564698320"></a>
### sendReliableMessages

```ml
function sendReliableMessages(server)
```

Send reliable messages through the active connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2709)

<a id="function-function-miniquake-server-sendreliablemessagesat-function-sendreliablemessagesat-server-realtime-src-miniquake-server-ml-593341759"></a>
### sendReliableMessagesAt

```ml
function sendReliableMessagesAt(server, realtime)
```

Reliable-only pump used by the explicit local signon loop. The full server frame calls sendClientMessagesAt so spawned clients receive their unreliable datagram before this reliable phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2682)

<a id="function-function-miniquake-server-sendserverinfo-function-sendserverinfo-server-client-src-miniquake-server-ml-2071163653"></a>
### sendServerInfo

```ml
function sendServerInfo(server, client)
```

Send server info through the active connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L496)

<a id="function-function-miniquake-server-servergametype-function-servergametype-server-src-miniquake-server-ml-114309072"></a>
### serverGameType

```ml
function serverGameType(server)
```

Return server game type derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L488)

<a id="function-function-miniquake-server-serverprogscrc-function-serverprogscrc-server-src-miniquake-server-ml-580131364"></a>
### serverProgsCrc

```ml
function serverProgsCrc(server)
```

Return server progs crc derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L480)

<a id="function-function-miniquake-server-setclientcolors-function-setclientcolors-server-clientvalue-topvalue-bottomvalue-src-miniquake-server-ml-898306806"></a>
### setClientColors

```ml
function setClientColors(server, clientValue, topValue, bottomValue)
```

Update module state for client colors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `setClientColors`. |
| `topValue` | `dynamic` | — | The top value input consumed by `setClientColors`. |
| `bottomValue` | `dynamic` | — | The bottom value input consumed by `setClientColors`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L942)

<a id="function-function-miniquake-server-setclientfloat-function-setclientfloat-server-clientvalue-fieldname-value-src-miniquake-server-ml-760792306"></a>
### setClientFloat

```ml
function setClientFloat(server, clientValue, fieldName, value)
```

Update module state for client float.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `setClientFloat`. |
| `fieldName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `value` | `dynamic` | — | Value consumed by `setClientFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L908)

<a id="function-function-miniquake-server-setclientidealpitch-function-setclientidealpitch-server-client-player-pitchscale-src-miniquake-server-ml-700587726"></a>
### setClientIdealPitch

```ml
function setClientIdealPitch(server, client, player, pitchScale)
```

SV_SetIdealPitch. This mirrors sv_user.c's six point traces and deliberately truncates each sampled height delta to the original C int `step`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `player` | `dynamic` | — | The player input consumed by `setClientIdealPitch`. |
| `pitchScale` | `dynamic` | — | The pitch scale input consumed by `setClientIdealPitch`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1591)

<a id="function-function-miniquake-server-setclientname-function-setclientname-server-clientvalue-newname-src-miniquake-server-ml-353182443"></a>
### setClientName

```ml
function setClientName(server, clientValue, newName)
```

Update module state for client name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `setClientName`. |
| `newName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L917)

<a id="function-function-miniquake-server-setgivefield-function-setgivefield-server-clientvalue-name-value-src-miniquake-server-ml-754669580"></a>
### setGiveField

```ml
function setGiveField(server, clientValue, name, value)
```

Update module state for give field.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `setGiveField`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `setGiveField`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1302)

<a id="function-function-miniquake-server-setqcentityfloat-function-setqcentityfloat-server-entityindex-fieldname-value-src-miniquake-server-ml-1266006801"></a>
### setQcEntityFloat

```ml
function setQcEntityFloat(server, entityIndex, fieldName, value)
```

Update module state for qc entity float.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `value` | `dynamic` | — | Value consumed by `setQcEntityFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3670)

<a id="function-function-miniquake-server-setqcentityvector-function-setqcentityvector-server-entityindex-fieldname-value-src-miniquake-server-ml-1951376397"></a>
### setQcEntityVector

```ml
function setQcEntityVector(server, entityIndex, fieldName, value)
```

Update module state for qc entity vector.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `value` | `dynamic` | — | Value consumed by `setQcEntityVector`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3660)

<a id="function-function-miniquake-server-setqcentityword-function-setqcentityword-server-entityindex-fieldname-value-src-miniquake-server-ml-279242899"></a>
### setQcEntityWord

```ml
function setQcEntityWord(server, entityIndex, fieldName, value)
```

Update module state for qc entity word.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `value` | `dynamic` | — | Value consumed by `setQcEntityWord`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3680)

<a id="function-function-miniquake-server-setsynchronizedvector-function-setsynchronizedvector-value-entityindex-fieldname-x-y-z-src-miniquake-server-ml-1714970083"></a>
### setSynchronizedVector

```ml
function setSynchronizedVector(value, entityIndex, fieldName, x, y, z)
```

Update module state for synchronized vector.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `setSynchronizedVector`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `x` | `dynamic` | — | The x input consumed by `setSynchronizedVector`. |
| `y` | `dynamic` | — | The y input consumed by `setSynchronizedVector`. |
| `z` | `dynamic` | — | The z input consumed by `setSynchronizedVector`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3163)

<a id="function-function-miniquake-server-shutdown-function-shutdown-server-src-miniquake-server-ml-394101172"></a>
### shutdown

```ml
function shutdown(server)
```

Implements the `shutdown` operation for `miniquake.server` (shutdown).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2897)

<a id="function-function-miniquake-server-soundindex-function-soundindex-server-name-src-miniquake-server-ml-1339514945"></a>
### soundIndex

```ml
function soundIndex(server, name)
```

Return sound index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L332)

<a id="function-function-miniquake-server-spawn-function-spawn-server-filesystem-mapname-skill-src-miniquake-server-ml-1767969913"></a>
### spawn

```ml
function spawn(server, filesystem, mapName, skill)
```

Implements the `spawn` operation for `miniquake.server` (spawn).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `spawn`. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `skill` | `dynamic` | — | The skill input consumed by `spawn`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L394)

<a id="function-function-miniquake-server-spawnruntime-function-spawnruntime-server-filesystem-mapname-skill-registry-commandsystem-src-miniquake-server-ml-1446217628"></a>
### spawnRuntime

```ml
function spawnRuntime(server, filesystem, mapName, skill, registry, commandSystem)
```

Allocate and initialize runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `spawnRuntime`. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `skill` | `dynamic` | — | The skill input consumed by `spawnRuntime`. |
| `registry` | `dynamic` | — | The registry input consumed by `spawnRuntime`. |
| `commandSystem` | `dynamic` | — | The command system input consumed by `spawnRuntime`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3584)

<a id="function-function-miniquake-server-synccommandtoquakec-function-synccommandtoquakec-server-clientvalue-src-miniquake-server-ml-1982916796"></a>
### syncCommandToQuakeC

```ml
function syncCommandToQuakeC(server, clientValue)
```

Update module state for command to quake c.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `syncCommandToQuakeC`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3722)

<a id="function-function-miniquake-server-syncestablishedqcvectorintoat-function-syncestablishedqcvectorintoat-machine-entityindex-offset-target-x-y-z-src-miniquake-server-ml-23498230"></a>
### syncEstablishedQcVectorIntoAt

```ml
function syncEstablishedQcVectorIntoAt(machine, entityIndex, offset, target, x, y, z)
```

Copy one snapshot vector into an established mirror slot. Spawn and load synchronization have already validated every nested Vec3 before the server can publish snapshots, so repeating a dynamic type-name lookup here for four vectors on every live edict only burns frame time. Keep the guarded helper above for lifecycle boundaries where incomplete external state is possible.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `syncEstablishedQcVectorIntoAt`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `target` | `dynamic` | — | The target input consumed by `syncEstablishedQcVectorIntoAt`. |
| `x` | `dynamic` | — | The x input consumed by `syncEstablishedQcVectorIntoAt`. |
| `y` | `dynamic` | — | The y input consumed by `syncEstablishedQcVectorIntoAt`. |
| `z` | `dynamic` | — | The z input consumed by `syncEstablishedQcVectorIntoAt`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3231)

<a id="function-function-miniquake-server-synchronizededictoffsets-function-synchronizededictoffsets-machine-src-miniquake-server-ml-738767878"></a>
### synchronizedEdictOffsets

```ml
function synchronizedEdictOffsets(machine)
```

The C engine resolves ddef_t offsets while loading progs.dat and then uses direct word offsets for every edict.  Resolve the MiniLang mirror's fixed synchronization set once per range instead of scanning fieldDefs 18 times for every live edict on every server frame.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `synchronizedEdictOffsets`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3090)

<a id="global-global-miniquake-server-synchronizedoffsetmachine-synchronizedoffsetmachine-src-miniquake-server-ml-32584651"></a>
### synchronizedOffsetMachine

```ml
synchronizedOffsetMachine
```

Tracks the module-level synchronized offset machine state owned by `miniquake.server`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3120)

<a id="global-global-miniquake-server-synchronizedoffsets-synchronizedoffsets-src-miniquake-server-ml-56815203"></a>
### synchronizedOffsets

```ml
synchronizedOffsets
```

Tracks the module-level synchronized offsets state owned by `miniquake.server`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3122)

<a id="function-function-miniquake-server-synchronizedvectortarget-function-synchronizedvectortarget-value-entityindex-fieldname-x-y-z-src-miniquake-server-ml-163443893"></a>
### synchronizedVectorTarget

```ml
function synchronizedVectorTarget(value, entityIndex, fieldName, x, y, z)
```

The original server keeps edicts in one stable array and mutates their fields in place.  Rebuilding every QuakeEdict and every nested Vec3 on each frame creates avoidable allocation pressure and makes object lifetime depend on expression-temporary GC roots.  Keep the derived MiniLang mirror stable: allocate only when the high-water mark grows or a previously absent record appears, then copy raw QuakeC words into the existing structs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `synchronizedVectorTarget`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `x` | `dynamic` | — | The x input consumed by `synchronizedVectorTarget`. |
| `y` | `dynamic` | — | The y input consumed by `synchronizedVectorTarget`. |
| `z` | `dynamic` | — | The z input consumed by `synchronizedVectorTarget`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3149)

<a id="function-function-miniquake-server-syncloadedquakecedicts-function-syncloadedquakecedicts-server-savedcount-src-miniquake-server-ml-1114271822"></a>
### syncLoadedQuakeCEdicts

```ml
function syncLoadedQuakeCEdicts(server, savedCount)
```

Update module state for loaded quake cedicts.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `savedCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3567)

<a id="function-function-miniquake-server-syncplayerfromquakec-function-syncplayerfromquakec-server-clientvalue-player-src-miniquake-server-ml-1240817425"></a>
### syncPlayerFromQuakeC

```ml
function syncPlayerFromQuakeC(server, clientValue, player)
```

Update module state for player from quake c.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `syncPlayerFromQuakeC`. |
| `player` | `dynamic` | — | The player input consumed by `syncPlayerFromQuakeC`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3765)

<a id="function-function-miniquake-server-syncplayertoquakec-function-syncplayertoquakec-server-clientvalue-player-src-miniquake-server-ml-452641681"></a>
### syncPlayerToQuakeC

```ml
function syncPlayerToQuakeC(server, clientValue, player)
```

Update module state for player to quake c.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `syncPlayerToQuakeC`. |
| `player` | `dynamic` | — | The player input consumed by `syncPlayerToQuakeC`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3689)

<a id="function-function-miniquake-server-syncqcvectorinto-function-syncqcvectorinto-machine-entityindex-fieldname-target-x-y-z-src-miniquake-server-ml-65959000"></a>
### syncQcVectorInto

```ml
function syncQcVectorInto(machine, entityIndex, fieldName, target, x, y, z)
```

Update module state for qc vector into.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `syncQcVectorInto`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `target` | `dynamic` | — | The target input consumed by `syncQcVectorInto`. |
| `x` | `dynamic` | — | The x input consumed by `syncQcVectorInto`. |
| `y` | `dynamic` | — | The y input consumed by `syncQcVectorInto`. |
| `z` | `dynamic` | — | The z input consumed by `syncQcVectorInto`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3179)

<a id="function-function-miniquake-server-syncqcvectorintoat-function-syncqcvectorintoat-machine-entityindex-offset-fieldname-target-x-y-z-src-miniquake-server-ml-508748745"></a>
### syncQcVectorIntoAt

```ml
function syncQcVectorIntoAt(machine, entityIndex, offset, fieldName, target, x, y, z)
```

Update module state for qc vector into at.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `syncQcVectorIntoAt`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `fieldName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `target` | `dynamic` | — | The target input consumed by `syncQcVectorIntoAt`. |
| `x` | `dynamic` | — | The x input consumed by `syncQcVectorIntoAt`. |
| `y` | `dynamic` | — | The y input consumed by `syncQcVectorIntoAt`. |
| `z` | `dynamic` | — | The z input consumed by `syncQcVectorIntoAt`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3204)

<a id="function-function-miniquake-server-syncquakecedict-function-syncquakecedict-server-entityindex-src-miniquake-server-ml-2107221469"></a>
### syncQuakeCEdict

```ml
function syncQuakeCEdict(server, entityIndex)
```

Update module state for quake cedict.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3461)

<a id="function-function-miniquake-server-syncquakecedictat-function-syncquakecedictat-server-entityindex-offsets-src-miniquake-server-ml-1483245179"></a>
### syncQuakeCEdictAt

```ml
function syncQuakeCEdictAt(server, entityIndex, offsets)
```

Update module state for quake cedict at.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `offsets` | `dynamic` | — | The offsets input consumed by `syncQuakeCEdictAt`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3315)

<a id="function-function-miniquake-server-syncquakecedictrange-function-syncquakecedictrange-server-count-src-miniquake-server-ml-31672483"></a>
### syncQuakeCEdictRange

```ml
function syncQuakeCEdictRange(server, count)
```

Update module state for quake cedict range.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3484)

<a id="function-function-miniquake-server-syncquakecedicts-function-syncquakecedicts-server-src-miniquake-server-ml-1416139772"></a>
### syncQuakeCEdicts

```ml
function syncQuakeCEdicts(server)
```

Update module state for quake cedicts.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3532)

<a id="function-function-miniquake-server-syncquakecsnapshotedictat-function-syncquakecsnapshotedictat-server-entityindex-offsets-src-miniquake-server-ml-778311015"></a>
### syncQuakeCSnapshotEdictAt

```ml
function syncQuakeCSnapshotEdictAt(server, entityIndex, offsets)
```

Synchronize only fields consumed by client snapshot encoding. Physics and collision already operate on the authoritative VM edicts; the full mirror remains available for lifecycle/save/compatibility boundaries.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `offsets` | `dynamic` | — | The offsets input consumed by `syncQuakeCSnapshotEdictAt`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3392)

<a id="function-function-miniquake-server-syncquakecsnapshotedicts-function-syncquakecsnapshotedicts-server-src-miniquake-server-ml-1333463600"></a>
### syncQuakeCSnapshotEdicts

```ml
function syncQuakeCSnapshotEdicts(server)
```

Update the stable client-snapshot mirror without copying server-only fields.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L3539)

<a id="function-function-miniquake-server-touchplayertriggers-function-touchplayertriggers-server-clientvalue-player-src-miniquake-server-ml-849509407"></a>
### touchPlayerTriggers

```ml
function touchPlayerTriggers(server, clientValue, player)
```

Implements the `touchPlayerTriggers` operation for `miniquake.server` (touch player triggers).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `touchPlayerTriggers`. |
| `player` | `dynamic` | — | The player input consumed by `touchPlayerTriggers`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2303)

<a id="function-function-miniquake-server-truncatebytes-function-truncatebytes-text-maximum-src-miniquake-server-ml-552824742"></a>
### truncateBytes

```ml
function truncateBytes(text, maximum)
```

Return truncate bytes derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `maximum` | `dynamic` | — | Largest accepted value. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L886)

<a id="function-function-miniquake-server-updatereliableclientstate-function-updatereliableclientstate-server-src-miniquake-server-ml-423626478"></a>
### updateReliableClientState

```ml
function updateReliableClientState(server)
```

Update module state for reliable client state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2574)

<a id="function-function-miniquake-server-writebaseline-function-writebaseline-buffer-item-src-miniquake-server-ml-1302989954"></a>
### writeBaseline

```ml
function writeBaseline(buffer, item)
```

Writes baseline for `miniquake.server`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeBaseline`. |
| `item` | `dynamic` | — | The item input consumed by `writeBaseline`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L302)

<a id="function-function-miniquake-server-writebegin-function-writebegin-client-src-miniquake-server-ml-525107872"></a>
### writeBegin

```ml
function writeBegin(client)
```

Encode and write begin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L850)

<a id="function-function-miniquake-server-writeclientdata-function-writeclientdata-buffer-player-src-miniquake-server-ml-1845444048"></a>
### writeClientData

```ml
function writeClientData(buffer, player)
```

Encode and write client data.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeClientData`. |
| `player` | `dynamic` | — | The player input consumed by `writeClientData`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1791)

<a id="function-function-miniquake-server-writeclientdataforclient-function-writeclientdataforclient-buffer-server-client-player-src-miniquake-server-ml-2123273060"></a>
### writeClientDataForClient

```ml
function writeClientDataForClient(buffer, server, client, player)
```

Encode and write client data for client.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeClientDataForClient`. |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `player` | `dynamic` | — | The player input consumed by `writeClientDataForClient`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1767)

<a id="function-function-miniquake-server-writeclientdatawithflags-function-writeclientdatawithflags-buffer-player-serverflags-src-miniquake-server-ml-682847048"></a>
### writeClientDataWithFlags

```ml
function writeClientDataWithFlags(buffer, player, serverFlags)
```

Encode and write client data with flags.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeClientDataWithFlags`. |
| `player` | `dynamic` | — | The player input consumed by `writeClientDataWithFlags`. |
| `serverFlags` | `dynamic` | — | The server flags input consumed by `writeClientDataWithFlags`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1776)

<a id="function-function-miniquake-server-writedamage-function-writedamage-server-client-buffer-src-miniquake-server-ml-1992543087"></a>
### writeDamage

```ml
function writeDamage(server, client, buffer)
```

Encode and write damage.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeDamage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1563)

<a id="function-function-miniquake-server-writedamageandangle-function-writedamageandangle-server-client-player-buffer-src-miniquake-server-ml-155597772"></a>
### writeDamageAndAngle

```ml
function writeDamageAndAngle(server, client, player, buffer)
```

Encode and write damage and angle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `player` | `dynamic` | — | The player input consumed by `writeDamageAndAngle`. |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeDamageAndAngle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1671)

<a id="function-function-miniquake-server-writeentityupdate-function-writeentityupdate-server-buffer-item-src-miniquake-server-ml-177412997"></a>
### writeEntityUpdate

```ml
function writeEntityUpdate(server, buffer, item)
```

Encode and write entity update.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeEntityUpdate`. |
| `item` | `dynamic` | — | The item input consumed by `writeEntityUpdate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1865)

<a id="function-function-miniquake-server-writefixangle-function-writefixangle-server-client-player-buffer-src-miniquake-server-ml-245400602"></a>
### writeFixAngle

```ml
function writeFixAngle(server, client, player, buffer)
```

Encode and write fix angle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `player` | `dynamic` | — | The player input consumed by `writeFixAngle`. |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeFixAngle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1646)

<a id="function-function-miniquake-server-writeplannedentityupdate-function-writeplannedentityupdate-server-buffer-item-src-miniquake-server-ml-2021892835"></a>
### writePlannedEntityUpdate

```ml
function writePlannedEntityUpdate(server, buffer, item)
```

Encode and write planned entity update.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `buffer` | `dynamic` | — | The buffer input consumed by `writePlannedEntityUpdate`. |
| `item` | `dynamic` | — | The item input consumed by `writePlannedEntityUpdate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1943)

<a id="function-function-miniquake-server-writeplannedentityupdatereserved-function-writeplannedentityupdatereserved-server-buffer-item-reservedbytes-src-miniquake-server-ml-1781757846"></a>
### writePlannedEntityUpdateReserved

```ml
function writePlannedEntityUpdateReserved(server, buffer, item, reservedBytes)
```

Encode and write planned entity update reserved.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `buffer` | `dynamic` | — | The buffer input consumed by `writePlannedEntityUpdateReserved`. |
| `item` | `dynamic` | — | The item input consumed by `writePlannedEntityUpdateReserved`. |
| `reservedBytes` | `dynamic` | — | Byte data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1917)

<a id="function-function-miniquake-server-writeplayerupdate-function-writeplayerupdate-server-buffer-client-player-src-miniquake-server-ml-1406339230"></a>
### writePlayerUpdate

```ml
function writePlayerUpdate(server, buffer, client, player)
```

Encode and write player update.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `buffer` | `dynamic` | — | The buffer input consumed by `writePlayerUpdate`. |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `player` | `dynamic` | — | The player input consumed by `writePlayerUpdate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1800)

<a id="function-function-miniquake-server-writequeuedparticle-function-writequeuedparticle-server-event-src-miniquake-server-ml-1406953718"></a>
### writeQueuedParticle

```ml
function writeQueuedParticle(server, event)
```

Encode and write queued particle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `event` | `dynamic` | — | Runtime event to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2534)

<a id="function-function-miniquake-server-writequeuedsound-function-writequeuedsound-server-event-src-miniquake-server-ml-2127660866"></a>
### writeQueuedSound

```ml
function writeQueuedSound(server, event)
```

Encode and write queued sound.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `event` | `dynamic` | — | Runtime event to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2511)

<a id="function-function-miniquake-server-writesignonstage2-function-writesignonstage2-server-client-src-miniquake-server-ml-397139471"></a>
### writeSignonStage2

```ml
function writeSignonStage2(server, client)
```

Encode and write signon stage2.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L697)

<a id="function-function-miniquake-server-writespawn-function-writespawn-server-client-player-src-miniquake-server-ml-1995010450"></a>
### writeSpawn

```ml
function writeSpawn(server, client, player)
```

Encode and write spawn.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `player` | `dynamic` | — | The player input consumed by `writeSpawn`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L773)

<a id="function-function-miniquake-server-writevisibleentityclassreserved-function-writevisibleentityclassreserved-server-buffer-pvs-clientedict-reservedbytes-priorityprojectiles-src-miniquake-server-ml-1186919204"></a>
### writeVisibleEntityClassReserved

```ml
function writeVisibleEntityClassReserved(server, buffer, pvs, clientEdict, reservedBytes, priorityProjectiles)
```

Write one snapshot class while retaining the Protocol-15 packet budget. The caller selects either priority projectiles or ordinary entities; the client edict is handled separately so it can never be duplicated.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeVisibleEntityClassReserved`. |
| `pvs` | `dynamic` | — | The pvs input consumed by `writeVisibleEntityClassReserved`. |
| `clientEdict` | `dynamic` | — | The client edict input consumed by `writeVisibleEntityClassReserved`. |
| `reservedBytes` | `dynamic` | — | Byte data consumed by the operation. |
| `priorityProjectiles` | `dynamic` | — | The priority projectiles input consumed by `writeVisibleEntityClassReserved`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L1967)

<a id="function-function-miniquake-server-writevisibleentityupdatesreserved-function-writevisibleentityupdatesreserved-server-buffer-pvs-clientedict-reservedbytes-src-miniquake-server-ml-428425170"></a>
### writeVisibleEntityUpdatesReserved

```ml
function writeVisibleEntityUpdatesReserved(server, buffer, pvs, clientEdict, reservedBytes)
```

Write a complete visible-entity snapshot with the player and active projectiles ahead of less time-sensitive entities. Protocol 15 accepts fast updates in any entity order. Prioritization prevents a high-numbered rocket or grenade from disappearing when a dense PVS reaches MAX_DATAGRAM.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeVisibleEntityUpdatesReserved`. |
| `pvs` | `dynamic` | — | The pvs input consumed by `writeVisibleEntityUpdatesReserved`. |
| `clientEdict` | `dynamic` | — | The client edict input consumed by `writeVisibleEntityUpdatesReserved`. |
| `reservedBytes` | `dynamic` | — | Byte data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L2012)

<a id="function-function-miniquake-server-zerospawnparms-function-zerospawnparms-src-miniquake-server-ml-25185925"></a>
### zeroSpawnParms

```ml
function zeroSpawnParms()
```

Create the zero-initialized state for spawn parms.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server.ml#L47)
