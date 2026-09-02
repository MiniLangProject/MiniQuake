/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Frozen source-guided QuakeC 1.09 compatibility contract.
*/
package miniquake.quakec.contract

import miniquake.constants as c
import miniquake.quakec.opcodes as op
import miniquake.quakec.vm as vm
import miniquake.quakec.builtins as builtins

/// Defines the status value used by `miniquake.quakec.contract`.
const STATUS = "quakec_109_frozen_v1"
/// Defines the expected version value used by `miniquake.quakec.contract`.
const EXPECTED_VERSION = 6
/// Defines the expected header crc value used by `miniquake.quakec.contract`.
const EXPECTED_HEADER_CRC = 5927
/// Defines the expected opcode count value used by `miniquake.quakec.contract`.
const EXPECTED_OPCODE_COUNT = 66
/// Defines the expected builtin count value used by `miniquake.quakec.contract`.
const EXPECTED_BUILTIN_COUNT = 79
/// Defines the expected fixme count value used by `miniquake.quakec.contract`.
const EXPECTED_FIXME_COUNT = 14
/// Defines the expected stack depth value used by `miniquake.quakec.contract`.
const EXPECTED_STACK_DEPTH = 32
/// Defines the expected localstack size value used by `miniquake.quakec.contract`.
const EXPECTED_LOCALSTACK_SIZE = 2048
/// Defines the fnv offset value used by `miniquake.quakec.contract`.
const FNV_OFFSET = 2166136261
/// Defines the fnv prime value used by `miniquake.quakec.contract`.
const FNV_PRIME = 16777619

/// Returns whether `miniquake.quakec.contract` has h byte.
/// @param hash The hash input consumed by `hashByte`.
/// @param value Value consumed by `hashByte`.
function inline hashByte(hash, value)
  return ((hash ^ (value & 255)) * FNV_PRIME) & 0xffffffff
end function

/// Fold word into the deterministic rolling hash.
/// @param hash The hash input consumed by `hashWord`.
/// @param value Value consumed by `hashWord`.
function hashWord(hash, value)
  result = hash
  shift = 0
  while shift < 32
    result = hashByte(result, (value >> shift) & 255)
    shift = shift + 8
  end while
  return result
end function

/// Fold text into the deterministic rolling hash.
/// @param hash The hash input consumed by `hashText`.
/// @param text Text to parse or process.
function hashText(hash, text)
  result = hash
  data = bytes(text)
  index = 0
  while index < len(data)
    result = hashByte(result, data[index])
    index = index + 1
  end while
  return hashByte(result, 0)
end function

/// Implements the `contractFingerprint` operation for `miniquake.quakec.contract` (contract fingerprint).
function contractFingerprint()
  hash = FNV_OFFSET
  hash = hashWord(hash, EXPECTED_VERSION)
  hash = hashWord(hash, EXPECTED_HEADER_CRC)
  hash = hashWord(hash, EXPECTED_OPCODE_COUNT)
  hash = hashWord(hash, EXPECTED_BUILTIN_COUNT)
  hash = hashWord(hash, EXPECTED_FIXME_COUNT)
  hash = hashWord(hash, EXPECTED_STACK_DEPTH)
  hash = hashWord(hash, EXPECTED_LOCALSTACK_SIZE)
  hash = hashWord(hash, builtins.builtinContractFingerprint())
  hash = hashText(hash, STATUS)
  return hash
end function

/// Validates d globals for `miniquake.quakec.contract`.
function requiredGlobals()
  return [
    "self", "other", "world", "time", "frametime", "force_retouch", "mapname", "deathmatch", "coop", "teamplay",
    "serverflags", "total_secrets", "total_monsters", "found_secrets", "killed_monsters", "parm1", "parm2", "parm3",
    "parm4", "parm5", "parm6", "parm7", "parm8", "parm9", "parm10", "parm11", "parm12", "parm13", "parm14",
    "parm15", "parm16", "v_forward", "v_up", "v_right", "trace_allsolid", "trace_startsolid", "trace_fraction",
    "trace_endpos", "trace_plane_normal", "trace_plane_dist", "trace_ent", "trace_inopen", "trace_inwater", "msg_entity",
    "main", "StartFrame", "PlayerPreThink", "PlayerPostThink", "ClientKill", "ClientConnect", "PutClientInServer",
    "ClientDisconnect", "SetNewParms", "SetChangeParms",
  ]
end function

/// Validates d fields for `miniquake.quakec.contract`.
function requiredFields()
  return [
    "modelindex", "absmin", "absmax", "ltime", "movetype", "solid", "origin", "oldorigin", "velocity", "angles",
    "avelocity", "punchangle", "classname", "model", "frame", "skin", "effects", "mins", "maxs", "size", "touch",
    "use", "think", "blocked", "nextthink", "groundentity", "health", "frags", "weapon", "weaponmodel", "weaponframe",
    "currentammo", "ammo_shells", "ammo_nails", "ammo_rockets", "ammo_cells", "items", "takedamage", "chain", "deadflag",
    "view_ofs", "button0", "button1", "button2", "impulse", "fixangle", "v_angle", "idealpitch", "netname", "enemy",
    "flags", "colormap", "team", "max_health", "teleport_time", "armortype", "armorvalue", "waterlevel", "watertype",
    "ideal_yaw", "yaw_speed", "aiment", "goalentity", "spawnflags", "target", "targetname", "dmg_take", "dmg_save",
    "dmg_inflictor", "owner", "movedir", "message", "sounds", "noise", "noise1", "noise2", "noise3",
  ]
