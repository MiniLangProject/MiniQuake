/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.black_port_source_contract.
*/
package miniquake.black_port_source_contract

import miniquake.source_profile_contract as profile
import miniquake.black_port_corpus as corpus

/// Defines the status value used by `miniquake.black_port_source_contract`.
const STATUS = "black_port_source_109_frozen_v1"
/// Defines the fingerprint value used by `miniquake.black_port_source_contract`.
const FINGERPRINT = 0x309b0737
/// Defines the schema version value used by `miniquake.black_port_source_contract`.
const SCHEMA_VERSION = 1
/// Defines the source unit count value used by `miniquake.black_port_source_contract`.
const SOURCE_UNIT_COUNT = 53
/// Defines the header unit count value used by `miniquake.black_port_source_contract`.
const HEADER_UNIT_COUNT = 10
/// Defines the target function count value used by `miniquake.black_port_source_contract`.
const TARGET_FUNCTION_COUNT = 1094
/// Defines the unclassified function count value used by `miniquake.black_port_source_contract`.
const UNCLASSIFIED_FUNCTION_COUNT = 0
/// Defines the corpus scenario count value used by `miniquake.black_port_source_contract`.
const CORPUS_SCENARIO_COUNT = 4
/// Defines the corpus frames per scenario value used by `miniquake.black_port_source_contract`.
const CORPUS_FRAMES_PER_SCENARIO = 64

/// Implements the `contractVector` operation for `miniquake.black_port_source_contract` (contract vector).
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

/// Implements the `validate` operation for `miniquake.black_port_source_contract` (validate).
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
