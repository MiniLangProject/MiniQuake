package miniquake.menu

import miniquake.types as t
import miniquake.render.draw2d as menuDraw
import miniquake.render.gl11 as menuGl
import miniquake.filesystem as menuFs
import miniquake.cvar as menuCvar
import miniquake.native as menuNative
import miniquake.wad as menuWad
import miniquake.input as menuInput
import miniquake.keys as menuKeys
import miniquake.net_main as menuNet
import miniquake.gl_vidnt as glvid
import miniquake.mathlib as menuMath
import miniquake.render_ui_contract as menuUiContract

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
const PAGE_NET = "net"
const PAGE_LAN = "lanconfig"
const PAGE_GAME_OPTIONS = "gameoptions"
const PAGE_SEARCH = "search"
const PAGE_SERVER_LIST = "serverlist"
const PAGE_SERIAL = "serialconfig"
const PAGE_MODEM = "modemconfig"
const HELP_PAGES = 6
const MNET_IPX = 1
const MNET_TCP = 2

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
  if page == PAGE_SETUP then return ["Hostname", "Your name", "Shirt color", "Pants color", "Accept Changes"] end if
  if page == PAGE_VIDEO then return ["Resolution"] end if
  if page == PAGE_NET then return ["Modem", "Direct Connect", "IPX", "TCP/IP"] end if
  if page == PAGE_LAN then return ["Port", "Search for local games...", "Join game at:"] end if
  if page == PAGE_GAME_OPTIONS then return ["begin game", "Max players", "Game Type", "Teamplay", "Skill", "Frag Limit", "Time Limit", "Episode", "Level"] end if
  if page == PAGE_SEARCH then return ["Searching..."] end if
  if page == PAGE_SERVER_LIST then return [] end if
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
  if page == PAGE_NET then return "NETWORK" end if
  if page == PAGE_LAN then return "TCP/IP" end if
  if page == PAGE_GAME_OPTIONS then return "GAME OPTIONS" end if
  if page == PAGE_SEARCH then return "SEARCH" end if
  if page == PAGE_SERVER_LIST then return "SERVER LIST" end if
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
    [],
    [],
    void,
    "",
    "player",
    0,
    0,
    0,
    0,
    26000,
    "26000",
    "",
    true,
    true,
    "0.0.0.0",
    0,
    16,
    0,
    0,
    "id1",
    false,
    0.0,
    [],
    false,
    "",
    false,
    ["serial", "modem", "ipx"],
    void,
    void,
    [false, false, false, false, false, false, false, false, false, false, false, false],
  )
end function

function storedSelection(state, page, fallback)
  for each item in state.pageSelections
    if item[0] == page then return item[1] end if
  end for
  return fallback
end function

function rememberSelection(state)
  if state.page == "" then return 0 end if
  updated = []
  found = false
  for each item in state.pageSelections
    if item[0] == state.page then
      updated = updated + [[state.page, state.selection]]
      found = true
    else
      updated = updated + [item]
    end if
  end for
  if not found then updated = updated + [[state.page, state.selection]] end if
  state.pageSelections = updated
  return state.selection
end function

function openPage(state, page)
  rememberSelection(state)
  if page == PAGE_QUIT then state.previousPage = state.page end if
  state.page = page
  state.title = titleForPage(page)
  state.items = itemsForPage(page)
  fallback = 0
  if page == PAGE_SETUP then fallback = 4 end if
  if page == PAGE_NET then fallback = 3 end if
  if page == PAGE_LAN then fallback = 2 end if
  state.selection = storedSelection(state, page, fallback)
  if len(state.items) > 0 and state.selection >= len(state.items) then state.selection = 0 end if
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

function setItems(state, items)
  state.items = items
  if state.selection < 0 or state.selection >= len(state.items) then state.selection = 0 end if
  return len(state.items)
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
  else if state.page == PAGE_NET then
    openPage(state, PAGE_MULTIPLAYER)
  else if state.page == PAGE_LAN or state.page == PAGE_GAME_OPTIONS then
    openPage(state, PAGE_NET)
  else if state.page == PAGE_SEARCH or state.page == PAGE_SERVER_LIST then
    openPage(state, PAGE_LAN)
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
  menuDraw.configureDraw(filesystem, palette, void)
  pictureValue = try(menuDraw.Draw_CachePic(path))
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
  pictureValue = try(menuDraw.Draw_PicFromWad(lumpName))
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
  loadPicture(state, filesystem, palette, "gfx/bigbox.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/netmen1.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/netmen2.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/netmen3.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/netmen4.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/dim_modm.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/dim_drct.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/dim_ipx.lmp", true)
  loadPicture(state, filesystem, palette, "gfx/dim_tcp.lmp", true)

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
  deletedTextures = []
  for each pictureValue in state.pictures
    if pictureValue is not void and pictureValue.textureId != 0 and not menuDraw.PictureUsesScrap(pictureValue) then
      alreadyDeleted = false
      for each texture in deletedTextures
        if texture == pictureValue.textureId then alreadyDeleted = true end if
      end for
      if not alreadyDeleted then
        menuGl.deleteTexture(pictureValue.textureId)
        deletedTextures = deletedTextures + [pictureValue.textureId]
      end if
    end if
  end for
  state.pictures = []
  state.initialized = false
  return true
end function

function layout(width, height)
  return menuUiContract.virtualCanvasLayout(width, height)
end function

