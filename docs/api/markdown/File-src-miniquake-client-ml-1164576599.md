# `src/miniquake/client.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.client`](Package-miniquake-client-1106059288.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/client_protocol.ml` as `protocol` → [src/miniquake/client_protocol.ml](File-src-miniquake-client-protocol-ml-948659732.md)
- `miniquake/cmd.ml` as `commandBuffer` → [src/miniquake/cmd.ml](File-src-miniquake-cmd-ml-1014778996.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/cvar.ml` as `cvar` → [src/miniquake/cvar.ml](File-src-miniquake-cvar-ml-171521436.md)
- `miniquake/demo.ml` as `demo` → [src/miniquake/demo.ml](File-src-miniquake-demo-ml-103505867.md)
- `miniquake/input.ml` as `input` → [src/miniquake/input.ml](File-src-miniquake-input-ml-1422374844.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/message.ml` as `msg` → [src/miniquake/message.ml](File-src-miniquake-message-ml-238261765.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/net_main.ml` as `netmain` → [src/miniquake/net_main.ml](File-src-miniquake-net-main-ml-940970693.md)
- `miniquake/particles.ml` as `particles` → [src/miniquake/particles.ml](File-src-miniquake-particles-ml-1296519509.md)
- `miniquake/protocol_delivery.ml` as `delivery` → [src/miniquake/protocol_delivery.ml](File-src-miniquake-protocol-delivery-ml-1050507123.md)
- `miniquake/protocol_signon.ml` as `protocolSignon` → [src/miniquake/protocol_signon.ml](File-src-miniquake-protocol-signon-ml-1645139383.md)
- `miniquake/protocol_write.ml` as `writer` → [src/miniquake/protocol_write.ml](File-src-miniquake-protocol-write-ml-1461808162.md)
- `miniquake/sizebuf.ml` as `sz` → [src/miniquake/sizebuf.ml](File-src-miniquake-sizebuf-ml-252484438.md)
- `miniquake/statusbar.ml` as `statusbar` → [src/miniquake/statusbar.ml](File-src-miniquake-statusbar-ml-945138613.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-client-addentityeffectdlights-function-addentityeffectdlights-entity-currenttime-src-miniquake-client-ml-2036522698"></a>
### addEntityEffectDlights

```ml
function addEntityEffectDlights(entity, currentTime)
```

Add state for add entity effect dlights.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L388)

<a id="function-function-miniquake-client-advancesignon-function-advancesignon-client-stage-src-miniquake-client-ml-653940056"></a>
### advanceSignon

```ml
function advanceSignon(client, stage)
```

Advance signon by one processing step.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `stage` | `dynamic` | — | The stage input consumed by `advanceSignon`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1386)

<a id="function-function-miniquake-client-appendprioritizedvisibleentity-function-appendprioritizedvisibleentity-builder-entity-modelflags-src-miniquake-client-ml-1738667461"></a>
### appendPrioritizedVisibleEntity

```ml
function appendPrioritizedVisibleEntity(builder, entity, modelFlags)
```

Append one dynamic render entity while preserving projectile visibility at the original MAX_VISEDICTS limit. A newly allocated rocket or grenade often has a high edict number; when the list is already full, replace the newest ordinary entry rather than rendering only the later explosion event.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `builder` | `dynamic` | — | The builder input consumed by `appendPrioritizedVisibleEntity`. |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `modelFlags` | `dynamic` | — | The model flags input consumed by `appendPrioritizedVisibleEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L433)

<a id="function-function-miniquake-client-applybaseline-function-applybaseline-client-number-baseline-src-miniquake-client-ml-698982596"></a>
### applyBaseline

```ml
function applyBaseline(client, number, baseline)
```

Apply baseline to the active subsystem state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `number` | `dynamic` | — | The number input consumed by `applyBaseline`. |
| `baseline` | `dynamic` | — | The baseline input consumed by `applyBaseline`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1317)

<a id="function-function-miniquake-client-applyevent-function-applyevent-client-item-src-miniquake-client-ml-561537353"></a>
### applyEvent

```ml
function applyEvent(client, item)
```

Apply event to the active subsystem state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `item` | `dynamic` | — | The item input consumed by `applyEvent`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1422)

<a id="function-function-miniquake-client-applyfastupdate-function-applyfastupdate-client-payload-src-miniquake-client-ml-1076717246"></a>
### applyFastUpdate

```ml
function applyFastUpdate(client, payload)
```

