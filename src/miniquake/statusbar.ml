package miniquake.statusbar

import miniquake.constants as c
import miniquake.native as native
import miniquake.menu as menu
import miniquake.render.draw2d as draw
import miniquake.byteio as bio
import miniquake.array_util as arrayutil
import miniquake.render_ui_contract as renderUiContract

const SBAR_HEIGHT = 24
const STAT_MINUS = 10

sb_updates = 0
sb_showscores = false
sb_lines = 48
sbarInitialized = false
sbarHipnotic = false
sbarRogue = false
sbarState = void
sbarFontTexture = 0
sbarPlayer = void
sbarClient = void
sbarWidth = 320
sbarHeight = 200
sbarGameType = c.GAME_COOP
sbarTeamplay = 0.0
sbarConsoleCurrent = -1.0
sbarNumPages = 999999
sbarCopyEverything = false
sbarFullUpdate = 0
sbarPictures = []
sbarPictureNames = []
sbarInjectedPictures = []
sbarLoadTrace = []
fragsort = []
scoreboardtext = []
scoreboardtop = []
scoreboardbottom = []
scoreboardlines = 0
sbarTrace = []

function rememberSbarPicture(name, value)
  global sbarPictures, sbarPictureNames
  if value is error then return value end if
  sbarPictureNames = sbarPictureNames + [name]
  sbarPictures = sbarPictures + [value]
  return value
end function

function loadSbarPicture(name)
  global sbarLoadTrace
  sbarLoadTrace = sbarLoadTrace + [name]
  index = 0
  while index < len(sbarPictureNames)
    if sbarPictureNames[index] == name then return sbarPictures[index] end if
    index = index + 1
  end while
  for each injected in sbarInjectedPictures
    if injected.name == name then return rememberSbarPicture(name, injected) end if
  end for
  return rememberSbarPicture(name, draw.Draw_PicFromWad(name))
end function

function loadedSbarPicture(name)
  index = 0
  while index < len(sbarPictureNames)
    if sbarPictureNames[index] == name then return sbarPictures[index] end if
    index = index + 1
  end while
  for each injected in sbarInjectedPictures
    if injected.name == name then return injected end if
  end for
  if sbarState is not void then
    found = menu.findWadPicture(sbarState, name)
    if found is not void then return found end if
  end if
  return void
end function

function picture(state, name)
  if state is void then return void end if
  return menu.findWadPicture(state, name)
end function

function drawPicture(state, name, x, y, scale, alpha)
  value = picture(state, name)
  if value is void or value.textureId == 0 then return false end if
  return draw.Draw_PicScaled(value, x, y, scale, alpha)
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

function faceNameFor(items, health)
  if (items & (c.IT_INVISIBILITY | c.IT_INVULNERABILITY)) == (c.IT_INVISIBILITY | c.IT_INVULNERABILITY) then return "face_inv2" end if
  if (items & c.IT_QUAD) != 0 then return "face_quad" end if
  if (items & c.IT_INVISIBILITY) != 0 then return "face_invis" end if
  if (items & c.IT_INVULNERABILITY) != 0 then return "face_invul2" end if
  if health >= 80 then return "face1" end if
  if health >= 60 then return "face2" end if
  if health >= 40 then return "face3" end if
  if health >= 20 then return "face4" end if
  return "face5"
end function

function faceName(player)
  return faceNameFor(native.trunc(player.items), native.trunc(player.health))
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
function render(state, fontTexture, player, width, height, viewSize, clientState, teamplay)
  if state is void or player is void or fontTexture == 0 then return false end if
  if picture(state, "sbar") is void then return false end if
  lines = 48
  if viewSize >= 120.0 then lines = 0 else if viewSize >= 110.0 then lines = 24 end if
  Sbar_Configure(state, fontTexture, player, clientState, width, height, lines, teamplay)
  return Sbar_Draw()
end function

// =============================================================================
// sbar.c compatibility surface
// =============================================================================

function Sbar_ShowScores()
  global sb_showscores, sb_updates
  if sb_showscores then return false end if
  sb_showscores = true
  sb_updates = 0
  return true
end function

function Sbar_DontShowScores()
  global sb_showscores, sb_updates
  sb_showscores = false
  sb_updates = 0
  return true
end function

function Sbar_Changed()
  global sb_updates
  sb_updates = 0
  return true
end function

