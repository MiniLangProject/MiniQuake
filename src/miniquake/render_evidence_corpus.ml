/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Deterministic render-evidence corpus shared by BP-053 runtime tests and the
optional Original-MiniQuake comparison gate.  Scenario records are plain arrays
so the command-line runner and MiniLang fixtures can consume the same stable
layout without introducing another runtime object type.
*/
package miniquake.render_evidence_corpus

const CORPUS_SCHEMA = 1
const CAPTURE_WIDTH = 640
const CAPTURE_HEIGHT = 480
const ORIGINAL_SSIM_MILLI = 950
const EXACT_PAIR_REQUIRED = 1

// [name, map, frame]
function scenarios()
  return [
    ["start-064", "start", 64],
    ["start-128", "start", 128],
    ["e1m1-128", "e1m1", 128],
  ]
end function

// Return count derived from the active module state.
function count()
  return len(scenarios())
end function

// Provide scenario behavior for the active subsystem.
function scenario(index)
  values = scenarios()
  if index < 0 or index >= len(values) then return error(5300, "render evidence scenario index is outside the corpus") end if
  return values[index]
end function

// Return name derived from the active module state.
function name(index)
  return scenario(index)[0]
end function

// Return map name derived from the active module state.
function mapName(index)
  return scenario(index)[1]
end function

// Advance the requested value by one processing step.
function frame(index)
  return scenario(index)[2]
end function

// Provide mini prefix behavior for the active subsystem.
function miniPrefix(root, index, suffix)
  return root + "/" + name(index) + "-" + suffix
end function

// Return original file name derived from the active module state.
function originalFileName(index)
  return name(index) + ".tga"
end function

// Provide exact pair behavior for the active subsystem.
function exactPair(hashA, hashB, sampleA, sampleB)
  return hashA == hashB and sampleA == sampleB
end function

// Provide ssim accepted behavior for the active subsystem.
function ssimAccepted(value)
  return value * 1000.0 >= ORIGINAL_SSIM_MILLI
end function

// Provide minimum behavior for the active subsystem.
function minimum(values)
  if len(values) == 0 then return error(5301, "render evidence corpus has no SSIM values") end if
  result = values[0]
  index = 1
  while index < len(values)
    if values[index] < result then result = values[index] end if
    index = index + 1
  end while
  return result
end function

// Provide average behavior for the active subsystem.
function average(values)
  if len(values) == 0 then return error(5302, "render evidence corpus has no values") end if
  total = 0.0
  for each value in values
    total = total + value
  end for
  return total / len(values)
end function

// Return contract vector derived from the active module state.
function contractVector()
  return [
    CORPUS_SCHEMA,
    CAPTURE_WIDTH,
    CAPTURE_HEIGHT,
    count(),
    ORIGINAL_SSIM_MILLI,
    EXACT_PAIR_REQUIRED,
  ]
end function
