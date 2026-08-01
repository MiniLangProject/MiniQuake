package miniquake.protocol_update

import miniquake.constants as c
import miniquake.message as msg

function absolute(value)
  if value < 0.0 then return -value end if
  return value
end function

// Exact Protocol-15 bit selection from WinQuake sv_main.c:
// SV_WriteEntitiesToClient.  The entity-state baseline includes effects even
// though svc_spawnbaseline does not transmit it; SV_CreateBaseline leaves that
// field at zero in the original zero-initialized edict baseline.
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

// Exact byte count for one Protocol-15 fast entity update. The original
// SV_WriteEntitiesToClient used a fixed 16-byte preflight even though the
// theoretical long-entity maximum is 18 bytes. MiniQuake preserves the
// original 16-byte scheduling gate and adds this exact memory-safety check.
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

function canWrite(buffer, bits)
  remaining = buffer.maxSize - buffer.curSize
  if remaining < 16 then return false end if
  return encodedSize(bits) <= remaining
end function

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