function Sbar_Init(gameDirectory)
  global sbarInitialized, sbarHipnotic, sbarRogue, sbarPictureNames, sbarPictures, sbarLoadTrace
  if sbarInitialized and ((gameDirectory == "hipnotic") == sbarHipnotic) and ((gameDirectory == "rogue") == sbarRogue) then return true end if
  sbarHipnotic = bio.lower(gameDirectory) == "hipnotic"
  sbarRogue = bio.lower(gameDirectory) == "rogue"
  sbarPictureNames = []
  sbarPictures = []
  sbarLoadTrace = []
  index = 0
  while index < 10
    loadSbarPicture("num_" + index)
    loadSbarPicture("anum_" + index)
    index = index + 1
  end while
  loadSbarPicture("num_minus")
  loadSbarPicture("anum_minus")
  loadSbarPicture("num_colon")
  loadSbarPicture("num_slash")
  weapons = ["shotgun", "sshotgun", "nailgun", "snailgun", "rlaunch", "srlaunch", "lightng"]
  for each weapon in weapons
    loadSbarPicture("inv_" + weapon)
  end for
  for each weapon in weapons
    loadSbarPicture("inv2_" + weapon)
  end for
  flash = 1
  while flash <= 5
    for each weapon in weapons
      loadSbarPicture("inva" + flash + "_" + weapon)
    end for
    flash = flash + 1
  end while
  stock = [
    "sb_shells", "sb_nails", "sb_rocket", "sb_cells",
    "sb_armor1", "sb_armor2", "sb_armor3",
    "sb_key1", "sb_key2", "sb_invis", "sb_invuln", "sb_suit", "sb_quad",
    "sb_sigil1", "sb_sigil2", "sb_sigil3", "sb_sigil4",
    "face1", "face_p1", "face2", "face_p2", "face3", "face_p3",
    "face4", "face_p4", "face5", "face_p5",
    "face_invis", "face_invul2", "face_inv2", "face_quad",
    "sbar", "ibar", "scorebar",
  ]
  for each name in stock
    loadSbarPicture(name)
  end for
  if sbarHipnotic then
    hipWeapons = ["laser", "mjolnir", "gren_prox", "prox_gren", "prox"]
    for each weapon in hipWeapons
      loadSbarPicture("inv_" + weapon)
    end for
    for each weapon in hipWeapons
      loadSbarPicture("inv2_" + weapon)
    end for
    flash = 1
    while flash <= 5
      for each weapon in hipWeapons
        loadSbarPicture("inva" + flash + "_" + weapon)
      end for
      flash = flash + 1
    end while
    loadSbarPicture("sb_wsuit")
    loadSbarPicture("sb_eshld")
  end if
  if sbarRogue then
    rogueNames = [
      "r_invbar1", "r_invbar2", "r_lava", "r_superlava", "r_gren",
      "r_multirock", "r_plasma", "r_shield1", "r_agrav1", "r_teambord",
      "r_ammolava", "r_ammomulti", "r_ammoplasma",
    ]
    for each name in rogueNames
      loadSbarPicture(name)
    end for
  end if
  sbarInitialized = true
  return true
end function

function Sbar_SetFrameState(consoleCurrent, numPages)
  global sbarConsoleCurrent, sbarNumPages
  sbarConsoleCurrent = consoleCurrent
  sbarNumPages = numPages
  return true
end function

function sbarItems()
  if sbarClient is not void then return native.trunc(sbarClient.items) end if
  if sbarPlayer is not void then return native.trunc(sbarPlayer.items) end if
  return 0
end function

// Deterministic state injection for the direct pinned-source differential.
// Production functions remain the code under test; only their globals/assets
// are arranged without requiring retail gfx.wad or an OpenGL context.
function Sbar_DifferentialReset(pictures)
  global sb_updates, sb_showscores, sb_lines, sbarInitialized, sbarHipnotic, sbarRogue
  global sbarState, sbarFontTexture, sbarPlayer, sbarClient, sbarWidth, sbarHeight
  global sbarGameType, sbarTeamplay, sbarPictures, sbarPictureNames, sbarInjectedPictures
  global fragsort, scoreboardtext, scoreboardtop, scoreboardbottom, scoreboardlines
  global sbarTrace, sbarLoadTrace, sbarConsoleCurrent, sbarNumPages
  global sbarCopyEverything, sbarFullUpdate
  sb_updates = 0
  sb_showscores = false
  sb_lines = 48
  sbarInitialized = false
  sbarHipnotic = false
  sbarRogue = false
  sbarState = void
  sbarFontTexture = 1
  sbarPlayer = void
  sbarClient = void
  sbarWidth = 320
  sbarHeight = 200
  sbarGameType = c.GAME_COOP
  sbarTeamplay = 0.0
  sbarPictures = []
  sbarPictureNames = []
  sbarInjectedPictures = pictures
  fragsort = []
  scoreboardtext = []
  scoreboardtop = []
  scoreboardbottom = []
  scoreboardlines = 0
  sbarTrace = []
  sbarLoadTrace = []
  sbarConsoleCurrent = -1.0
  sbarNumPages = 999999
  sbarCopyEverything = false
  sbarFullUpdate = 0
  return true
end function

function Sbar_DifferentialState()
  return [
    sb_updates, sb_showscores, sb_lines, sbarCopyEverything, sbarFullUpdate,
    fragsort, scoreboardtext, scoreboardtop, scoreboardbottom, sbarLoadTrace,
  ]
end function

function Sbar_DifferentialSetState(updates, showScores, hipnoticValue, rogueValue, teamplayValue)
  global sb_updates, sb_showscores, sbarHipnotic, sbarRogue, sbarTeamplay
  sb_updates = updates
  sb_showscores = showScores
  sbarHipnotic = hipnoticValue
  sbarRogue = rogueValue
  sbarTeamplay = teamplayValue
  return true
end function

function Sbar_DifferentialClearTrace()
  global sbarTrace
  sbarTrace = []
  return true
end function

