package miniquake.menu

import miniquake.types as t
import miniquake.render.draw2d as menuDraw
import miniquake.render.gl11 as menuGl
import miniquake.filesystem as menuFs
import miniquake.cvar as menuCvar
import miniquake.native as menuNative
import miniquake.wad as menuWad
import miniquake.input as menuInput

const PAGE_MAIN = "main"
const PAGE_SINGLE = "singleplayer"
const PAGE_MULTI = "multiplayer"
// Descriptive aliases retained for callers that use the long names.
const PAGE_SINGLEPLAYER = PAGE_SINGLE
const PAGE_MULTIPLAYER = PAGE_MULTI
const PAGE_OPTIONS = "options"
const PAGE_KEYS = "keys"
const PAGE_LOAD = "load"
const PAGE_SAVE = "save"
const PAGE_SETUP = "setup"
const PAGE_VIDEO = "video"
const PAGE_HELP = "help"
const PAGE_QUIT = "quit"
const HELP_PAGES = 6

function mainItems()
  return ["Single Player", "Multiplayer", "Options", "Help", "Quit"]
end function

function singlePlayerItems()
  return ["New Game", "Load", "Save"]
end function

function multiplayerItems()
  return ["Join a Game", "New Game", "Setup"]
end function

function optionsItems()
  // OPTIONS_ITEMS is 14 in WinQuake on Windows.
  return [
    "Customize controls",
    "Go to console",
    "Reset to defaults",
    "Screen size",
    "Brightness",
    "Mouse Speed",
    "CD Music Volume",
    "Sound Volume",
    "Always Run",
    "Invert Mouse",
    "Lookspring",
    "Lookstrafe",
    "Video Options",
    "Use Mouse",
  ]
end function

function keyCommands()
  // bindnames from WinQuake/menu.c, kept in the original order.
  return [
    "+attack", "impulse 10", "+jump", "+forward", "+back", "+left",
    "+right", "+speed", "+moveleft", "+moveright", "+strafe", "+lookup",
    "+lookdown", "centerview", "+mlook", "+klook", "+moveup", "+movedown",
  ]
end function

function keyItems()
  return [
    "attack", "change weapon", "jump / swim up", "walk forward", "backpedal",
    "turn left", "turn right", "run", "step left", "step right", "sidestep",
    "look up", "look down", "center view", "mouse look", "keyboard look",
    "swim up", "swim down",
  ]
end function

function saveSlotItems()
  return [
    "--- UNUSED SLOT ---", "--- UNUSED SLOT ---", "--- UNUSED SLOT ---",
    "--- UNUSED SLOT ---", "--- UNUSED SLOT ---", "--- UNUSED SLOT ---",
    "--- UNUSED SLOT ---", "--- UNUSED SLOT ---", "--- UNUSED SLOT ---",
    "--- UNUSED SLOT ---", "--- UNUSED SLOT ---", "--- UNUSED SLOT ---",
  ]
end function

function itemsForPage(page)
  if page == PAGE_MAIN then return mainItems() end if
  if page == PAGE_SINGLEPLAYER then return singlePlayerItems() end if
  if page == PAGE_MULTIPLAYER then return multiplayerItems() end if
  if page == PAGE_OPTIONS then return optionsItems() end if
  if page == PAGE_KEYS then return keyItems() end if
  if page == PAGE_LOAD or page == PAGE_SAVE then return saveSlotItems() end if
  if page == PAGE_SETUP then return ["Name", "Shirt color", "Pants color", "Accept Changes"] end if
  if page == PAGE_VIDEO then return ["Windowed mode", "Resolution", "Apply on restart"] end if
  return []
end function

function titleForPage(page)
  if page == PAGE_SINGLEPLAYER then return "SINGLE PLAYER" end if
  if page == PAGE_MULTIPLAYER then return "MULTIPLAYER" end if
  if page == PAGE_OPTIONS then return "OPTIONS" end if
  if page == PAGE_KEYS then return "CUSTOMIZE CONTROLS" end if
  if page == PAGE_LOAD then return "LOAD" end if
  if page == PAGE_SAVE then return "SAVE" end if
  if page == PAGE_SETUP then return "SETUP" end if
  if page == PAGE_VIDEO then return "VIDEO OPTIONS" end if
  if page == PAGE_HELP then return "HELP" end if
  if page == PAGE_QUIT then return "QUIT" end if
  return "QUAKE"