Apply fast update to the active subsystem state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `payload` | `dynamic` | — | The payload input consumed by `applyFastUpdate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1326)

<a id="function-function-miniquake-client-assignbaseline-function-assignbaseline-entity-baseline-src-miniquake-client-ml-296526737"></a>
### assignBaseline

```ml
function assignBaseline(entity, baseline)
```

Apply baseline values to an existing dynamic or static client entity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `baseline` | `dynamic` | — | The baseline input consumed by `assignBaseline`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1287)

<a id="function-function-miniquake-client-cl-activevisibleentities-function-cl-activevisibleentities-client-src-miniquake-client-ml-143413136"></a>
### CL_ActiveVisibleEntities

```ml
function CL_ActiveVisibleEntities(client)
```

Return the exact entity list consumed by the renderer after CL_RelinkEntities. WinQuake renders cl_visedicts rather than the entire sparse cl_entities array. Keep this as a defensive view: invalid/cleared entries can never leak into a modern backend even if a caller retained an older visibleEntities array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L591)

<a id="function-function-miniquake-client-cl-allocdlight-function-cl-allocdlight-key-src-miniquake-client-ml-1661865940"></a>
### CL_AllocDlight

```ml
function CL_AllocDlight(key)
```

CL_AllocDlight from cl_main.c.  Exact key matches are preferred, then an expired slot, with slot zero as the original overflow fallback.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L153)

<a id="function-function-miniquake-client-cl-allocdlightat-function-cl-allocdlightat-key-currenttime-src-miniquake-client-ml-1142432974"></a>
### CL_AllocDlightAt

```ml
function CL_AllocDlightAt(key, currentTime)
```

Apply the Quake-compatible cl alloc dlight at behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L182)

<a id="function-function-miniquake-client-cl-applyauthoritativeentityvisibility-function-cl-applyauthoritativeentityvisibility-client-authoritativeedicts-src-miniquake-client-ml-152207595"></a>
### CL_ApplyAuthoritativeEntityVisibility

```ml
function CL_ApplyAuthoritativeEntityVisibility(client, authoritativeEdicts)
```

Apply an integrated listen server's authoritative entity visibility before CL_RelinkEntities constructs the frame list. Pickups commonly clear only their QuakeC `model` string while retaining the precached modelindex for a possible deathmatch respawn. Protocol omission clears the entity on the following client message; the shared local process can safely clear it in the same frame and must do so before any renderer or efrag consumer runs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `authoritativeEdicts` | `dynamic` | — | The authoritative edicts input consumed by `CL_ApplyAuthoritativeEntityVisibility`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L671)

<a id="function-function-miniquake-client-cl-assignmodelsyncbase-function-cl-assignmodelsyncbase-entity-previousmodelindex-src-miniquake-client-ml-606462002"></a>
### CL_AssignModelSyncBase

```ml
function CL_AssignModelSyncBase(entity, previousModelIndex)
```

Apply the Quake-compatible cl assign model sync base behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `previousModelIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L303)

<a id="function-function-miniquake-client-cl-beginrelinkparticles-function-cl-beginrelinkparticles-active-src-miniquake-client-ml-1968743517"></a>
### CL_BeginRelinkParticles

```ml
function CL_BeginRelinkParticles(active)
```

Apply the Quake-compatible cl begin relink particles behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `active` | `dynamic` | — | The active input consumed by `CL_BeginRelinkParticles`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L363)

<a id="function-function-miniquake-client-cl-cleardlights-function-cl-cleardlights-src-miniquake-client-ml-125785969"></a>
### CL_ClearDlights

```ml
function CL_ClearDlights()
```

Apply the Quake-compatible cl clear dlights behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L123)

<a id="function-function-miniquake-client-cl-clearstate-function-cl-clearstate-client-src-miniquake-client-ml-2138678872"></a>
### CL_ClearState

```ml
function CL_ClearState(client)
```

CL_ClearState wipes client_state_t while retaining the transport and the client_static_t connection/signon fields represented by LocalClient.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L851)

<a id="function-function-miniquake-client-cl-decaylights-function-cl-decaylights-src-miniquake-client-ml-137076249"></a>
### CL_DecayLights

```ml
function CL_DecayLights()
```

Apply the Quake-compatible cl decay lights behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L202)

<a id="function-function-miniquake-client-cl-decaylightsat-function-cl-decaylightsat-currenttime-elapsed-src-miniquake-client-ml-1120381153"></a>
### CL_DecayLightsAt

```ml
function CL_DecayLightsAt(currentTime, elapsed)
```

Apply the Quake-compatible cl decay lights at behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `elapsed` | `dynamic` | — | The elapsed input consumed by `CL_DecayLightsAt`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L221)

<a id="function-function-miniquake-client-cl-disconnect-function-cl-disconnect-client-src-miniquake-client-ml-1979584400"></a>
### CL_Disconnect

```ml
function CL_Disconnect(client)
```

Apply the Quake-compatible cl disconnect behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1155)

<a id="function-function-miniquake-client-cl-disconnect-f-function-cl-disconnect-f-client-src-miniquake-client-ml-917343150"></a>
### CL_Disconnect_f

```ml
function CL_Disconnect_f(client)
```