function Sbar_Configure(state, fontTexture, player, clientState, width, height, lines, teamplay)
  global sbarState, sbarFontTexture, sbarPlayer, sbarClient, sbarWidth, sbarHeight, sb_lines, sbarGameType, sbarTeamplay
  sbarState = state
  sbarFontTexture = fontTexture
  sbarPlayer = player
  sbarClient = clientState
  sbarWidth = width
  sbarHeight = height
  sb_lines = lines
  sbarTeamplay = teamplay
  sbarGameType = c.GAME_COOP
  if clientState is not void then sbarGameType = clientState.gameType end if
  return true
end function

function sbarXOffset()
  return renderUiContract.statusbarXOffset(sbarWidth, sbarGameType)
end function

function traceSbar(command)
  global sbarTrace
  sbarTrace = sbarTrace + [command]
  return true
end function

function sbarDirectPic(x, y, pic)
  if pic is void then return false end if
  traceSbar(["pic", pic.name, x, y])
  return draw.Draw_Pic(x, y, pic)
end function

function sbarDirectTransPic(x, y, pic)
  if pic is void then return false end if
  traceSbar(["transpic", pic.name, x, y])
  return draw.Draw_TransPic(x, y, pic)
end function

function sbarDirectCharacter(x, y, num)
  traceSbar(["char", num, x, y])
  return draw.Draw_Character(x, y, num)
end function

function sbarDirectString(x, y, text)
  traceSbar(["string", text, x, y])
  return draw.Draw_String(x, y, text)
end function

function sbarDirectFill(x, y, width, height, color)
  traceSbar(["fill", x, y, width, height, color])
  return draw.Draw_Fill(x, y, width, height, color)
end function

function sbarDirectTileClear(x, y, width, height)
  traceSbar(["tileclear", x, y, width, height])
  return draw.Draw_TileClear(x, y, width, height)
end function

function Sbar_DrawPic(x, y, pic)
  if pic is void then return false end if
  drawX = x + sbarXOffset()
  drawY = y + sbarHeight - SBAR_HEIGHT
  traceSbar(["pic", pic.name, drawX, drawY])
  return draw.Draw_Pic(drawX, drawY, pic)
end function

function Sbar_DrawTransPic(x, y, pic)
  if pic is void then return false end if
  drawX = x + sbarXOffset()
  drawY = y + sbarHeight - SBAR_HEIGHT
  traceSbar(["transpic", pic.name, drawX, drawY])
  return draw.Draw_TransPic(drawX, drawY, pic)
end function

function Sbar_DrawCharacter(x, y, num)
  drawX = x + sbarXOffset() + 4
  drawY = y + sbarHeight - SBAR_HEIGHT
  traceSbar(["char", num, drawX, drawY])
  return draw.Draw_Character(drawX, drawY, num)
end function

function Sbar_DrawString(x, y, text)
  drawX = x + sbarXOffset()
  drawY = y + sbarHeight - SBAR_HEIGHT
  traceSbar(["string", text, drawX, drawY])
  return draw.Draw_String(drawX, drawY, text)
end function

// The C routine fills a caller buffer and returns its length.  MiniLang
// returns [text, length].
function Sbar_itoa(num)
  text = "" + native.trunc(num)
  return [text, len(bytes(text))]
end function

function numberPicture(color, frame)
  prefix = "num_"
  if color != 0 then prefix = "anum_" end if
  if frame == STAT_MINUS then return loadedSbarPicture(prefix + "minus") end if
  return loadedSbarPicture(prefix + frame)
end function

function Sbar_DrawNum(x, y, num, digits, color)
  converted = Sbar_itoa(num)
  text = bytes(converted[0])
  start = 0
  if len(text) > digits then start = len(text) - digits end if
  if len(text) < digits then x = x + (digits - len(text)) * 24 end if
  index = start
  while index < len(text)
    frame = text[index] - 48
    if text[index] == 45 then frame = STAT_MINUS end if
    Sbar_DrawTransPic(x, y, numberPicture(color, frame))
    x = x + 24
    index = index + 1
  end while
  return true
end function

function Sbar_SortFrags(scores)
  global fragsort, scoreboardlines
  fragsort = []
  if scores is void then scoreboardlines = 0; return fragsort end if
  index = 0
  while index < len(scores)
    if scores[index].name != "" then fragsort = fragsort + [index] end if
    index = index + 1
  end while
  i = 0
  while i < len(fragsort)
    j = 0
    while j < len(fragsort) - 1 - i
      if scores[fragsort[j]].frags < scores[fragsort[j + 1]].frags then
        temporary = fragsort[j]
        fragsort[j] = fragsort[j + 1]
        fragsort[j + 1] = temporary
      end if
      j = j + 1
    end while
    i = i + 1
  end while
  scoreboardlines = len(fragsort)
  return fragsort
end function

function inline Sbar_ColorForMap(mapColor)
  return mapColor + 8
end function

function padFrag(value)
  text = "" + native.trunc(value)
  while len(bytes(text)) < 3
    text = " " + text
  end while
  return text
end function

function fragGlyphs(value)
  return slice(bytes(padFrag(value)), 0, 3)
end function

