package miniquake.render.gl_rmisc

import miniquake.array_util as arrayutil
import miniquake.constants as c

// Direct MiniLang pendant of WinQuake/gl_rmisc.c. The host-facing renderer
// keeps platform I/O in its existing bridges; this module owns the original
// texture-generation, palette-translation and renderer-reset semantics so
// they can also be executed without an OpenGL context by the differential
// oracle.

r_notexture_mip = void
r_notexture_mips = []
r_notexture_offsets = []
particletexture = 0
texture_extension_number = 1000
playertextures = 0
envmap = false
rmiscCommands = 0
rmiscCvars = 0
rmiscInitParticles = 0
rmiscClearParticles = 0
rmiscBuildLightmaps = 0
rmiscParticlePixels = bytes()
rmiscSkinPixels = bytes()
rmiscBoundTexture = -1
rmiscUploadWidth = 0
rmiscUploadHeight = 0
rmiscEnvDirections = []
rmiscTextureNames = []
rmiscLeafCount = 0
rmiscLightStyles = []
rmiscSkyTexture = -1
rmiscMirrorTexture = -1
rmiscRenderViews = 0
rmiscLastYaw = 0.0
rmiscLastDrawBuffer = -1
rmiscEndRendering = 0
rmiscSkin = bytes()
rmiscSkinWidth = 0
rmiscSkinHeight = 0
rmiscColors = 0
rmiscMaxSize = 4
rmiscPlayerMip = 0

function ResetCompatibility()
  global r_notexture_mip, r_notexture_mips, r_notexture_offsets
  global particletexture, texture_extension_number, playertextures, envmap
  global rmiscCommands, rmiscCvars, rmiscInitParticles, rmiscClearParticles
  global rmiscBuildLightmaps, rmiscParticlePixels, rmiscSkinPixels
  global rmiscBoundTexture, rmiscUploadWidth, rmiscUploadHeight
  global rmiscEnvDirections, rmiscTextureNames, rmiscLeafCount
  global rmiscLightStyles, rmiscSkyTexture, rmiscMirrorTexture
  global rmiscRenderViews, rmiscLastYaw, rmiscLastDrawBuffer, rmiscEndRendering
  global rmiscSkin, rmiscSkinWidth, rmiscSkinHeight, rmiscColors
  global rmiscMaxSize, rmiscPlayerMip
  r_notexture_mip = void
  r_notexture_mips = []
  r_notexture_offsets = []
  particletexture = 0
  texture_extension_number = 1000
  playertextures = 0
  envmap = false
  rmiscCommands = 0
  rmiscCvars = 0
  rmiscInitParticles = 0
  rmiscClearParticles = 0
  rmiscBuildLightmaps = 0
  rmiscParticlePixels = bytes()
  rmiscSkinPixels = bytes()
  rmiscBoundTexture = -1
  rmiscUploadWidth = 0
  rmiscUploadHeight = 0
  rmiscEnvDirections = []
  rmiscTextureNames = []
  rmiscLeafCount = 0
  rmiscLightStyles = []
  rmiscSkyTexture = -1
  rmiscMirrorTexture = -1
  rmiscRenderViews = 0
  rmiscLastYaw = 0.0
  rmiscLastDrawBuffer = -1
  rmiscEndRendering = 0
  rmiscSkin = bytes()
  rmiscSkinWidth = 0
  rmiscSkinHeight = 0
  rmiscColors = 0
  rmiscMaxSize = 4
  rmiscPlayerMip = 0
  return true
end function

function R_InitTextures()
  global r_notexture_mip, r_notexture_mips, r_notexture_offsets
  sizes = [16, 8, 4, 2]
  // sizeof(texture_t) in the pinned Win32 reference fixture is 68 bytes.
  r_notexture_offsets = [68, 324, 388, 404]
  combined = bytes(16 * 16 + 8 * 8 + 4 * 4 + 2 * 2)
  mips = arrayutil.makeEmptyArray(4)
  destination = 0
  mip = 0
  while mip < 4
    size = sizes[mip]
    pixels = bytes(size * size)
    y = 0
    while y < size
      x = 0
      while x < size
        value = 255
        if (y < (8 >> mip)) != (x < (8 >> mip)) then value = 0 end if
        pixels[y * size + x] = value
        combined[destination] = value
        destination = destination + 1
        x = x + 1
      end while
      y = y + 1
    end while
    mips[mip] = pixels
    mip = mip + 1
  end while
  r_notexture_mips = mips
  r_notexture_mip = combined
  return combined