Apply the Quake-compatible cl disconnect f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1184)

<a id="function-function-miniquake-client-cl-dlightindexforkey-function-cl-dlightindexforkey-key-src-miniquake-client-ml-578929552"></a>
### CL_DlightIndexForKey

```ml
function CL_DlightIndexForKey(key)
```

Apply the Quake-compatible cl dlight index for key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L190)

<a id="function-function-miniquake-client-cl-dlights-function-cl-dlights-src-miniquake-client-ml-1431753521"></a>
### CL_Dlights

```ml
function CL_Dlights()
```

Apply the Quake-compatible cl dlights behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L135)

<a id="function-function-miniquake-client-cl-efragremovalcandidates-function-cl-efragremovalcandidates-client-src-miniquake-client-ml-1455452754"></a>
### CL_EfragRemovalCandidates

```ml
function CL_EfragRemovalCandidates(client)
```

Apply the Quake-compatible cl efrag removal candidates behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L713)

<a id="function-function-miniquake-client-cl-endrelinkparticles-function-cl-endrelinkparticles-src-miniquake-client-ml-894941935"></a>
### CL_EndRelinkParticles

```ml
function CL_EndRelinkParticles()
```

Apply the Quake-compatible cl end relink particles behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L371)

<a id="function-function-miniquake-client-cl-entitynum-function-cl-entitynum-client-number-src-miniquake-client-ml-1819830219"></a>
### CL_EntityNum

```ml
function CL_EntityNum(client, number)
```

Apply the Quake-compatible cl entity num behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `number` | `dynamic` | — | The number input consumed by `CL_EntityNum`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L990)

<a id="function-function-miniquake-client-cl-establishconnection-function-cl-establishconnection-client-network-host-src-miniquake-client-ml-390758290"></a>
### CL_EstablishConnection

```ml
function CL_EstablishConnection(client, network, host)
```

Apply the Quake-compatible cl establish connection behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `network` | `dynamic` | — | The network input consumed by `CL_EstablishConnection`. |
| `host` | `dynamic` | — | The host input consumed by `CL_EstablishConnection`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1043)

<a id="function-function-miniquake-client-cl-establishinteropconnection-function-cl-establishinteropconnection-client-network-host-timeoutmilliseconds-resendmilliseconds-src-miniquake-client-ml-527509508"></a>
### CL_EstablishInteropConnection

```ml
function CL_EstablishInteropConnection(client, network, host, timeoutMilliseconds, resendMilliseconds)
```

Apply the Quake-compatible cl establish interop connection behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `network` | `dynamic` | — | The network input consumed by `CL_EstablishInteropConnection`. |
| `host` | `dynamic` | — | The host input consumed by `CL_EstablishInteropConnection`. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `CL_EstablishInteropConnection`. |
| `resendMilliseconds` | `dynamic` | — | The resend milliseconds input consumed by `CL_EstablishInteropConnection`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1080)

<a id="function-function-miniquake-client-cl-filterauthoritativevisibleentities-function-cl-filterauthoritativevisibleentities-visibleentities-authoritativeedicts-src-miniquake-client-ml-661367973"></a>
### CL_FilterAuthoritativeVisibleEntities

```ml
function CL_FilterAuthoritativeVisibleEntities(visibleEntities, authoritativeEdicts)
```

Filter an integrated listen client's render list against the authoritative server-edict mirror. Protocol 15 normally removes an omitted entity during CL_RelinkEntities. This final boundary also covers a retained list from an earlier frame: a freed edict or an item hidden by `self.model = string_null` must never reach any renderer backend. The common all-valid path is deliberately zero-copy.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `visibleEntities` | `dynamic` | — | The visible entities input consumed by `CL_FilterAuthoritativeVisibleEntities`. |
| `authoritativeEdicts` | `dynamic` | — | The authoritative edicts input consumed by `CL_FilterAuthoritativeVisibleEntities`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L623)

<a id="function-function-miniquake-client-cl-init-function-cl-init-client-registry-src-miniquake-client-ml-358734093"></a>
### CL_Init

```ml
function CL_Init(client, registry)
```