function Sbar_UpdateScoreboard()
  global scoreboardtext, scoreboardtop, scoreboardbottom
  scores = []
  if sbarClient is not void then scores = sbarClient.scores end if
  Sbar_SortFrags(scores)
  scoreboardtext = arrayutil.makeEmptyArray(scoreboardlines)
  scoreboardtop = arrayutil.makeEmptyArray(scoreboardlines)
  scoreboardbottom = arrayutil.makeEmptyArray(scoreboardlines)
  index = 0
  while index < scoreboardlines
    score = scores[fragsort[index]]
    // C stores this payload at scoreboardtext[i][1], leaving byte zero as NUL.
    // The ML string models the useful payload beginning at that offset.
    scoreboardtext[index] = padFrag(score.frags) + " " + score.name
    scoreboardtop[index] = Sbar_ColorForMap(score.colors & 0xf0)
    scoreboardbottom[index] = Sbar_ColorForMap((score.colors & 15) << 4)
    index = index + 1
  end while
  return scoreboardlines
end function

function stat(index, fallback)
  if sbarClient is not void and index >= 0 and index < len(sbarClient.stats) then return sbarClient.stats[index] end if
  return fallback
end function

function Sbar_SoloScoreboard()
  monsters = stat(c.STAT_MONSTERS, 0)
  totalMonsters = stat(c.STAT_TOTALMONSTERS, 0)
  secrets = stat(c.STAT_SECRETS, 0)
  totalSecrets = stat(c.STAT_TOTALSECRETS, 0)
  currentTime = 0.0
  levelName = ""
  if sbarClient is not void then currentTime = sbarClient.time; levelName = sbarClient.levelName end if
  minutes = native.trunc(currentTime / 60.0)
  seconds = native.trunc(currentTime - minutes * 60)
  Sbar_DrawString(8, 4, "Monsters:" + padFrag(monsters) + " /" + padFrag(totalMonsters))
  Sbar_DrawString(8, 12, "Secrets :" + padFrag(secrets) + " /" + padFrag(totalSecrets))
  Sbar_DrawString(184, 4, "Time :" + padFrag(minutes) + ":" + native.trunc(seconds / 10) + (seconds % 10))
  Sbar_DrawString(232 - len(bytes(levelName)) * 4, 12, levelName)
  return true
end function

function Sbar_DrawScoreboard()
  Sbar_SoloScoreboard()
  if sbarGameType == c.GAME_DEATHMATCH then Sbar_DeathmatchOverlay() end if
  return true
end function

function weaponFlash(itemIndex, activeWeapon, currentTime)
  global sb_updates
  acquired = 0.0
  if sbarClient is not void and itemIndex < len(sbarClient.itemGetTime) then acquired = sbarClient.itemGetTime[itemIndex] end if
  flash = native.trunc((currentTime - acquired) * 10.0)
  if flash >= 10 then
    if activeWeapon == (1 << itemIndex) then return 1 end if
    return 0
  end if
  result = (flash % 5) + 2
  if result > 1 then sb_updates = 0 end if
  return result
end function

function flashWeaponName(prefix, weapon, flash)
  if flash == 0 then return "inv_" + weapon end if
  if flash == 1 then return "inv2_" + weapon end if
  return "inva" + (flash - 1) + "_" + weapon
end function

function itemNeedsRefresh(itemIndex, currentTime)
  global sb_updates
  if sbarClient is void or itemIndex >= len(sbarClient.itemGetTime) then return false end if
  acquired = sbarClient.itemGetTime[itemIndex]
  if acquired != 0.0 and acquired > currentTime - 2.0 then
    sb_updates = 0
    return true
  end if
  return false
end function

function sbarActiveWeapon()
  if sbarPlayer is void then return 0 end if
  return native.trunc(stat(c.STAT_ACTIVEWEAPON, sbarPlayer.activeWeapon))
end function

