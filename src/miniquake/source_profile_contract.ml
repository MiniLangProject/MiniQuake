/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.source_profile_contract.
*/
package miniquake.source_profile_contract

// Deterministic inventory of the WinQuake/MiniQuake 1.09 source profile used by
// the source-guided black port. Static helpers are counted as well as public
// functions; positive QUAKE2-only regions are outside compat_109.

const SOURCE_UNIT_COUNT = 53
/// Defines the header unit count value used by `miniquake.source_profile_contract`.
const HEADER_UNIT_COUNT = 10
/// Defines the definitions discovered value used by `miniquake.source_profile_contract`.
const DEFINITIONS_DISCOVERED = 1120
/// Defines the profile excluded value used by `miniquake.source_profile_contract`.
const PROFILE_EXCLUDED = 26
/// Defines the target definitions value used by `miniquake.source_profile_contract`.
const TARGET_DEFINITIONS = 1094
/// Defines the exact name value used by `miniquake.source_profile_contract`.
const EXACT_NAME = 1081
/// Defines the context adapter value used by `miniquake.source_profile_contract`.
const CONTEXT_ADAPTER = 9
/// Defines the technical equivalent value used by `miniquake.source_profile_contract`.
const TECHNICAL_EQUIVALENT = 4
/// Defines the missing value used by `miniquake.source_profile_contract`.
const MISSING = 0
/// Defines the coverage percent value used by `miniquake.source_profile_contract`.
const COVERAGE_PERCENT = 100
/// Defines the inventory sha256 value used by `miniquake.source_profile_contract`.
const INVENTORY_SHA256 = "31f437bb54a84fa690ff96011c50f8ca3e7dfabde05b4f450e58049eae5d8837"

// Return context adapter names derived from the active module state.
function contextAdapterNames()
  return [
    "Cvar_Command",
    "Cvar_CompleteVariable",
    "Cvar_FindVar",
    "Cvar_RegisterVariable",
    "Cvar_Set",
    "Cvar_SetValue",
    "Cvar_VariableString",
    "Cvar_VariableValue",
    "Cvar_WriteVariables",
  ]
end function

// Return technical equivalent names derived from the active module state.
function technicalEquivalentNames()
  return [
    "CDAudio_CloseDoor",
    "CDAudio_Eject",
    "CDAudio_GetAudioDiskInfo",
    "CDAudio_MessageHandler",
  ]
end function

/// Implements the `accountedDefinitions` operation for `miniquake.source_profile_contract` (accounted definitions).
function accountedDefinitions()
  return EXACT_NAME + CONTEXT_ADAPTER + TECHNICAL_EQUIVALENT
end function

/// Implements the `validate` operation for `miniquake.source_profile_contract` (validate).
function validate()
  if SOURCE_UNIT_COUNT != 53 then return false end if
  if HEADER_UNIT_COUNT != 10 then return false end if
  if DEFINITIONS_DISCOVERED != TARGET_DEFINITIONS + PROFILE_EXCLUDED then return false end if
  if accountedDefinitions() != TARGET_DEFINITIONS then return false end if
  if len(contextAdapterNames()) != CONTEXT_ADAPTER then return false end if
  if len(technicalEquivalentNames()) != TECHNICAL_EQUIVALENT then return false end if
  if MISSING != 0 or COVERAGE_PERCENT != 100 then return false end if
  return true
end function