Apply the Quake-compatible cl init behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `CL_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1775)

<a id="function-function-miniquake-client-cl-keepalivemessage-function-cl-keepalivemessage-client-localserveractive-realtime-src-miniquake-client-ml-384213409"></a>
### CL_KeepaliveMessage

```ml
function CL_KeepaliveMessage(client, localServerActive, realtime)
```

Apply the Quake-compatible cl keepalive message behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `localServerActive` | `dynamic` | — | The local server active input consumed by `CL_KeepaliveMessage`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1114)

<a id="function-function-miniquake-client-cl-lerppoint-function-cl-lerppoint-client-src-miniquake-client-ml-163982752"></a>
### CL_LerpPoint

```ml
function CL_LerpPoint(client)
```

Apply the Quake-compatible cl lerp point behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L230)

<a id="function-function-miniquake-client-cl-modelflags-function-cl-modelflags-src-miniquake-client-ml-2131247569"></a>
### CL_ModelFlags

```ml
function CL_ModelFlags()
```

Apply the Quake-compatible cl model flags behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L273)

<a id="function-function-miniquake-client-cl-modelsynctypes-function-cl-modelsynctypes-src-miniquake-client-ml-1644676323"></a>
### CL_ModelSyncTypes

```ml
function CL_ModelSyncTypes()
```

Apply the Quake-compatible cl model sync types behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L287)

<a id="function-function-miniquake-client-cl-movemessagecount-function-cl-movemessagecount-src-miniquake-client-ml-1667516883"></a>
### CL_MoveMessageCount

```ml
function CL_MoveMessageCount()
```

Apply the Quake-compatible cl move message count behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1812)

<a id="function-function-miniquake-client-cl-newtranslation-function-cl-newtranslation-client-slot-src-miniquake-client-ml-1559253490"></a>
### CL_NewTranslation

```ml
function CL_NewTranslation(client, slot)
```

Apply the Quake-compatible cl new translation behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `slot` | `dynamic` | — | The slot input consumed by `CL_NewTranslation`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L998)

<a id="function-function-miniquake-client-cl-nextdemo-function-cl-nextdemo-commands-demos-demonumber-src-miniquake-client-ml-2015417077"></a>
### CL_NextDemo

```ml
function CL_NextDemo(commands, demos, demoNumber)
```

CL_NextDemo returns the updated demonum because MiniLang integers are value types. The command buffer and demo selection behavior match cl_main.c.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commands` | `dynamic` | — | The commands input consumed by `CL_NextDemo`. |
| `demos` | `dynamic` | — | The demos input consumed by `CL_NextDemo`. |
| `demoNumber` | `dynamic` | — | The demo number input consumed by `CL_NextDemo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L911)

<a id="function-function-miniquake-client-cl-printentities-f-function-cl-printentities-f-client-src-miniquake-client-ml-1005033768"></a>
### CL_PrintEntities_f

```ml
function CL_PrintEntities_f(client)
```

Apply the Quake-compatible cl print entities f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L928)

<a id="function-function-miniquake-client-cl-readfromserver-function-cl-readfromserver-client-frametime-realtime-src-miniquake-client-ml-850191875"></a>
### CL_ReadFromServer

```ml
function CL_ReadFromServer(client, frameTime, realtime)
```

Apply the Quake-compatible cl read from server behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1730)

<a id="function-function-miniquake-client-cl-registeredcommands-function-cl-registeredcommands-src-miniquake-client-ml-832441105"></a>
### CL_RegisteredCommands

```ml
function CL_RegisteredCommands()
```

Apply the Quake-compatible cl registered commands behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1806)

<a id="function-function-miniquake-client-cl-relinkentities-function-cl-relinkentities-client-src-miniquake-client-ml-637028160"></a>
### CL_RelinkEntities

```ml
function CL_RelinkEntities(client)
```

Apply the Quake-compatible cl relink entities behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L455)

<a id="function-function-miniquake-client-cl-sendcmd-function-cl-sendcmd-client-command-src-miniquake-client-ml-122191721"></a>
### CL_SendCmd

```ml
function CL_SendCmd(client, command)
```

Apply the Quake-compatible cl send cmd behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1742)

<a id="function-function-miniquake-client-cl-sendmove-function-cl-sendmove-client-command-src-miniquake-client-ml-310852799"></a>
### CL_SendMove

```ml
function CL_SendMove(client, command)
```

Apply the Quake-compatible cl send move behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1280)

<a id="function-function-miniquake-client-cl-servershutdownrequested-function-cl-servershutdownrequested-src-miniquake-client-ml-335168513"></a>
### CL_ServerShutdownRequested

```ml
function CL_ServerShutdownRequested()
```

Apply the Quake-compatible cl server shutdown requested behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1191)

<a id="function-function-miniquake-client-cl-setchaseactive-function-cl-setchaseactive-active-src-miniquake-client-ml-796239375"></a>
### CL_SetChaseActive

```ml
function CL_SetChaseActive(active)
```

Apply the Quake-compatible cl set chase active behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `active` | `dynamic` | — | The active input consumed by `CL_SetChaseActive`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L316)

<a id="function-function-miniquake-client-cl-setdlighttime-function-cl-setdlighttime-oldtime-currenttime-src-miniquake-client-ml-1615684825"></a>
### CL_SetDlightTime

```ml
function CL_SetDlightTime(oldTime, currentTime)
```

Apply the Quake-compatible cl set dlight time behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `oldTime` | `dynamic` | — | Time value used by the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L143)

<a id="function-function-miniquake-client-cl-setmodelflags-function-cl-setmodelflags-flags-src-miniquake-client-ml-453530268"></a>
### CL_SetModelFlags

```ml
function CL_SetModelFlags(flags)
```

Apply the Quake-compatible cl set model flags behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `flags` | `dynamic` | — | The flags input consumed by `CL_SetModelFlags`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L266)

<a id="function-function-miniquake-client-cl-setmodelsynctypes-function-cl-setmodelsynctypes-synctypes-src-miniquake-client-ml-1764345209"></a>
### CL_SetModelSyncTypes

```ml
function CL_SetModelSyncTypes(syncTypes)
```

Apply the Quake-compatible cl set model sync types behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `syncTypes` | `dynamic` | — | The sync types input consumed by `CL_SetModelSyncTypes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L280)