function Sbar_DrawInventory()
  if sbarPlayer is void then return false end if
  items = sbarItems()
  active = sbarActiveWeapon()
  currentTime = 0.0
  if sbarClient is not void then currentTime = sbarClient.time end if
  if sbarRogue then
    if active >= c.RIT_LAVA_NAILGUN then Sbar_DrawPic(0, -24, loadedSbarPicture("r_invbar1"))
    else Sbar_DrawPic(0, -24, loadedSbarPicture("r_invbar2"))
    end if
  else Sbar_DrawPic(0, -24, loadedSbarPicture("ibar"))
  end if
  weapons = ["shotgun", "sshotgun", "nailgun", "snailgun", "rlaunch", "srlaunch", "lightng"]
  index = 0
  while index < 7
    bit = c.IT_SHOTGUN << index
    if (items & bit) != 0 then
      flash = weaponFlash(index, active, currentTime)
      Sbar_DrawPic(index * 24, -16, loadedSbarPicture(flashWeaponName("", weapons[index], flash)))
    end if
    index = index + 1
  end while
  if sbarHipnotic then
    if (items & c.HIT_LASER_CANNON) != 0 then
      flash = weaponFlash(c.HIT_LASER_CANNON_BIT, active, currentTime)
      Sbar_DrawPic(176, -16, loadedSbarPicture(flashWeaponName("", "laser", flash)))
    end if
    if (items & c.HIT_MJOLNIR) != 0 then
      flash = weaponFlash(c.HIT_MJOLNIR_BIT, active, currentTime)
      Sbar_DrawPic(200, -16, loadedSbarPicture(flashWeaponName("", "mjolnir", flash)))
    end if
    grenadeFlashing = false
    if (items & c.IT_GRENADE_LAUNCHER) != 0 and (items & c.HIT_PROXIMITY_GUN) != 0 then
      flash = weaponFlash(4, active, currentTime)
      if flash != 0 then
        grenadeFlashing = true
        Sbar_DrawPic(96, -16, loadedSbarPicture(flashWeaponName("", "gren_prox", flash)))
      end if
    end if
    if (items & c.HIT_PROXIMITY_GUN) != 0 and not grenadeFlashing then
      flash = weaponFlash(c.HIT_PROXIMITY_GUN_BIT, active, currentTime)
      if (items & c.IT_GRENADE_LAUNCHER) != 0 then Sbar_DrawPic(96, -16, loadedSbarPicture(flashWeaponName("", "prox_gren", flash)))
      else Sbar_DrawPic(96, -16, loadedSbarPicture(flashWeaponName("", "prox", flash)))
      end if
    end if
  end if
  if sbarRogue and active >= c.RIT_LAVA_NAILGUN then
    names = ["r_lava", "r_superlava", "r_gren", "r_multirock", "r_plasma"]
    index = 0
    while index < 5
      if active == (c.RIT_LAVA_NAILGUN << index) then Sbar_DrawPic((index + 2) * 24, -16, loadedSbarPicture(names[index])) end if
      index = index + 1
    end while
  end if
  counts = [
    stat(c.STAT_SHELLS, sbarPlayer.shells),
    stat(c.STAT_NAILS, sbarPlayer.nails),
    stat(c.STAT_ROCKETS, sbarPlayer.rockets),
    stat(c.STAT_CELLS, sbarPlayer.cells),
  ]
  index = 0
  while index < 4
    text = fragGlyphs(counts[index])
    digit = 0
    while digit < 3
      if text[digit] != 32 then Sbar_DrawCharacter((6 * index + 1 + digit) * 8 - 2, -24, 18 + text[digit] - 48) end if
      digit = digit + 1
    end while
    index = index + 1
  end while
  baseItems = ["sb_key1", "sb_key2", "sb_invis", "sb_invuln", "sb_suit", "sb_quad"]
  index = 0
  while index < 6
    if (items & (1 << (17 + index))) != 0 then
      if not sbarHipnotic or index > 1 then Sbar_DrawPic(192 + index * 16, -16, loadedSbarPicture(baseItems[index])) end if
      itemNeedsRefresh(17 + index, currentTime)
    end if
    index = index + 1
  end while
  if sbarHipnotic then
    // MiniQuake 1.09 tests raw inventory bits 24 and 25 here.  Keep that
    // historical behavior even though the mission-pack symbolic constants
    // call later bits HIT_WETSUIT/HIT_EMPATHY_SHIELDS.
    if (items & (1 << 24)) != 0 then Sbar_DrawPic(288, -16, loadedSbarPicture("sb_wsuit")); itemNeedsRefresh(24, currentTime) end if
    if (items & (1 << 25)) != 0 then Sbar_DrawPic(304, -16, loadedSbarPicture("sb_eshld")); itemNeedsRefresh(25, currentTime) end if
  end if
  if sbarRogue then
    if (items & c.RIT_SHIELD) != 0 then Sbar_DrawPic(288, -16, loadedSbarPicture("r_shield1")); itemNeedsRefresh(29, currentTime) end if
    if (items & c.RIT_ANTIGRAV) != 0 then Sbar_DrawPic(304, -16, loadedSbarPicture("r_agrav1")); itemNeedsRefresh(30, currentTime) end if
  else
    index = 0
    while index < 4
      if (items & (1 << (28 + index))) != 0 then
        Sbar_DrawPic(288 + index * 8, -16, loadedSbarPicture("sb_sigil" + (index + 1)))
        itemNeedsRefresh(28 + index, currentTime)
      end if
      index = index + 1
    end while
  end if
  return true
end function

function Sbar_DrawFrags()
  if sbarClient is void then return false end if
  scores = sbarClient.scores
  Sbar_SortFrags(scores)
  count = scoreboardlines
  if count > 4 then count = 4 end if
  x = 23
  index = 0
  while index < count
    clientIndex = fragsort[index]
    score = scores[clientIndex]
    fillX = sbarXOffset() + x * 8 + 10
    fillY = sbarHeight - SBAR_HEIGHT - 23
    sbarDirectFill(fillX, fillY, 28, 4, Sbar_ColorForMap(score.colors & 0xf0))
    sbarDirectFill(fillX, fillY + 4, 28, 3, Sbar_ColorForMap((score.colors & 15) << 4))
    text = fragGlyphs(score.frags)
    Sbar_DrawCharacter((x + 1) * 8, -24, text[0])
    Sbar_DrawCharacter((x + 2) * 8, -24, text[1])
    Sbar_DrawCharacter((x + 3) * 8, -24, text[2])
    if clientIndex == sbarClient.viewEntity - 1 then Sbar_DrawCharacter(x * 8 + 2, -24, 16); Sbar_DrawCharacter((x + 4) * 8 - 4, -24, 17) end if
    x = x + 4
    index = index + 1
  end while
  return true
end function

