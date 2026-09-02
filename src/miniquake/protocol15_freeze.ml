/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Protocol-15 closure metadata.  BP-019 freezes the observable WinQuake 1.09
wire contract after the source-guided BP-010..BP-018 audit.  This module does
not replace the production writers/parsers; it gives tests and diagnostics one
canonical catalog and fingerprint for the constants that define the protocol.
*/
package miniquake.protocol15_freeze

import miniquake.constants as c

/// Defines the status value used by `miniquake.protocol15_freeze`.
const STATUS = "protocol15_frozen_v1"
/// Defines the protocol version value used by `miniquake.protocol15_freeze`.
const PROTOCOL_VERSION = 15
/// Defines the svc valid count value used by `miniquake.protocol15_freeze`.
const SVC_VALID_COUNT = 33
/// Defines the clc valid count value used by `miniquake.protocol15_freeze`.
const CLC_VALID_COUNT = 4
/// Defines the fast update mask value used by `miniquake.protocol15_freeze`.
const FAST_UPDATE_MASK = 0x7fff
/// Defines the client data mask value used by `miniquake.protocol15_freeze`.
const CLIENT_DATA_MASK = 0x7eff
/// Defines the sound mask value used by `miniquake.protocol15_freeze`.
const SOUND_MASK = 0x0007
/// Defines the temp entity count value used by `miniquake.protocol15_freeze`.
const TEMP_ENTITY_COUNT = 14
/// Defines the fingerprint value used by `miniquake.protocol15_freeze`.
const FINGERPRINT = 0x0cf1e12a

// Report whether valid svc commands.
function validSvcCommands()
  return [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
    32, 33, 34,
  ]
end function

// Report whether valid clc commands.
function inline validClcCommands()
  return [1, 2, 3, 4]
end function

// Return fast update bits derived from the active module state.
function fastUpdateBits()
  return [
    c.U_MOREBITS, c.U_ORIGIN1, c.U_ORIGIN2, c.U_ORIGIN3,
    c.U_ANGLE2, c.U_NOLERP, c.U_FRAME, c.U_SIGNAL,
    c.U_ANGLE1, c.U_ANGLE3, c.U_MODEL, c.U_COLORMAP,
    c.U_SKIN, c.U_EFFECTS, c.U_LONGENTITY,
  ]
end function

// Return client data bits derived from the active module state.
function clientDataBits()
  return [
    c.SU_VIEWHEIGHT, c.SU_IDEALPITCH,
    c.SU_PUNCH1, c.SU_PUNCH2, c.SU_PUNCH3,
    c.SU_VELOCITY1, c.SU_VELOCITY2, c.SU_VELOCITY3,
    c.SU_ITEMS, c.SU_ONGROUND, c.SU_INWATER,
    c.SU_WEAPONFRAME, c.SU_ARMOR, c.SU_WEAPON,
  ]
end function

// Return sound bits derived from the active module state.
function soundBits()
  return [c.SND_VOLUME, c.SND_ATTENUATION, c.SND_LOOPING]
end function

/// Implements the `temporaryEntityTypes` operation for `miniquake.protocol15_freeze` (temporary entity types).
function temporaryEntityTypes()
  return [
    c.TE_SPIKE, c.TE_SUPERSPIKE, c.TE_GUNSHOT, c.TE_EXPLOSION,
    c.TE_TAREXPLOSION, c.TE_LIGHTNING1, c.TE_LIGHTNING2,
    c.TE_WIZSPIKE, c.TE_KNIGHTSPIKE, c.TE_LIGHTNING3,
    c.TE_LAVASPLASH, c.TE_TELEPORT, c.TE_EXPLOSION2, c.TE_BEAM,
  ]
end function

/// Implements the `contains` operation for `miniquake.protocol15_freeze` (contains).
/// @param values The values input consumed by `contains`.
/// @param wanted The wanted input consumed by `contains`.
function contains(values, wanted)
  for each value in values
    if value == wanted then return true end if
  end for
  return false
end function

/// Report whether is valid svc.
/// @param command Console or protocol command to execute.
function isValidSvc(command)
  return contains(validSvcCommands(), command)
end function

/// Report whether is reserved svc.
/// @param command Console or protocol command to execute.
function isReservedSvc(command)
  return command == c.SVC_BAD or command == c.SVC_SPAWNBINARY
end function

/// Report whether is valid clc.
/// @param command Console or protocol command to execute.
function isValidClc(command)
  return contains(validClcCommands(), command)
end function

/// Implements the `combineMask` operation for `miniquake.protocol15_freeze` (combine mask).
/// @param values The values input consumed by `combineMask`.
function combineMask(values)
  result = 0
  for each value in values
    result = result | value
  end for
  return result
end function

/// Return fingerprint value derived from the active module state.
/// @param current The current input consumed by `fingerprintValue`.
/// @param value Value consumed by `fingerprintValue`.
function inline fingerprintValue(current, value)
  return ((current ^ (value & 0xffffffff)) * 16777619) & 0xffffffff
end function

/// Return fingerprint values derived from the active module state.
/// @param current The current input consumed by `fingerprintValues`.
/// @param values The values input consumed by `fingerprintValues`.
function fingerprintValues(current, values)
  result = current
  for each value in values
    result = fingerprintValue(result, value)
  end for
  return result
end function

/// Implements the `protocolFingerprint` operation for `miniquake.protocol15_freeze` (protocol fingerprint).
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

// Return coverage summary derived from the active module state.
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