end function

/// Validates d functions for `miniquake.quakec.contract`.
function requiredFunctions()
  return [
    "main", "StartFrame", "PlayerPreThink", "PlayerPostThink", "ClientKill", "ClientConnect", "PutClientInServer",
    "ClientDisconnect", "SetNewParms", "SetChangeParms", "worldspawn",
  ]
end function

/// Report whether definition.
/// @param definitions The definitions input consumed by `hasDefinition`.
/// @param name Stable name that identifies the requested object or option.
function hasDefinition(definitions, name)
  for each definition in definitions
    if definition.name == name then return true end if
  end for
  return false
end function

/// Report whether function.
/// @param program The program input consumed by `hasFunction`.
/// @param name Stable name that identifies the requested object or option.
function hasFunction(program, name)
  for each functionValue in program.functions
    if functionValue.name == name then return true end if
  end for
  return false
end function

/// Return builtin reference count derived from the active module state.
/// @param program The program input consumed by `builtinReferenceCount`.
function builtinReferenceCount(program)
  count = 0
  for each functionValue in program.functions
    if functionValue.firstStatement < 0 then count = count + 1 end if
  end for
  return count
end function

/// Implements the `maximumBuiltinReference` operation for `miniquake.quakec.contract` (maximum builtin reference).
/// @param program The program input consumed by `maximumBuiltinReference`.
function maximumBuiltinReference(program)
  maximum = 0
  for each functionValue in program.functions
    if functionValue.firstStatement < 0 then
      index = -functionValue.firstStatement
      if index > maximum then maximum = index end if
    end if
  end for
  return maximum
end function

/// Implements the `validate` operation for `miniquake.quakec.contract` (validate).
/// @param program The program input consumed by `validate`.
function validate(program)
  if program.version != EXPECTED_VERSION then return error(3380, "QuakeC contract: expected version 6") end if
  if program.crc != EXPECTED_HEADER_CRC then return error(3381, "QuakeC contract: expected system CRC 5927") end if
  if op.OP_BITOR + 1 != EXPECTED_OPCODE_COUNT then return error(3382, "QuakeC contract: opcode table mismatch") end if
  if builtins.BUILTIN_COUNT != EXPECTED_BUILTIN_COUNT then return error(3383, "QuakeC contract: builtin table mismatch") end if
  if vm.MAX_STACK_DEPTH != EXPECTED_STACK_DEPTH or vm.LOCALSTACK_SIZE != EXPECTED_LOCALSTACK_SIZE then
    return error(3384, "QuakeC contract: VM stack limits mismatch")
  end if
  if len(builtins.fixmeSlots()) != EXPECTED_FIXME_COUNT then return error(3385, "QuakeC contract: PF_Fixme slot mismatch") end if
  if program.entityFields < 1 then return error(3386, "QuakeC contract: invalid entity field count") end if

  for each functionValue in program.functions
    if functionValue.firstStatement < 0 then
      builtinIndex = -functionValue.firstStatement
      if builtinIndex < 1 or builtinIndex >= EXPECTED_BUILTIN_COUNT then
        return error(3387, "QuakeC contract: builtin reference outside stock table: " + builtinIndex)
      end if
    end if
  end for

  for each name in requiredGlobals()
    if not hasDefinition(program.globalDefs, name) then return error(3388, "QuakeC contract: missing global " + name) end if
  end for
  for each name in requiredFields()
    if not hasDefinition(program.fieldDefs, name) then return error(3389, "QuakeC contract: missing field " + name) end if
  end for
  for each name in requiredFunctions()
    if not hasFunction(program, name) then return error(3390, "QuakeC contract: missing function " + name) end if
  end for
  return true
end function

/// Implements the `programFingerprint` operation for `miniquake.quakec.contract` (program fingerprint).
/// @param program The program input consumed by `programFingerprint`.
function programFingerprint(program)
  hash = FNV_OFFSET
  hash = hashWord(hash, program.version)
  hash = hashWord(hash, program.crc)
  hash = hashWord(hash, len(program.statements))
  hash = hashWord(hash, len(program.globalDefs))
  hash = hashWord(hash, len(program.fieldDefs))
  hash = hashWord(hash, len(program.functions))
  hash = hashWord(hash, len(program.globals))
  hash = hashWord(hash, program.entityFields)
  for each definition in program.globalDefs
    hash = hashWord(hash, definition.type)
    hash = hashWord(hash, definition.offset)
    hash = hashText(hash, definition.name)
  end for
  for each definition in program.fieldDefs
    hash = hashWord(hash, definition.type)
    hash = hashWord(hash, definition.offset)
    hash = hashText(hash, definition.name)
  end for
  for each functionValue in program.functions
    hash = hashWord(hash, functionValue.firstStatement)
    hash = hashWord(hash, functionValue.parmStart)
    hash = hashWord(hash, functionValue.locals)
    hash = hashText(hash, functionValue.name)
    hash = hashText(hash, functionValue.file)
  end for
  return hash
end function

/// Return summary derived from the active module state.
/// @param program The program input consumed by `summary`.
function summary(program)
  return [
    STATUS,
    contractFingerprint(),
    programFingerprint(program),
    len(program.statements),
    len(program.functions),
    len(program.globalDefs),
    len(program.fieldDefs),
    len(program.globals),
    program.entityFields,
    builtinReferenceCount(program),
    maximumBuiltinReference(program),
  ]
end function