function Sbar_DrawFace()
  global sb_updates
  if sbarPlayer is void then return false end if
  items = sbarItems()
  if sbarRogue and sbarClient is not void and sbarClient.maxClients != 1 and sbarTeamplay > 3.0 and sbarTeamplay < 7.0 and sbarClient.viewEntity > 0 and sbarClient.viewEntity <= len(sbarClient.scores) then
    score = sbarClient.scores[sbarClient.viewEntity - 1]
    xOffset = sbarXOffset() + 113
    Sbar_DrawPic(112, 0, loadedSbarPicture("r_teambord"))
    sbarDirectFill(xOffset, sbarHeight - SBAR_HEIGHT + 3, 22, 9, Sbar_ColorForMap(score.colors & 0xf0))
    sbarDirectFill(xOffset, sbarHeight - SBAR_HEIGHT + 12, 22, 9, Sbar_ColorForMap((score.colors & 15) << 4))
    text = fragGlyphs(score.frags)
    top = Sbar_ColorForMap(score.colors & 0xf0)
    if top == 8 then
      if text[0] != 32 then Sbar_DrawCharacter(109, 3, 18 + text[0] - 48) end if
      if text[1] != 32 then Sbar_DrawCharacter(116, 3, 18 + text[1] - 48) end if
      if text[2] != 32 then Sbar_DrawCharacter(123, 3, 18 + text[2] - 48) end if
    else
      Sbar_DrawCharacter(109, 3, text[0]); Sbar_DrawCharacter(116, 3, text[1]); Sbar_DrawCharacter(123, 3, text[2])
    end if
    return true
  end if
  face = faceNameFor(items, native.trunc(stat(c.STAT_HEALTH, sbarPlayer.health)))
  if sbarClient is not void and sbarClient.time <= sbarClient.faceAnimTime then
    sb_updates = 0
    if face == "face1" then face = "face_p1"
    else if face == "face2" then face = "face_p2"
    else if face == "face3" then face = "face_p3"
    else if face == "face4" then face = "face_p4"
    else if face == "face5" then face = "face_p5"
    end if
  end if
  return Sbar_DrawPic(112, 0, loadedSbarPicture(face))
end function

function rogueArmorName(items)
  if (items & c.RIT_ARMOR3) != 0 then return "sb_armor3" end if
  if (items & c.RIT_ARMOR2) != 0 then return "sb_armor2" end if
  if (items & c.RIT_ARMOR1) != 0 then return "sb_armor1" end if
  return ""
end function

function rogueAmmoName(items)
  if (items & c.RIT_SHELLS) != 0 then return "sb_shells" end if
  if (items & c.RIT_NAILS) != 0 then return "sb_nails" end if
  if (items & c.RIT_ROCKETS) != 0 then return "sb_rocket" end if
  if (items & c.RIT_CELLS) != 0 then return "sb_cells" end if
  if (items & c.RIT_LAVA_NAILS) != 0 then return "r_ammolava" end if
  if (items & c.RIT_PLASMA_AMMO) != 0 then return "r_ammomulti" end if
  if (items & c.RIT_MULTI_ROCKETS) != 0 then return "r_ammoplasma" end if
  return ""
end function

function Sbar_Draw()
  global sb_updates, sbarTrace, sbarCopyEverything
  sbarTrace = []
  if sbarPlayer is void then return false end if
  if sbarConsoleCurrent == sbarHeight then return false end if
  if sb_updates >= sbarNumPages then return false end if
  sbarCopyEverything = true
  sb_updates = sb_updates + 1
  if sb_lines != 0 and sbarWidth > 320 then
    sbarDirectTileClear(0, sbarHeight - sb_lines, sbarWidth, sb_lines)
  end if
  if sb_lines > 24 then
    Sbar_DrawInventory()
    if sbarClient is not void and sbarClient.maxClients != 1 then Sbar_DrawFrags() end if
  end if
  health = stat(c.STAT_HEALTH, sbarPlayer.health)
  if sb_showscores or health <= 0.0 then
    Sbar_DrawPic(0, 0, loadedSbarPicture("scorebar"))
    Sbar_DrawScoreboard()
    sb_updates = 0
  else if sb_lines != 0 then
    Sbar_DrawPic(0, 0, loadedSbarPicture("sbar"))
    items = sbarItems()
    if sbarHipnotic then
      if (items & c.IT_KEY1) != 0 then Sbar_DrawPic(209, 3, loadedSbarPicture("sb_key1")) end if
      if (items & c.IT_KEY2) != 0 then Sbar_DrawPic(209, 12, loadedSbarPicture("sb_key2")) end if
    end if
    if (items & c.IT_INVULNERABILITY) != 0 then
      Sbar_DrawNum(24, 0, 666, 3, 1)
      Sbar_DrawPic(0, 0, loadedSbarPicture("disc"))
    else
      armorColor = 0
      armorValue = stat(c.STAT_ARMOR, sbarPlayer.armor)
      if armorValue <= 25.0 then armorColor = 1 end if
      Sbar_DrawNum(24, 0, armorValue, 3, armorColor)
      armor = armorName(items)
      if sbarRogue then armor = rogueArmorName(items) end if
      if armor != "" then Sbar_DrawPic(0, 0, loadedSbarPicture(armor)) end if
    end if
    Sbar_DrawFace()
    healthColor = 0
    if health <= 25.0 then healthColor = 1 end if
    Sbar_DrawNum(136, 0, health, 3, healthColor)
    ammo = ammoName(items)
    if sbarRogue then ammo = rogueAmmoName(items) end if
    if ammo != "" then Sbar_DrawPic(224, 0, loadedSbarPicture(ammo)) end if
    ammoColor = 0
    ammoValue = stat(c.STAT_AMMO, sbarPlayer.ammo)
    if ammoValue <= 10.0 then ammoColor = 1 end if
    Sbar_DrawNum(248, 0, ammoValue, 3, ammoColor)
  end if
  if sbarGameType == c.GAME_DEATHMATCH and sbarWidth > 320 then Sbar_MiniDeathmatchOverlay() end if
  return true
