import miniquake.statusbar as sbar
import miniquake.render.draw2d as draw
import miniquake.render.gl11 as gl
import miniquake.types as t
import miniquake.constants as c
import miniquake.client as client
import miniquake.player_move as player_move
import miniquake.array_util as arrayutil
import miniquake.native as native

function inline fnvByte(hash, value)
  return ((hash ^ (value & 255)) * 16777619) & 4294967295
end function

function hashInt(hash, value)
  number = native.trunc(value)
  index = 0
  while index < 4
    hash = fnvByte(hash, (number >> (index * 8)) & 255)
    index = index + 1
  end while
  return hash
end function

function hashString(hash, value)
  data = bytes(value)
  for each item in data
    hash = fnvByte(hash, item)
  end for
  return fnvByte(hash, 0)
end function

function hashCommands(commands)
  hash = 2166136261
  calls = 0
  for each command in commands
    kind = command[0]
    if kind == "pic" or kind == "transpic" then
      hash = hashString(hash, kind)
      hash = hashString(hash, command[1])
      hash = hashInt(hash, command[2])
      hash = hashInt(hash, command[3])
      calls = calls + 1
    else if kind == "char" then
      hash = hashString(hash, kind)
      hash = hashInt(hash, command[1])
      hash = hashInt(hash, command[2])
      hash = hashInt(hash, command[3])
      calls = calls + 1
    else if kind == "string" then
      hash = hashString(hash, kind)
      hash = hashString(hash, command[1])
      hash = hashInt(hash, command[2])
      hash = hashInt(hash, command[3])
      calls = calls + 1
    else if kind == "fill" then
      hash = hashString(hash, kind)
      index = 1
      while index < 6
        hash = hashInt(hash, command[index])
        index = index + 1
      end while
      calls = calls + 1
    else if kind == "tileclear" then
      hash = hashString(hash, kind)
      index = 1
      while index < 5
        hash = hashInt(hash, command[index])
        index = index + 1
      end while
      calls = calls + 1
    end if
  end for
  return [calls, hash]
end function

function hashNames(names)
  hash = 2166136261
  for each name in names
    hash = hashString(hash, name)
  end for
  return hash
end function

function emitOps(functionName, scene)
  result = hashCommands(sbar.Sbar_CommandTrace())
  print "{\"function\":\"" + functionName + "\",\"scene\":\"" + scene + "\",\"calls\":" + result[0] + ",\"hash\":" + result[1] + "}"
end function

function palette()
  result = bytes(768)
  index = 0
  while index < len(result)
    result[index] = index & 255
    index = index + 1
  end while
  return result
end function

function fixturePicture(name, width)
  value = t.MenuPicture(name, width, 24, 10 + width)
  draw.registerDrawPicture(value, [0.0, 0.0, 1.0, 1.0], bytes(width * 24))
  return value
end function

function addPicture(pictures, name)
  width = 24
  if name == "gfx/ranking.lmp" then width = 160 end if
  if name == "gfx/complete.lmp" then width = 192 end if
  if name == "gfx/inter.lmp" then width = 320 end if
  if name == "gfx/finale.lmp" then width = 128 end if
  return pictures + [fixturePicture(name, width)]
end function

function makePictures()
  names = []
  index = 0
  while index < 10
    names = names + ["num_" + index, "anum_" + index]
    index = index + 1
  end while
  names = names + ["num_minus", "anum_minus", "num_colon", "num_slash"]
  weapons = ["shotgun", "sshotgun", "nailgun", "snailgun", "rlaunch", "srlaunch", "lightng"]
  for each weapon in weapons
    names = names + ["inv_" + weapon]
  end for
  for each weapon in weapons
    names = names + ["inv2_" + weapon]
  end for
  flash = 1
  while flash <= 5
    for each weapon in weapons
      names = names + ["inva" + flash + "_" + weapon]
    end for
    flash = flash + 1
  end while
  names = names + [
    "sb_shells", "sb_nails", "sb_rocket", "sb_cells",
    "sb_armor1", "sb_armor2", "sb_armor3",
    "sb_key1", "sb_key2", "sb_invis", "sb_invuln", "sb_suit", "sb_quad",
    "sb_sigil1", "sb_sigil2", "sb_sigil3", "sb_sigil4",
    "face1", "face_p1", "face2", "face_p2", "face3", "face_p3",
    "face4", "face_p4", "face5", "face_p5",
    "face_invis", "face_invul2", "face_inv2", "face_quad",
    "sbar", "ibar", "scorebar",
  ]
  hipWeapons = ["laser", "mjolnir", "gren_prox", "prox_gren", "prox"]
  for each weapon in hipWeapons
    names = names + ["inv_" + weapon]
  end for
  for each weapon in hipWeapons
    names = names + ["inv2_" + weapon]
  end for
  flash = 1
  while flash <= 5
    for each weapon in hipWeapons
      names = names + ["inva" + flash + "_" + weapon]
    end for
    flash = flash + 1
  end while
  names = names + [
    "sb_wsuit", "sb_eshld",
    "r_invbar1", "r_invbar2", "r_lava", "r_superlava", "r_gren",
    "r_multirock", "r_plasma", "r_shield1", "r_agrav1", "r_teambord",
    "r_ammolava", "r_ammomulti", "r_ammoplasma",
    "disc", "probe",
    "gfx/ranking.lmp", "gfx/complete.lmp", "gfx/inter.lmp", "gfx/finale.lmp",
  ]
  pictures = []
  for each name in names
    pictures = addPicture(pictures, name)
  end for
  return pictures
