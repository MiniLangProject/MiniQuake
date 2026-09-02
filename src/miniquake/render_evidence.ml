/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Deterministic framebuffer evidence for the black-port workflow.  Captures are
requested explicitly, happen after the complete 3D/2D composition and before
the buffer swap, and never participate in ordinary interactive frames.
*/
package miniquake.render_evidence

import miniquake.build_info as buildInfo
import miniquake.compat_diagnostics as diagnostics
import miniquake.render.gl11 as gl
import miniquake.screen as screen
import miniquake.native as native
import std.fs as fs

/// Defines the evidence schema value used by `miniquake.render_evidence`.
const EVIDENCE_SCHEMA = 1
/// Defines the sample grid value used by `miniquake.render_evidence`.
const SAMPLE_GRID = 16
/// Defines the fnv offset value used by `miniquake.render_evidence`.
const FNV_OFFSET = 2166136261
/// Defines the fnv prime value used by `miniquake.render_evidence`.
const FNV_PRIME = 16777619

/// Tracks the module-level capture requested state owned by `miniquake.render_evidence`.
captureRequested = false
/// Tracks the module-level capture target frame state owned by `miniquake.render_evidence`.
captureTargetFrame = -1
/// Tracks the module-level capture prefix state owned by `miniquake.render_evidence`.
capturePrefix = ""
/// Tracks the module-level capture done state owned by `miniquake.render_evidence`.
captureDone = false
/// Tracks the module-level capture result state owned by `miniquake.render_evidence`.
captureResult = void

/// Returns whether `miniquake.render_evidence` has h byte.
/// @param state Mutable `miniquake.render_evidence` state used by `hashByte`.
/// @param value Value consumed by `hashByte`.
function inline hashByte(state, value)
  return (((state & 0xffffffff) ^ (value & 255)) * FNV_PRIME) & 0xffffffff
end function

/// Fold bytes into the deterministic rolling hash.
/// @param data Input data consumed by the operation.
function hashBytes(data)
  result = FNV_OFFSET
  index = 0
  while index < len(data)
    result = hashByte(result, data[index])
    index = index + 1
  end while
  return result
end function

/// Build deterministic test data for coordinate.
/// @param cell The cell input consumed by `sampleCoordinate`.
/// @param extent The extent input consumed by `sampleCoordinate`.
/// @param gridSize Size of the requested data or resource.
function sampleCoordinate(cell, extent, gridSize)
  if extent <= 1 then return 0 end if
  coordinate = native.trunc(((cell * 2 + 1) * extent) / (gridSize * 2))
  if coordinate < 0 then coordinate = 0 end if
  if coordinate >= extent then coordinate = extent - 1 end if
  return coordinate
end function

/// Build deterministic test data for pixel hash.
/// @param rgba The rgba input consumed by `samplePixelHash`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param gridSize Size of the requested data or resource.
function samplePixelHash(rgba, width, height, gridSize)
  if width <= 0 or height <= 0 or gridSize <= 0 then return FNV_OFFSET end if
  required = width * height * 4
  if len(rgba) < required then return FNV_OFFSET end if
  result = FNV_OFFSET
  row = 0
  while row < gridSize
    y = sampleCoordinate(row, height, gridSize)
    column = 0
    while column < gridSize
      x = sampleCoordinate(column, width, gridSize)
      offset = (y * width + x) * 4
      result = hashByte(result, rgba[offset])
      result = hashByte(result, rgba[offset + 1])
      result = hashByte(result, rgba[offset + 2])
      result = hashByte(result, rgba[offset + 3])
      column = column + 1
    end while
    row = row + 1
  end while
  return result
end function

/// Implements the `nonBlackPixels` operation for `miniquake.render_evidence` (non black pixels).
/// @param rgba The rgba input consumed by `nonBlackPixels`.
function nonBlackPixels(rgba)
  count = 0
  index = 0
  while index + 3 < len(rgba)
    if rgba[index] != 0 or rgba[index + 1] != 0 or rgba[index + 2] != 0 then count = count + 1 end if
    index = index + 4
  end while
  return count
end function

/// Return tga path derived from the active module state.
/// @param prefix The prefix input consumed by `tgaPath`.
function tgaPath(prefix)
  return prefix + ".tga"
end function

/// Return summary path derived from the active module state.
/// @param prefix The prefix input consumed by `summaryPath`.
function summaryPath(prefix)
  return prefix + "-summary.json"
end function

/// Implements the `reset` operation for `miniquake.render_evidence` (reset).
function reset()
  global captureRequested, captureTargetFrame, capturePrefix, captureDone, captureResult
  captureRequested = false
  captureTargetFrame = -1
  capturePrefix = ""
  captureDone = false
  captureResult = void
  return true
end function

