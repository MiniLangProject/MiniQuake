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

/// Defines the corpus schema value used by `miniquake.render_evidence_corpus`.
const CORPUS_SCHEMA = 1
/// Defines the capture width value used by `miniquake.render_evidence_corpus`.
const CAPTURE_WIDTH = 640
/// Defines the capture height value used by `miniquake.render_evidence_corpus`.
const CAPTURE_HEIGHT = 480
/// Defines the original ssim milli value used by `miniquake.render_evidence_corpus`.
const ORIGINAL_SSIM_MILLI = 950
/// Defines the exact pair required value used by `miniquake.render_evidence_corpus`.
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

/// Implements the `scenario` operation for `miniquake.render_evidence_corpus` (scenario).
/// @param index Zero-based index of the requested entry.
function scenario(index)
  values = scenarios()
  if index < 0 or index >= len(values) then return error(5300, "render evidence scenario index is outside the corpus") end if
  return values[index]
end function

/// Return name derived from the active module state.
/// @param index Zero-based index of the requested entry.
function name(index)
  return scenario(index)[0]
end function

/// Return map name derived from the active module state.
/// @param index Zero-based index of the requested entry.
function mapName(index)
  return scenario(index)[1]
end function

/// Implements the `frame` operation for `miniquake.render_evidence_corpus` (frame).
/// @param index Zero-based index of the requested entry.
function frame(index)
  return scenario(index)[2]
end function

/// Implements the `miniPrefix` operation for `miniquake.render_evidence_corpus` (mini prefix).
/// @param root The root input consumed by `miniPrefix`.
/// @param index Zero-based index of the requested entry.
/// @param suffix The suffix input consumed by `miniPrefix`.
function miniPrefix(root, index, suffix)
  return root + "/" + name(index) + "-" + suffix
end function

/// Return original file name derived from the active module state.
/// @param index Zero-based index of the requested entry.
function originalFileName(index)
  return name(index) + ".tga"
end function

/// Implements the `exactPair` operation for `miniquake.render_evidence_corpus` (exact pair).
/// @param hashA The hash a input consumed by `exactPair`.
/// @param hashB The hash b input consumed by `exactPair`.
/// @param sampleA The sample a input consumed by `exactPair`.
/// @param sampleB The sample b input consumed by `exactPair`.
function exactPair(hashA, hashB, sampleA, sampleB)
  return hashA == hashB and sampleA == sampleB
end function

/// Implements the `ssimAccepted` operation for `miniquake.render_evidence_corpus` (ssim accepted).
/// @param value Value consumed by `ssimAccepted`.
function ssimAccepted(value)
  return value * 1000.0 >= ORIGINAL_SSIM_MILLI
end function

/// Implements the `minimum` operation for `miniquake.render_evidence_corpus` (minimum).
/// @param values The values input consumed by `minimum`.
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

/// Implements the `average` operation for `miniquake.render_evidence_corpus` (average).
/// @param values The values input consumed by `average`.
function average(values)
  if len(values) == 0 then return error(5302, "render evidence corpus has no values") end if
  total = 0.0
  for each value in values
    total = total + value
  end for
  return total / len(values)
end function

/// Implements the `contractVector` operation for `miniquake.render_evidence_corpus` (contract vector).
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
