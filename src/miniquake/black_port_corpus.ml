/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.black_port_corpus.
*/
package miniquake.black_port_corpus

/// Defines the schema version value used by `miniquake.black_port_corpus`.
const SCHEMA_VERSION = 1
/// Defines the frames per scenario value used by `miniquake.black_port_corpus`.
const FRAMES_PER_SCENARIO = 64
/// Defines the scenario count value used by `miniquake.black_port_corpus`.
const SCENARIO_COUNT = 4

/// Implements the `scenarios` operation for `miniquake.black_port_corpus` (scenarios).
function scenarios()
  return [
    ["start-064", "start", 64],
    ["e1m1-064", "e1m1", 64],
    ["e1m2-064", "e1m2", 64],
    ["e1m3-064", "e1m3", 64],
  ]
end function

/// Implements the `scenarioAt` operation for `miniquake.black_port_corpus` (scenario at).
/// @param index Zero-based index of the requested entry.
function scenarioAt(index)
  values = scenarios()
  if index < 0 or index >= len(values) then return error(8400, "black-port corpus scenario index out of range") end if
  return values[index]
end function

/// Implements the `validate` operation for `miniquake.black_port_corpus` (validate).
function validate()
  values = scenarios()
  if SCHEMA_VERSION != 1 or len(values) != SCENARIO_COUNT then return false end if
  index = 0
  while index < len(values)
    item = values[index]
    if len(item) != 3 then return false end if
    if item[2] != FRAMES_PER_SCENARIO then return false end if
    index = index + 1
  end while
  return true
end function