<a id="function-function-miniquake-client-cl-setmovemessagecount-function-cl-setmovemessagecount-value-src-miniquake-client-ml-1580855958"></a>
### CL_SetMoveMessageCount

```ml
function CL_SetMoveMessageCount(value)
```

Apply the Quake-compatible cl set move message count behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `CL_SetMoveMessageCount`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1819)

<a id="function-function-miniquake-client-cl-setrandomseed-function-cl-setrandomseed-seed-src-miniquake-client-ml-2010292694"></a>
### CL_SetRandomSeed

```ml
function CL_SetRandomSeed(seed)
```

Apply the Quake-compatible cl set random seed behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `seed` | `dynamic` | — | The seed input consumed by `CL_SetRandomSeed`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L381)

<a id="function-function-miniquake-client-cl-setstandardquake-function-cl-setstandardquake-client-value-src-miniquake-client-ml-1645705785"></a>
### CL_SetStandardQuake

```ml
function CL_SetStandardQuake(client, value)
```

Apply the Quake-compatible cl set standard quake behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `value` | `dynamic` | — | Value consumed by `CL_SetStandardQuake`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L841)

<a id="function-function-miniquake-client-cl-signonreply-function-cl-signonreply-client-src-miniquake-client-ml-2022757044"></a>
### CL_SignonReply

```ml
function CL_SignonReply(client)
```

Apply the Quake-compatible cl signon reply behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1399)

<a id="function-function-miniquake-client-cl-takerelinkparticleeffects-function-cl-takerelinkparticleeffects-src-miniquake-client-ml-844624049"></a>
### CL_TakeRelinkParticleEffects

```ml
function CL_TakeRelinkParticleEffects()
```

Apply the Quake-compatible cl take relink particle effects behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L354)

<a id="function-function-miniquake-client-cl-updateentitydlights-function-cl-updateentitydlights-client-currenttime-src-miniquake-client-ml-1859521218"></a>
### CL_UpdateEntityDlights

```ml
function CL_UpdateEntityDlights(client, currentTime)
```

The EF_* lights are created during CL_RelinkEntities in WinQuake.  This helper performs only that lighting side effect; entity interpolation and trail generation remain in their existing rendering path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L733)

<a id="function-function-miniquake-client-cl-viewentityorigin-function-cl-viewentityorigin-client-src-miniquake-client-ml-902149100"></a>
### CL_ViewEntityOrigin

```ml
function CL_ViewEntityOrigin(client)
```

gl_refrag.c removes stale efrags when a force-linked entity no longer has a model.  The integrated renderer does not expose native efrag pointers, so this source-guided list is the hand-off boundary for efrag-aware backends.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L701)

<a id="global-global-miniquake-client-clchaseactive-clchaseactive-src-miniquake-client-ml-1285173319"></a>
### clChaseActive

```ml
clChaseActive
```

Tracks the module-level cl chase active state owned by `miniquake.client`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L44)

<a id="global-global-miniquake-client-cldisconnectrequestedservershutdown-cldisconnectrequestedservershutdown-src-miniquake-client-ml-1598943331"></a>
### clDisconnectRequestedServerShutdown

```ml
clDisconnectRequestedServerShutdown
```

Tracks the module-level cl disconnect requested server shutdown state owned by `miniquake.client`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L62)

<a id="global-global-miniquake-client-cldlightoldtime-cldlightoldtime-src-miniquake-client-ml-714399611"></a>
### clDlightOldTime

```ml
clDlightOldTime
```

Tracks the module-level cl dlight old time state owned by `miniquake.client`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L36)

<a id="global-global-miniquake-client-cldlights-cldlights-src-miniquake-client-ml-1753779063"></a>
### clDlights

```ml
clDlights
```

cl_main.c: client-side dynamic-light pool.  The original stores this as a fixed translation-unit array rather than inside client_state_t; a package global is the direct MiniLang equivalent.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L32)

<a id="global-global-miniquake-client-cldlighttime-cldlighttime-src-miniquake-client-ml-693103863"></a>
### clDlightTime

