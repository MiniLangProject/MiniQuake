/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Load-time RGBA texture upscalers used by every MiniQuake rendering backend.
The scalers operate before the ordinary GLQuake mip-chain builder, keeping
OpenGL, Direct3D 9 and Vulkan visually consistent without native ABI changes.
*/
package miniquake.render.texture_upscale

import miniquake.native as native

const UPSCALE_OFF = 0
const UPSCALE_NEAREST_2X = 1
const UPSCALE_SCALE2X = 2
const UPSCALE_SCALE3X = 3
const UPSCALE_HQ2X = 4
const UPSCALE_XBR2X = 5
const UPSCALE_XBR4X = 6
const UPSCALE_MODE_COUNT = 7

// Clamp a persisted or console-provided mode to the supported range.
function clampMode(mode)
  mode = native.trunc(mode)
  if mode < UPSCALE_OFF then return UPSCALE_OFF end if
  if mode >= UPSCALE_MODE_COUNT then return UPSCALE_XBR4X end if
  return mode
end function

// Return the stable English display name for one texture-upscale mode.
function modeName(mode)
  mode = clampMode(mode)
  return ["OFF", "NEAREST 2X", "SCALE2X", "SCALE3X", "HQ2X", "XBR2X", "XBR4X"][mode]
end function

// Return the integer enlargement factor associated with a mode.
function scaleFactor(mode)
  mode = clampMode(mode)
  if mode == UPSCALE_SCALE3X then return 3 end if
  if mode == UPSCALE_XBR4X then return 4 end if
  if mode == UPSCALE_OFF then return 1 end if
  return 2
end function

// Validate dimensions and the complete RGBA source span before scaling.
function validateSource(pixels, width, height)
  if width <= 0 or height <= 0 then return error(4060, "texture upscale: invalid dimensions") end if
  pixelCount = width * height
  if pixelCount <= 0 or pixelCount > 16777216 then return error(4061, "texture upscale: image is too large") end if
  if len(pixels) < pixelCount * 4 then return error(4062, "texture upscale: RGBA source is truncated") end if
  return pixelCount
end function

// Report exact equality for two RGBA pixels in the same byte buffer.
function pixelsEqual(pixels, first, second)
  return pixels[first] == pixels[second] and
    pixels[first + 1] == pixels[second + 1] and
    pixels[first + 2] == pixels[second + 2] and
    pixels[first + 3] == pixels[second + 3]
end function

// Return an absolute integer without converting the hot scaler path to float.
function absoluteInteger(value)
  if value < 0 then return -value end if
  return value
end function

// Measure perceptual RGBA distance with extra weight on green and alpha.
function pixelDistance(pixels, first, second)
  red = absoluteInteger(pixels[first] - pixels[second])
  green = absoluteInteger(pixels[first + 1] - pixels[second + 1])
  blue = absoluteInteger(pixels[first + 2] - pixels[second + 2])
  alpha = absoluteInteger(pixels[first + 3] - pixels[second + 3])
  return red * 3 + green * 6 + blue * 2 + alpha * 8
end function

// Report perceptual similarity at the supplied HQ/xBR edge threshold.
function pixelsSimilar(pixels, first, second, threshold)
  return pixelDistance(pixels, first, second) <= threshold
end function

// Copy one complete pixel into an already allocated destination image.
function copyPixel(destination, destinationOffset, source, sourceOffset)
  destination[destinationOffset] = source[sourceOffset]
  destination[destinationOffset + 1] = source[sourceOffset + 1]
  destination[destinationOffset + 2] = source[sourceOffset + 2]
  destination[destinationOffset + 3] = source[sourceOffset + 3]
  return destinationOffset + 4
end function