end function

function makePlayer()
  player = player_move.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  player.health = 75
  player.armor = 42
  player.ammo = 9
  player.shells = 5
  player.nails = 67
  player.rockets = 1234
  player.cells = 0
  player.items = c.IT_SHOTGUN | c.IT_NAILGUN | c.IT_ARMOR2 | c.IT_NAILS | c.IT_KEY1 | c.IT_INVISIBILITY | c.IT_SIGIL1
  player.activeWeapon = c.IT_NAILGUN
  return player
end function

function makeClient(player)
  state = client.create(player)
  state.maxClients = 5
  state.gameType = c.GAME_COOP
  state.viewEntity = 2
  // Only cl.time drives status-bar time, item flashes and face animation.
  // Keep the newest svc_time deliberately different to catch mtime misuse.
  state.serverTime = 99.0
  state.time = 12.75
  state.completedTime = 185.0
  state.levelName = "The Slipgate Complex"
  state.scores = [
    t.ClientScore("alpha", 0.0, -2, 0x4d),
    t.ClientScore("bravo", 0.0, 1234, 0x00),
    t.ClientScore("charlie", 0.0, 17, 0xb3),
    t.ClientScore("delta", 0.0, 17, 0x6f),
    t.ClientScore("", 0.0, 0, 0),
  ]
  state.stats[c.STAT_HEALTH] = 75
  state.stats[c.STAT_ARMOR] = 42
  state.stats[c.STAT_AMMO] = 9
  state.stats[c.STAT_SHELLS] = 5
  state.stats[c.STAT_NAILS] = 67
  state.stats[c.STAT_ROCKETS] = 1234
  state.stats[c.STAT_CELLS] = 0
  state.stats[c.STAT_ACTIVEWEAPON] = c.IT_NAILGUN
  state.stats[c.STAT_SECRETS] = 2
  state.stats[c.STAT_TOTALSECRETS] = 7
  state.stats[c.STAT_MONSTERS] = 11
  state.stats[c.STAT_TOTALMONSTERS] = 30
  state.items = player.items
  state.itemGetTime[0] = 0.0
  state.itemGetTime[2] = 12.25
  state.itemGetTime[17] = 12.0
  return state
end function

function configure(pictures, player, state)
  sbar.Sbar_Configure(void, 1, player, state, 640, 480, 48, 0.0)
  sbar.Sbar_SetFrameState(0.0, 3)
  draw.Draw_DifferentialSetCaches([], pictures, void)
  return true
end function

function resetTrace()
  gl.Trace_Begin()
  sbar.Sbar_DifferentialClearTrace()
end function

function finishTrace()
  gl.Trace_End()
  return true
end function