```ml
clDlightTime
```

Tracks the module-level cl dlight time state owned by `miniquake.client`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L34)

<a id="function-function-miniquake-client-clearstate-function-clearstate-client-src-miniquake-client-ml-1203550288"></a>
### clearState

```ml
function clearState(client)
```

Update module state for state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L902)

<a id="function-function-miniquake-client-clientcommandexists-function-clientcommandexists-name-src-miniquake-client-ml-942184920"></a>
### clientCommandExists

```ml
function clientCommandExists(name)
```

Report whether client command exists holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1757)

<a id="function-function-miniquake-client-clientfloat-function-clientfloat-value-src-miniquake-client-ml-698122572"></a>
### clientFloat

```ml
function clientFloat(value)
```

client_state_t stores interpolation velocities, entity transforms and dlight fields as C floats even though cl.time/mtime are doubles.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `clientFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L67)

<a id="function-function-miniquake-client-clientlerp-function-clientlerp-previous-current-fraction-src-miniquake-client-ml-1220592601"></a>
### clientLerp

```ml
function clientLerp(previous, current, fraction)
```

Implements the `clientLerp` operation for `miniquake.client` (client lerp).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `previous` | `dynamic` | — | The previous input consumed by `clientLerp`. |
| `current` | `dynamic` | — | The current input consumed by `clientLerp`. |
| `fraction` | `dynamic` | — | The fraction input consumed by `clientLerp`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L75)

<a id="global-global-miniquake-client-clkeepalivelastmessage-clkeepalivelastmessage-src-miniquake-client-ml-2056268891"></a>
### clKeepaliveLastMessage

```ml
clKeepaliveLastMessage
```

Tracks the module-level cl keepalive last message state owned by `miniquake.client`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L54)

<a id="global-global-miniquake-client-clmodelflags-clmodelflags-src-miniquake-client-ml-158595413"></a>
### clModelFlags

```ml
clModelFlags
```

Tracks the module-level cl model flags state owned by `miniquake.client`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L38)

<a id="global-global-miniquake-client-clmodelsynctypes-clmodelsynctypes-src-miniquake-client-ml-1236907659"></a>
### clModelSyncTypes

```ml
clModelSyncTypes
```

Tracks the module-level cl model sync types state owned by `miniquake.client`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L40)

<a id="global-global-miniquake-client-clmovemessages-clmovemessages-src-miniquake-client-ml-1844394027"></a>
### clMoveMessages

```ml
clMoveMessages
```

Tracks the module-level cl move messages state owned by `miniquake.client`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L52)

<a id="global-global-miniquake-client-clregisteredcommands-clregisteredcommands-src-miniquake-client-ml-224476509"></a>
### clRegisteredCommands

```ml
clRegisteredCommands
```

Tracks the module-level cl registered commands state owned by `miniquake.client`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L60)

<a id="global-global-miniquake-client-clrelinkparticleeffects-clrelinkparticleeffects-src-miniquake-client-ml-659414579"></a>
### clRelinkParticleEffects

```ml
clRelinkParticleEffects
```

Tracks the module-level cl relink particle effects state owned by `miniquake.client`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L42)

<a id="global-global-miniquake-client-clrelinkparticlepool-clrelinkparticlepool-src-miniquake-client-ml-561023295"></a>
### clRelinkParticlePool

```ml
clRelinkParticlePool
```

Tracks the module-level cl relink particle pool state owned by `miniquake.client`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L46)

<a id="global-global-miniquake-client-clrelinkparticlepoolactive-clrelinkparticlepoolactive-src-miniquake-client-ml-1404959363"></a>
### clRelinkParticlePoolActive

```ml
clRelinkParticlePoolActive
```

Tracks the module-level cl relink particle pool active state owned by `miniquake.client`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L48)

<a id="global-global-miniquake-client-clrelinkparticletime-clrelinkparticletime-src-miniquake-client-ml-236019885"></a>
### clRelinkParticleTime

```ml
clRelinkParticleTime
```

Tracks the module-level cl relink particle time state owned by `miniquake.client`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L50)

<a id="global-global-miniquake-client-clstandardquake-clstandardquake-src-miniquake-client-ml-1147900055"></a>
### clStandardQuake

```ml
clStandardQuake
```

Tracks the module-level cl standard quake state owned by `miniquake.client`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L58)

<a id="global-global-miniquake-client-cltranslations-cltranslations-src-miniquake-client-ml-1385834817"></a>
### clTranslations

```ml
clTranslations
```

Tracks the module-level cl translations state owned by `miniquake.client`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L56)

<a id="function-function-miniquake-client-connect-function-connect-client-network-src-miniquake-client-ml-280517724"></a>
### connect

```ml
function connect(client, network)
```

Implements the `connect` operation for `miniquake.client` (connect).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `network` | `dynamic` | — | The network input consumed by `connect`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1035)

<a id="function-function-miniquake-client-connecthost-function-connecthost-client-network-host-src-miniquake-client-ml-339926654"></a>
### connectHost

```ml
function connectHost(client, network, host)
```

Establish host using the active network transport.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `network` | `dynamic` | — | The network input consumed by `connectHost`. |
| `host` | `dynamic` | — | The host input consumed by `connectHost`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1070)

<a id="function-function-miniquake-client-connecthostinterop-function-connecthostinterop-client-network-host-timeoutmilliseconds-resendmilliseconds-src-miniquake-client-ml-1096186696"></a>
### connectHostInterop

```ml
function connectHostInterop(client, network, host, timeoutMilliseconds, resendMilliseconds)
```

Establish host interop using the active network transport.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `network` | `dynamic` | — | The network input consumed by `connectHostInterop`. |
| `host` | `dynamic` | — | The host input consumed by `connectHostInterop`. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `connectHostInterop`. |
| `resendMilliseconds` | `dynamic` | — | The resend milliseconds input consumed by `connectHostInterop`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1106)

<a id="function-function-miniquake-client-consumemessages-function-consumemessages-client-src-miniquake-client-ml-1309792872"></a>
### consumeMessages

```ml
function consumeMessages(client)
```

Consume pending state for consume messages.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1827)

<a id="function-function-miniquake-client-consumeprintlog-function-consumeprintlog-client-src-miniquake-client-ml-884505690"></a>
### consumePrintLog

```ml
function consumePrintLog(client)
```

Consume pending state for consume print log.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1835)

<a id="function-function-miniquake-client-create-function-create-player-src-miniquake-client-ml-1612503042"></a>
### create

```ml
function create(player)
```

Implements the `create` operation for `miniquake.client` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `create`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L780)

<a id="function-function-miniquake-client-createentity-function-createentity-number-src-miniquake-client-ml-1585044098"></a>
### createEntity

```ml
function createEntity(number)
```

Create and initialize entity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `number` | `dynamic` | — | The number input consumed by `createEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L746)

