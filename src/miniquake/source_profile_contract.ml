package miniquake.source_profile_contract

// Deterministic inventory of the WinQuake/MiniQuake 1.09 source profile used by
// the source-guided black port. Static helpers are counted as well as public
// functions; positive QUAKE2-only regions are outside compat_109.

const SOURCE_UNIT_COUNT = 53
const HEADER_UNIT_COUNT = 10
const DEFINITIONS_DISCOVERED = 1120
const PROFILE_EXCLUDED = 26
const TARGET_DEFINITIONS = 1094
const EXACT_NAME = 1081
const CONTEXT_ADAPTER = 9
const TECHNICAL_EQUIVALENT = 4
const MISSING = 0
const COVERAGE_PERCENT = 100
const INVENTORY_SHA256 = "31f437bb54a84fa690ff96011c50f8ca3e7dfabde05b4f450e58049eae5d8837"

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

function technicalEquivalentNames()
  return [
    "CDAudio_CloseDoor",
    "CDAudio_Eject",
    "CDAudio_GetAudioDiskInfo",
    "CDAudio_MessageHandler",
  ]
end function

function accountedDefinitions()
  return EXACT_NAME + CONTEXT_ADAPTER + TECHNICAL_EQUIVALENT
end function

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