end function

function Sbar_IntermissionNumber(x, y, num, digits, color)
  converted = Sbar_itoa(num)
  text = bytes(converted[0])
  start = 0
  if len(text) > digits then start = len(text) - digits end if
  if len(text) < digits then x = x + (digits - len(text)) * 24 end if
  index = start
  while index < len(text)
    frame = text[index] - 48
    if text[index] == 45 then frame = STAT_MINUS end if
    sbarDirectTransPic(x, y, numberPicture(color, frame))
    x = x + 24
    index = index + 1
  end while
  return true
end function

function sbarOverlayPic(x, y, pic, transform, transparent)
  if pic is void then return false end if
  drawX = transform[0] + x * transform[2]
  drawY = transform[1] + y * transform[2]
  command = "pic"
  if transparent then command = "transpic" end if
  traceSbar([command, pic.name, drawX, drawY, transform[2]])
  return draw.Draw_PicSized(
    pic,
    drawX,
    drawY,
    pic.width * transform[2],
    pic.height * transform[2],
    255,
  )
end function

function Sbar_IntermissionNumberScaled(x, y, num, digits, color, transform)
  converted = Sbar_itoa(num)
  text = bytes(converted[0])
  start = 0
  if len(text) > digits then start = len(text) - digits end if
  if len(text) < digits then x = x + (digits - len(text)) * 24 end if
  index = start
  while index < len(text)
    frame = text[index] - 48
    if text[index] == 45 then frame = STAT_MINUS end if
    sbarOverlayPic(x, y, numberPicture(color, frame), transform, true)
    x = x + 24
    index = index + 1
  end while
  return true
end function

function Sbar_DeathmatchOverlay()
  global sbarCopyEverything, sbarFullUpdate
  if sbarClient is void then return false end if
  sbarCopyEverything = true
  sbarFullUpdate = 0
  ranking = try(draw.Draw_CachePic("gfx/ranking.lmp"))
  if ranking is not error then sbarDirectPic(native.trunc((sbarWidth - ranking.width) / 2), 8, ranking) end if
  scores = sbarClient.scores
  Sbar_SortFrags(scores)
  x = 80 + native.trunc((sbarWidth - 320) / 2)
  y = 40
  index = 0
  while index < scoreboardlines
    clientIndex = fragsort[index]
    score = scores[clientIndex]
    sbarDirectFill(x, y, 40, 4, Sbar_ColorForMap(score.colors & 0xf0))
    sbarDirectFill(x, y + 4, 40, 4, Sbar_ColorForMap((score.colors & 15) << 4))
    text = fragGlyphs(score.frags)
    sbarDirectCharacter(x + 8, y, text[0]); sbarDirectCharacter(x + 16, y, text[1]); sbarDirectCharacter(x + 24, y, text[2])
    if clientIndex == sbarClient.viewEntity - 1 then sbarDirectCharacter(x - 8, y, 12) end if
    sbarDirectString(x + 64, y, score.name)
    traceSbar(["score", clientIndex, score.frags, score.name, x, y])
    y = y + 10
    index = index + 1
  end while
  return true
end function

function Sbar_MiniDeathmatchOverlay()
  global sbarCopyEverything, sbarFullUpdate
  if sbarClient is void or sbarWidth < 512 or sb_lines == 0 then return false end if
  sbarCopyEverything = true
  sbarFullUpdate = 0
  scores = sbarClient.scores
  Sbar_SortFrags(scores)
  numLines = native.trunc(sb_lines / 8)
  if numLines < 3 then return false end if
  current = 0
  while current < scoreboardlines and fragsort[current] != sbarClient.viewEntity - 1
    current = current + 1
  end while
  start = current - native.trunc(numLines / 2)
  if current == scoreboardlines then start = 0 end if
  if start > scoreboardlines - numLines then start = scoreboardlines - numLines end if
  if start < 0 then start = 0 end if
  x = 324
  y = sbarHeight - sb_lines
  index = start
  while index < scoreboardlines and y < sbarHeight - 8
    clientIndex = fragsort[index]
    score = scores[clientIndex]
    sbarDirectFill(x, y + 1, 40, 3, Sbar_ColorForMap(score.colors & 0xf0))
    sbarDirectFill(x, y + 4, 40, 4, Sbar_ColorForMap((score.colors & 15) << 4))
    text = fragGlyphs(score.frags)
    sbarDirectCharacter(x + 8, y, text[0]); sbarDirectCharacter(x + 16, y, text[1]); sbarDirectCharacter(x + 24, y, text[2])
    if clientIndex == sbarClient.viewEntity - 1 then sbarDirectCharacter(x, y, 16); sbarDirectCharacter(x + 32, y, 17) end if
    sbarDirectString(x + 48, y, score.name)
    traceSbar(["miniscore", clientIndex, score.frags, score.name, x, y])
    y = y + 8
    index = index + 1
  end while
  return true