<a id="function-function-miniquake-client-disconnect-function-disconnect-client-src-miniquake-client-ml-875521952"></a>
### disconnect

```ml
function disconnect(client)
```

Terminate the requested value and release its transport state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1178)

<a id="function-function-miniquake-client-drainmessages-function-drainmessages-client-src-miniquake-client-ml-785463168"></a>
### drainMessages

```ml
function drainMessages(client)
```

Consume pending state for drain messages.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1843)

<a id="function-function-miniquake-client-dropconnection-function-dropconnection-client-src-miniquake-client-ml-907562040"></a>
### dropConnection

```ml
function dropConnection(client)
```

Release state for drop connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1198)

<a id="function-function-miniquake-client-ensureclientcvar-function-ensureclientcvar-registry-name-value-archive-src-miniquake-client-ml-1693084026"></a>
### ensureClientCvar

```ml
function ensureClientCvar(registry, name, value, archive)
```

Ensure sufficient storage or state for client cvar.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `ensureClientCvar`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `ensureClientCvar`. |
| `archive` | `dynamic` | — | The archive input consumed by `ensureClientCvar`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1766)

<a id="function-function-miniquake-client-ensuredynamiclights-function-ensuredynamiclights-src-miniquake-client-ml-1128221889"></a>
### ensureDynamicLights

```ml
function ensureDynamicLights()
```

Ensure sufficient storage or state for dynamic lights.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L110)

<a id="function-function-miniquake-client-ensureentity-function-ensureentity-client-number-src-miniquake-client-ml-517017983"></a>
### ensureEntity

```ml
function ensureEntity(client, number)
```

Ensure sufficient storage or state for entity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `number` | `dynamic` | — | The number input consumed by `ensureEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L979)

<a id="function-function-miniquake-client-interpolatedangle-function-interpolatedangle-previous-current-fraction-src-miniquake-client-ml-1707655605"></a>
### interpolatedAngle

```ml
function interpolatedAngle(previous, current, fraction)
```

Implements the `interpolatedAngle` operation for `miniquake.client` (interpolated angle).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `previous` | `dynamic` | — | The previous input consumed by `interpolatedAngle`. |
| `current` | `dynamic` | — | The current input consumed by `interpolatedAngle`. |
| `fraction` | `dynamic` | — | The fraction input consumed by `interpolatedAngle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L258)

<a id="function-function-miniquake-client-modelflagsforindex-function-modelflagsforindex-modelindex-src-miniquake-client-ml-705456080"></a>
### modelFlagsForIndex

```ml
function modelFlagsForIndex(modelIndex)
```

