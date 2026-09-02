/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Protocol-15 server-to-client payload writers shared by the integrated server
and the source-guided parity fixtures.  The field order, optional-bit rules
and strict datagram boundary match WinQuake/sv_main.c.
*/
package miniquake.protocol_serverdata

import miniquake.types as t
import miniquake.constants as c
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.native as native
import miniquake.protocol_transients as transients

/// Defines the plan send unreliable value used by `miniquake.protocol_serverdata`.
const PLAN_SEND_UNRELIABLE = 1
/// Defines the plan send nop value used by `miniquake.protocol_serverdata`.
const PLAN_SEND_NOP = 2
/// Defines the plan wait signon value used by `miniquake.protocol_serverdata`.
const PLAN_WAIT_SIGNON = 4
/// Defines the plan reliable phase value used by `miniquake.protocol_serverdata`.
const PLAN_RELIABLE_PHASE = 8

/// Defines the reliable none value used by `miniquake.protocol_serverdata`.
const RELIABLE_NONE = 0
/// Defines the reliable drop overflow value used by `miniquake.protocol_serverdata`.
const RELIABLE_DROP_OVERFLOW = 1
/// Defines the reliable wait value used by `miniquake.protocol_serverdata`.
const RELIABLE_WAIT = 2
/// Defines the reliable drop asap value used by `miniquake.protocol_serverdata`.
const RELIABLE_DROP_ASAP = 3
/// Defines the reliable send value used by `miniquake.protocol_serverdata`.
const RELIABLE_SEND = 4

/// Implements the `progsCrcText` operation for `miniquake.protocol_serverdata` (progs crc text).
/// @param crc The crc input consumed by `progsCrcText`.
function progsCrcText(crc)
  return "\u0002\nVERSION 1.09 SERVER (" + native.trunc(crc) + " CRC)"
end function

/// Encode and write precache list.
/// @param buffer The buffer input consumed by `writePrecacheList`.
/// @param values The values input consumed by `writePrecacheList`.
function writePrecacheList(buffer, values)
  index = 1
  while index < len(values)
    value = values[index]
    if value is void or value == "" then break end if
    msg.writeString(buffer, value)
    index = index + 1
  end while
  msg.writeByte(buffer, 0)
  return index - 1
end function

/// SV_SendServerinfo payload, including the leading version print and stage-1
/// signon marker.  client lifecycle flags remain the caller's responsibility.
/// @param buffer The buffer input consumed by `writeServerInfo`.
/// @param progsCrc The progs crc input consumed by `writeServerInfo`.
/// @param maxClients The max clients input consumed by `writeServerInfo`.
/// @param gameType The game type input consumed by `writeServerInfo`.
/// @param levelName Name that identifies the requested value or resource.
/// @param modelPrecache The model precache input consumed by `writeServerInfo`.
/// @param soundPrecache The sound precache input consumed by `writeServerInfo`.
/// @param cdTrack The cd track input consumed by `writeServerInfo`.
/// @param viewEntity The view entity input consumed by `writeServerInfo`.
function writeServerInfo(
  buffer,
  progsCrc,
  maxClients,
  gameType,
  levelName,
  modelPrecache,
  soundPrecache,
  cdTrack,
  viewEntity,
)
  start = buffer.curSize
  msg.writeByte(buffer, c.SVC_PRINT)
  msg.writeString(buffer, progsCrcText(progsCrc))
  msg.writeByte(buffer, c.SVC_SERVERINFO)
  msg.writeLong(buffer, c.PROTOCOL_VERSION)
  msg.writeByte(buffer, maxClients)
  msg.writeByte(buffer, gameType)
  msg.writeString(buffer, levelName)
  writePrecacheList(buffer, modelPrecache)
  writePrecacheList(buffer, soundPrecache)
  msg.writeByte(buffer, c.SVC_CDTRACK)
  msg.writeByte(buffer, cdTrack)
  msg.writeByte(buffer, cdTrack)
  msg.writeByte(buffer, c.SVC_SETVIEW)
  msg.writeShort(buffer, viewEntity)
  msg.writeByte(buffer, c.SVC_SIGNONNUM)
  msg.writeByte(buffer, c.SIGNON_SERVERINFO)
  return buffer.curSize - start
end function

/// Implements the `soundFieldMask` operation for `miniquake.protocol_serverdata` (sound field mask).
/// @param volume The volume input consumed by `soundFieldMask`.
/// @param attenuation The attenuation input consumed by `soundFieldMask`.
function soundFieldMask(volume, attenuation)
  return transients.soundFieldMask(volume, attenuation)
