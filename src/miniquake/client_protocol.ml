package miniquake.client_protocol

import miniquake.types as t
import miniquake.constants as c
import miniquake.message as msg
import miniquake.temp_entities as temporary
import miniquake.array_util as arrays

function event(name, payload)
  return t.ProtocolEvent(name, payload)
end function

function readBaseline(reader)
  model = msg.readByte(reader)
  frame = msg.readByte(reader)
  colormap = msg.readByte(reader)
  skin = msg.readByte(reader)
  // Quake protocol 15 interleaves each coordinate with the matching angle.
  // Reading xyz followed by all three angles silently desynchronizes every
  // baseline whose values are not zero.
  origin = t.Vec3(0.0, 0.0, 0.0)
  angles = t.Vec3(0.0, 0.0, 0.0)
  origin.x = msg.readCoord(reader); angles.x = msg.readAngle(reader)
  origin.y = msg.readCoord(reader); angles.y = msg.readAngle(reader)
  origin.z = msg.readCoord(reader); angles.z = msg.readAngle(reader)
  return [model, frame, colormap, skin, origin, angles]
end function

function readFastUpdate(reader, lowBits)
  bits = lowBits
  if (bits & c.U_MOREBITS) != 0 then bits = bits | (msg.readByte(reader) << 8) end if
  entityNumber = msg.readByte(reader)
  if (bits & c.U_LONGENTITY) != 0 then entityNumber = msg.readUnsignedShort(reader) end if
  model = void
  frame = void
  colormap = void
  skin = void
  effects = void
  origin = [void, void, void]
  angles = [void, void, void]
  if (bits & c.U_MODEL) != 0 then model = msg.readByte(reader) end if
  if (bits & c.U_FRAME) != 0 then frame = msg.readByte(reader) end if
  if (bits & c.U_COLORMAP) != 0 then colormap = msg.readByte(reader) end if
  if (bits & c.U_SKIN) != 0 then skin = msg.readByte(reader) end if
  if (bits & c.U_EFFECTS) != 0 then effects = msg.readByte(reader) end if
  if (bits & c.U_ORIGIN1) != 0 then origin[0] = msg.readCoord(reader) end if
  if (bits & c.U_ANGLE1) != 0 then angles[0] = msg.readAngle(reader) end if
  if (bits & c.U_ORIGIN2) != 0 then origin[1] = msg.readCoord(reader) end if
  if (bits & c.U_ANGLE2) != 0 then angles[1] = msg.readAngle(reader) end if
  if (bits & c.U_ORIGIN3) != 0 then origin[2] = msg.readCoord(reader) end if
  if (bits & c.U_ANGLE3) != 0 then angles[2] = msg.readAngle(reader) end if
  return event("fast_update", [entityNumber, bits, model, frame, colormap, skin, effects, origin, angles])
end function

function readClientData(reader)
  bits = msg.readUnsignedShort(reader)
  viewHeight = void
  idealPitch = void
  punch = [void, void, void]
  velocity = [void, void, void]
  if (bits & c.SU_VIEWHEIGHT) != 0 then viewHeight = msg.readChar(reader) end if
  if (bits & c.SU_IDEALPITCH) != 0 then idealPitch = msg.readChar(reader) end if
  i = 0
  while i < 3
    if (bits & (c.SU_PUNCH1 << i)) != 0 then punch[i] = msg.readChar(reader) end if
    if (bits & (c.SU_VELOCITY1 << i)) != 0 then velocity[i] = msg.readChar(reader) * 16 end if
    i = i + 1
  end while
  items = msg.readLong(reader)
  weaponFrame = 0
  armor = 0
  weapon = 0
  if (bits & c.SU_WEAPONFRAME) != 0 then weaponFrame = msg.readByte(reader) end if
  if (bits & c.SU_ARMOR) != 0 then armor = msg.readByte(reader) end if
  if (bits & c.SU_WEAPON) != 0 then weapon = msg.readByte(reader) end if
  health = msg.readShort(reader)
  ammo = msg.readByte(reader)
  shells = msg.readByte(reader)
  nails = msg.readByte(reader)
  rockets = msg.readByte(reader)
  cells = msg.readByte(reader)
  activeWeapon = msg.readByte(reader)
  return event("svc_clientdata", [bits, viewHeight, idealPitch, punch, velocity, items, weaponFrame, armor, weapon, health, ammo, shells, nails, rockets, cells, activeWeapon])