/// Implements the `configure` operation for `miniquake.render_evidence` (configure).
/// @param prefix The prefix input consumed by `configure`.
/// @param targetFrame The target frame input consumed by `configure`.
function configure(prefix, targetFrame)
  global captureRequested, captureTargetFrame, capturePrefix, captureDone, captureResult
  if typeof(prefix) != "string" or prefix == "" then return error(4801, "render evidence prefix is empty") end if
  if targetFrame is not int or targetFrame < 1 then return error(4802, "render evidence frame must be positive") end if
  captureRequested = true
  captureTargetFrame = targetFrame
  capturePrefix = prefix
  captureDone = false
  captureResult = void
  return true
end function

/// Report whether should capture.
/// @param frameNumber The frame number input consumed by `shouldCapture`.
function shouldCapture(frameNumber)
  if not captureRequested or captureDone then return false end if
  return frameNumber >= captureTargetFrame
end function

/// Implements the `captured` operation for `miniquake.render_evidence` (captured).
function captured()
  return captureDone
end function

// Return last result for the active module state.
function lastResult()
  return captureResult
end function

/// Implements the `boolText` operation for `miniquake.render_evidence` (bool text).
/// @param value Value consumed by `boolText`.
function boolText(value)
  if value then return "true" end if
  return "false"
end function

/// Implements the `summaryJson` operation for `miniquake.render_evidence` (summary json).
/// @param frameNumber The frame number input consumed by `summaryJson`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param pixelBytes Byte data consumed by the operation.
/// @param tgaBytes Byte data consumed by the operation.
/// @param pixelHash The pixel hash input consumed by `summaryJson`.
/// @param tgaHash The tga hash input consumed by `summaryJson`.
/// @param sampleHash The sample hash input consumed by `summaryJson`.
/// @param nonBlack The non black input consumed by `summaryJson`.
/// @param imagePath Filesystem path used by the operation.
function summaryJson(frameNumber, width, height, pixelBytes, tgaBytes, pixelHash, tgaHash, sampleHash, nonBlack, imagePath)
  result = "{"
  result = result + "\"schema\":" + EVIDENCE_SCHEMA + ","
  result = result + "\"package\":" + diagnostics.jsonString(buildInfo.PACKAGE_ID) + ","
  result = result + "\"profile\":" + diagnostics.jsonString(buildInfo.COMPATIBILITY_PROFILE) + ","
  result = result + "\"frame\":" + frameNumber + ","
  result = result + "\"width\":" + width + ","
  result = result + "\"height\":" + height + ","
  result = result + "\"pixel_bytes\":" + pixelBytes + ","
  result = result + "\"tga_bytes\":" + tgaBytes + ","
  result = result + "\"pixel_hash\":" + diagnostics.jsonString(diagnostics.u32Hex(pixelHash)) + ","
  result = result + "\"tga_hash\":" + diagnostics.jsonString(diagnostics.u32Hex(tgaHash)) + ","
  result = result + "\"sample_grid\":" + SAMPLE_GRID + ","
  result = result + "\"sample_hash\":" + diagnostics.jsonString(diagnostics.u32Hex(sampleHash)) + ","
  result = result + "\"non_black_pixels\":" + nonBlack + ","
  result = result + "\"tga_path\":" + diagnostics.jsonString(imagePath) + ","
  result = result + "\"capture_stage\":\"after_ui_before_swap\","
  result = result + "\"ok\":" + boolText(nonBlack > 0)
  result = result + "}\n"
  return result
end function

/// Implements the `captureIfRequested` operation for `miniquake.render_evidence` (capture if requested).
/// @param frameNumber The frame number input consumed by `captureIfRequested`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function captureIfRequested(frameNumber, width, height)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  global captureRequested, captureDone, captureResult
  if not shouldCapture(frameNumber) then return false end if
  if width <= 0 or height <= 0 then return error(4803, "render evidence framebuffer dimensions are invalid") end if

  gl.finish()
  rgba = gl.readPixelsRgba(0, 0, width, height)
  if len(rgba) != width * height * 4 then return error(4804, "render evidence framebuffer byte count differs") end if
  tga = try(screen.BuildTga(width, height, rgba))
  if tga is error then return tga end if

  imagePath = tgaPath(capturePrefix)
  metadataPath = summaryPath(capturePrefix)
  pixelHash = hashBytes(rgba)
  tgaHash = hashBytes(tga)
  sampled = samplePixelHash(rgba, width, height, SAMPLE_GRID)
  nonBlack = nonBlackPixels(rgba)

  writtenImage = try(fs.writeAllBytes(imagePath, tga))
  if writtenImage is error then return writtenImage end if
  metadata = summaryJson(
    frameNumber,
    width,
    height,
    len(rgba),
    len(tga),
    pixelHash,
    tgaHash,
    sampled,
    nonBlack,
    imagePath,
  )
  writtenSummary = try(fs.writeAllText(metadataPath, metadata))
  if writtenSummary is error then return writtenSummary end if

  captureResult = [
    imagePath,
    metadataPath,
    frameNumber,
    width,
    height,
    pixelHash,
    tgaHash,
    sampled,
    nonBlack,
  ]
  captureDone = true
  captureRequested = false
  return true
end function