// Blend a center pixel with two edge neighbors in premultiplied-alpha space.
// This prevents the hidden RGB value of Quake palette index 255 from forming
// colored fringes around sprite and alias-model cutouts.
function blendCorner(destination, destinationOffset, source, center, first, second, centerWeight, neighborWeight)
  totalWeight = centerWeight + neighborWeight * 2
  centerAlpha = source[center + 3]
  firstAlpha = source[first + 3]
  secondAlpha = source[second + 3]
  alphaSum = centerAlpha * centerWeight + firstAlpha * neighborWeight + secondAlpha * neighborWeight
  outputAlpha = native.trunc((alphaSum + native.trunc(totalWeight / 2)) / totalWeight)
  channel = 0
  while channel < 3
    if alphaSum == 0 then
      destination[destinationOffset + channel] = 0
    else
      premultiplied = source[center + channel] * centerAlpha * centerWeight
      premultiplied = premultiplied + source[first + channel] * firstAlpha * neighborWeight
      premultiplied = premultiplied + source[second + channel] * secondAlpha * neighborWeight
      destination[destinationOffset + channel] = native.trunc((premultiplied + native.trunc(alphaSum / 2)) / alphaSum)
    end if
    channel = channel + 1
  end while
  destination[destinationOffset + 3] = outputAlpha
  return destinationOffset + 4
end function

// Enlarge an RGBA image with exact nearest-neighbor replication.
function nearest(pixels, width, height, factor)
  validated = validateSource(pixels, width, height)
  if validated is error then return validated end if
  outputWidth = width * factor
  outputHeight = height * factor
  if outputWidth * outputHeight > 16777216 then return error(4063, "texture upscale: nearest output is too large") end if
  output = bytes(outputWidth * outputHeight * 4)
  y = 0
  while y < outputHeight
    sourceY = native.trunc(y / factor)
    x = 0
    while x < outputWidth
      sourceX = native.trunc(x / factor)
      copyPixel(output, (y * outputWidth + x) * 4, pixels, (sourceY * width + sourceX) * 4)
      x = x + 1
    end while
    y = y + 1
  end while
  return [output, outputWidth, outputHeight]
end function

// Apply the canonical Scale2x neighborhood rules to an RGBA image.
function scale2x(pixels, width, height)
  // Validate and allocate once, then apply the four canonical neighborhood
  // choices independently for every source pixel.
  validated = validateSource(pixels, width, height)
  if validated is error then return validated end if
  outputWidth = width * 2
  outputHeight = height * 2
  if outputWidth * outputHeight > 16777216 then return error(4064, "texture upscale: Scale2x output is too large") end if
  output = bytes(outputWidth * outputHeight * 4)
  y = 0
  while y < height
    northY = y - 1
    if northY < 0 then northY = 0 end if
    southY = y + 1
    if southY >= height then southY = height - 1 end if
    x = 0
    while x < width
      westX = x - 1
      if westX < 0 then westX = 0 end if
      eastX = x + 1
      if eastX >= width then eastX = width - 1 end if
      north = (northY * width + x) * 4
      west = (y * width + westX) * 4
      center = (y * width + x) * 4
      east = (y * width + eastX) * 4
      south = (southY * width + x) * 4
      topLeft = center
      topRight = center
      bottomLeft = center
      bottomRight = center
      if not pixelsEqual(pixels, north, south) and not pixelsEqual(pixels, west, east) then
        if pixelsEqual(pixels, west, north) then topLeft = west end if
        if pixelsEqual(pixels, north, east) then topRight = east end if
        if pixelsEqual(pixels, west, south) then bottomLeft = west end if
        if pixelsEqual(pixels, south, east) then bottomRight = east end if
      end if
      destination = ((y * 2) * outputWidth + x * 2) * 4
      copyPixel(output, destination, pixels, topLeft)
      copyPixel(output, destination + 4, pixels, topRight)
      destination = destination + outputWidth * 4
      copyPixel(output, destination, pixels, bottomLeft)
      copyPixel(output, destination + 4, pixels, bottomRight)
      x = x + 1
    end while
    y = y + 1
  end while
  return [output, outputWidth, outputHeight]
end function