Return model flags for index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `modelIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L324)

<a id="function-function-miniquake-client-modelsynctypeforindex-function-modelsynctypeforindex-modelindex-src-miniquake-client-ml-47523486"></a>
### modelSyncTypeForIndex

```ml
function modelSyncTypeForIndex(modelIndex)
```

Return model sync type for index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `modelIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L294)

<a id="function-function-miniquake-client-newdynamiclight-function-newdynamiclight-src-miniquake-client-ml-1586680407"></a>
### newDynamicLight

```ml
function newDynamicLight()
```

Create and initialize dynamic light.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L81)

<a id="function-function-miniquake-client-nextdlightrandom-function-nextdlightrandom-src-miniquake-client-ml-447406001"></a>
### nextDlightRandom

```ml
function nextDlightRandom()
```

Return next dlight random for the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L724)

<a id="function-function-miniquake-client-parsemessage-function-parsemessage-client-data-src-miniquake-client-ml-2056549764"></a>
### parseMessage

```ml
function parseMessage(client, data)
```

Read and validate message.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1655)

<a id="function-function-miniquake-client-projectilemodelflags-function-projectilemodelflags-modelflags-src-miniquake-client-ml-1510568417"></a>
### projectileModelFlags

```ml
function projectileModelFlags(modelFlags)
```

Report whether alias-model flags identify a stock trail projectile whose model is more time-sensitive than an ordinary visible entity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `modelFlags` | `dynamic` | — | The model flags input consumed by `projectileModelFlags`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L422)

<a id="function-function-miniquake-client-pump-function-pump-client-src-miniquake-client-ml-1012944976"></a>
### pump

```ml
function pump(client)
```

Implements the `pump` operation for `miniquake.client` (pump).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1696)

<a id="function-function-miniquake-client-pumprecording-function-pumprecording-client-recording-src-miniquake-client-ml-1761908553"></a>
### pumpRecording

```ml
function pumpRecording(client, recording)
```

Advance recording by one processing step.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `recording` | `dynamic` | — | The recording input consumed by `pumpRecording`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1703)

<a id="function-function-miniquake-client-queuerelinkparticleeffect-function-queuerelinkparticleeffect-command-payload-src-miniquake-client-ml-1531150224"></a>
### queueRelinkParticleEffect

```ml
function queueRelinkParticleEffect(command, payload)
```

Add state for queue relink particle effect.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `payload` | `dynamic` | — | The payload input consumed by `queueRelinkParticleEffect`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L333)

<a id="function-function-miniquake-client-queuestring-function-queuestring-client-text-src-miniquake-client-ml-1065247317"></a>
### queueString

```ml
function queueString(client, text)
```

Add state for queue string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1212)

<a id="function-function-miniquake-client-readnetworkmessages-function-readnetworkmessages-client-realtime-src-miniquake-client-ml-1291595159"></a>
### readNetworkMessages

```ml
function readNetworkMessages(client, realtime)
```

Read and validate network messages.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1668)

<a id="function-function-miniquake-client-reconnect-function-reconnect-client-src-miniquake-client-ml-730665114"></a>
### reconnect

```ml
function reconnect(client)
```

Implements the `reconnect` operation for `miniquake.client` (reconnect).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1142)

<a id="function-function-miniquake-client-resetdynamiclight-function-resetdynamiclight-light-key-src-miniquake-client-ml-1899259140"></a>
### resetDynamicLight

```ml
function resetDynamicLight(light, key)
```

Update module state for dynamic light.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `light` | `dynamic` | — | The light input consumed by `resetDynamicLight`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L95)

<a id="function-function-miniquake-client-resetscores-function-resetscores-client-count-src-miniquake-client-ml-417330247"></a>
### resetScores

```ml
function resetScores(client, count)
```

Update module state for scores.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L958)

<a id="function-function-miniquake-client-sendmove-function-sendmove-client-command-src-miniquake-client-ml-78009481"></a>
### sendMove

```ml
function sendMove(client, command)
```

Send move through the active connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1241)

<a id="function-function-miniquake-client-sendreliable-function-sendreliable-client-src-miniquake-client-ml-1538509228"></a>
### sendReliable

```ml
function sendReliable(client)
```

Send reliable through the active connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1220)

<a id="function-function-miniquake-client-sendstring-function-sendstring-client-text-src-miniquake-client-ml-1020730717"></a>
### sendString

```ml
function sendString(client, text)
```

Send string through the active connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L1232)

<a id="function-function-miniquake-client-setpal-inline-function-setpal-index-src-miniquake-client-ml-1090483920"></a>
### SetPal

```ml
inline function SetPal(index)
```

The MiniQuake SetPal debug body is compiled out with #if 0.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L951)

<a id="function-function-miniquake-client-validscoreindex-function-validscoreindex-client-index-src-miniquake-client-ml-256622874"></a>
### validScoreIndex

```ml
function validScoreIndex(client, index)
```

Report whether score index.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client.ml#L972)