end function

/// SV_StartSound's wire payload. C has already converted channel/volume to int
/// and attenuation to float before entering the function. Recreate that ABI
/// boundary here so dynamic MiniLang callers cannot alter the optional bits.
/// Validation, precache lookup and the MAX_DATAGRAM-16 early-out are performed
/// by the production wrappers.
/// @param buffer The buffer input consumed by `writeSound`.
/// @param entityNumber The entity number input consumed by `writeSound`.
/// @param channel The channel input consumed by `writeSound`.
/// @param soundNumber The sound number input consumed by `writeSound`.
/// @param volume The volume input consumed by `writeSound`.
/// @param attenuation The attenuation input consumed by `writeSound`.
/// @param center The center input consumed by `writeSound`.
function writeSound(buffer, entityNumber, channel, soundNumber, volume, attenuation, center)
  start = buffer.curSize
  entityValue = native.trunc(entityNumber)
  channelValue = native.trunc(channel)
  volumeValue = native.trunc(volume)
  roundedAttenuation = transients.cFloat(attenuation)
  fieldMask = soundFieldMask(volumeValue, roundedAttenuation)
  msg.writeByte(buffer, c.SVC_SOUND)
  msg.writeByte(buffer, fieldMask)
  if (fieldMask & c.SND_VOLUME) != 0 then msg.writeByte(buffer, volumeValue) end if
  if (fieldMask & c.SND_ATTENUATION) != 0 then
    msg.writeByte(buffer, transients.soundAttenuationByte(roundedAttenuation))
  end if
  msg.writeShort(buffer, transients.packSoundChannel(entityValue, channelValue))
  msg.writeByte(buffer, soundNumber)
  msg.writeCoord(buffer, center.x)
  msg.writeCoord(buffer, center.y)
  msg.writeCoord(buffer, center.z)
  return buffer.curSize - start
end function

/// Writes baseline for `miniquake.protocol_serverdata`.
/// @param buffer The buffer input consumed by `writeBaseline`.
/// @param entityNumber The entity number input consumed by `writeBaseline`.
/// @param baseline The baseline input consumed by `writeBaseline`.
function writeBaseline(buffer, entityNumber, baseline)
  start = buffer.curSize
  msg.writeByte(buffer, c.SVC_SPAWNBASELINE)
  msg.writeShort(buffer, entityNumber)
  msg.writeByte(buffer, baseline.modelIndex)
  msg.writeByte(buffer, baseline.frame)
  msg.writeByte(buffer, baseline.colormap)
  msg.writeByte(buffer, baseline.skin)
  msg.writeCoord(buffer, baseline.origin.x)
  msg.writeAngle(buffer, baseline.angles.x)
  msg.writeCoord(buffer, baseline.origin.y)
  msg.writeAngle(buffer, baseline.angles.y)
  msg.writeCoord(buffer, baseline.origin.z)
  msg.writeAngle(buffer, baseline.angles.z)
  return buffer.curSize - start
end function

/// Return client data bits derived from the active module state.
/// @param data Input data consumed by the operation.
function clientDataBits(data)
  bits = c.SU_ITEMS | c.SU_WEAPON
  if data.viewHeight != c.DEFAULT_VIEWHEIGHT then bits = bits | c.SU_VIEWHEIGHT end if
  if data.idealPitch != 0.0 then bits = bits | c.SU_IDEALPITCH end if
  if (native.trunc(data.flags) & c.FL_ONGROUND) != 0 then bits = bits | c.SU_ONGROUND end if
  if native.trunc(data.waterLevel) >= 2 then bits = bits | c.SU_INWATER end if

  if data.punch.x != 0.0 then bits = bits | c.SU_PUNCH1 end if
  if data.punch.y != 0.0 then bits = bits | c.SU_PUNCH2 end if
  if data.punch.z != 0.0 then bits = bits | c.SU_PUNCH3 end if
  if data.velocity.x != 0.0 then bits = bits | c.SU_VELOCITY1 end if
  if data.velocity.y != 0.0 then bits = bits | c.SU_VELOCITY2 end if
  if data.velocity.z != 0.0 then bits = bits | c.SU_VELOCITY3 end if
  if data.weaponFrame != 0.0 then bits = bits | c.SU_WEAPONFRAME end if
  if data.armor != 0.0 then bits = bits | c.SU_ARMOR end if
  return bits
end function

