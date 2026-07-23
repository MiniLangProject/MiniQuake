package miniquake.temp_entities

import miniquake.types as t
import miniquake.constants as c
import miniquake.message as msg

function readPosition(reader)
  return t.Vec3(msg.readCoord(reader), msg.readCoord(reader), msg.readCoord(reader))
end function

// Mirrors CL_ParseTEnt's wire consumption.  Keeping this in the protocol layer
// is important: treating svc_temp_entity as a one-byte payload desynchronizes
// every command that follows it in the same server message.
function parseType(reader, type)
  origin = t.Vec3(0.0, 0.0, 0.0)
  endPosition = t.Vec3(0.0, 0.0, 0.0)
  entity = 0

  if type == c.TE_LIGHTNING1 or type == c.TE_LIGHTNING2 or type == c.TE_LIGHTNING3 or type == c.TE_BEAM then
    entity = msg.readShort(reader)
    origin = readPosition(reader)
    endPosition = readPosition(reader)
  else if type == c.TE_SPIKE or type == c.TE_SUPERSPIKE or type == c.TE_GUNSHOT or type == c.TE_EXPLOSION or type == c.TE_TAREXPLOSION or type == c.TE_WIZSPIKE or type == c.TE_KNIGHTSPIKE or type == c.TE_LAVASPLASH or type == c.TE_TELEPORT then
    origin = readPosition(reader)
  else if type == c.TE_EXPLOSION2 then
    origin = readPosition(reader)
    colorStart = msg.readByte(reader)
    colorLength = msg.readByte(reader)
    entity = (colorStart << 8) | colorLength
  else
    return error(2360, "CL_ParseTEnt: bad type " + type)
  end if

  return t.TemporaryEntity(type, origin, endPosition, entity)
end function

function parse(reader)
  return parseType(reader, msg.readByte(reader))
end function