// Apply the canonical Scale3x 3x3 neighborhood rules to an RGBA image.
function scale3x(pixels, width, height)
  // Expand each source texel to a 3x3 block whose edge cells are selected
  // from the complete A..I neighborhood before any destination write.
  validated = validateSource(pixels, width, height)
  if validated is error then return validated end if
  outputWidth = width * 3
  outputHeight = height * 3
  if outputWidth * outputHeight > 16777216 then return error(4065, "texture upscale: Scale3x output is too large") end if
  output = bytes(outputWidth * outputHeight * 4)
  y = 0
  while y < height
    northY = y - 1
    if northY < 0 then northY = 0 end if
    southY = y + 1
    if southY >= height then southY = height - 1 end if
    x = 0
    while x < width
      westX = x - 1
      if westX < 0 then westX = 0 end if
      eastX = x + 1
      if eastX >= width then eastX = width - 1 end if
      a = (northY * width + westX) * 4
      b = (northY * width + x) * 4
      c = (northY * width + eastX) * 4
      d = (y * width + westX) * 4
      e = (y * width + x) * 4
      f = (y * width + eastX) * 4
      g = (southY * width + westX) * 4
      h = (southY * width + x) * 4
      i = (southY * width + eastX) * 4
      e0 = e; e1 = e; e2 = e; e3 = e; e4 = e; e5 = e; e6 = e; e7 = e; e8 = e
      if not pixelsEqual(pixels, b, h) and not pixelsEqual(pixels, d, f) then
        if pixelsEqual(pixels, d, b) then e0 = d end if
        if (pixelsEqual(pixels, d, b) and not pixelsEqual(pixels, e, c)) or (pixelsEqual(pixels, b, f) and not pixelsEqual(pixels, e, a)) then e1 = b end if
        if pixelsEqual(pixels, b, f) then e2 = f end if
        if (pixelsEqual(pixels, d, b) and not pixelsEqual(pixels, e, g)) or (pixelsEqual(pixels, d, h) and not pixelsEqual(pixels, e, a)) then e3 = d end if
        if (pixelsEqual(pixels, b, f) and not pixelsEqual(pixels, e, i)) or (pixelsEqual(pixels, h, f) and not pixelsEqual(pixels, e, c)) then e5 = f end if
        if pixelsEqual(pixels, d, h) then e6 = d end if
        if (pixelsEqual(pixels, d, h) and not pixelsEqual(pixels, e, i)) or (pixelsEqual(pixels, h, f) and not pixelsEqual(pixels, e, g)) then e7 = h end if
        if pixelsEqual(pixels, h, f) then e8 = f end if
      end if
      destination = ((y * 3) * outputWidth + x * 3) * 4
      copyPixel(output, destination, pixels, e0); copyPixel(output, destination + 4, pixels, e1); copyPixel(output, destination + 8, pixels, e2)
      destination = destination + outputWidth * 4
      copyPixel(output, destination, pixels, e3); copyPixel(output, destination + 4, pixels, e4); copyPixel(output, destination + 8, pixels, e5)
      destination = destination + outputWidth * 4
      copyPixel(output, destination, pixels, e6); copyPixel(output, destination + 4, pixels, e7); copyPixel(output, destination + 8, pixels, e8)
      x = x + 1
    end while
    y = y + 1
  end while
  return [output, outputWidth, outputHeight]
end function

// Blend one HQ2x corner when its two adjoining colors form a coherent edge.
function hqCorner(output, destination, pixels, center, first, second)
  if pixelsSimilar(pixels, first, second, 420) and not pixelsSimilar(pixels, center, first, 420) and not pixelsSimilar(pixels, center, second, 420) then
    blendCorner(output, destination, pixels, center, first, second, 4, 2)
  end if
  return true
end function