end function

function readServerInfo(reader)
  version = msg.readLong(reader)
  maxClients = msg.readByte(reader)
  gameType = msg.readByte(reader)
  levelName = msg.readString(reader)

  // The serverinfo lists are bounded by the protocol constants.  Build them
  // into mutable backing arrays instead of repeatedly concatenating arrays;
  // this keeps signon parsing linear and avoids allocation-sensitive `+`
  // expressions around heap objects.
  modelBuilder = arrays.createArrayBuilder(c.MAX_MODELS)
  done = false
  while not done
    name = msg.readString(reader)
    if name == "" then
      done = true
    else
      arrays.pushArrayBuilder(modelBuilder, name)
    end if
  end while

  soundBuilder = arrays.createArrayBuilder(c.MAX_SOUNDS)
  done = false
  while not done
    name = msg.readString(reader)
    if name == "" then
      done = true
    else
      arrays.pushArrayBuilder(soundBuilder, name)
    end if
  end while

  models = arrays.finishArrayBuilder(modelBuilder)
  sounds = arrays.finishArrayBuilder(soundBuilder)
  return event("svc_serverinfo", [version, maxClients, gameType, levelName, models, sounds])
end function

function readSound(reader)
  fieldMask = msg.readByte(reader)
  volume = 255
  attenuation = 1.0
  if (fieldMask & 1) != 0 then volume = msg.readByte(reader) end if
  if (fieldMask & 2) != 0 then attenuation = msg.readByte(reader) / 64.0 end if
  channel = msg.readShort(reader)
  sound = msg.readByte(reader)
  position = t.Vec3(msg.readCoord(reader), msg.readCoord(reader), msg.readCoord(reader))
  return event("svc_sound", [fieldMask, volume, attenuation, channel, sound, position])
end function

function readParticle(reader)
  origin = t.Vec3(msg.readCoord(reader), msg.readCoord(reader), msg.readCoord(reader))
  direction = t.Vec3(msg.readChar(reader) * 0.0625, msg.readChar(reader) * 0.0625, msg.readChar(reader) * 0.0625)
  count = msg.readByte(reader)
  color = msg.readByte(reader)
  return event("svc_particle", [origin, direction, count, color])
end function

function readStaticSound(reader)
  origin = t.Vec3(msg.readCoord(reader), msg.readCoord(reader), msg.readCoord(reader))
  sound = msg.readByte(reader)
  volume = msg.readByte(reader)
  attenuation = msg.readByte(reader)
  return event("svc_spawnstaticsound", [origin, sound, volume, attenuation])
end function

