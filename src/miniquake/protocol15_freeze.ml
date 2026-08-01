/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Protocol-15 closure metadata.  BP-019 freezes the observable WinQuake 1.09
wire contract after the source-guided BP-010..BP-018 audit.  This module does
not replace the production writers/parsers; it gives tests and diagnostics one
canonical catalog and fingerprint for the constants that define the protocol.
*/

package miniquake.protocol15_freeze

import miniquake.constants as c

const STATUS = "protocol15_frozen_v1"
const PROTOCOL_VERSION = 15
const SVC_VALID_COUNT = 33
const CLC_VALID_COUNT = 4
const FAST_UPDATE_MASK = 0x7fff
const CLIENT_DATA_MASK = 0x7eff
const SOUND_MASK = 0x0007
const TEMP_ENTITY_COUNT = 14
const FINGERPRINT = 0x0cf1e12a

function validSvcCommands()
  return [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
    32, 33, 34,
  ]
end function

function validClcCommands()
  return [1, 2, 3, 4]
end function

function fastUpdateBits()
  return [
    c.U_MOREBITS, c.U_ORIGIN1, c.U_ORIGIN2, c.U_ORIGIN3,
    c.U_ANGLE2, c.U_NOLERP, c.U_FRAME, c.U_SIGNAL,
    c.U_ANGLE1, c.U_ANGLE3, c.U_MODEL, c.U_COLORMAP,
    c.U_SKIN, c.U_EFFECTS, c.U_LONGENTITY,
  ]
end function

function clientDataBits()
  return [
    c.SU_VIEWHEIGHT, c.SU_IDEALPITCH,
    c.SU_PUNCH1, c.SU_PUNCH2, c.SU_PUNCH3,
    c.SU_VELOCITY1, c.SU_VELOCITY2, c.SU_VELOCITY3,
    c.SU_ITEMS, c.SU_ONGROUND, c.SU_INWATER,
    c.SU_WEAPONFRAME, c.SU_ARMOR, c.SU_WEAPON,
  ]
end function

function soundBits()
  return [c.SND_VOLUME, c.SND_ATTENUATION, c.SND_LOOPING]
end function

function temporaryEntityTypes()
  return [
    c.TE_SPIKE, c.TE_SUPERSPIKE, c.TE_GUNSHOT, c.TE_EXPLOSION,
    c.TE_TAREXPLOSION, c.TE_LIGHTNING1, c.TE_LIGHTNING2,
    c.TE_WIZSPIKE, c.TE_KNIGHTSPIKE, c.TE_LIGHTNING3,
    c.TE_LAVASPLASH, c.TE_TELEPORT, c.TE_EXPLOSION2, c.TE_BEAM,
  ]
end function

function contains(values, wanted)
  for each value in values
    if value == wanted then return true end if
  end for
  return false
end function

function isValidSvc(command)
  return contains(validSvcCommands(), command)
end function

function isReservedSvc(command)
  return command == c.SVC_BAD or command == c.SVC_SPAWNBINARY
end function

function isValidClc(command)
  return contains(validClcCommands(), command)
end function

function combineMask(values)
  result = 0
  for each value in values
    result = result | value
  end for
  return result
end function

function fingerprintValue(current, value)
  return ((current ^ (value & 0xffffffff)) * 16777619) & 0xffffffff
end function

function fingerprintValues(current, values)
  result = current
  for each value in values
    result = fingerprintValue(result, value)
  end for
  return result
end function

function protocolFingerprint()
  result = 2166136261
  result = fingerprintValue(result, c.PROTOCOL_VERSION)
  result = fingerprintValue(result, 0x535643)
  result = fingerprintValues(result, validSvcCommands())
  result = fingerprintValue(result, 0x434c43)
  result = fingerprintValues(result, validClcCommands())
  result = fingerprintValue(result, 0x55424954)
  result = fingerprintValues(result, fastUpdateBits())
  result = fingerprintValue(result, 0x53554249)
  result = fingerprintValues(result, clientDataBits())
  result = fingerprintValue(result, 0x534e44)
  result = fingerprintValues(result, soundBits())
  result = fingerprintValue(result, 0x5445)
  result = fingerprintValues(result, temporaryEntityTypes())
  return result
end function

function coverageSummary()
  return [
    c.PROTOCOL_VERSION,
    len(validSvcCommands()),
    len(validClcCommands()),
    combineMask(fastUpdateBits()),
    combineMask(clientDataBits()),
    combineMask(soundBits()),
    len(temporaryEntityTypes()),
    protocolFingerprint(),
  ]
end function