// Blend one xBR corner after comparing the two competing diagonal gradients.
function xbrCorner(output, destination, pixels, center, first, second, diagonal, farFirst, farSecond)
  if not pixelsSimilar(pixels, first, second, 720) then return false end if
  if pixelsSimilar(pixels, center, first, 420) or pixelsSimilar(pixels, center, second, 420) then return false end if
  edgeCost = pixelDistance(pixels, diagonal, first) + pixelDistance(pixels, diagonal, second)
  edgeCost = edgeCost + pixelDistance(pixels, center, farFirst) + pixelDistance(pixels, center, farSecond)
  edgeCost = edgeCost + pixelDistance(pixels, first, second) * 4
  centerCost = pixelDistance(pixels, first, farFirst) + pixelDistance(pixels, first, center)
  centerCost = centerCost + pixelDistance(pixels, second, center) + pixelDistance(pixels, second, farSecond)
  centerCost = centerCost + pixelDistance(pixels, center, diagonal) * 4
  if edgeCost <= centerCost then
    blendCorner(output, destination, pixels, center, first, second, 2, 3)
    return true
  end if
  return false
end function

// Apply HQ2x or xBR2x edge-directed smoothing without touching flat regions.
function edgeAware2x(pixels, width, height, xbr)
  // Seed all four output corners with the center color, then replace only
  // corners where the HQ or xBR gradient test establishes a coherent edge.
  validated = validateSource(pixels, width, height)
  if validated is error then return validated end if
  outputWidth = width * 2
  outputHeight = height * 2
  if outputWidth * outputHeight > 16777216 then return error(4066, "texture upscale: edge output is too large") end if
  output = bytes(outputWidth * outputHeight * 4)
  y = 0
  while y < height
    northY = y - 1
    if northY < 0 then northY = 0 end if
    southY = y + 1
    if southY >= height then southY = height - 1 end if
    x = 0
    while x < width
      westX = x - 1
      if westX < 0 then westX = 0 end if
      eastX = x + 1
      if eastX >= width then eastX = width - 1 end if
      a = (northY * width + westX) * 4
      b = (northY * width + x) * 4
      c = (northY * width + eastX) * 4
      d = (y * width + westX) * 4
      e = (y * width + x) * 4
      f = (y * width + eastX) * 4
      g = (southY * width + westX) * 4
      h = (southY * width + x) * 4
      i = (southY * width + eastX) * 4
      topLeft = ((y * 2) * outputWidth + x * 2) * 4
      topRight = topLeft + 4
      bottomLeft = topLeft + outputWidth * 4
      bottomRight = bottomLeft + 4
      copyPixel(output, topLeft, pixels, e); copyPixel(output, topRight, pixels, e)
      copyPixel(output, bottomLeft, pixels, e); copyPixel(output, bottomRight, pixels, e)
      if xbr then
        xbrCorner(output, topLeft, pixels, e, b, d, a, c, g)
        xbrCorner(output, topRight, pixels, e, b, f, c, a, i)
        xbrCorner(output, bottomLeft, pixels, e, d, h, g, a, i)
        xbrCorner(output, bottomRight, pixels, e, f, h, i, c, g)
      else
        hqCorner(output, topLeft, pixels, e, b, d)
        hqCorner(output, topRight, pixels, e, b, f)
        hqCorner(output, bottomLeft, pixels, e, d, h)
        hqCorner(output, bottomRight, pixels, e, f, h)
      end if
      x = x + 1
    end while
    y = y + 1
  end while
  return [output, outputWidth, outputHeight]
end function

// Apply one selected load-time upscaler and return [pixels, width, height].
function apply(pixels, width, height, mode)
  mode = clampMode(mode)
  if mode == UPSCALE_OFF then
    validated = validateSource(pixels, width, height)
    if validated is error then return validated end if
    return [pixels, width, height]
  end if
  if mode == UPSCALE_NEAREST_2X then return nearest(pixels, width, height, 2) end if
  if mode == UPSCALE_SCALE2X then return scale2x(pixels, width, height) end if
  if mode == UPSCALE_SCALE3X then return scale3x(pixels, width, height) end if
  if mode == UPSCALE_HQ2X then return edgeAware2x(pixels, width, height, false) end if
  if mode == UPSCALE_XBR2X then return edgeAware2x(pixels, width, height, true) end if
  firstPass = edgeAware2x(pixels, width, height, true)
  if firstPass is error then return firstPass end if
  return edgeAware2x(firstPass[0], firstPass[1], firstPass[2], true)
end function