end function

function create()
  return t.MenuState(
    false,
    0,
    mainItems(),
    "QUAKE",
    false,
    PAGE_MAIN,
    PAGE_MAIN,
    0,
    [],
    false,
    "",
    false,
  )
end function

function openPage(state, page)
  if page == PAGE_QUIT then state.previousPage = state.page end if
  state.page = page
  state.title = titleForPage(page)
  state.items = itemsForPage(page)
  state.selection = 0
  state.statusText = ""
  state.waitingForKey = false
  if page == PAGE_HELP then state.helpPage = 0 end if
  return page
end function

// Public spelling used by the host and tests.  Keeping page changes in one
// function ensures selection/status state is reset exactly once.
function setPage(state, page)
  return openPage(state, page)
end function

function openMain(state)
  openPage(state, PAGE_MAIN)
  state.active = true
  return true
end function

function setStatus(state, text)
  state.statusText = text
  return text
end function

function setActive(state, active)
  state.active = active
  if active and state.page == "" then openPage(state, PAGE_MAIN) end if
  if state.selection < 0 or state.selection >= len(state.items) then state.selection = 0 end if
  return state.active
end function

function toggle(state)
  if state.active then return setActive(state, false) end if
  return openMain(state)
end function

function move(state, delta)
  if state.page == PAGE_HELP then return moveHelp(state, delta) end if
  if len(state.items) == 0 then state.selection = 0; return 0 end if
  state.selection = state.selection + delta
  while state.selection < 0
    state.selection = state.selection + len(state.items)
  end while
  while state.selection >= len(state.items)
    state.selection = state.selection - len(state.items)
  end while
  state.statusText = ""
  return state.selection
end function

function moveHelp(state, delta)
  state.helpPage = state.helpPage + delta
  while state.helpPage < 0
    state.helpPage = state.helpPage + HELP_PAGES
  end while
  while state.helpPage >= HELP_PAGES
    state.helpPage = state.helpPage - HELP_PAGES
  end while
  return state.helpPage
end function

function changeHelpPage(state, delta)
  return moveHelp(state, delta)
end function

// This mirrors the original escape path: submenus return to the main menu;
// escape from the main menu returns to the game; quit returns to its caller.
function back(state)
  if state.waitingForKey then state.waitingForKey = false; return "page" end if
  if state.page == PAGE_MAIN then return "close" end if
  if state.page == PAGE_QUIT then
    previous = state.previousPage
    if previous == "" or previous == PAGE_QUIT then previous = PAGE_MAIN end if
    openPage(state, previous)
    return "page"
  end if
  if state.page == PAGE_KEYS or state.page == PAGE_VIDEO then
    openPage(state, PAGE_OPTIONS)
  else if state.page == PAGE_LOAD or state.page == PAGE_SAVE then
    openPage(state, PAGE_SINGLEPLAYER)
  else if state.page == PAGE_SETUP then
    openPage(state, PAGE_MULTIPLAYER)
  else
    openPage(state, PAGE_MAIN)
  end if
  return "page"
end function

function selectedCommand(state)
  if state.page == PAGE_MAIN then
    if state.selection == 0 then return "menu_single" end if
    if state.selection == 1 then return "menu_multi" end if
    if state.selection == 2 then return "menu_options" end if
    if state.selection == 3 then return "menu_help" end if
    if state.selection == 4 then return "menu_quit" end if
  else if state.page == PAGE_SINGLEPLAYER then
    if state.selection == 0 then return "new_game" end if
    if state.selection == 1 then return "load_game" end if
    if state.selection == 2 then return "save_game" end if
  else if state.page == PAGE_MULTIPLAYER then
    if state.selection == 0 then return "join_game" end if
    if state.selection == 1 then return "host_game" end if
    if state.selection == 2 then return "player_setup" end if
  else if state.page == PAGE_OPTIONS then
    if state.selection == 0 then return "customize_controls" end if
    if state.selection == 1 then return "open_console" end if
    if state.selection == 2 then return "reset_defaults" end if
    if state.selection == 12 then return "video_options" end if
    return "adjust_option"
  else if state.page == PAGE_KEYS then
    return "bind_selected"
  else if state.page == PAGE_LOAD then
    return "load_slot"
  else if state.page == PAGE_SAVE then
    return "save_slot"
  else if state.page == PAGE_SETUP then
    return "setup_option"
  else if state.page == PAGE_VIDEO then
    return "video_option"
  else if state.page == PAGE_HELP then
    return "help_next"
  end if
  return "none"
