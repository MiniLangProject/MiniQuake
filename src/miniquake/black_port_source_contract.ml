/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.black_port_source_contract.
*/
package miniquake.black_port_source_contract

import miniquake.source_profile_contract as profile
import miniquake.black_port_corpus as corpus

const STATUS = "black_port_source_109_frozen_v1"
const FINGERPRINT = 0x309b0737
const SCHEMA_VERSION = 1
const SOURCE_UNIT_COUNT = 53
const HEADER_UNIT_COUNT = 10
const TARGET_FUNCTION_COUNT = 1094
const UNCLASSIFIED_FUNCTION_COUNT = 0
const CORPUS_SCENARIO_COUNT = 4
const CORPUS_FRAMES_PER_SCENARIO = 64

// Return contract vector derived from the active module state.
function contractVector()
  return [
    SCHEMA_VERSION,
    SOURCE_UNIT_COUNT,
    HEADER_UNIT_COUNT,
    TARGET_FUNCTION_COUNT,
    profile.EXACT_NAME,
    profile.CONTEXT_ADAPTER,
    profile.TECHNICAL_EQUIVALENT,
    UNCLASSIFIED_FUNCTION_COUNT,
    CORPUS_SCENARIO_COUNT,
    CORPUS_FRAMES_PER_SCENARIO,
  ]
end function

// Validate the requested value and report any incompatibility.
function validate()
  if STATUS != "black_port_source_109_frozen_v1" then return false end if
  if FINGERPRINT != 0x309b0737 then return false end if
  if not profile.validate() then return false end if
  if not corpus.validate() then return false end if
  if TARGET_FUNCTION_COUNT != profile.TARGET_DEFINITIONS then return false end if
  if UNCLASSIFIED_FUNCTION_COUNT != profile.MISSING then return false end if
  if CORPUS_SCENARIO_COUNT != corpus.SCENARIO_COUNT then return false end if
  return true
end function
