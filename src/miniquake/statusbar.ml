package miniquake.statusbar

import miniquake.constants as c
import miniquake.native as native
import miniquake.menu as menu
import miniquake.render.draw2d as draw

function picture(state, name)
  if state is void then return void end if
  return menu.findWadPicture(state, name)
end function

function drawPicture(state, name, x, y, scale, alpha)
  value = picture(state, name)
  if value is void or value.textureId == 0 then return false end if
  draw.texturedQuad(
    value.textureId,
    x,
    y,
    value.width * scale,
    value.height * scale,
    0.0,
    0.0,
    1.0,
    1.0,
    255,
    255,
    255,
    alpha,
  )
  return true
end function

function scaleFor(width, height)
  // The WinQuake status area is authored at 320 pixels. Use an integral scale
  // so the original indexed artwork remains crisp while avoiding an oversized
  // bar in a short widescreen window.
  value = native.trunc(width / 640.0)
  if value < 1 then value = 1 end if
  while 48.0 * value > height * 0.28 and value > 1
    value = value - 1
  end while
  return value * 1.0
end function

function drawNumber(state, x, y, number, digits, alternate, scale)
  value = native.trunc(number)
  source = bytes("" + value)
  start = 0
  if len(source) > digits then start = len(source) - digits end if
  visible = len(source) - start
  if visible < digits then x = x + (digits - visible) * 24.0 * scale end if
  index = start
  while index < len(source)
    code = source[index]
    name = ""
    if code == 45 then
      if alternate then name = "anum_minus" else name = "num_minus" end if
    else if code >= 48 and code <= 57 then
      if alternate then name = "anum_" + (code - 48) else name = "num_" + (code - 48) end if
    end if
    if name != "" then drawPicture(state, name, x, y, scale, 255) end if
    x = x + 24.0 * scale
    index = index + 1
  end while
  return true
end function

function smallAmmoDigit(texture, x, y, digit, scale)
  if digit < 0 or digit > 9 then return false end if
  draw.character(texture, x, y, 18 + digit, scale, 255)
  return true
end function

function drawSmallAmmo(texture, x, y, number, scale)
  value = native.trunc(number)
  if value < 0 then value = 0 end if
  if value > 999 then value = 999 end if
  hundreds = native.trunc(value / 100.0)
  tens = native.trunc((value % 100) / 10.0)
  ones = value % 10
  if hundreds > 0 then smallAmmoDigit(texture, x, y, hundreds, scale) end if
  if hundreds > 0 or tens > 0 then smallAmmoDigit(texture, x + 8.0 * scale, y, tens, scale) end if
  smallAmmoDigit(texture, x + 16.0 * scale, y, ones, scale)
  return true
end function

function faceName(player)
  items = native.trunc(player.items)
  if (items & (c.IT_INVISIBILITY | c.IT_INVULNERABILITY)) == (c.IT_INVISIBILITY | c.IT_INVULNERABILITY) then return "face_inv2" end if
  if (items & c.IT_QUAD) != 0 then return "face_quad" end if
  if (items & c.IT_INVISIBILITY) != 0 then return "face_invis" end if
  if (items & c.IT_INVULNERABILITY) != 0 then return "face_invul2" end if
  health = native.trunc(player.health)
  if health >= 100 then return "face1" end if
  if health >= 80 then return "face2" end if
  if health >= 60 then return "face3" end if
  if health >= 40 then return "face4" end if
  return "face5"
end function

function armorName(items)
  if (items & c.IT_ARMOR3) != 0 then return "sb_armor3" end if
  if (items & c.IT_ARMOR2) != 0 then return "sb_armor2" end if
  if (items & c.IT_ARMOR1) != 0 then return "sb_armor1" end if
  return ""
end function

function ammoName(items)
  if (items & c.IT_SHELLS) != 0 then return "sb_shells" end if
  if (items & c.IT_NAILS) != 0 then return "sb_nails" end if
  if (items & c.IT_ROCKETS) != 0 then return "sb_rocket" end if
  if (items & c.IT_CELLS) != 0 then return "sb_cells" end if
  return ""
end function

function drawInventory(state, fontTexture, player, x, y, scale)
  drawPicture(state, "ibar", x, y, scale, 255)
  items = native.trunc(player.items)
  active = native.trunc(player.activeWeapon)
  weaponNames = ["shotgun", "sshotgun", "nailgun", "snailgun", "rlaunch", "srlaunch", "lightng"]
  index = 0
  while index < len(weaponNames)
    bit = c.IT_SHOTGUN << index
    if (items & bit) != 0 then
      prefix = "inv_"
      if active == bit then prefix = "inv2_" end if
      drawPicture(state, prefix + weaponNames[index], x + index * 24.0 * scale, y + 8.0 * scale, scale, 255)
    end if
    index = index + 1
  end while

  counts = [player.shells, player.nails, player.rockets, player.cells]
  index = 0
  while index < 4
    drawSmallAmmo(
      fontTexture,
      x + ((6.0 * index + 1.0) * 8.0 - 2.0) * scale,
      y,
      counts[index],
      scale,
    )
    index = index + 1
  end while

  itemNames = ["sb_key1", "sb_key2", "sb_invis", "sb_invuln", "sb_suit", "sb_quad"]
  index = 0
  while index < 6
    bit = 1 << (17 + index)
    if (items & bit) != 0 then
      drawPicture(state, itemNames[index], x + (192.0 + index * 16.0) * scale, y + 8.0 * scale, scale, 255)
    end if
    index = index + 1
  end while

  index = 0
  while index < 4
    bit = 1 << (28 + index)
    if (items & bit) != 0 then
      drawPicture(state, "sb_sigil" + (index + 1), x + (288.0 + index * 8.0) * scale, y + 8.0 * scale, scale, 255)
    end if
    index = index + 1
  end while
  return true
end function

function drawMainBar(state, player, x, y, scale)
  drawPicture(state, "sbar", x, y, scale, 255)
  items = native.trunc(player.items)

  if (items & c.IT_INVULNERABILITY) != 0 then
    drawNumber(state, x + 24.0 * scale, y, 666, 3, true, scale)
    drawPicture(state, "disc", x, y, scale, 255)
  else
    drawNumber(state, x + 24.0 * scale, y, player.armor, 3, player.armor <= 25.0, scale)
    armor = armorName(items)
    if armor != "" then drawPicture(state, armor, x, y, scale, 255) end if
  end if

  drawPicture(state, faceName(player), x + 112.0 * scale, y, scale, 255)
  drawNumber(state, x + 136.0 * scale, y, player.health, 3, player.health <= 25.0, scale)
  ammo = ammoName(items)
  if ammo != "" then drawPicture(state, ammo, x + 224.0 * scale, y, scale, 255) end if
  drawNumber(state, x + 248.0 * scale, y, player.ammo, 3, player.ammo <= 10.0, scale)
  return true
end function

// Sbar_Draw for the stock single-player layout. The original 320x24/48 qpics
// are taken from the user's gfx.wad; no Quake art is embedded in MiniQuake.
function render(state, fontTexture, player, width, height, viewSize)
  if state is void or player is void or fontTexture == 0 then return false end if
  if picture(state, "sbar") is void then return false end if
  if viewSize >= 120.0 then return false end if
  scale = scaleFor(width, height)
  x = (width - 320.0 * scale) * 0.5
  y = height - 24.0 * scale
  if viewSize < 110.0 then drawInventory(state, fontTexture, player, x, y - 24.0 * scale, scale) end if
  drawMainBar(state, player, x, y, scale)
  return true
end function