end function

function findPicture(state, name)
  for each pictureValue in state.pictures
    if pictureValue.name == name then return pictureValue end if
  end for
  return void
end function

function loadPicture(state, filesystem, palette, path, transparent)
  if findPicture(state, path) is not void then return true end if
  source = try(menuFs.readFile(filesystem, path))
  if source is error then return false end if
  pictureValue = try(menuDraw.uploadPicture(source, palette, path, transparent))
  if pictureValue is error then return false end if
  state.pictures = state.pictures + [pictureValue]
  return true
end function

// Draw_PicFromWad compatibility. Status-bar and common UI pictures live in
// gfx.wad rather than as loose qpic files. Keep a distinct registry key so a
// WAD lump can never collide with a similarly named filesystem picture.
function loadWadPicture(state, archive, palette, lumpName, transparent)
  key = "wad:" + lumpName
  if findPicture(state, key) is not void then return true end if
  source = try(menuWad.readLump(archive, lumpName))
  if source is error then return false end if
  pictureValue = try(menuDraw.uploadPicture(source, palette, key, transparent))
  if pictureValue is error then return false end if
  state.pictures = state.pictures + [pictureValue]
  return true
end function

function findWadPicture(state, lumpName)
  return findPicture(state, "wad:" + lumpName)
end function

function loadStatusBarPictures(state, filesystem, palette)
  wadData = try(menuFs.readFile(filesystem, "gfx.wad"))
  if wadData is error then return false end if
  archive = try(menuWad.parse(wadData, "gfx.wad"))
  if archive is error then return false end if

  // Opaque 320-pixel backdrops.
  loadWadPicture(state, archive, palette, "sbar", false)
  loadWadPicture(state, archive, palette, "ibar", false)
  loadWadPicture(state, archive, palette, "scorebar", false)

  index = 0
  while index < 10
    loadWadPicture(state, archive, palette, "num_" + index, true)
    loadWadPicture(state, archive, palette, "anum_" + index, true)
    index = index + 1
  end while
  loadWadPicture(state, archive, palette, "num_minus", true)
  loadWadPicture(state, archive, palette, "anum_minus", true)
  loadWadPicture(state, archive, palette, "num_colon", true)
  loadWadPicture(state, archive, palette, "num_slash", true)
  loadWadPicture(state, archive, palette, "disc", true)

  weaponNames = ["shotgun", "sshotgun", "nailgun", "snailgun", "rlaunch", "srlaunch", "lightng"]
  for each weaponName in weaponNames
    loadWadPicture(state, archive, palette, "inv_" + weaponName, true)
    loadWadPicture(state, archive, palette, "inv2_" + weaponName, true)
    flash = 1
    while flash <= 5
      loadWadPicture(state, archive, palette, "inva" + flash + "_" + weaponName, true)
      flash = flash + 1
    end while
  end for

  simpleNames = [
    "sb_shells", "sb_nails", "sb_rocket", "sb_cells",
    "sb_armor1", "sb_armor2", "sb_armor3",
    "sb_key1", "sb_key2", "sb_invis", "sb_invuln", "sb_suit", "sb_quad",
    "sb_sigil1", "sb_sigil2", "sb_sigil3", "sb_sigil4",
    "face1", "face_p1", "face2", "face_p2", "face3", "face_p3",
    "face4", "face_p4", "face5", "face_p5",
    "face_invis", "face_invul2", "face_inv2", "face_quad",
  ]
  for each lumpName in simpleNames
    loadWadPicture(state, archive, palette, lumpName, true)
  end for
  return true
end function