function parse(data)
  reader = msg.beginReadingBytes(data)

  // A protocol event consumes at least one input byte, so len(data) is a
  // strict upper bound for the number of events in this message.  Keeping a
  // mutable builder removes the former `events = events + [event]` pattern.
  // Besides being O(n^2), that expression relies on generic `+` dispatch for
  // arrays containing heap-backed structs.  Real Quake frames contain dozens
  // of fast entity updates and exercise that path much more heavily than the
  // previous one-event synthetic test.  Direct indexed writes are both simpler
  // and deterministic here.
  events = arrays.createArrayBuilder(len(data))

  while msg.remaining(reader) > 0
    command = msg.readByte(reader)
    nextEvent = void

    if (command & c.U_SIGNAL) != 0 then
      nextEvent = readFastUpdate(reader, command & 127)
    else if command == c.SVC_BAD then
      return error(2100, "svc_bad")
    else if command == c.SVC_NOP then
      nextEvent = event("svc_nop", void)
    else if command == c.SVC_DISCONNECT then
      nextEvent = event("svc_disconnect", void)
    else if command == c.SVC_UPDATESTAT then
      nextEvent = event("svc_updatestat", [msg.readByte(reader), msg.readLong(reader)])
    else if command == c.SVC_VERSION then
      nextEvent = event("svc_version", msg.readLong(reader))
    else if command == c.SVC_SETVIEW then
      nextEvent = event("svc_setview", msg.readShort(reader))
    else if command == c.SVC_SOUND then
      nextEvent = readSound(reader)
    else if command == c.SVC_TIME then
      nextEvent = event("svc_time", msg.readFloat(reader))
    else if command == c.SVC_PRINT then
      nextEvent = event("svc_print", msg.readString(reader))
    else if command == c.SVC_STUFFTEXT then
      nextEvent = event("svc_stufftext", msg.readString(reader))
    else if command == c.SVC_SETANGLE then
      nextEvent = event("svc_setangle", t.Vec3(msg.readAngle(reader), msg.readAngle(reader), msg.readAngle(reader)))
    else if command == c.SVC_SERVERINFO then
      nextEvent = readServerInfo(reader)
    else if command == c.SVC_LIGHTSTYLE then
      nextEvent = event("svc_lightstyle", [msg.readByte(reader), msg.readString(reader)])
    else if command == c.SVC_UPDATENAME then
      nextEvent = event("svc_updatename", [msg.readByte(reader), msg.readString(reader)])
    else if command == c.SVC_UPDATEFRAGS then
      nextEvent = event("svc_updatefrags", [msg.readByte(reader), msg.readShort(reader)])
    else if command == c.SVC_CLIENTDATA then
      nextEvent = readClientData(reader)
    else if command == c.SVC_STOPSOUND then
      nextEvent = event("svc_stopsound", msg.readShort(reader))
    else if command == c.SVC_UPDATECOLORS then
      nextEvent = event("svc_updatecolors", [msg.readByte(reader), msg.readByte(reader)])
    else if command == c.SVC_PARTICLE then
      nextEvent = readParticle(reader)
    else if command == c.SVC_DAMAGE then
      save = msg.readByte(reader)
      take = msg.readByte(reader)
      origin = t.Vec3(msg.readCoord(reader), msg.readCoord(reader), msg.readCoord(reader))
      nextEvent = event("svc_damage", [save, take, origin])
    else if command == c.SVC_SPAWNSTATIC then
      nextEvent = event("svc_spawnstatic", readBaseline(reader))
    else if command == c.SVC_SPAWNBASELINE then
      entityNumber = msg.readShort(reader)
      nextEvent = event("svc_spawnbaseline", [entityNumber, readBaseline(reader)])
    else if command == c.SVC_TEMP_ENTITY then
      nextEvent = event("svc_temp_entity", temporary.parse(reader))
    else if command == c.SVC_SETPAUSE then
      nextEvent = event("svc_setpause", msg.readByte(reader))
    else if command == c.SVC_SIGNONNUM then
      nextEvent = event("svc_signonnum", msg.readByte(reader))
    else if command == c.SVC_CENTERPRINT then
      nextEvent = event("svc_centerprint", msg.readString(reader))
    else if command == c.SVC_KILLEDMONSTER then
      nextEvent = event("svc_killedmonster", void)
    else if command == c.SVC_FOUNDSECRET then
      nextEvent = event("svc_foundsecret", void)
    else if command == c.SVC_SPAWNSTATICSOUND then
      nextEvent = readStaticSound(reader)
    else if command == c.SVC_INTERMISSION then
      nextEvent = event("svc_intermission", void)
    else if command == c.SVC_FINALE then
      nextEvent = event("svc_finale", msg.readString(reader))
    else if command == c.SVC_CDTRACK then
      nextEvent = event("svc_cdtrack", [msg.readByte(reader), msg.readByte(reader)])
    else if command == c.SVC_SELLSCREEN then
      nextEvent = event("svc_sellscreen", void)
    else if command == c.SVC_CUTSCENE then
      nextEvent = event("svc_cutscene", msg.readString(reader))
    else
      return error(2101, "unknown server command " + command)
    end if

    if reader.badRead then
      return error(2102, "truncated server message after command " + command)
    end if

    eventType = typeof(nextEvent)
    if eventType != "struct" then
      return error(2103, "server command produced " + typeName(nextEvent) + " instead of a protocol event")
    end if
    arrays.pushArrayBuilder(events, nextEvent)
  end while

  return t.ProtocolResult(arrays.finishArrayBuilder(events), reader.readCount)
end function
