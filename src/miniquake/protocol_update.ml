/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.protocol_update.
*/
package miniquake.protocol_update

import miniquake.constants as c
import miniquake.message as msg

/// Implements the `absolute` operation for `miniquake.protocol_update` (absolute).
/// @param value Value consumed by `absolute`.
function absolute(value)
  if value < 0.0 then return -value end if
  return value
end function

/// Exact Protocol-15 bit selection from WinQuake sv_main.c:
/// SV_WriteEntitiesToClient.  The entity-state baseline includes effects even
/// though svc_spawnbaseline does not transmit it; SV_CreateBaseline leaves that
/// field at zero in the original zero-initialized edict baseline.
/// @param entityNumber The entity number input consumed by `computeBits`.
/// @param baseline The baseline input consumed by `computeBits`.
/// @param modelIndex Zero-based index of the requested entry.
/// @param frame The frame input consumed by `computeBits`.
/// @param colormap The colormap input consumed by `computeBits`.
/// @param skin The skin input consumed by `computeBits`.
/// @param effects The effects input consumed by `computeBits`.
/// @param origin World-space origin of the operation.
/// @param angles Orientation angles used by the operation.
/// @param moveType The move type input consumed by `computeBits`.
function computeBits(
  entityNumber,
  baseline,
  modelIndex,
  frame,
  colormap,
  skin,
  effects,
  origin,
  angles,
  moveType,
)
  bits = 0
  if absolute(origin.x - baseline.origin.x) > 0.1 then bits = bits | c.U_ORIGIN1 end if
  if absolute(origin.y - baseline.origin.y) > 0.1 then bits = bits | c.U_ORIGIN2 end if
  if absolute(origin.z - baseline.origin.z) > 0.1 then bits = bits | c.U_ORIGIN3 end if
  if angles.x != baseline.angles.x then bits = bits | c.U_ANGLE1 end if
  if angles.y != baseline.angles.y then bits = bits | c.U_ANGLE2 end if
  if angles.z != baseline.angles.z then bits = bits | c.U_ANGLE3 end if
  if moveType == c.MOVETYPE_STEP then bits = bits | c.U_NOLERP end if
  if baseline.colormap != colormap then bits = bits | c.U_COLORMAP end if
  if baseline.skin != skin then bits = bits | c.U_SKIN end if
  if baseline.frame != frame then bits = bits | c.U_FRAME end if
  if baseline.effects != effects then bits = bits | c.U_EFFECTS end if
  if baseline.modelIndex != modelIndex then bits = bits | c.U_MODEL end if
  if entityNumber >= 256 then bits = bits | c.U_LONGENTITY end if
  if bits >= 256 then bits = bits | c.U_MOREBITS end if
  return bits
end function

/// Exact byte count for one Protocol-15 fast entity update. The original
/// SV_WriteEntitiesToClient used a fixed 16-byte preflight even though the
/// theoretical long-entity maximum is 18 bytes. MiniQuake preserves the
/// original 16-byte scheduling gate and adds this exact memory-safety check.
/// @param bits The bits input consumed by `encodedSize`.
function encodedSize(bits)
  count = 1
  if (bits & c.U_MOREBITS) != 0 then count = count + 1 end if
  if (bits & c.U_LONGENTITY) != 0 then count = count + 2 else count = count + 1 end if
  if (bits & c.U_MODEL) != 0 then count = count + 1 end if
  if (bits & c.U_FRAME) != 0 then count = count + 1 end if
  if (bits & c.U_COLORMAP) != 0 then count = count + 1 end if
  if (bits & c.U_SKIN) != 0 then count = count + 1 end if
  if (bits & c.U_EFFECTS) != 0 then count = count + 1 end if
  if (bits & c.U_ORIGIN1) != 0 then count = count + 2 end if
  if (bits & c.U_ANGLE1) != 0 then count = count + 1 end if
  if (bits & c.U_ORIGIN2) != 0 then count = count + 2 end if
  if (bits & c.U_ANGLE2) != 0 then count = count + 1 end if
  if (bits & c.U_ORIGIN3) != 0 then count = count + 2 end if
  if (bits & c.U_ANGLE3) != 0 then count = count + 1 end if
  return count
end function

/// Report whether can write.
/// @param buffer The buffer input consumed by `canWrite`.
/// @param bits The bits input consumed by `canWrite`.
function canWrite(buffer, bits)
  remaining = buffer.maxSize - buffer.curSize
  if remaining < 16 then return false end if
  return encodedSize(bits) <= remaining