function initialize(state, filesystem, palette)
  if state is void or state.initialized then return true end if

  // These are the qpic_t resources cached by the original WinQuake menu.c.
  loadPicture(state, filesystem, palette, "gfx/qplaque.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/ttl_main.lmp", false)
  loadPicture(state, filesystem, palette, "gfx/mainmenu.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/ttl_sgl.lmp", false)
  loadPicture(state, filesystem, palette, "gfx/sp_menu.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/p_multi.lmp", false)
  loadPicture(state, filesystem, palette, "gfx/mp_menu.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/p_option.lmp", false)
  loadPicture(state, filesystem, palette, "gfx/p_load.lmp", false)
  loadPicture(state, filesystem, palette, "gfx/p_save.lmp", false)
  loadPicture(state, filesystem, palette, "gfx/ttl_cstm.lmp", false)
  loadPicture(state, filesystem, palette, "gfx/menuplyr.lmp", true)

  // Original menu dialog frame pieces.  They are loaded from the user's Quake
  // data and are available for the quit/confirmation panels and future save
  // slot pages; no copyrighted artwork is embedded in MiniQuake itself.
  loadPicture(state, filesystem, palette, "gfx/box_tl.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/box_ml.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/box_bl.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/box_tm.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/box_mm.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/box_mm2.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/box_bm.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/box_tr.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/box_mr.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/box_br.lmp", true)

  index = 1
  while index <= 6
    loadPicture(state, filesystem, palette, "gfx/menudot" + index + ".lmp", true)
    index = index + 1
  end while
  index = 0
  while index < HELP_PAGES
    loadPicture(state, filesystem, palette, "gfx/help" + index + ".lmp", false)
    index = index + 1
  end while

  // Sbar_Init / Draw_Init resources from gfx.wad. The pictures remain owned by
  // the shared UI registry and are deleted by menu.shutdown with the menu art.
  loadStatusBarPictures(state, filesystem, palette)

  state.initialized = true
  return true
end function

function shutdown(state)
  if state is void then return true end if
  for each pictureValue in state.pictures
    if pictureValue is not void and pictureValue.textureId != 0 then
      menuGl.deleteTexture(pictureValue.textureId)
      pictureValue.textureId = 0
    end if
  end for
  state.pictures = []
  state.initialized = false
  return true
end function

function layout(width, height)
  scaleX = width / 320.0
  scaleY = height / 200.0
  scale = scaleX
  if scaleY < scale then scale = scaleY end if
  // Nearest-filtered 1996 menu art stays crisp only at an integer scale.  The
  // unscaled 320x200 layout is kept when the window is smaller than that.
  scale = menuNative.trunc(scale)
  if scale < 1 then scale = 1 end if
  originX = (width - 320.0 * scale) * 0.5
  originY = (height - 200.0 * scale) * 0.5
  return [originX, originY, scale]
end function