function virtualPicture(state, name, x, y, transform, alpha)
  pictureValue = findPicture(state, name)
  if pictureValue is void or pictureValue.textureId == 0 then return false end if
  scale = transform[2]
  menuDraw.Draw_PicSized(
    pictureValue,
    transform[0] + x * scale,
    transform[1] + y * scale,
    pictureValue.width * scale,
    pictureValue.height * scale,
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
  if not state.tcpAvailable then virtualCenteredString(texture, 148.0, "No Communications Available", transform, 255) end if
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
  if state.videoDrawCallback is not void then virtualString(texture, 16.0, 128.0, "         Video Options", transform, 255) end if
  windowed = glvid.VID_State().modeState == glvid.MS_WINDOWED
  if windowed then virtualString(texture, 16.0, 136.0, "             Use Mouse", transform, 255) end if

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
  if windowed then drawCheckbox(texture, 220.0, 136.0, windowedMouse != 0.0, transform) end if

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
    found = M_FindKeysForCommand(commands[index])
    bindingText = "???"
    if found[0] != -1 then
      bindingText = menuKeys.Key_KeynumToString(found[0])
      if found[1] != -1 then bindingText = bindingText + " or " + menuKeys.Key_KeynumToString(found[1]) end if
    end if
    virtualString(texture, 140.0, y, bindingText, transform, 255)
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

function playerTranslation(registry)
  colors = 0
  if registry is not void then colors = menuNative.trunc(menuCvar.variableValue(registry, "_cl_color")) end if
  top = ((colors >> 4) & 15) * 16
  bottom = (colors & 15) * 16
  translation = bytes(256)
  index = 0
  while index < 256
    translation[index] = index
    index = index + 1
  end while
  index = 0
  while index < 16
    if top < 128 then translation[16 + index] = top + index else translation[16 + index] = top + 15 - index end if
    if bottom < 128 then translation[96 + index] = bottom + index else translation[96 + index] = bottom + 15 - index end if
    index = index + 1
  end while
  return translation
end function

function drawSetup(state, texture, transform, realtime, registry)
  virtualCenteredPicture(state, "gfx/p_multi.lmp", 4.0, transform, 255)
  virtualString(texture, 64.0, 40.0, "Hostname", transform, 255)
  drawTextBox(state, 160.0, 32.0, 16, 1, transform)
  virtualWhiteString(texture, 168.0, 40.0, state.setupHostname, transform, 255)
  virtualString(texture, 64.0, 56.0, "Your name", transform, 255)
  drawTextBox(state, 160.0, 48.0, 16, 1, transform)
  virtualWhiteString(texture, 168.0, 56.0, state.setupName, transform, 255)
  virtualString(texture, 64.0, 80.0, "Shirt color", transform, 255)
  virtualString(texture, 64.0, 104.0, "Pants color", transform, 255)
  virtualPicture(state, "gfx/bigbox.lmp", 160.0, 64.0, transform, 255)
  playerPicture = findPicture(state, "gfx/menuplyr.lmp")
  if playerPicture is not void then
    menuDraw.Draw_TransPicTranslateSized(
      transform[0] + 172.0 * transform[2],
      transform[1] + 72.0 * transform[2],
      playerPicture.width * transform[2],
      playerPicture.height * transform[2],
      playerPicture,
      M_BuildTranslationTable(state.setupTop * 16, state.setupBottom * 16),
    )
  end if
  drawTextBox(state, 64.0, 132.0, 14, 1, transform)
  virtualString(texture, 72.0, 140.0, "Accept Changes", transform, 255)
  cursor = 12 + (menuNative.trunc(realtime * 4.0) & 1)
  cursorY = [40.0, 56.0, 80.0, 104.0, 140.0][state.selection]
  menuDraw.character(texture, transform[0] + 56.0 * transform[2], transform[1] + cursorY * transform[2], cursor, transform[2], 255)
  if state.selection == 0 then
    menuDraw.character(texture, transform[0] + (168.0 + len(bytes(state.setupHostname)) * 8.0) * transform[2], transform[1] + 40.0 * transform[2], 10 + (menuNative.trunc(realtime * 4.0) & 1), transform[2], 255)
  else if state.selection == 1 then
    menuDraw.character(texture, transform[0] + (168.0 + len(bytes(state.setupName)) * 8.0) * transform[2], transform[1] + 56.0 * transform[2], 10 + (menuNative.trunc(realtime * 4.0) & 1), transform[2], 255)
  end if
end function

function baseEpisodes()
  return [
    ["Welcome to Quake", 0, 1],
    ["Doomed Dimension", 1, 8],
    ["Realm of Black Magic", 9, 7],
    ["Netherworld", 16, 7],
    ["The Elder World", 23, 8],
    ["Final Level", 31, 1],
    ["Deathmatch Arena", 32, 6],
  ]
end function

function baseLevels()
  return [
    ["start", "Entrance"],
    ["e1m1", "Slipgate Complex"], ["e1m2", "Castle of the Damned"], ["e1m3", "The Necropolis"], ["e1m4", "The Grisly Grotto"],
    ["e1m5", "Gloom Keep"], ["e1m6", "The Door To Chthon"], ["e1m7", "The House of Chthon"], ["e1m8", "Ziggurat Vertigo"],
    ["e2m1", "The Installation"], ["e2m2", "Ogre Citadel"], ["e2m3", "Crypt of Decay"], ["e2m4", "The Ebon Fortress"],
    ["e2m5", "The Wizard's Manse"], ["e2m6", "The Dismal Oubliette"], ["e2m7", "Underearth"],
    ["e3m1", "Termination Central"], ["e3m2", "The Vaults of Zin"], ["e3m3", "The Tomb of Terror"], ["e3m4", "Satan's Dark Delight"],
    ["e3m5", "Wind Tunnels"], ["e3m6", "Chambers of Torment"], ["e3m7", "The Haunted Halls"],
    ["e4m1", "The Sewage System"], ["e4m2", "The Tower of Despair"], ["e4m3", "The Elder God Shrine"], ["e4m4", "The Palace of Hate"],
    ["e4m5", "Hell's Atrium"], ["e4m6", "The Pain Maze"], ["e4m7", "Azure Agony"], ["e4m8", "The Nameless City"],
    ["end", "Shub-Niggurath's Pit"],
    ["dm1", "Place of Two Deaths"], ["dm2", "Claustrophobopolis"], ["dm3", "The Abandoned Base"],
    ["dm4", "The Bad Place"], ["dm5", "The Cistern"], ["dm6", "The Dark Zone"],
  ]
end function

function hipnoticEpisodes()
  return [
    ["Scourge of Armagon", 0, 1],
    ["Fortress of the Dead", 1, 5],
    ["Dominion of Darkness", 6, 6],
    ["The Rift", 12, 4],
    ["Final Level", 16, 1],
    ["Deathmatch Arena", 17, 1],
  ]
end function

function hipnoticLevels()
  return [
    ["start", "Command HQ"],
    ["hip1m1", "The Pumping Station"], ["hip1m2", "Storage Facility"], ["hip1m3", "The Lost Mine"],
    ["hip1m4", "Research Facility"], ["hip1m5", "Military Complex"],
    ["hip2m1", "Ancient Realms"], ["hip2m2", "The Black Cathedral"], ["hip2m3", "The Catacombs"],
    ["hip2m4", "The Crypt"], ["hip2m5", "Mortum's Keep"], ["hip2m6", "The Gremlin's Domain"],
    ["hip3m1", "Tur Torment"], ["hip3m2", "Pandemonium"], ["hip3m3", "Limbo"], ["hip3m4", "The Gauntlet"],
    ["hipend", "Armagon's Lair"], ["hipdm1", "The Edge of Oblivion"],
  ]
end function

function rogueEpisodes()
  return [
    ["Introduction", 0, 1],
    ["Hell's Fortress", 1, 7],
    ["Corridors of Time", 8, 8],
    ["Deathmatch Arena", 16, 1],
  ]
end function

function rogueLevels()
  return [
    ["start", "Split Decision"],
    ["r1m1", "Deviant's Domain"], ["r1m2", "Dread Portal"], ["r1m3", "Judgement Call"], ["r1m4", "Cave of Death"],
    ["r1m5", "Towers of Wrath"], ["r1m6", "Temple of Pain"], ["r1m7", "Tomb of the Overlord"],
    ["r2m1", "Tempus Fugit"], ["r2m2", "Elemental Fury I"], ["r2m3", "Elemental Fury II"], ["r2m4", "Curse of Osiris"],
    ["r2m5", "Wizard's Keep"], ["r2m6", "Blood Sacrifice"], ["r2m7", "Last Bastion"], ["r2m8", "Source of Evil"],
    ["ctf1", "Division of Change"],
  ]
end function

function episodeTable(state)
  if state.missionPack == "hipnotic" then return hipnoticEpisodes() end if
  if state.missionPack == "rogue" then return rogueEpisodes() end if
  return baseEpisodes()
end function

function levelTable(state)
  if state.missionPack == "hipnotic" then return hipnoticLevels() end if
  if state.missionPack == "rogue" then return rogueLevels() end if
  return baseLevels()
end function

function selectedLevel(state)
  episodes = episodeTable(state)
  levels = levelTable(state)
  episode = episodes[state.startEpisode]
  return levels[episode[1] + state.startLevel]
end function

function drawNetwork(state, texture, transform, realtime)
  virtualPicture(state, "gfx/qplaque.lmp", 16.0, 4.0, transform, 255)
  virtualCenteredPicture(state, "gfx/p_multi.lmp", 4.0, transform, 255)
  virtualPicture(state, "gfx/dim_ipx.lmp", 72.0, 70.0, transform, 255)
  if state.tcpAvailable then
    virtualPicture(state, "gfx/netmen4.lmp", 72.0, 89.0, transform, 255)
  else
    virtualPicture(state, "gfx/dim_tcp.lmp", 72.0, 89.0, transform, 255)
  end if
  drawTextBox(state, 56.0, 134.0, 24, 4, transform)
  virtualString(texture, 64.0, 142.0, " Commonly used to play  ", transform, 255)
  virtualString(texture, 64.0, 150.0, " over the Internet, but ", transform, 255)
  virtualString(texture, 64.0, 158.0, " also used on a Local   ", transform, 255)
  virtualString(texture, 64.0, 166.0, " Area Network.          ", transform, 255)
  drawDot(state, realtime, 32.0 + state.selection * 20.0, transform)
end function

function drawLanConfig(state, texture, transform, realtime)
  virtualPicture(state, "gfx/qplaque.lmp", 16.0, 4.0, transform, 255)
  title = findPicture(state, "gfx/p_multi.lmp")
  baseX = 72.0
  if title is not void then baseX = (320.0 - title.width) * 0.5 end if
  virtualCenteredPicture(state, "gfx/p_multi.lmp", 4.0, transform, 255)
  mode = "New Game - TCP/IP"
  if state.joiningGame then mode = "Join Game - TCP/IP" end if
  virtualString(texture, baseX, 32.0, mode, transform, 255)
  baseX = baseX + 8.0
  virtualString(texture, baseX, 52.0, "Address:", transform, 255)
  virtualString(texture, baseX + 72.0, 52.0, state.localAddress, transform, 255)
  virtualString(texture, baseX, 72.0, "Port", transform, 255)
  drawTextBox(state, baseX + 64.0, 64.0, 6, 1, transform)
  virtualString(texture, baseX + 72.0, 72.0, state.lanPortText, transform, 255)
  if state.joiningGame then
    virtualString(texture, baseX, 92.0, "Search for local games...", transform, 255)
    virtualString(texture, baseX, 108.0, "Join game at:", transform, 255)
    drawTextBox(state, baseX + 8.0, 116.0, 22, 1, transform)
    virtualString(texture, baseX + 16.0, 124.0, state.lanJoinName, transform, 255)
  else
    drawTextBox(state, baseX, 84.0, 2, 1, transform)
    virtualString(texture, baseX + 8.0, 92.0, "OK", transform, 255)
  end if
  cursorY = [72.0, 92.0, 124.0][state.selection]
  M_DrawCharacter(texture, baseX - 8.0, cursorY, 12 + (menuNative.trunc(realtime * 4.0) & 1), transform)
  if state.returnReason != "" then virtualWhiteString(texture, baseX, 148.0, state.returnReason, transform, 255) end if
end function

function gameTypeText(registry)
  if menuCvar.variableValue(registry, "coop") != 0.0 then return "Cooperative" end if
  return "Deathmatch"
end function

function teamplayText(state, registry)
  value = menuNative.trunc(menuCvar.variableValue(registry, "teamplay"))
  if value == 1 then return "No Friendly Fire" end if
  if value == 2 then return "Friendly Fire" end if
  if state.missionPack == "rogue" then
    if value == 3 then return "Tag" end if
    if value == 4 then return "Capture the Flag" end if
    if value == 5 then return "One Flag CTF" end if
    if value == 6 then return "Three Team CTF" end if
  end if
  return "Off"
end function

function drawGameOptions(state, texture, transform, realtime, registry)
  virtualPicture(state, "gfx/qplaque.lmp", 16.0, 4.0, transform, 255)
  virtualCenteredPicture(state, "gfx/p_multi.lmp", 4.0, transform, 255)
  drawTextBox(state, 152.0, 32.0, 10, 1, transform)
  virtualString(texture, 160.0, 40.0, "begin game", transform, 255)
  labels = ["      Max players", "        Game Type", "        Teamplay", "            Skill", "       Frag Limit", "       Time Limit"]
  index = 0
  while index < len(labels)
    virtualString(texture, 0.0, 56.0 + index * 8.0, labels[index], transform, 255)
    index = index + 1
  end while
  virtualString(texture, 160.0, 56.0, "" + state.maxPlayers, transform, 255)
  virtualString(texture, 160.0, 64.0, gameTypeText(registry), transform, 255)
  virtualString(texture, 160.0, 72.0, teamplayText(state, registry), transform, 255)
  skill = menuNative.trunc(menuCvar.variableValue(registry, "skill"))
  if skill < 0 then skill = 0 end if
  if skill > 3 then skill = 3 end if
  skillText = ["Easy difficulty", "Normal difficulty", "Hard difficulty", "Nightmare difficulty"][skill]
  virtualString(texture, 160.0, 80.0, skillText, transform, 255)
  frag = menuNative.trunc(menuCvar.variableValue(registry, "fraglimit"))
  fragText = "none"
  if frag != 0 then fragText = "" + frag + " frags" end if
  virtualString(texture, 160.0, 88.0, fragText, transform, 255)
  limit = menuNative.trunc(menuCvar.variableValue(registry, "timelimit"))
  limitText = "none"
  if limit != 0 then limitText = "" + limit + " minutes" end if
  virtualString(texture, 160.0, 96.0, limitText, transform, 255)
  episodes = episodeTable(state)
  level = selectedLevel(state)
  virtualString(texture, 0.0, 112.0, "         Episode", transform, 255)
  virtualString(texture, 160.0, 112.0, episodes[state.startEpisode][0], transform, 255)
  virtualString(texture, 0.0, 120.0, "           Level", transform, 255)
  virtualString(texture, 160.0, 120.0, level[1], transform, 255)
  virtualString(texture, 160.0, 128.0, level[0], transform, 255)
  cursorY = [40.0, 56.0, 64.0, 72.0, 80.0, 88.0, 96.0, 112.0, 120.0][state.selection]
  M_DrawCharacter(texture, 144.0, cursorY, 12 + (menuNative.trunc(realtime * 4.0) & 1), transform)
end function

function drawSearch(state, texture, transform)
  virtualCenteredPicture(state, "gfx/p_multi.lmp", 4.0, transform, 255)
  drawTextBox(state, 104.0, 32.0, 12, 1, transform)
  virtualString(texture, 112.0, 40.0, "Searching...", transform, 255)
  if state.searchComplete and len(state.servers) == 0 then
    virtualWhiteString(texture, 72.0, 64.0, "No Quake servers found", transform, 255)
  end if
end function

function sortServers(state)
  if state.serverListSorted then return state.servers end if
  i = 0
  while i < len(state.servers)
    j = i + 1
    while j < len(state.servers)
      if menuStringLess(state.servers[j][1], state.servers[i][1]) then
        temporary = state.servers[i]
        state.servers[i] = state.servers[j]
        state.servers[j] = temporary
      end if
      j = j + 1
    end while
    i = i + 1
  end while
  state.serverListSorted = true
  return state.servers
end function

function menuStringLess(left, right)
  leftBytes = bytes(left)
  rightBytes = bytes(right)
  count = len(leftBytes)
  if len(rightBytes) < count then count = len(rightBytes) end if
  index = 0
  while index < count
    a = leftBytes[index]
    b = rightBytes[index]
    if a < b then return true end if
    if a > b then return false end if
    index = index + 1
  end while
  return len(leftBytes) < len(rightBytes)
end function

function fixedServerField(text, width)
  source = bytes(text)
  result = ""
  index = 0
  while index < width
    if index < len(source) then result = result + menuNative.asciiChar(source[index]) else result = result + " " end if
    index = index + 1
  end while
  return result
end function

function widthTwo(number)
  if number < 10 then return " " + number end if
  return "" + number
end function

function drawServerList(state, texture, transform, realtime)
  sortServers(state)
  virtualCenteredPicture(state, "gfx/p_multi.lmp", 4.0, transform, 255)
  index = 0
  while index < len(state.servers)
    item = state.servers[index]
    line = fixedServerField(item[1], 15) + " " + fixedServerField(item[2], 15)
    if item[4] > 0 then line = line + " " + widthTwo(item[3]) + "/" + widthTwo(item[4]) end if
    virtualString(texture, 16.0, 32.0 + index * 8.0, line, transform, 255)
    index = index + 1
  end while
  if len(state.servers) > 0 then
    M_DrawCharacter(texture, 0.0, 32.0 + state.selection * 8.0, 12 + (menuNative.trunc(realtime * 4.0) & 1), transform)
  end if
  if state.returnReason != "" then virtualWhiteString(texture, 16.0, 148.0, state.returnReason, transform, 255) end if
end function

function drawVideo(state, texture, transform, realtime)
  virtualCenteredPicture(state, "gfx/vidmodes.lmp", 4.0, transform, 255)
  modeName = "WINDOWED"
  if glvid.VID_State().modeState == glvid.MS_FULLDIB then modeName = "FULLSCREEN" end if
  virtualCenteredString(texture, 28.0, modeName + " - SELECT RESOLUTION", transform, 255)
  virtualString(texture, 8.0, 40.0, "WIDTHxHEIGHTxBPP", transform, 220)
  modes = glvid.VID_MenuDraw()
  for each command in modes
    if command[0] == "mode" then
      x = 8.0 + command[4] * 104.0
      y = 52.0 + command[5] * 8.0
      if len(command) > 6 and command[6] then virtualWhiteString(texture, x - 8.0, y, ">", transform, 255) end if
      if command[3] then virtualWhiteString(texture, x, y, command[2], transform, 255)
      else virtualString(texture, x, y, command[2], transform, 255)
      end if
    end if
  end for
  virtualCenteredString(texture, 140.0, "ARROWS SELECT", transform, 255)
  virtualCenteredString(texture, 148.0, "ENTER APPLIES IMMEDIATELY", transform, 255)
  virtualCenteredString(texture, 164.0, "ESC RETURNS TO OPTIONS", transform, 220)
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
    M_Main_Draw(state, texture, transform, realtime)
  else if page == PAGE_SINGLEPLAYER then
    M_SinglePlayer_Draw(state, texture, transform, realtime)
  else if page == PAGE_MULTIPLAYER then
    M_MultiPlayer_Draw(state, texture, transform, realtime)
  else if page == PAGE_OPTIONS then
    M_Options_Draw(state, texture, transform, realtime, registry)
  else if page == PAGE_KEYS then
    M_Keys_Draw(state, texture, transform, realtime)
  else if page == PAGE_LOAD or page == PAGE_SAVE then
    if page == PAGE_LOAD then M_Load_Draw(state, texture, transform, realtime) else M_Save_Draw(state, texture, transform, realtime) end if
  else if page == PAGE_SETUP then
    M_Setup_Draw(state, texture, transform, realtime, registry)
  else if page == PAGE_VIDEO then
    M_Video_Draw(state, texture, transform, realtime)
  else if page == PAGE_HELP then
    M_Help_Draw(state, texture, transform)
  else if page == PAGE_NET then
    M_Net_Draw(state, texture, transform, realtime)
  else if page == PAGE_LAN then
    M_LanConfig_Draw(state, texture, transform, realtime)
  else if page == PAGE_GAME_OPTIONS then
    M_GameOptions_Draw(state, texture, transform, realtime, registry)
  else if page == PAGE_SEARCH then
    M_Search_Draw(state, texture, transform, realtime)
  else if page == PAGE_SERVER_LIST then
    M_ServerList_Draw(state, texture, transform, realtime)
  end if
end function

function M_Draw(state, texture, width, height, mapName, realtime, registry)
  if state is void or not state.active or texture == 0 then return false end if
  state.drawTrace = [["fade"]]
  menuDraw.begin2d(width, height)
  // Draw_FadeScreen uses glColor4f(0,0,0,0.8).
  menuDraw.solidQuad(0.0, 0.0, width * 1.0, height * 1.0, 0, 0, 0, 204)
  transform = layout(width, height)

  if state.page == PAGE_QUIT then
    previous = state.previousPage
    if previous == "" or previous == PAGE_QUIT then previous = PAGE_MAIN end if
    drawPage(state, texture, transform, realtime, registry, previous)
    M_Quit_Draw(state, texture, transform)
  else
    drawPage(state, texture, transform, realtime, registry, state.page)
  end if

  if state.statusText != "" then
    virtualSolid(8.0, 184.0, 304.0, 12.0, transform, 0, 0, 0, 220)
    virtualCenteredString(texture, 186.0, state.statusText, transform, 235)
  end if
  menuDraw.end2d()
  if state.enterSound then
    state.action = ["sound", "misc/menu2.wav"]
    state.enterSound = false
  end if
  return true
end function

function render(state, texture, width, height, mapName, realtime, registry)
  return M_Draw(state, texture, width, height, mapName, realtime, registry)
end function

// -----------------------------------------------------------------------------
// Exact menu.c / menu.h entry points.

function traceDraw(state, name)
  state.drawTrace = state.drawTrace + [[name]]
  return name
end function

function M_DrawCharacter(texture, x, y, number, transform)
  if texture == 0 then return false end if
  menuDraw.character(texture, transform[0] + x * transform[2], transform[1] + y * transform[2], number, transform[2], 255)
  return true
end function

function M_Print(texture, x, y, text, transform)
  return virtualString(texture, x, y, text, transform, 255)
end function

function M_PrintWhite(texture, x, y, text, transform)
  return virtualWhiteString(texture, x, y, text, transform, 255)
end function

function M_DrawTransPic(state, name, x, y, transform)
  return virtualPicture(state, name, x, y, transform, 255)
end function

function M_DrawPic(state, name, x, y, transform)
  return virtualPicture(state, name, x, y, transform, 255)
end function

function M_BuildTranslationTable(top, bottom)
  translation = bytes(256)
  index = 0
  while index < 256
    translation[index] = index
    index = index + 1
  end while
  index = 0
  while index < 16
    if top < 128 then translation[16 + index] = top + index else translation[16 + index] = top + 15 - index end if
    if bottom < 128 then translation[96 + index] = bottom + index else translation[96 + index] = bottom + 15 - index end if
    index = index + 1
  end while
  return translation
end function

function M_DrawTransPicTranslate(state, name, x, y, transform, top, bottom)
  pictureValue = findPicture(state, name)
  if pictureValue is void then return false end if
  menuDraw.Draw_TransPicTranslateSized(
    transform[0] + x * transform[2],
    transform[1] + y * transform[2],
    pictureValue.width * transform[2],
    pictureValue.height * transform[2],
    pictureValue,
    M_BuildTranslationTable(top, bottom),
  )
  return true
end function

function M_DrawTextBox(state, x, y, width, lines, transform)
  return drawTextBox(state, x, y, width, lines, transform)
end function

function M_ToggleMenu_f(state)
  state.enterSound = true
  if state.active then
    if state.page != PAGE_MAIN then return M_Menu_Main_f(state) end if
    state.active = false
    return false
  end if
  return M_Menu_Main_f(state)
end function

function M_Menu_Main_f(state)
  openPage(state, PAGE_MAIN)
  state.active = true
  state.enterSound = true
  return true
end function

function M_Menu_SinglePlayer_f(state)
  openPage(state, PAGE_SINGLEPLAYER)
  state.active = true
  state.enterSound = true
  return true
end function

function M_Menu_Load_f(state)
  openPage(state, PAGE_LOAD)
  state.active = true
  state.enterSound = true
  return true
end function

function M_Menu_Save_f(state, serverActive, intermission, maxClients)
  if not serverActive or intermission != 0 or maxClients != 1 then return false end if
  openPage(state, PAGE_SAVE)
  state.active = true
  state.enterSound = true
  return true
end function

function M_Menu_MultiPlayer_f(state)
  openPage(state, PAGE_MULTIPLAYER)
  state.active = true
  state.enterSound = true
  return true
end function

function M_Menu_Setup_f(state, registry)
  openPage(state, PAGE_SETUP)
  state.active = true
  state.enterSound = true
  state.setupName = menuCvar.variableString(registry, "_cl_name")
  state.setupHostname = menuCvar.variableString(registry, "hostname")
  colors = menuNative.trunc(menuCvar.variableValue(registry, "_cl_color"))
  state.setupTop = (colors >> 4) & 15
  state.setupBottom = colors & 15
  state.setupOldTop = state.setupTop
  state.setupOldBottom = state.setupBottom
  return true
end function

function M_Menu_Net_f(state)
  openPage(state, PAGE_NET)
  state.active = true
  state.enterSound = true
  // Serial/modem and IPX are deliberate target exclusions. The original
  // cursor-skipping loop therefore lands directly on TCP/IP.
  state.selection = 3
  return true
end function

function M_Menu_Options_f(state)
  openPage(state, PAGE_OPTIONS)
  state.active = true
  state.enterSound = true
  return true
end function

function M_Menu_Keys_f(state)
  openPage(state, PAGE_KEYS)
  state.active = true
  state.enterSound = true
  return true
end function

function M_Menu_Video_f(state)
  openPage(state, PAGE_VIDEO)
  glvid.VID_MenuReset()
  state.active = true
  state.enterSound = true
  return true
end function

function M_Menu_Help_f(state)
  openPage(state, PAGE_HELP)
  state.helpPage = 0
  state.active = true
  state.enterSound = true
  return true
end function

function M_Menu_Quit_f(state)
  if state.page == PAGE_QUIT then return false end if
  state.previousPage = state.page
  openPage(state, PAGE_QUIT)
  state.active = true
  state.enterSound = true
  return true
end function

function excludedMenuPath(state, name)
  state.action = ["excluded", name]
  state.statusText = name + " networking is excluded from the Windows x64 MiniQuake target"
  return false
end function

function M_Menu_SerialConfig_f(state)
  return excludedMenuPath(state, "serial/modem")
end function

function M_Menu_ModemConfig_f(state)
  return excludedMenuPath(state, "physical modem")
end function

function M_Menu_LanConfig_f(state)
  hadSelection = false
  for each item in state.pageSelections
    if item[0] == PAGE_LAN then hadSelection = true end if
  end for
  openPage(state, PAGE_LAN)
  state.active = true
  state.enterSound = true
  if not hadSelection then
    if state.joiningGame and state.tcpAvailable then state.selection = 2 else state.selection = 1 end if
  end if
  if not state.joiningGame and state.selection == 2 then state.selection = 1 end if
  state.lanPort = menuNet.DEFAULTnet_hostport
  state.lanPortText = "" + state.lanPort
  state.returnReason = ""
  return true
end function

function M_Menu_GameOptions_f(state, maximumClients, missionPack)
  openPage(state, PAGE_GAME_OPTIONS)
  state.active = true
  state.enterSound = true
  state.missionPack = missionPack
  state.maxPlayersLimit = maximumClients
  if state.maxPlayers == 0 then state.maxPlayers = maximumClients end if
  if state.maxPlayers < 2 then state.maxPlayers = maximumClients end if
  if state.maxPlayers < 2 then state.maxPlayers = 2 end if
  return true
end function

function M_Menu_Search_f(state, network, port, realtime)
  openPage(state, PAGE_SEARCH)
  state.active = true
  state.enterSound = false
  state.searchComplete = false
  state.searchCompleteTime = realtime
  state.servers = []
  menuNet.NET_Slist_f(network, true, false, port)
  return true
end function

function M_Menu_ServerList_f(state, servers)
  openPage(state, PAGE_SERVER_LIST)
  state.active = true
  state.enterSound = true
  state.selection = 0
  state.servers = servers
  state.items = []
  for each server in servers
    state.items = state.items + [server[1]]
  end for
  state.serverListSorted = false
  state.returnReason = ""
  return true
end function

function M_Main_Draw(state, texture, transform, realtime)
  traceDraw(state, "M_Main_Draw")
  return drawMain(state, texture, transform, realtime)
end function

function M_SinglePlayer_Draw(state, texture, transform, realtime)
  traceDraw(state, "M_SinglePlayer_Draw")
  return drawSinglePlayer(state, texture, transform, realtime)
end function

function M_Load_Draw(state, texture, transform, realtime)
  traceDraw(state, "M_Load_Draw")
  return drawSaveSlots(state, texture, transform, realtime, PAGE_LOAD)
end function

function M_Save_Draw(state, texture, transform, realtime)
  traceDraw(state, "M_Save_Draw")
  return drawSaveSlots(state, texture, transform, realtime, PAGE_SAVE)
end function

function M_MultiPlayer_Draw(state, texture, transform, realtime)
  traceDraw(state, "M_MultiPlayer_Draw")
  return drawMultiplayer(state, texture, transform, realtime)
end function

function M_Setup_Draw(state, texture, transform, realtime, registry)
  traceDraw(state, "M_Setup_Draw")
  return drawSetup(state, texture, transform, realtime, registry)
end function

function M_Net_Draw(state, texture, transform, realtime)
  traceDraw(state, "M_Net_Draw")
  return drawNetwork(state, texture, transform, realtime)
end function

function M_Options_Draw(state, texture, transform, realtime, registry)
  traceDraw(state, "M_Options_Draw")
  return drawOptions(state, texture, transform, realtime, registry)
end function

function M_Keys_Draw(state, texture, transform, realtime)
  traceDraw(state, "M_Keys_Draw")
  return drawKeys(state, texture, transform, realtime)
end function

function M_Video_Draw(state, texture, transform, realtime)
  traceDraw(state, "M_Video_Draw")
  if state.videoDrawCallback is not void then state.action = state.videoDrawCallback() end if
  return drawVideo(state, texture, transform, realtime)
end function

function M_Help_Draw(state, texture, transform)
  traceDraw(state, "M_Help_Draw")
  return drawHelp(state, texture, transform)
end function

function M_Quit_Draw(state, texture, transform)
  traceDraw(state, "M_Quit_Draw")
  return drawQuit(state, texture, transform)
end function

function M_SerialConfig_Draw(state, texture, transform)
  traceDraw(state, "M_SerialConfig_Draw:excluded")
  virtualCenteredString(texture, 96.0, "SERIAL/MODEM EXCLUDED", transform, 255)
  return false
end function

function M_ModemConfig_Draw(state, texture, transform)
  traceDraw(state, "M_ModemConfig_Draw:excluded")
  virtualCenteredString(texture, 96.0, "PHYSICAL MODEM EXCLUDED", transform, 255)
  return false
end function

function M_LanConfig_Draw(state, texture, transform, realtime)
  traceDraw(state, "M_LanConfig_Draw")
  return drawLanConfig(state, texture, transform, realtime)
end function

function M_GameOptions_Draw(state, texture, transform, realtime, registry)
  traceDraw(state, "M_GameOptions_Draw")
  return drawGameOptions(state, texture, transform, realtime, registry)
end function

function M_Search_Draw(state, texture, transform, realtime)
  traceDraw(state, "M_Search_Draw")
  drawSearch(state, texture, transform)
  if menuNet.slistInProgress then
    menuNet.NET_Poll()
    return true
  end if
  if not state.searchComplete then
    state.searchComplete = true
    state.searchCompleteTime = realtime
    state.servers = menuNet.hostcache
  end if
  if len(state.servers) > 0 then
    M_Menu_ServerList_f(state, state.servers)
    return true
  end if
  if realtime - state.searchCompleteTime >= 3.0 then M_Menu_LanConfig_f(state) end if
  return true
end function

function M_ServerList_Draw(state, texture, transform, realtime)
  traceDraw(state, "M_ServerList_Draw")
  return drawServerList(state, texture, transform, realtime)
end function

function M_ScanSaves(state, labels, loadable)
  state.items = labels
  state.loadable = loadable
  return len(labels)
end function

function M_AdjustSliders(state, registry, direction)
  selection = state.selection
  if selection == 3 then
    menuCvar.setValue(registry, "viewsize", menuMath.clamp(menuCvar.variableValue(registry, "viewsize") + direction * 10.0, 30.0, 120.0))
  else if selection == 4 then
    menuCvar.setValue(registry, "gamma", menuMath.clamp(menuCvar.variableValue(registry, "gamma") - direction * 0.05, 0.5, 1.0))
  else if selection == 5 then
    menuCvar.setValue(registry, "sensitivity", menuMath.clamp(menuCvar.variableValue(registry, "sensitivity") + direction * 0.5, 1.0, 11.0))
  else if selection == 6 then
    // WinQuake changes CD volume as an on/off step on Windows.
    menuCvar.setValue(registry, "bgmvolume", menuMath.clamp(menuCvar.variableValue(registry, "bgmvolume") + direction * 1.0, 0.0, 1.0))
  else if selection == 7 then
    menuCvar.setValue(registry, "volume", menuMath.clamp(menuCvar.variableValue(registry, "volume") + direction * 0.1, 0.0, 1.0))
  else if selection == 8 then
    speed = 400.0
    if menuCvar.variableValue(registry, "cl_forwardspeed") > 200.0 then speed = 200.0 end if
    menuCvar.setValue(registry, "cl_forwardspeed", speed)
    menuCvar.setValue(registry, "cl_backspeed", speed)
  else if selection == 9 then
    menuCvar.setValue(registry, "m_pitch", -menuCvar.variableValue(registry, "m_pitch"))
  else if selection == 10 then
    value = 1.0
    if menuCvar.variableValue(registry, "lookspring") != 0.0 then value = 0.0 end if
    menuCvar.setValue(registry, "lookspring", value)
  else if selection == 11 then
    value = 1.0
    if menuCvar.variableValue(registry, "lookstrafe") != 0.0 then value = 0.0 end if
    menuCvar.setValue(registry, "lookstrafe", value)
  else if selection == 13 then
    value = 1.0
    if menuCvar.variableValue(registry, "_windowed_mouse") != 0.0 then value = 0.0 end if
    menuCvar.setValue(registry, "_windowed_mouse", value)
  else
    return false
  end if
  return true
end function

function M_DrawSlider(texture, x, y, range, transform)
  drawSlider(texture, x, y, range, transform)
  return true
end function

function M_DrawCheckbox(texture, x, y, enabled, transform)
  drawCheckbox(texture, x, y, enabled, transform)
  return true
end function

function M_FindKeysForCommand(command)
  result = [-1, -1]
  commandBytes = bytes(command)
  count = 0
  keynum = 0
  while keynum < 256 and count < 2
    binding = menuInput.bindingForCode(keynum)
    matches = binding is not void
    if matches then
      bindingBytes = bytes(binding)
      if len(bindingBytes) < len(commandBytes) then matches = false end if
      index = 0
      while matches and index < len(commandBytes)
        if bindingBytes[index] != commandBytes[index] then matches = false end if
        index = index + 1
      end while
    end if
    if matches then result[count] = keynum; count = count + 1 end if
    keynum = keynum + 1
  end while
  return result
end function

function M_UnbindCommand(command)
  commandBytes = bytes(command)
  keynum = 0
  while keynum < 256
    binding = menuInput.bindingForCode(keynum)
    matches = binding is not void
    if matches then
      bindingBytes = bytes(binding)
      if len(bindingBytes) < len(commandBytes) then matches = false end if
      index = 0
      while matches and index < len(commandBytes)
        if bindingBytes[index] != commandBytes[index] then matches = false end if
        index = index + 1
      end while
    end if
    if matches then menuKeys.Key_SetBinding(keynum, "") end if
    keynum = keynum + 1
  end while
  return true
end function

function setupAppend(state, key)
  character = menuNative.asciiChar(key)
  if state.selection == 0 and len(bytes(state.setupHostname)) < 15 then state.setupHostname = state.setupHostname + character end if
  if state.selection == 1 and len(bytes(state.setupName)) < 15 then state.setupName = state.setupName + character end if
  return true
end function

function setupBackspace(state)
  if state.selection == 0 and len(bytes(state.setupHostname)) > 0 then state.setupHostname = decode(slice(bytes(state.setupHostname), 0, len(bytes(state.setupHostname)) - 1)) end if
  if state.selection == 1 and len(bytes(state.setupName)) > 0 then state.setupName = decode(slice(bytes(state.setupName), 0, len(bytes(state.setupName)) - 1)) end if
  return true
end function

function M_Main_Key(state, key)
  if key == menuKeys.K_ESCAPE then state.active = false; return "close" end if
  if key == menuKeys.K_DOWNARROW then move(state, 1); return "move" end if
  if key == menuKeys.K_UPARROW then move(state, -1); return "move" end if
  if key == menuKeys.K_ENTER then return selectedCommand(state) end if
  return "none"
end function

function M_SinglePlayer_Key(state, key)
  if key == menuKeys.K_ESCAPE then M_Menu_Main_f(state); return "back" end if
  if key == menuKeys.K_DOWNARROW then move(state, 1); return "move" end if
  if key == menuKeys.K_UPARROW then move(state, -1); return "move" end if
  if key == menuKeys.K_ENTER then return selectedCommand(state) end if
  return "none"
end function

function M_Load_Key(state, key)
  if key == menuKeys.K_ESCAPE then M_Menu_SinglePlayer_f(state); return "back" end if
  if key == menuKeys.K_UPARROW or key == menuKeys.K_LEFTARROW then move(state, -1); return "move" end if
  if key == menuKeys.K_DOWNARROW or key == menuKeys.K_RIGHTARROW then move(state, 1); return "move" end if
  if key == menuKeys.K_ENTER and state.loadable[state.selection] then return "load_slot" end if
  return "none"
end function

function M_Save_Key(state, key)
  if key == menuKeys.K_ESCAPE then M_Menu_SinglePlayer_f(state); return "back" end if
  if key == menuKeys.K_UPARROW or key == menuKeys.K_LEFTARROW then move(state, -1); return "move" end if
  if key == menuKeys.K_DOWNARROW or key == menuKeys.K_RIGHTARROW then move(state, 1); return "move" end if
  if key == menuKeys.K_ENTER then return "save_slot" end if
  return "none"
end function

function M_MultiPlayer_Key(state, key)
  if key == menuKeys.K_ESCAPE then M_Menu_Main_f(state); return "back" end if
  if key == menuKeys.K_DOWNARROW then move(state, 1); return "move" end if
  if key == menuKeys.K_UPARROW then move(state, -1); return "move" end if
  if key == menuKeys.K_ENTER then
    if state.selection == 2 then return "player_setup" end if
    state.joiningGame = state.selection == 0
    M_Menu_Net_f(state)
    return "network"
  end if
  return "none"
end function

function M_Setup_Key(state, key)
  if key == menuKeys.K_ESCAPE then M_Menu_MultiPlayer_f(state); return "back" end if
  if key == menuKeys.K_UPARROW then move(state, -1); return "move" end if
  if key == menuKeys.K_DOWNARROW then move(state, 1); return "move" end if
  if key == menuKeys.K_BACKSPACE then setupBackspace(state); return "edit" end if
  if key == menuKeys.K_LEFTARROW or key == menuKeys.K_RIGHTARROW or key == menuKeys.K_ENTER then
    if state.selection < 2 then return "none" end if
    direction = 1
    if key == menuKeys.K_LEFTARROW then direction = -1 end if
    if state.selection == 2 then state.setupTop = state.setupTop + direction end if
    if state.selection == 3 then state.setupBottom = state.setupBottom + direction end if
    if state.selection == 4 and key == menuKeys.K_ENTER then return ["setup_accept", state.setupHostname, state.setupName, state.setupTop, state.setupBottom] end if
    while state.setupTop < 0
      state.setupTop = state.setupTop + 14
    end while
    while state.setupTop > 13
      state.setupTop = state.setupTop - 14
    end while
    while state.setupBottom < 0
      state.setupBottom = state.setupBottom + 14
    end while
    while state.setupBottom > 13
      state.setupBottom = state.setupBottom - 14
    end while
    return "adjust"
  end if
  if key >= 32 and key <= 127 then setupAppend(state, key); return "edit" end if
  return "none"
end function

function M_Net_Key(state, key)
  if key == menuKeys.K_ESCAPE then M_Menu_MultiPlayer_f(state); return "back" end if
  if key == menuKeys.K_UPARROW or key == menuKeys.K_DOWNARROW then state.selection = 3; return "move" end if
  if key == menuKeys.K_ENTER and state.tcpAvailable then M_Menu_LanConfig_f(state); return "lan_config" end if
  return "none"
end function

function M_Options_Key(state, key, registry)
  if key == menuKeys.K_ESCAPE then M_Menu_Main_f(state); return "back" end if
  if key == menuKeys.K_UPARROW or key == menuKeys.K_DOWNARROW then
    direction = 1
    if key == menuKeys.K_UPARROW then direction = -1 end if
    move(state, direction)
    if state.selection == 12 and state.videoDrawCallback is void then
      if key == menuKeys.K_UPARROW then state.selection = 11 else state.selection = 0 end if
    end if
    if state.selection == 13 and glvid.VID_State().modeState != glvid.MS_WINDOWED then
      if key == menuKeys.K_UPARROW then state.selection = 12 else state.selection = 0 end if
    end if
    return "move"
  end if
  if key == menuKeys.K_LEFTARROW then M_AdjustSliders(state, registry, -1); return "adjust" end if
  if key == menuKeys.K_RIGHTARROW then M_AdjustSliders(state, registry, 1); return "adjust" end if
  if key == menuKeys.K_ENTER then return selectedCommand(state) end if
  return "none"
end function

function M_Keys_Key(state, key)
  if state.waitingForKey then
    if key == menuKeys.K_ESCAPE then state.waitingForKey = false; return "bind_cancel" end if
    if key != 96 then menuKeys.Key_SetBinding(key, keyCommandAt(state)) end if
    state.waitingForKey = false
    return "bound"
  end if
  if key == menuKeys.K_ESCAPE then M_Menu_Options_f(state); return "back" end if
  if key == menuKeys.K_LEFTARROW or key == menuKeys.K_UPARROW then move(state, -1); return "move" end if
  if key == menuKeys.K_DOWNARROW or key == menuKeys.K_RIGHTARROW then move(state, 1); return "move" end if
  if key == menuKeys.K_ENTER then
    found = M_FindKeysForCommand(keyCommandAt(state))
    if found[1] != -1 then M_UnbindCommand(keyCommandAt(state)) end if
    state.waitingForKey = true
    return "bind_grab"
  end if
  if key == menuKeys.K_BACKSPACE or key == menuKeys.K_DEL then M_UnbindCommand(keyCommandAt(state)); return "unbind" end if
  return "none"
end function

function M_Video_Key(state, key)
  if state.videoKeyCallback is not void then
    action = state.videoKeyCallback(key)
    if action == "options" then M_Menu_Options_f(state); return "back" end if
    if action == "mode_applied" or action == "mode_error" then
      setStatus(state, glvid.VID_State().lastModeMessage)
      state.enterSound = action == "mode_applied"
      return action
    end if
    if action != "none" then return action end if
  end if
  if key == menuKeys.K_ESCAPE then M_Menu_Options_f(state); return "back" end if
  return "none"
end function

function M_Help_Key(state, key)
  if key == menuKeys.K_ESCAPE then M_Menu_Main_f(state); return "back" end if
  if key == menuKeys.K_UPARROW or key == menuKeys.K_RIGHTARROW then moveHelp(state, 1); state.enterSound = true; return "page" end if
  if key == menuKeys.K_DOWNARROW or key == menuKeys.K_LEFTARROW then moveHelp(state, -1); state.enterSound = true; return "page" end if
  return "none"
end function

function M_Quit_Key(state, key)
  if key == menuKeys.K_ESCAPE or key == 110 or key == 78 then back(state); state.enterSound = true; return "cancel_quit" end if
  if key == 121 or key == 89 then return "quit" end if
  return "none"
end function

function M_SerialConfig_Key(state, key)
  excludedMenuPath(state, "serial/modem")
  return "excluded"
end function

function M_ModemConfig_Key(state, key)
  excludedMenuPath(state, "physical modem")
  return "excluded"
end function

function normalizeLanPort(state)
  parsed = toNumber(state.lanPortText)
  if parsed is void and state.lanPortText == "" then parsed = 0 end if
  if parsed is void or parsed > 65535 then
    state.lanPortText = "" + state.lanPort
  else
    state.lanPort = menuNative.trunc(parsed)
    state.lanPortText = "" + state.lanPort
  end if
  return state.lanPort
end function

function M_LanConfig_Key(state, key)
  if key == menuKeys.K_ESCAPE then M_Menu_Net_f(state); return "back" end if
  if key == menuKeys.K_UPARROW then
    state.selection = state.selection - 1
    if state.selection < 0 then state.selection = 2 end if
  else if key == menuKeys.K_DOWNARROW then
    state.selection = state.selection + 1
    if state.selection > 2 then state.selection = 0 end if
  else if key == menuKeys.K_ENTER then
    if state.selection == 1 then
      M_ConfigureNetSubsystem(state)
      if state.joiningGame then return "search" end if
      return "game_options"
    end if
    if state.selection == 2 and state.joiningGame then return ["connect", state.lanJoinName] end if
  else if key == menuKeys.K_BACKSPACE then
    if state.selection == 0 and len(bytes(state.lanPortText)) > 0 then state.lanPortText = decode(slice(bytes(state.lanPortText), 0, len(bytes(state.lanPortText)) - 1)) end if
    if state.selection == 2 and len(bytes(state.lanJoinName)) > 0 then state.lanJoinName = decode(slice(bytes(state.lanJoinName), 0, len(bytes(state.lanJoinName)) - 1)) end if
  else if key >= 32 and key <= 127 then
    character = menuNative.asciiChar(key)
    if state.selection == 2 and len(bytes(state.lanJoinName)) < 21 then state.lanJoinName = state.lanJoinName + character end if
    if state.selection == 0 and key >= 48 and key <= 57 and len(bytes(state.lanPortText)) < 5 then state.lanPortText = state.lanPortText + character end if
  end if
  if not state.joiningGame and state.selection == 2 then
    if key == menuKeys.K_UPARROW then state.selection = 1 else state.selection = 0 end if
  end if
  normalizeLanPort(state)
  return "edit"
end function

function M_NetStart_Change(state, registry, direction)
  selection = state.selection
  if selection == 1 then
    state.maxPlayers = state.maxPlayers + direction
    if state.maxPlayers > state.maxPlayersLimit then state.maxPlayers = state.maxPlayersLimit end if
    if state.maxPlayers < 2 then state.maxPlayers = 2 end if
  else if selection == 2 then
    value = 1.0
    if menuCvar.variableValue(registry, "coop") != 0.0 then value = 0.0 end if
    menuCvar.setValue(registry, "coop", value)
  else if selection == 3 then
    count = 2
    if state.missionPack == "rogue" then count = 6 end if
    value = menuNative.trunc(menuCvar.variableValue(registry, "teamplay")) + direction
    if value > count then value = 0 end if
    if value < 0 then value = count end if
    menuCvar.setValue(registry, "teamplay", value)
  else if selection == 4 then
    value = menuNative.trunc(menuCvar.variableValue(registry, "skill")) + direction
    if value > 3 then value = 0 end if
    if value < 0 then value = 3 end if
    menuCvar.setValue(registry, "skill", value)
  else if selection == 5 then
    value = menuNative.trunc(menuCvar.variableValue(registry, "fraglimit")) + direction * 10
    if value > 100 then value = 0 end if
    if value < 0 then value = 100 end if
    menuCvar.setValue(registry, "fraglimit", value)
  else if selection == 6 then
    value = menuNative.trunc(menuCvar.variableValue(registry, "timelimit")) + direction * 5
    if value > 60 then value = 0 end if
    if value < 0 then value = 60 end if
    menuCvar.setValue(registry, "timelimit", value)
  else if selection == 7 then
    episodes = episodeTable(state)
    episodeCount = len(episodes)
    if state.missionPack != "hipnotic" and state.missionPack != "rogue" and menuCvar.variableValue(registry, "registered") == 0.0 then episodeCount = 2 end if
    state.startEpisode = state.startEpisode + direction
    if state.startEpisode < 0 then state.startEpisode = episodeCount - 1 end if
    if state.startEpisode >= episodeCount then state.startEpisode = 0 end if
    state.startLevel = 0
  else if selection == 8 then
    episodes = episodeTable(state)
    count = episodes[state.startEpisode][2]
    state.startLevel = state.startLevel + direction
    if state.startLevel < 0 then state.startLevel = count - 1 end if
    if state.startLevel >= count then state.startLevel = 0 end if
  end if
  return true
end function

function M_GameOptions_Key(state, key, registry)
  if key == menuKeys.K_ESCAPE then M_Menu_Net_f(state); return "back" end if
  if key == menuKeys.K_UPARROW then move(state, -1); return "move" end if
  if key == menuKeys.K_DOWNARROW then move(state, 1); return "move" end if
  if key == menuKeys.K_LEFTARROW and state.selection != 0 then M_NetStart_Change(state, registry, -1); return "adjust" end if
  if key == menuKeys.K_RIGHTARROW and state.selection != 0 then M_NetStart_Change(state, registry, 1); return "adjust" end if
  if key == menuKeys.K_ENTER then
    if state.selection == 0 then return ["begin_game", selectedLevel(state)[0], state.maxPlayers] end if
    M_NetStart_Change(state, registry, 1)
    return "adjust"
  end if
  return "none"
end function

function M_Search_Key(state, key)
  return "none"
end function

function M_ServerList_Key(state, key)
  if key == menuKeys.K_ESCAPE then M_Menu_LanConfig_f(state); return "back" end if
  if key == menuKeys.K_SPACE then return "search" end if
  if key == menuKeys.K_UPARROW or key == menuKeys.K_LEFTARROW then move(state, -1); return "move" end if
  if key == menuKeys.K_DOWNARROW or key == menuKeys.K_RIGHTARROW then move(state, 1); return "move" end if
  if key == menuKeys.K_ENTER and len(state.servers) > 0 then
    state.serverListSorted = false
    return ["connect", state.servers[state.selection][0]]
  end if
  return "none"
end function

function M_Keydown(state, key, registry)
  if state.page == PAGE_MAIN then return M_Main_Key(state, key) end if
  if state.page == PAGE_SINGLEPLAYER then return M_SinglePlayer_Key(state, key) end if
  if state.page == PAGE_LOAD then return M_Load_Key(state, key) end if
  if state.page == PAGE_SAVE then return M_Save_Key(state, key) end if
  if state.page == PAGE_MULTIPLAYER then return M_MultiPlayer_Key(state, key) end if
  if state.page == PAGE_SETUP then return M_Setup_Key(state, key) end if
  if state.page == PAGE_NET then return M_Net_Key(state, key) end if
  if state.page == PAGE_OPTIONS then return M_Options_Key(state, key, registry) end if
  if state.page == PAGE_KEYS then return M_Keys_Key(state, key) end if
  if state.page == PAGE_VIDEO then return M_Video_Key(state, key) end if
  if state.page == PAGE_HELP then return M_Help_Key(state, key) end if
  if state.page == PAGE_QUIT then return M_Quit_Key(state, key) end if
  if state.page == PAGE_SERIAL then return M_SerialConfig_Key(state, key) end if
  if state.page == PAGE_MODEM then return M_ModemConfig_Key(state, key) end if
  if state.page == PAGE_LAN then return M_LanConfig_Key(state, key) end if
  if state.page == PAGE_GAME_OPTIONS then return M_GameOptions_Key(state, key, registry) end if
  if state.page == PAGE_SEARCH then return M_Search_Key(state, key) end if
  if state.page == PAGE_SERVER_LIST then return M_ServerList_Key(state, key) end if
  return "none"
end function

function M_ConfigureNetSubsystem(state)
  return state.lanPort
end function

function M_SetVideoCallbacks(state, drawCallback, keyCallback)
  state.videoDrawCallback = drawCallback
  state.videoKeyCallback = keyCallback
  return true
end function

function M_CommandTrace(state)
  return state.drawTrace
end function

function M_ExcludedPaths(state)
  return state.excludedPaths
end function

function M_Init(state)
  state.excludedPaths = ["serial", "modem", "ipx"]
  return [
    "togglemenu", "menu_main", "menu_singleplayer", "menu_load", "menu_save",
    "menu_multiplayer", "menu_setup", "menu_options", "menu_keys",
    "menu_video", "help", "menu_quit",
  ]
end function