end function

function R_InitParticleTexture()
  global particletexture, texture_extension_number, rmiscParticlePixels
  global rmiscBoundTexture, rmiscUploadWidth, rmiscUploadHeight
  dot = [
    [0, 1, 1, 0, 0, 0, 0, 0],
    [1, 1, 1, 1, 0, 0, 0, 0],
    [1, 1, 1, 1, 0, 0, 0, 0],
    [0, 1, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
  ]
  pixels = bytes(8 * 8 * 4)
  x = 0
  while x < 8
    y = 0
    while y < 8
      offset = (y * 8 + x) * 4
      pixels[offset] = 255
      pixels[offset + 1] = 255
      pixels[offset + 2] = 255
      pixels[offset + 3] = dot[x][y] * 255
      y = y + 1
    end while
    x = x + 1
  end while
  particletexture = texture_extension_number
  texture_extension_number = texture_extension_number + 1
  rmiscBoundTexture = particletexture
  rmiscUploadWidth = 8
  rmiscUploadHeight = 8
  rmiscParticlePixels = pixels
  return particletexture
end function

function R_Envmap_f()
  global envmap, rmiscEnvDirections, rmiscRenderViews
  global rmiscLastDrawBuffer, rmiscEndRendering
  envmap = true
  rmiscEnvDirections = [
    [0.0, 0.0], [0.0, 90.0], [0.0, 180.0],
    [0.0, 270.0], [-90.0, 0.0], [90.0, 0.0],
  ]
  rmiscRenderViews = 6
  envmap = false
  rmiscLastDrawBuffer = 0x0405
  rmiscEndRendering = 1
  return rmiscEnvDirections
end function

function R_Init(multitexture)
  global rmiscCommands, rmiscCvars, rmiscInitParticles
  global playertextures, texture_extension_number
  rmiscCommands = 3
  rmiscCvars = 24
  rmiscInitParticles = 1
  R_InitParticleTexture()
  playertextures = texture_extension_number
  texture_extension_number = texture_extension_number + 16
  textureSort = 1
  if multitexture then textureSort = 0 end if
  return textureSort
end function

function SetPlayerSkinCompatibility(width, height, pixels, colors, maxSize, playerMip)
  global rmiscSkinWidth, rmiscSkinHeight, rmiscSkin, rmiscColors
  global rmiscMaxSize, rmiscPlayerMip
  rmiscSkinWidth = width
  rmiscSkinHeight = height
  rmiscSkin = pixels
  rmiscColors = colors
  rmiscMaxSize = maxSize
  rmiscPlayerMip = playerMip
  return true
end function

function SetPlayerTextureBase(value)
  global playertextures
  playertextures = value
  return playertextures
end function

function translatedIndex(value, top, bottom)
  if value >= c.TOP_RANGE and value < c.TOP_RANGE + 16 then
    offset = value - c.TOP_RANGE
    if top < 128 then return top + offset end if
    return top + 15 - offset
  end if
  if value >= c.BOTTOM_RANGE and value < c.BOTTOM_RANGE + 16 then
    offset = value - c.BOTTOM_RANGE
    if bottom < 128 then return bottom + offset end if
    return bottom + 15 - offset
  end if
  return value
end function

function R_TranslatePlayerSkin(playernum)
  global rmiscSkinPixels, rmiscBoundTexture, rmiscUploadWidth, rmiscUploadHeight
  if rmiscSkinWidth <= 0 or rmiscSkinHeight <= 0 or len(rmiscSkin) < rmiscSkinWidth * rmiscSkinHeight then return false end if
  top = rmiscColors & 0xf0
  bottom = (rmiscColors & 15) << 4
  scaledWidth = rmiscMaxSize
  if scaledWidth > 512 then scaledWidth = 512 end if
  scaledHeight = rmiscMaxSize
  if scaledHeight > 256 then scaledHeight = 256 end if
  scaledWidth = scaledWidth >> rmiscPlayerMip
  scaledHeight = scaledHeight >> rmiscPlayerMip
  if scaledWidth < 1 then scaledWidth = 1 end if
  if scaledHeight < 1 then scaledHeight = 1 end if
  output = bytes(scaledWidth * scaledHeight * 4)
  fractionStep = rmiscSkinWidth * 65536 / scaledWidth
  y = 0
  while y < scaledHeight
    sourceRow = rmiscSkinWidth * (y * rmiscSkinHeight / scaledHeight)
    fraction = fractionStep >> 1
    x = 0
    while x < scaledWidth
      sourceIndex = sourceRow + (fraction >> 16)
      value = translatedIndex(rmiscSkin[sourceIndex], top, bottom)
      offset = (y * scaledWidth + x) * 4
      output[offset] = value
      output[offset + 1] = value
      output[offset + 2] = value
      output[offset + 3] = 255
      fraction = fraction + fractionStep
      x = x + 1
    end while
    y = y + 1
  end while
  rmiscBoundTexture = playertextures + playernum
  rmiscUploadWidth = scaledWidth
  rmiscUploadHeight = scaledHeight
  rmiscSkinPixels = output
  return true
end function

function SetNewMapCompatibility(textureNames, leafCount)
  global rmiscTextureNames, rmiscLeafCount
  rmiscTextureNames = textureNames
  rmiscLeafCount = leafCount
  return true
end function

function startsWith(value, prefix)
  left = bytes(value)
  right = bytes(prefix)
  if len(left) < len(right) then return false end if
  index = 0
  while index < len(right)
    if left[index] != right[index] then return false end if
    index = index + 1
  end while
  return true
end function

function R_NewMap()
  global rmiscLightStyles, rmiscSkyTexture, rmiscMirrorTexture
  global rmiscClearParticles, rmiscBuildLightmaps
  rmiscLightStyles = arrayutil.makeFilledArray(256, 264)
  rmiscSkyTexture = -1
  rmiscMirrorTexture = -1
  index = 0
  while index < len(rmiscTextureNames)
    name = rmiscTextureNames[index]
    if startsWith(name, "sky") then rmiscSkyTexture = index end if
    if startsWith(name, "window02_1") then rmiscMirrorTexture = index end if
    index = index + 1
  end while
  rmiscClearParticles = 1
  rmiscBuildLightmaps = 1
  return true
end function

function R_TimeRefresh_f()
  global rmiscRenderViews, rmiscLastYaw, rmiscLastDrawBuffer
  global rmiscEndRendering
  rmiscRenderViews = 128
  rmiscLastYaw = 127 / 128.0 * 360.0
  rmiscLastDrawBuffer = 0x0405
  rmiscEndRendering = 1
  return [2.0, 64.0]
end function

function D_FlushCaches()
  return void
end function

function GetTextureState()
  return [r_notexture_offsets, r_notexture_mip]
end function

function GetParticleState()
  return [particletexture, texture_extension_number, rmiscBoundTexture, rmiscUploadWidth, rmiscUploadHeight, rmiscParticlePixels]
end function

function GetInitState()
  return [rmiscCommands, rmiscCvars, rmiscInitParticles, playertextures, texture_extension_number]
end function

function GetSkinState()
  return [rmiscBoundTexture, rmiscUploadWidth, rmiscUploadHeight, rmiscSkinPixels]
end function

function GetNewMapState()
  return [rmiscLightStyles, rmiscLeafCount, rmiscSkyTexture, rmiscMirrorTexture, rmiscClearParticles, rmiscBuildLightmaps]
end function

function inline GetRefreshState()
  return [rmiscRenderViews, rmiscLastYaw, rmiscLastDrawBuffer, rmiscEndRendering]
end function