function virtualPicture(state, name, x, y, transform, alpha)
  pictureValue = findPicture(state, name)
  if pictureValue is void or pictureValue.textureId == 0 then return false end if
  scale = transform[2]
  menuDraw.texturedQuad(
    pictureValue.textureId,
    transform[0] + x * scale,
    transform[1] + y * scale,
    pictureValue.width * scale,
    pictureValue.height * scale,
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

function virtualCenteredPicture(state, name, y, transform, alpha)
  pictureValue = findPicture(state, name)
  if pictureValue is void then return false end if
  return virtualPicture(state, name, (320.0 - pictureValue.width) * 0.5, y, transform, alpha)
end function

function virtualString(texture, x, y, text, transform, alpha)
  if texture == 0 then return false end if
  // M_Print uses the brown character bank in conchars (ASCII + 128).
  source = bytes(text)
  cursorX = x
  cursorY = y
  index = 0
  while index < len(source)
    code = source[index]
    if code == 10 then
      cursorX = x
      cursorY = cursorY + 8.0
    else if code >= 32 then
      menuDraw.character(
        texture,
        transform[0] + cursorX * transform[2],
        transform[1] + cursorY * transform[2],
        (code + 128) & 255,
        transform[2],
        alpha,
      )
      cursorX = cursorX + 8.0
    end if
    index = index + 1
  end while
  return true
end function

function virtualWhiteString(texture, x, y, text, transform, alpha)
  if texture == 0 then return false end if
  // M_PrintWhite uses the normal ASCII bank unchanged.
  menuDraw.string(
    texture,
    transform[0] + x * transform[2],
    transform[1] + y * transform[2],
    text,
    transform[2],
    alpha,
  )
  return true
end function

function virtualCenteredString(texture, y, text, transform, alpha)
  x = (320.0 - len(bytes(text)) * 8.0) * 0.5
  if x < 0.0 then x = 0.0 end if
  return virtualString(texture, x, y, text, transform, alpha)
end function

function virtualSolid(x, y, width, height, transform, red, green, blue, alpha)
  menuDraw.solidQuad(
    transform[0] + x * transform[2],
    transform[1] + y * transform[2],
    width * transform[2],
    height * transform[2],
    red,
    green,
    blue,
    alpha,
  )
end function

// M_DrawTextBox from WinQuake/menu.c. Width is measured in characters; every
// center tile covers two characters (16 pixels).
function drawTextBox(state, x, y, width, lines, transform)
  cx = x
  cy = y
  virtualPicture(state, "gfx/box_tl.lmp", cx, cy, transform, 255)
  row = 0
  while row < lines
    cy = cy + 8.0
    virtualPicture(state, "gfx/box_ml.lmp", cx, cy, transform, 255)
    row = row + 1
  end while
  virtualPicture(state, "gfx/box_bl.lmp", cx, cy + 8.0, transform, 255)

  cx = cx + 8.0
  remaining = width
  while remaining > 0
    cy = y
    virtualPicture(state, "gfx/box_tm.lmp", cx, cy, transform, 255)
    row = 0
    middle = "gfx/box_mm.lmp"
    while row < lines
      cy = cy + 8.0
      // M_DrawTextBox changes to box_mm2 at row one and keeps that tile for
      // every following row; it does not switch back to box_mm.
      if row >= 1 then middle = "gfx/box_mm2.lmp" end if
      virtualPicture(state, middle, cx, cy, transform, 255)
      row = row + 1
    end while
    virtualPicture(state, "gfx/box_bm.lmp", cx, cy + 8.0, transform, 255)
    remaining = remaining - 2
    cx = cx + 16.0
  end while

  cy = y
  virtualPicture(state, "gfx/box_tr.lmp", cx, cy, transform, 255)
  row = 0
  while row < lines
    cy = cy + 8.0
    virtualPicture(state, "gfx/box_mr.lmp", cx, cy, transform, 255)
    row = row + 1
  end while
  virtualPicture(state, "gfx/box_br.lmp", cx, cy + 8.0, transform, 255)
  return true
end function

function drawFallbackList(state, texture, transform)
  virtualCenteredString(texture, 12.0, state.title, transform, 255)
  y = 48.0
  index = 0
  while index < len(state.items)
    prefix = "  "
    if index == state.selection then prefix = "> " end if
    virtualCenteredString(texture, y, prefix + state.items[index], transform, 255)
    y = y + 16.0
    index = index + 1
  end while
end function

function drawDot(state, realtime, y, transform)
  frame = (menuNative.trunc(realtime * 10.0) % 6) + 1
  return virtualPicture(state, "gfx/menudot" + frame + ".lmp", 54.0, y, transform, 255)
end function

function drawMain(state, texture, transform, realtime)
  plaque = virtualPicture(state, "gfx/qplaque.lmp", 16.0, 4.0, transform, 255)
  title = virtualCenteredPicture(state, "gfx/ttl_main.lmp", 4.0, transform, 255)
  body = virtualPicture(state, "gfx/mainmenu.lmp", 72.0, 32.0, transform, 255)
  drawDot(state, realtime, 32.0 + state.selection * 20.0, transform)
  if not plaque or not title or not body then drawFallbackList(state, texture, transform) end if
end function

function drawSinglePlayer(state, texture, transform, realtime)
  plaque = virtualPicture(state, "gfx/qplaque.lmp", 16.0, 4.0, transform, 255)
  title = virtualCenteredPicture(state, "gfx/ttl_sgl.lmp", 4.0, transform, 255)
  body = virtualPicture(state, "gfx/sp_menu.lmp", 72.0, 32.0, transform, 255)
  drawDot(state, realtime, 32.0 + state.selection * 20.0, transform)
  if not plaque or not title or not body then drawFallbackList(state, texture, transform) end if
end function

function drawMultiplayer(state, texture, transform, realtime)
  plaque = virtualPicture(state, "gfx/qplaque.lmp", 16.0, 4.0, transform, 255)
  title = virtualCenteredPicture(state, "gfx/p_multi.lmp", 4.0, transform, 255)
  body = virtualPicture(state, "gfx/mp_menu.lmp", 72.0, 32.0, transform, 255)
  drawDot(state, realtime, 32.0 + state.selection * 20.0, transform)
  if not plaque or not title or not body then drawFallbackList(state, texture, transform) end if
  virtualCenteredString(texture, 148.0, "UDP/IP NETWORK PLAY IS WIP", transform, 190)
end function

function drawSlider(texture, x, y, range, transform)
  if range < 0.0 then range = 0.0 end if
  if range > 1.0 then range = 1.0 end if
  scale = transform[2]
  menuDraw.character(texture, transform[0] + (x - 8.0) * scale, transform[1] + y * scale, 128, scale, 255)
  index = 0
  while index < 10
    menuDraw.character(texture, transform[0] + (x + index * 8.0) * scale, transform[1] + y * scale, 129, scale, 255)
    index = index + 1
  end while
  menuDraw.character(texture, transform[0] + (x + 80.0) * scale, transform[1] + y * scale, 130, scale, 255)
  menuDraw.character(texture, transform[0] + (x + 72.0 * range) * scale, transform[1] + y * scale, 131, scale, 255)
end function

function drawCheckbox(texture, x, y, enabled, transform)
  if enabled then
    virtualString(texture, x, y, "on", transform, 255)
  else
    virtualString(texture, x, y, "off", transform, 255)
  end if
end function

function drawOptions(state, texture, transform, realtime, registry)
  plaque = virtualPicture(state, "gfx/qplaque.lmp", 16.0, 4.0, transform, 255)
  title = virtualCenteredPicture(state, "gfx/p_option.lmp", 4.0, transform, 255)
  if not plaque or not title then drawFallbackList(state, texture, transform); return end if

  virtualString(texture, 16.0, 32.0, "    Customize controls", transform, 255)
  virtualString(texture, 16.0, 40.0, "         Go to console", transform, 255)
  virtualString(texture, 16.0, 48.0, "     Reset to defaults", transform, 255)
  virtualString(texture, 16.0, 56.0, "           Screen size", transform, 255)
  virtualString(texture, 16.0, 64.0, "            Brightness", transform, 255)
  virtualString(texture, 16.0, 72.0, "           Mouse Speed", transform, 255)
  virtualString(texture, 16.0, 80.0, "       CD Music Volume", transform, 255)
  virtualString(texture, 16.0, 88.0, "          Sound Volume", transform, 255)
  virtualString(texture, 16.0, 96.0, "            Always Run", transform, 255)
  virtualString(texture, 16.0, 104.0, "          Invert Mouse", transform, 255)
  virtualString(texture, 16.0, 112.0, "            Lookspring", transform, 255)
  virtualString(texture, 16.0, 120.0, "            Lookstrafe", transform, 255)
  virtualString(texture, 16.0, 128.0, "         Video Options", transform, 255)
  virtualString(texture, 16.0, 136.0, "             Use Mouse", transform, 255)

  viewSize = menuCvar.variableValue(registry, "viewsize")
  gamma = menuCvar.variableValue(registry, "gamma")
  sensitivity = menuCvar.variableValue(registry, "sensitivity")
  bgm = menuCvar.variableValue(registry, "bgmvolume")
  volume = menuCvar.variableValue(registry, "volume")
  forwardSpeed = menuCvar.variableValue(registry, "cl_forwardspeed")
  pitch = menuCvar.variableValue(registry, "m_pitch")
  lookSpring = menuCvar.variableValue(registry, "lookspring")
  lookStrafe = menuCvar.variableValue(registry, "lookstrafe")
  windowedMouse = menuCvar.variableValue(registry, "_windowed_mouse")

  drawSlider(texture, 220.0, 56.0, (viewSize - 30.0) / 90.0, transform)
  drawSlider(texture, 220.0, 64.0, (1.0 - gamma) / 0.5, transform)
  drawSlider(texture, 220.0, 72.0, (sensitivity - 1.0) / 10.0, transform)
  drawSlider(texture, 220.0, 80.0, bgm, transform)
  drawSlider(texture, 220.0, 88.0, volume, transform)
  drawCheckbox(texture, 220.0, 96.0, forwardSpeed > 200.0, transform)
  drawCheckbox(texture, 220.0, 104.0, pitch < 0.0, transform)
  drawCheckbox(texture, 220.0, 112.0, lookSpring != 0.0, transform)
  drawCheckbox(texture, 220.0, 120.0, lookStrafe != 0.0, transform)
  drawCheckbox(texture, 220.0, 136.0, windowedMouse != 0.0, transform)

  cursorCode = 12 + (menuNative.trunc(realtime * 4.0) & 1)
  menuDraw.character(
    texture,
    transform[0] + 200.0 * transform[2],
    transform[1] + (32.0 + state.selection * 8.0) * transform[2],
    cursorCode,
    transform[2],
    255,
  )
end function

function keyCommandAt(state)
  commands = keyCommands()
  if state.selection < 0 or state.selection >= len(commands) then return "" end if
  return commands[state.selection]
end function

function drawKeys(state, texture, transform, realtime)
  virtualCenteredPicture(state, "gfx/ttl_cstm.lmp", 4.0, transform, 255)
  if state.waitingForKey then
    virtualString(texture, 12.0, 32.0, "Press a key or button for this action", transform, 255)
  else
    virtualString(texture, 18.0, 32.0, "Enter to change, backspace to clear", transform, 255)
  end if
  commands = keyCommands()
  index = 0
  while index < len(state.items)
    y = 48.0 + index * 8.0
    virtualString(texture, 16.0, y, state.items[index], transform, 255)
    virtualString(texture, 140.0, y, menuInput.bindingForCommand(commands[index]), transform, 255)
    index = index + 1
  end while
  cursor = 12 + (menuNative.trunc(realtime * 4.0) & 1)
  if state.waitingForKey then cursor = 61 end if
  menuDraw.character(
    texture,
    transform[0] + 130.0 * transform[2],
    transform[1] + (48.0 + state.selection * 8.0) * transform[2],
    cursor,
    transform[2],
    255,
  )
end function

function drawSaveSlots(state, texture, transform, realtime, page)
  pictureName = "gfx/p_load.lmp"
  if page == PAGE_SAVE then pictureName = "gfx/p_save.lmp" end if
  virtualCenteredPicture(state, pictureName, 4.0, transform, 255)
  index = 0
  while index < len(state.items)
    virtualString(texture, 16.0, 32.0 + index * 8.0, state.items[index], transform, 255)
    index = index + 1
  end while
  cursor = 12 + (menuNative.trunc(realtime * 4.0) & 1)
  menuDraw.character(texture, transform[0] + 8.0 * transform[2], transform[1] + (32.0 + state.selection * 8.0) * transform[2], cursor, transform[2], 255)
end function

function drawSetup(state, texture, transform, realtime)
  virtualCenteredPicture(state, "gfx/p_multi.lmp", 4.0, transform, 255)
  virtualString(texture, 64.0, 40.0, "Your name", transform, 255)
  drawTextBox(state, 160.0, 32.0, 16, 1, transform)
  virtualWhiteString(texture, 168.0, 40.0, "player", transform, 255)
  virtualString(texture, 64.0, 64.0, "Shirt color", transform, 255)
  virtualString(texture, 64.0, 88.0, "Pants color", transform, 255)
  virtualPicture(state, "gfx/menuplyr.lmp", 172.0, 72.0, transform, 255)
  drawTextBox(state, 64.0, 140.0, 14, 1, transform)
  virtualString(texture, 72.0, 148.0, "Accept Changes", transform, 255)
  cursor = 12 + (menuNative.trunc(realtime * 4.0) & 1)
  cursorY = [40.0, 64.0, 88.0, 148.0][state.selection]
  menuDraw.character(texture, transform[0] + 56.0 * transform[2], transform[1] + cursorY * transform[2], cursor, transform[2], 255)
  virtualCenteredString(texture, 176.0, "NAME/COLOR EDITING IS STILL PENDING", transform, 180)
end function

function drawVideo(state, texture, transform, realtime)
  virtualCenteredPicture(state, "gfx/p_option.lmp", 4.0, transform, 255)
  virtualCenteredString(texture, 48.0, "VIDEO OPTIONS", transform, 255)
  virtualString(texture, 48.0, 72.0, "Display mode is selected with -window", transform, 255)
  virtualString(texture, 48.0, 88.0, "Resolution uses -width and -height", transform, 255)
  virtualString(texture, 48.0, 104.0, "Changes currently require a restart", transform, 255)
  cursor = 12 + (menuNative.trunc(realtime * 4.0) & 1)
  menuDraw.character(texture, transform[0] + 32.0 * transform[2], transform[1] + (72.0 + state.selection * 16.0) * transform[2], cursor, transform[2], 255)
end function

function drawHelp(state, texture, transform)
  name = "gfx/help" + state.helpPage + ".lmp"
  if not virtualPicture(state, name, 0.0, 0.0, transform, 255) then
    virtualCenteredString(texture, 80.0, "HELP PAGE " + (state.helpPage + 1), transform, 255)
    virtualCenteredString(texture, 96.0, "ARROWS CHANGE PAGE", transform, 220)
  end if
end function

function drawQuit(state, texture, transform)
  drawTextBox(state, 0.0, 0.0, 38, 23, transform)
  virtualWhiteString(texture, 16.0, 12.0, "  Quake version 1.09 by id Software", transform, 255)
  virtualWhiteString(texture, 16.0, 28.0, "Programming        Art", transform, 255)
  virtualString(texture, 16.0, 36.0, " John Carmack       Adrian Carmack", transform, 255)
  virtualString(texture, 16.0, 44.0, " Michael Abrash     Kevin Cloud", transform, 255)
  virtualString(texture, 16.0, 52.0, " John Cash          Paul Steed", transform, 255)
  virtualString(texture, 16.0, 60.0, " Dave 'Zoid' Kirsch", transform, 255)
  virtualWhiteString(texture, 16.0, 68.0, "Design             Biz", transform, 255)
  virtualString(texture, 16.0, 76.0, " John Romero        Jay Wilbur", transform, 255)
  virtualString(texture, 16.0, 84.0, " Sandy Petersen     Mike Wilson", transform, 255)
  virtualString(texture, 16.0, 92.0, " American McGee     Donna Jackson", transform, 255)
  virtualString(texture, 16.0, 100.0, " Tim Willits        Todd Hollenshead", transform, 255)
  virtualWhiteString(texture, 16.0, 108.0, "Support            Projects", transform, 255)
  virtualString(texture, 16.0, 116.0, " Barrett Alexander  Shawn Green", transform, 255)
  virtualWhiteString(texture, 16.0, 124.0, "Sound Effects", transform, 255)
  virtualString(texture, 16.0, 132.0, " Trent Reznor and Nine Inch Nails", transform, 255)
  virtualWhiteString(texture, 16.0, 140.0, "Quake is a trademark of Id Software,", transform, 255)
  virtualWhiteString(texture, 16.0, 148.0, "inc., (c)1996 Id Software, inc. All", transform, 255)
  virtualWhiteString(texture, 16.0, 156.0, "rights reserved. NIN logo is a", transform, 255)
  virtualWhiteString(texture, 16.0, 164.0, "registered trademark licensed to", transform, 255)
  virtualWhiteString(texture, 16.0, 172.0, "Nothing Interactive, Inc. All rights", transform, 255)
  virtualWhiteString(texture, 16.0, 180.0, "reserved. Press y to exit", transform, 255)
end function

function drawPage(state, texture, transform, realtime, registry, page)
  if page == PAGE_MAIN then
    drawMain(state, texture, transform, realtime)
  else if page == PAGE_SINGLEPLAYER then
    drawSinglePlayer(state, texture, transform, realtime)
  else if page == PAGE_MULTIPLAYER then
    drawMultiplayer(state, texture, transform, realtime)
  else if page == PAGE_OPTIONS then
    drawOptions(state, texture, transform, realtime, registry)
  else if page == PAGE_KEYS then
    drawKeys(state, texture, transform, realtime)
  else if page == PAGE_LOAD or page == PAGE_SAVE then
    drawSaveSlots(state, texture, transform, realtime, page)
  else if page == PAGE_SETUP then
    drawSetup(state, texture, transform, realtime)
  else if page == PAGE_VIDEO then
    drawVideo(state, texture, transform, realtime)
  else if page == PAGE_HELP then
    drawHelp(state, texture, transform)
  end if
end function

function render(state, texture, width, height, mapName, realtime, registry)
  if state is void or not state.active or texture == 0 then return false end if
  menuDraw.begin2d(width, height)
  menuDraw.solidQuad(0.0, 0.0, width * 1.0, height * 1.0, 0, 0, 0, 150)
  transform = layout(width, height)

  if state.page == PAGE_QUIT then
    previous = state.previousPage
    if previous == "" or previous == PAGE_QUIT then previous = PAGE_MAIN end if
    drawPage(state, texture, transform, realtime, registry, previous)
    drawQuit(state, texture, transform)
  else
    drawPage(state, texture, transform, realtime, registry, state.page)
  end if

  if state.statusText != "" then
    virtualSolid(8.0, 184.0, 304.0, 12.0, transform, 0, 0, 0, 220)
    virtualCenteredString(texture, 186.0, state.statusText, transform, 235)
  end if
  menuDraw.end2d()
  return true
end function