function main(args)
  pal = palette()
  draw.Draw_DifferentialReset(pal)
  pictures = makePictures()
  sbar.Sbar_DifferentialReset(pictures)

  sbar.Sbar_DifferentialSetState(5, false, false, false, 0.0)
  sbar.Sbar_ShowScores(); sbar.Sbar_ShowScores()
  print "{\"function\":\"Sbar_ShowScores\",\"scene\":\"show-idempotent\",\"shown\":1,\"updates\":" + sbar.Sbar_DifferentialState()[0] + "}"
  sbar.Sbar_DifferentialSetState(5, true, false, false, 0.0)
  sbar.Sbar_DontShowScores()
  print "{\"function\":\"Sbar_DontShowScores\",\"scene\":\"hide\",\"shown\":0,\"updates\":" + sbar.Sbar_DifferentialState()[0] + "}"
  sbar.Sbar_DifferentialSetState(9, false, false, false, 0.0)
  sbar.Sbar_Changed()
  print "{\"function\":\"Sbar_Changed\",\"scene\":\"invalidate\",\"updates\":" + sbar.Sbar_DifferentialState()[0] + "}"

  sbar.Sbar_Init("id1")
  base = sbar.Sbar_DifferentialState()[9]
  sbar.Sbar_Init("hipnotic")
  hip = sbar.Sbar_DifferentialState()[9]
  sbar.Sbar_Init("rogue")
  rogue = sbar.Sbar_DifferentialState()[9]
  print "{\"function\":\"Sbar_Init\",\"scene\":\"base-hipnotic-rogue-loads\",\"counts\":[" + len(base) + "," + len(hip) + "," + len(rogue) + "],\"hashes\":[" + hashNames(base) + "," + hashNames(hip) + "," + hashNames(rogue) + "],\"commands\":6}"

  player = makePlayer()
  state = makeClient(player)
  configure(pictures, player, state)
  probe = pictures[len(pictures) - 5]

  resetTrace(); state.gameType = c.GAME_COOP; configure(pictures, player, state); sbar.Sbar_DrawPic(3, -4, probe); state.gameType = c.GAME_DEATHMATCH; configure(pictures, player, state); sbar.Sbar_DrawPic(3, -4, probe); finishTrace()
  emitOps("Sbar_DrawPic", "coop-deathmatch-offsets")
  resetTrace(); state.gameType = c.GAME_COOP; configure(pictures, player, state); sbar.Sbar_DrawTransPic(5, -6, probe); state.gameType = c.GAME_DEATHMATCH; configure(pictures, player, state); sbar.Sbar_DrawTransPic(5, -6, probe); finishTrace()
  emitOps("Sbar_DrawTransPic", "coop-deathmatch-offsets")
  resetTrace(); state.gameType = c.GAME_COOP; configure(pictures, player, state); sbar.Sbar_DrawCharacter(7, -8, 65); state.gameType = c.GAME_DEATHMATCH; configure(pictures, player, state); sbar.Sbar_DrawCharacter(7, -8, 65); finishTrace()
  emitOps("Sbar_DrawCharacter", "coop-deathmatch-offsets")
  resetTrace(); state.gameType = c.GAME_COOP; configure(pictures, player, state); sbar.Sbar_DrawString(9, -10, "quake"); state.gameType = c.GAME_DEATHMATCH; configure(pictures, player, state); sbar.Sbar_DrawString(9, -10, "quake"); finishTrace()
  emitOps("Sbar_DrawString", "coop-deathmatch-offsets")

  negative = sbar.Sbar_itoa(-1234)
  zero = sbar.Sbar_itoa(0)
  positive = sbar.Sbar_itoa(9876)
  print "{\"function\":\"Sbar_itoa\",\"scene\":\"signed-decimal\",\"negative\":\"" + negative[0] + "\",\"length\":" + negative[1] + ",\"zero\":\"" + zero[0] + "\",\"positive\":\"" + positive[0] + "\"}"

  resetTrace(); state.gameType = c.GAME_COOP; configure(pictures, player, state); sbar.Sbar_DrawNum(10, -2, -1234, 3, 1); finishTrace()
  emitOps("Sbar_DrawNum", "crop-align-color")

  state = makeClient(player); configure(pictures, player, state)
  order = sbar.Sbar_SortFrags(state.scores)
  print "{\"function\":\"Sbar_SortFrags\",\"scene\":\"stable-descending\",\"order\":[" + order[0] + "," + order[1] + "," + order[2] + "," + order[3] + "],\"lines\":" + len(order) + "}"
  print "{\"function\":\"Sbar_ColorForMap\",\"scene\":\"palette-offset\",\"values\":[" + sbar.Sbar_ColorForMap(0) + "," + sbar.Sbar_ColorForMap(112) + "," + sbar.Sbar_ColorForMap(240) + "]}"
  sbar.Sbar_UpdateScoreboard()
  table = sbar.Sbar_DifferentialState()
  print "{\"function\":\"Sbar_UpdateScoreboard\",\"scene\":\"text-and-colors\",\"first\":\"" + table[6][0] + "\",\"top\":" + table[7][0] + ",\"bottom\":" + table[8][0] + "}"

  resetTrace(); state.gameType = c.GAME_COOP; configure(pictures, player, state); sbar.Sbar_SoloScoreboard(); finishTrace()
  emitOps("Sbar_SoloScoreboard", "stats-time-level")
  resetTrace(); state.gameType = c.GAME_DEATHMATCH; configure(pictures, player, state); sbar.Sbar_DrawScoreboard(); finishTrace()
  emitOps("Sbar_DrawScoreboard", "solo-plus-deathmatch")

  player = makePlayer(); state = makeClient(player); configure(pictures, player, state)
  resetTrace(); sbar.Sbar_DifferentialSetState(0, false, false, false, 0.0); sbar.Sbar_DrawInventory(); finishTrace()
  emitOps("Sbar_DrawInventory", "base-inventory")
  sbar.Sbar_DifferentialSetState(0, false, true, false, 0.0); state.items = state.items | c.HIT_LASER_CANNON | c.HIT_PROXIMITY_GUN | c.IT_GRENADE_LAUNCHER | c.HIT_WETSUIT; state.itemGetTime[c.HIT_LASER_CANNON_BIT] = 12.25; resetTrace(); sbar.Sbar_DrawInventory(); finishTrace()
  emitOps("Sbar_DrawInventory", "hipnotic-inventory")
  sbar.Sbar_DifferentialSetState(0, false, false, true, 0.0); state.items = state.items | c.RIT_SHIELD; state.stats[c.STAT_ACTIVEWEAPON] = c.RIT_MULTI_GRENADE; resetTrace(); sbar.Sbar_DrawInventory(); finishTrace()
  emitOps("Sbar_DrawInventory", "rogue-inventory")

  player = makePlayer(); state = makeClient(player); configure(pictures, player, state); sbar.Sbar_DifferentialSetState(0, false, false, false, 0.0)
  resetTrace(); sbar.Sbar_DrawFrags(); finishTrace()
  emitOps("Sbar_DrawFrags", "top-four-colors-markers")

  resetTrace(); state.items = c.IT_INVISIBILITY | c.IT_INVULNERABILITY; sbar.Sbar_DrawFace()
  state.items = 0; state.stats[c.STAT_HEALTH] = 20; state.faceAnimTime = state.time; sbar.Sbar_DrawFace()
  state.gameType = c.GAME_DEATHMATCH; state.scores[state.viewEntity - 1].colors = 0; configure(pictures, player, state); sbar.Sbar_DifferentialSetState(0, false, false, true, 4.0); sbar.Sbar_DrawFace(); finishTrace()
  emitOps("Sbar_DrawFace", "power-health-animation-team")

  player = makePlayer(); state = makeClient(player); configure(pictures, player, state); sbar.Sbar_DifferentialSetState(0, false, false, false, 0.0)
  resetTrace(); sbar.Sbar_Draw(); finishTrace()
  emitOps("Sbar_Draw", "normal-wide-order")
  sbar.Sbar_DifferentialSetState(0, true, false, false, 0.0); state.gameType = c.GAME_DEATHMATCH; configure(pictures, player, state); resetTrace(); sbar.Sbar_Draw(); finishTrace()
  emitOps("Sbar_Draw", "score-deathmatch-order")
  state.gameType = c.GAME_COOP
  sbar.Sbar_Configure(void, 1, player, state, 640, 480, 0, 0.0)
  sbar.Sbar_SetFrameState(0.0, 3)
  sbar.Sbar_DifferentialSetState(0, false, false, false, 0.0)
  resetTrace(); sbar.Sbar_Draw(); finishTrace()
  emitOps("Sbar_Draw", "zero-lines-no-main-bar")

  resetTrace(); sbar.Sbar_IntermissionNumber(10, 20, -1234, 3, 1); finishTrace()
  emitOps("Sbar_IntermissionNumber", "absolute-crop-align")
  player = makePlayer(); state = makeClient(player); state.gameType = c.GAME_DEATHMATCH; configure(pictures, player, state)
  resetTrace(); sbar.Sbar_DeathmatchOverlay(); finishTrace()
  emitOps("Sbar_DeathmatchOverlay", "ranked-scoreboard")
  resetTrace(); sbar.Sbar_MiniDeathmatchOverlay(); finishTrace()
  emitOps("Sbar_MiniDeathmatchOverlay", "centered-player-window")
  state.gameType = c.GAME_COOP; configure(pictures, player, state)
  resetTrace(); sbar.Sbar_IntermissionOverlay(); finishTrace()
  emitOps("Sbar_IntermissionOverlay", "completion-stats")
  resetTrace(); sbar.Sbar_FinaleOverlay(); finishTrace()
  emitOps("Sbar_FinaleOverlay", "centered-finale")
  return 0
end function