/// The final active-weapon byte intentionally follows stock Quake's two modes.
/// In mission-pack mode a zero bitfield emits no byte, matching the original C
/// loop's fall-through behavior.
/// @param buffer The buffer input consumed by `writeClientData`.
/// @param data Input data consumed by the operation.
function writeClientData(buffer, data)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  start = buffer.curSize
  bits = clientDataBits(data)
  msg.writeByte(buffer, c.SVC_CLIENTDATA)
  msg.writeShort(buffer, bits)
  if (bits & c.SU_VIEWHEIGHT) != 0 then msg.writeChar(buffer, data.viewHeight) end if
  if (bits & c.SU_IDEALPITCH) != 0 then msg.writeChar(buffer, data.idealPitch) end if

  if (bits & c.SU_PUNCH1) != 0 then msg.writeChar(buffer, data.punch.x) end if
  if (bits & c.SU_VELOCITY1) != 0 then msg.writeChar(buffer, data.velocity.x / 16.0) end if
  if (bits & c.SU_PUNCH2) != 0 then msg.writeChar(buffer, data.punch.y) end if
  if (bits & c.SU_VELOCITY2) != 0 then msg.writeChar(buffer, data.velocity.y / 16.0) end if
  if (bits & c.SU_PUNCH3) != 0 then msg.writeChar(buffer, data.punch.z) end if
  if (bits & c.SU_VELOCITY3) != 0 then msg.writeChar(buffer, data.velocity.z / 16.0) end if

  msg.writeLong(buffer, data.items)
  if (bits & c.SU_WEAPONFRAME) != 0 then msg.writeByte(buffer, data.weaponFrame) end if
  if (bits & c.SU_ARMOR) != 0 then msg.writeByte(buffer, data.armor) end if
  msg.writeByte(buffer, data.weaponModel)
  msg.writeShort(buffer, data.health)
  msg.writeByte(buffer, data.currentAmmo)
  msg.writeByte(buffer, data.shells)
  msg.writeByte(buffer, data.nails)
  msg.writeByte(buffer, data.rockets)
  msg.writeByte(buffer, data.cells)

  if data.standardQuake then
    msg.writeByte(buffer, data.activeWeapon)
  else
    active = native.trunc(data.activeWeapon)
    bit = 0
    while bit < 32
      if (active & (1 << bit)) != 0 then
        msg.writeByte(buffer, bit)
        return [bits, buffer.curSize - start]
      end if
      bit = bit + 1
    end while
  end if
  return [bits, buffer.curSize - start]
end function

/// SV_SendClientDatagram copies sv.datagram only when the resulting size is
/// strictly less than MAX_DATAGRAM. Equality is intentionally rejected.
/// @param destination Destination value or collection to update.
/// @param source Source value or collection to read.
function appendDatagramIfFits(destination, source)
  if destination.curSize + source.curSize >= destination.maxSize then return false end if
  if source.curSize > 0 then sz.write(destination, source.data, 0, source.curSize) end if
  return true
end function

/// First phase of SV_SendClientMessages. Spawned clients send an unreliable
/// datagram and continue into the reliable phase. Unspawned clients without a
/// requested signon stage either receive a five-second keepalive or wait.
/// @param spawned The spawned input consumed by `initialDeliveryPlan`.
/// @param sendSignon The send signon input consumed by `initialDeliveryPlan`.
/// @param elapsed The elapsed input consumed by `initialDeliveryPlan`.
function initialDeliveryPlan(spawned, sendSignon, elapsed)
  if spawned then return PLAN_SEND_UNRELIABLE | PLAN_RELIABLE_PHASE end if
  if not sendSignon then
    if elapsed > 5.0 then return PLAN_SEND_NOP end if
    return PLAN_WAIT_SIGNON
  end if
  return PLAN_RELIABLE_PHASE
end function

/// Implements the `reliableDeliveryPlan` operation for `miniquake.protocol_serverdata` (reliable delivery plan).
/// @param overflowed The overflowed input consumed by `reliableDeliveryPlan`.
/// @param messageSize Size of the requested data or resource.
/// @param dropAsap The drop asap input consumed by `reliableDeliveryPlan`.
/// @param canSend The can send input consumed by `reliableDeliveryPlan`.
function reliableDeliveryPlan(overflowed, messageSize, dropAsap, canSend)
  if overflowed then return RELIABLE_DROP_OVERFLOW end if
  if messageSize <= 0 and not dropAsap then return RELIABLE_NONE end if
  if not canSend then return RELIABLE_WAIT end if
  if dropAsap then return RELIABLE_DROP_ASAP end if
  return RELIABLE_SEND
end function