end function

/// The stock server appends sv.datagram after fast entity updates. Under a
/// dense PVS that can discard the complete transient tail, including gunshot
/// puffs and explosions. Reserve the already-known tail while scheduling
/// entity deltas; the strict '< maxSize' append boundary still applies.
/// @param buffer The buffer input consumed by `canWriteWithReservedTail`.
/// @param bits The bits input consumed by `canWriteWithReservedTail`.
/// @param reservedBytes Byte data consumed by the operation.
function canWriteWithReservedTail(buffer, bits, reservedBytes)
  if reservedBytes <= 0 then return canWrite(buffer, bits) end if
  remaining = buffer.maxSize - buffer.curSize - reservedBytes
  if remaining < 16 then return false end if
  return encodedSize(bits) < remaining
end function

/// Encode and write fast update bits.
/// @param buffer The buffer input consumed by `writeFastUpdateBits`.
/// @param bits The bits input consumed by `writeFastUpdateBits`.
/// @param entityNumber The entity number input consumed by `writeFastUpdateBits`.
/// @param modelIndex Zero-based index of the requested entry.
/// @param frame The frame input consumed by `writeFastUpdateBits`.
/// @param colormap The colormap input consumed by `writeFastUpdateBits`.
/// @param skin The skin input consumed by `writeFastUpdateBits`.
/// @param effects The effects input consumed by `writeFastUpdateBits`.
/// @param origin World-space origin of the operation.
/// @param angles Orientation angles used by the operation.
function writeFastUpdateBits(
  buffer,
  bits,
  entityNumber,
  modelIndex,
  frame,
  colormap,
  skin,
  effects,
  origin,
  angles,
)
  msg.writeByte(buffer, (bits & 255) | c.U_SIGNAL)
  if (bits & c.U_MOREBITS) != 0 then msg.writeByte(buffer, (bits >> 8) & 255) end if
  if (bits & c.U_LONGENTITY) != 0 then
    msg.writeShort(buffer, entityNumber)
  else
    msg.writeByte(buffer, entityNumber)
  end if
  if (bits & c.U_MODEL) != 0 then msg.writeByte(buffer, modelIndex) end if
  if (bits & c.U_FRAME) != 0 then msg.writeByte(buffer, frame) end if
  if (bits & c.U_COLORMAP) != 0 then msg.writeByte(buffer, colormap) end if
  if (bits & c.U_SKIN) != 0 then msg.writeByte(buffer, skin) end if
  if (bits & c.U_EFFECTS) != 0 then msg.writeByte(buffer, effects) end if
  if (bits & c.U_ORIGIN1) != 0 then msg.writeCoord(buffer, origin.x) end if
  if (bits & c.U_ANGLE1) != 0 then msg.writeAngle(buffer, angles.x) end if
  if (bits & c.U_ORIGIN2) != 0 then msg.writeCoord(buffer, origin.y) end if
  if (bits & c.U_ANGLE2) != 0 then msg.writeAngle(buffer, angles.y) end if
  if (bits & c.U_ORIGIN3) != 0 then msg.writeCoord(buffer, origin.z) end if
  if (bits & c.U_ANGLE3) != 0 then msg.writeAngle(buffer, angles.z) end if
  return bits
end function

/// Encode and write fast update.
/// @param buffer The buffer input consumed by `writeFastUpdate`.
/// @param entityNumber The entity number input consumed by `writeFastUpdate`.
/// @param baseline The baseline input consumed by `writeFastUpdate`.
/// @param modelIndex Zero-based index of the requested entry.
/// @param frame The frame input consumed by `writeFastUpdate`.
/// @param colormap The colormap input consumed by `writeFastUpdate`.
/// @param skin The skin input consumed by `writeFastUpdate`.
/// @param effects The effects input consumed by `writeFastUpdate`.
/// @param origin World-space origin of the operation.
/// @param angles Orientation angles used by the operation.
/// @param moveType The move type input consumed by `writeFastUpdate`.
function writeFastUpdate(
  buffer,
  entityNumber,
  baseline,
  modelIndex,
  frame,
  colormap,
  skin,
  effects,
  origin,
  angles,
  moveType,
)
  bits = computeBits(
    entityNumber,
    baseline,
    modelIndex,
    frame,
    colormap,
    skin,
    effects,
    origin,
    angles,
    moveType,
  )
  return writeFastUpdateBits(
    buffer, bits, entityNumber, modelIndex, frame, colormap, skin, effects, origin, angles,
  )
end function