end function

function Sbar_IntermissionOverlay()
  global sbarCopyEverything, sbarFullUpdate
  sbarCopyEverything = true
  sbarFullUpdate = 0
  if sbarGameType == c.GAME_DEATHMATCH then return Sbar_DeathmatchOverlay() end if
  complete = try(draw.Draw_CachePic("gfx/complete.lmp"))
  inter = try(draw.Draw_CachePic("gfx/inter.lmp"))
  completed = 0.0
  if sbarClient is not void then completed = sbarClient.completedTime end if
  minutes = native.trunc(completed / 60.0)
  seconds = native.trunc(completed - minutes * 60)
  transform = menu.layout(sbarWidth, sbarHeight)
  if transform[2] <= 1.0 then
    if complete is not error then sbarDirectPic(64, 24, complete) end if
    if inter is not error then sbarDirectTransPic(0, 56, inter) end if
    Sbar_IntermissionNumber(160, 64, minutes, 3, 0)
    sbarDirectTransPic(234, 64, loadedSbarPicture("num_colon"))
    sbarDirectTransPic(246, 64, numberPicture(0, native.trunc(seconds / 10)))
    sbarDirectTransPic(266, 64, numberPicture(0, seconds % 10))
    Sbar_IntermissionNumber(160, 104, stat(c.STAT_SECRETS, 0), 3, 0)
    sbarDirectTransPic(232, 104, loadedSbarPicture("num_slash"))
    Sbar_IntermissionNumber(240, 104, stat(c.STAT_TOTALSECRETS, 0), 3, 0)
    Sbar_IntermissionNumber(160, 144, stat(c.STAT_MONSTERS, 0), 3, 0)
    sbarDirectTransPic(232, 144, loadedSbarPicture("num_slash"))
    Sbar_IntermissionNumber(240, 144, stat(c.STAT_TOTALMONSTERS, 0), 3, 0)
  else
    if complete is not error then sbarOverlayPic(64, 24, complete, transform, false) end if
    if inter is not error then sbarOverlayPic(0, 56, inter, transform, true) end if
    Sbar_IntermissionNumberScaled(160, 64, minutes, 3, 0, transform)
    sbarOverlayPic(234, 64, loadedSbarPicture("num_colon"), transform, true)
    sbarOverlayPic(246, 64, numberPicture(0, native.trunc(seconds / 10)), transform, true)
    sbarOverlayPic(266, 64, numberPicture(0, seconds % 10), transform, true)
    Sbar_IntermissionNumberScaled(160, 104, stat(c.STAT_SECRETS, 0), 3, 0, transform)
    sbarOverlayPic(232, 104, loadedSbarPicture("num_slash"), transform, true)
    Sbar_IntermissionNumberScaled(240, 104, stat(c.STAT_TOTALSECRETS, 0), 3, 0, transform)
    Sbar_IntermissionNumberScaled(160, 144, stat(c.STAT_MONSTERS, 0), 3, 0, transform)
    sbarOverlayPic(232, 144, loadedSbarPicture("num_slash"), transform, true)
    Sbar_IntermissionNumberScaled(240, 144, stat(c.STAT_TOTALMONSTERS, 0), 3, 0, transform)
  end if
  traceSbar(["intermission", minutes, seconds])
  return true
end function

function Sbar_FinaleOverlay()
  global sbarCopyEverything
  sbarCopyEverything = true
  finale = try(draw.Draw_CachePic("gfx/finale.lmp"))
  if finale is error then return finale end if
  transform = menu.layout(sbarWidth, sbarHeight)
  if transform[2] <= 1.0 then
    drawX = native.trunc((sbarWidth - finale.width) / 2)
    sbarDirectTransPic(drawX, 16, finale)
    traceSbar(["finale", drawX, 16])
  else
    virtualX = (320.0 - finale.width) * 0.5
    sbarOverlayPic(virtualX, 16, finale, transform, true)
    traceSbar(["finale", transform[0] + virtualX * transform[2], transform[1] + 16.0 * transform[2], transform[2]])
  end if
  return true
end function

function Sbar_CommandTrace()
  return sbarTrace
end function

function Sbar_LayoutTrace(gameDirectory, player, clientState, width, height, lines, teamplay)
  global sbarHipnotic, sbarRogue
  previousHipnotic = sbarHipnotic
  previousRogue = sbarRogue
  sbarHipnotic = bio.lower(gameDirectory) == "hipnotic"
  sbarRogue = bio.lower(gameDirectory) == "rogue"
  result = [
    ["game", gameDirectory],
    ["inventory", lines > 24],
    ["rogue-powered", sbarRogue and player is not void and player.activeWeapon >= c.RIT_LAVA_NAILGUN],
    ["hipnotic-extra", sbarHipnotic],
    ["team-face", sbarRogue and clientState is not void and clientState.maxClients != 1 and teamplay > 3.0 and teamplay < 7.0],
    ["deathmatch", clientState is not void and clientState.gameType == c.GAME_DEATHMATCH],
  ]
  sbarHipnotic = previousHipnotic
  sbarRogue = previousRogue
  return result
end function
