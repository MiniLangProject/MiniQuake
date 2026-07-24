/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Branch and binary-layout checks for the header-only GLQuake logical units:
bspfile.h, modelgen.h, spritegn.h, protocol.h, pr_comp.h, progdefs.h,
progs.h, and the shared quakedef.h constants consumed by those formats.
*/

import miniquake.types as t
import miniquake.constants as c
import miniquake.byteio as bio
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.client_protocol as protocol
import miniquake.format.bsp as bsp
import miniquake.format.mdl as mdl
import miniquake.format.sprite as sprite
import miniquake.format.progs as progs
import miniquake.quakec.opcodes as op

function assertEqual(actual, expected, name)
  if actual != expected then return error(9940, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function assertNear(actual, expected, name)
  difference = actual - expected
  if difference < 0.0 then difference = -difference end if
  if difference > 0.00001 then return error(9941, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function assertTrue(value, name)
  if value != true then return error(9942, name + ": expected true") end if
  return true
end function

function testBspHeaderAbi()
  assertEqual(c.BSP_VERSION, 29, "BSPVERSION")
  assertEqual(c.BSP_TOOL_VERSION, 2, "TOOLVERSION")
  assertEqual(c.BSPVERSION, c.BSP_VERSION, "BSPVERSION alias")
  assertEqual(c.TOOLVERSION, c.BSP_TOOL_VERSION, "TOOLVERSION alias")
  assertEqual(c.MAX_KEY, 32, "MAX_KEY")
  assertEqual(c.MAX_VALUE, 1024, "MAX_VALUE")
  assertEqual(c.MIPLEVELS, 4, "MIPLEVELS")
  assertEqual(c.MAX_MAP_HULLS, 4, "MAX_MAP_HULLS")
  assertEqual(c.MAX_MAP_EDGES, 256000, "MAX_MAP_EDGES")
  assertEqual(c.MAX_MAP_SURFEDGES, 512000, "MAX_MAP_SURFEDGES")
  assertEqual(c.MAX_MAP_MIPTEX, 0x200000, "MAX_MAP_MIPTEX")
  assertEqual(c.CONTENTS_CURRENT_0, -9, "CONTENTS_CURRENT_0")
  assertEqual(c.CONTENTS_CURRENT_DOWN, -14, "CONTENTS_CURRENT_DOWN")
  assertEqual(c.AMBIENT_WATER, 0, "AMBIENT_WATER")
  assertEqual(c.AMBIENT_LAVA, 3, "AMBIENT_LAVA")
  assertEqual(c.NUM_AMBIENTS, 4, "NUM_AMBIENTS")

  nodeData = bytes(24)
  bio.putI32(nodeData, 0, 0x12345678)
  bio.putI16(nodeData, 4, -1)
  bio.putI16(nodeData, 6, 32767)
  bio.putI16(nodeData, 8, -300)
  bio.putI16(nodeData, 14, 400)
  bio.putU16(nodeData, 20, 65535)
  bio.putU16(nodeData, 22, 65534)
  nodes = bsp.Mod_LoadNodes(nodeData, t.Lump(0, 24))
  assertEqual(nodes[0].planeIndex, 0x12345678, "dnode.planenum i32")
  assertEqual(nodes[0].child0, -1, "dnode child signed")
  assertEqual(nodes[0].child1, 32767, "dnode child upper signed")
  assertEqual(nodes[0].mins.x, -300.0, "dnode mins signed")
  assertEqual(nodes[0].maxs.x, 400.0, "dnode maxs signed")
  assertEqual(nodes[0].firstFace, 65535, "dnode firstface unsigned")
  assertEqual(nodes[0].numFaces, 65534, "dnode numfaces unsigned")

  leafData = bytes(28)
  bio.putI32(leafData, 0, c.CONTENTS_CURRENT_90)
  bio.putI32(leafData, 4, -1)
  bio.putU16(leafData, 20, 65535)
  bio.putU16(leafData, 22, 2)
  leafData[24] = 1; leafData[25] = 2; leafData[26] = 3; leafData[27] = 4
  leafs = bsp.Mod_LoadLeafs(leafData, t.Lump(0, 28))
  assertEqual(leafs[0].contents, -10, "dleaf current contents")
  assertEqual(leafs[0].visibilityOffset, -1, "dleaf no visibility")
  assertEqual(leafs[0].firstMarkSurface, 65535, "dleaf firstmarksurface unsigned")
  assertEqual(leafs[0].ambient[3], 4, "dleaf ambient levels")

  modelData = bytes(64)
  bio.putF32(modelData, 0, -16.0)
  bio.putF32(modelData, 12, 16.0)
  bio.putI32(modelData, 36, 11)
  bio.putI32(modelData, 40, 22)
  bio.putI32(modelData, 44, 33)
  bio.putI32(modelData, 48, 44)
  bio.putI32(modelData, 52, 55)
  bio.putI32(modelData, 56, 66)
  bio.putI32(modelData, 60, 77)
  models = bsp.Mod_LoadSubmodels(modelData, t.Lump(0, 64))
  assertEqual(models[0].mins.x, -17.0, "dmodel mins runtime spread")
  assertEqual(models[0].maxs.x, 17.0, "dmodel maxs runtime spread")
  assertEqual(models[0].headNodes[3], 44, "dmodel four hull heads")
  assertEqual(models[0].visibleLeafs, 55, "dmodel visleafs")
  assertEqual(models[0].firstFace, 66, "dmodel firstface")
  assertEqual(models[0].numFaces, 77, "dmodel numfaces")

  assertTrue(try(bsp.Mod_LoadNodes(bytes(23), t.Lump(0, 23))) is error, "dnode stride rejection")
  assertTrue(try(bsp.Mod_LoadLeafs(bytes(27), t.Lump(0, 27))) is error, "dleaf stride rejection")
  assertTrue(try(bsp.parseLumps(bytes(123))) is error, "dheader truncation rejection")
  return true
end function

function testModelHeaderAbi()
  assertEqual(c.ALIAS_VERSION, 6, "ALIAS_VERSION")
  assertEqual(c.ALIAS_ONSEAM, 0x20, "ALIAS_ONSEAM")
  assertEqual(c.DT_FACES_FRONT, 0x10, "DT_FACES_FRONT")
  assertEqual(c.IDPOLYHEADER, 0x4f504449, "IDPOLYHEADER")
  assertEqual(c.ST_SYNC, 0, "ST_SYNC")
  assertEqual(c.ST_RAND, 1, "ST_RAND")

  // daliasgroup_t (12), two intervals, then two daliasframe_t records.
  group = bytes(12 + 8 + 2 * 28)
  bio.putI32(group, 0, 2)
  group[4] = 1; group[8] = 9
  bio.putF32(group, 12, 0.1)
  bio.putF32(group, 16, 0.3)
  group[44] = 65
  group[72] = 66
  parsedGroup = mdl.Mod_LoadAliasGroup(group, 0, 1)
  frameSet = parsedGroup[0]
  assertEqual(len(frameSet.frames), 2, "daliasgroup frame count")
  assertNear(frameSet.intervals[0], 0.1, "daliasinterval first")
  assertNear(frameSet.intervals[1], 0.3, "daliasinterval second")
  assertEqual(frameSet.frames[0].vertices[0].x, 65, "daliasframe first vertex")
  assertEqual(frameSet.frames[1].vertices[0].x, 66, "daliasframe second vertex")
  assertEqual(parsedGroup[1], len(group), "daliasgroup exact byte consumption")

  // daliasskingroup_t, intervals, and two one-byte skin images.
  skinGroup = bytes(4 + 4 + 8 + 2)
  bio.putI32(skinGroup, 0, c.ALIAS_SKIN_GROUP)
  bio.putI32(skinGroup, 4, 2)
  bio.putF32(skinGroup, 8, 0.2)
  bio.putF32(skinGroup, 12, 0.4)
  skinGroup[16] = 7
  skinGroup[17] = 8
  parsedSkin = mdl.parseSkin(skinGroup, 0, 1, 1)
  assertEqual(len(parsedSkin[0].images), 2, "daliasskingroup skin count")
  assertNear(parsedSkin[0].intervals[1], 0.4, "daliasskininterval second")
  assertEqual(parsedSkin[1], len(skinGroup), "daliasskingroup exact consumption")
  assertTrue(try(mdl.Mod_LoadAliasGroup(bytes(11), 0, 1)) is error, "daliasgroup truncation")
  return true
end function

function testSpriteHeaderAbi()
  assertEqual(c.SPRITE_VERSION, 1, "SPRITE_VERSION")
  assertEqual(c.IDSPRITEHEADER, 0x50534449, "IDSPRITEHEADER")
  assertEqual(c.SPR_VP_PARALLEL_UPRIGHT, 0, "SPR_VP_PARALLEL_UPRIGHT")
  assertEqual(c.SPR_VP_PARALLEL_ORIENTED, 4, "SPR_VP_PARALLEL_ORIENTED")
  assertEqual(c.SPR_SINGLE, 0, "SPR_SINGLE")
  assertEqual(c.SPR_GROUP, 1, "SPR_GROUP")

  // dspritegroup_t, two cumulative intervals, and two 1x1 frames.
  group = bytes(4 + 8 + 2 * 17)
  bio.putI32(group, 0, 2)
  bio.putF32(group, 4, 0.15)
  bio.putF32(group, 8, 0.5)
  bio.putI32(group, 20, 1); bio.putI32(group, 24, 1); group[28] = 11
  bio.putI32(group, 37, 1); bio.putI32(group, 41, 1); group[45] = 22
  parsed = sprite.Mod_LoadSpriteGroup(group, 0)
  assertNear(parsed[0].intervals[0], 0.15, "dspriteinterval first")
  assertNear(parsed[0].intervals[1], 0.5, "dspriteinterval cumulative")
  assertEqual(parsed[0].frames[0].pixels[0], 11, "dspriteframe first pixel")
  assertEqual(parsed[0].frames[1].pixels[0], 22, "dspriteframe second pixel")
  assertEqual(parsed[1], len(group), "dspritegroup exact consumption")
  invalid = bytes(8)
  bio.putI32(invalid, 0, 1)
  bio.putF32(invalid, 4, 0.0)
  assertTrue(try(sprite.Mod_LoadSpriteGroup(invalid, 0)) is error, "sprite interval nonpositive")
  return true
end function

function testQuakeCHeaderAbi()
  assertEqual(c.PROG_VERSION, 6, "PROG_VERSION")
  assertEqual(c.DEF_SAVEGLOBAL, 0x8000, "DEF_SAVEGLOBAL")
  assertEqual(c.QC_MAX_PARMS, 8, "MAX_PARMS")
  assertEqual(c.QC_MAX_ENT_LEAFS, 16, "MAX_ENT_LEAFS")
  assertEqual(c.MAX_ENT_LEAFS, c.QC_MAX_ENT_LEAFS, "MAX_ENT_LEAFS alias")
  assertEqual(op.OFS_RETURN, 1, "OFS_RETURN")
  assertEqual(op.OFS_PARM0, 4, "OFS_PARM0")
  assertEqual(op.OFS_PARM7, 25, "OFS_PARM7")
  assertEqual(op.RESERVED_OFS, 28, "RESERVED_OFS")
  assertEqual(op.OP_BITOR, 65, "last opcode")

  // One statement, one global def, one field def, one function, strings,
  // and 32-bit raw globals. This exercises every dprograms_t section stride.
  strings = bytes([0, 110, 97, 109, 101, 0, 102, 105, 108, 101, 0])
  statementOffset = 60
  globalDefOffset = 68
  fieldDefOffset = 76
  functionOffset = 84
  stringOffset = 120
  globalsOffset = stringOffset + len(strings)
  data = bytes(globalsOffset + 8)
  bio.putI32(data, 0, c.PROG_VERSION)
  bio.putI32(data, 4, 5927)
  bio.putI32(data, 8, statementOffset); bio.putI32(data, 12, 1)
  bio.putI32(data, 16, globalDefOffset); bio.putI32(data, 20, 1)
  bio.putI32(data, 24, fieldDefOffset); bio.putI32(data, 28, 1)
  bio.putI32(data, 32, functionOffset); bio.putI32(data, 36, 1)
  bio.putI32(data, 40, stringOffset); bio.putI32(data, 44, len(strings))
  bio.putI32(data, 48, globalsOffset); bio.putI32(data, 52, 2)
  bio.putI32(data, 56, 123)
  bio.putU16(data, statementOffset, op.OP_GOTO)
  bio.putI16(data, statementOffset + 2, -7)
  bio.putI16(data, statementOffset + 4, 8)
  bio.putI16(data, statementOffset + 6, -9)
  bio.putU16(data, globalDefOffset, c.DEF_SAVEGLOBAL | c.EV_FLOAT)
  bio.putU16(data, globalDefOffset + 2, 44)
  bio.putI32(data, globalDefOffset + 4, 1)
  bio.putU16(data, fieldDefOffset, c.EV_VECTOR)
  bio.putU16(data, fieldDefOffset + 2, 55)
  bio.putI32(data, fieldDefOffset + 4, 1)
  bio.putI32(data, functionOffset, -12)
  bio.putI32(data, functionOffset + 4, 30)
  bio.putI32(data, functionOffset + 8, 6)
  bio.putI32(data, functionOffset + 12, 99)
  bio.putI32(data, functionOffset + 16, 1)
  bio.putI32(data, functionOffset + 20, 6)
  bio.putI32(data, functionOffset + 24, 8)
  index = 0
  while index < c.QC_MAX_PARMS
    data[functionOffset + 28 + index] = index
    index = index + 1
  end while
  bio.copyInto(data, stringOffset, strings, 0, len(strings))
  bio.putU32(data, globalsOffset, 0x80000000)
  bio.putU32(data, globalsOffset + 4, 0x7fc00000)

  program = progs.parse(data, "abi-progs.dat")
  assertEqual(program.crc, 5927, "dprograms crc")
  assertEqual(program.entityFields, 123, "dprograms entityfields")
  assertEqual(program.statements[0].a, -7, "dstatement signed a")
  assertEqual(program.statements[0].c, -9, "dstatement signed c")
  assertEqual(program.globalDefs[0].type, c.DEF_SAVEGLOBAL | c.EV_FLOAT, "ddef save type")
  assertEqual(program.globalDefs[0].offset, 44, "ddef ofs")
  assertEqual(program.functions[0].firstStatement, -12, "dfunction builtin statement")
  assertEqual(program.functions[0].name, "name", "dfunction name string")
  assertEqual(program.functions[0].file, "file", "dfunction file string")
  assertEqual(program.functions[0].parmSize[7], 7, "dfunction parm_size[8]")
  assertEqual(program.globals[0], 0x80000000, "globals preserve raw sign bit")
  assertEqual(program.globals[1], 0x7fc00000, "globals preserve raw NaN bits")

  badSection = bytes(data)
  bio.putI32(badSection, 8, len(data) - 4)
  assertTrue(try(progs.parse(badSection, "bad-section.dat")) is error, "dprograms section bounds")
  badEmptySection = bytes(data)
  bio.putI32(badEmptySection, 16, len(data) + 1)
  bio.putI32(badEmptySection, 20, 0)
  assertTrue(try(progs.parse(badEmptySection, "bad-empty-section.dat")) is error, "empty dprograms section offset bounds")
  badVersion = bytes(data)
  bio.putI32(badVersion, 0, c.PROG_VERSION + 1)
  assertTrue(try(progs.parse(badVersion, "bad-version.dat")) is error, "dprograms version")
  return true
end function

function testProtocolHeaderAbi()
  assertNear(c.VERSION, 1.09, "VERSION")
  assertNear(c.GLQUAKE_VERSION, 1.0, "GLQUAKE_VERSION")
  assertNear(c.D3DQUAKE_VERSION, 0.01, "D3DQUAKE_VERSION")
  assertNear(c.WINQUAKE_VERSION, 0.996, "WINQUAKE_VERSION")
  assertNear(c.LINUX_VERSION, 1.30, "LINUX_VERSION")
  assertNear(c.X11_VERSION, 1.10, "X11_VERSION")
  assertEqual(c.QUAKE_VERSION, "1.09", "formatted VERSION")
  assertEqual(c.GAMENAME, "id1", "GAMENAME")
  assertEqual(c.GAME_NAME, c.GAMENAME, "game name alias")
  assertEqual(c.CACHE_SIZE, 32, "CACHE_SIZE")
  assertEqual(c.MINIMUM_MEMORY, 0x550000, "MINIMUM_MEMORY")
  assertEqual(c.MINIMUM_MEMORY_LEVELPAK, 0x650000, "MINIMUM_MEMORY_LEVELPAK")
  assertEqual(c.MAX_NUM_ARGVS, 50, "MAX_NUM_ARGVS")
  assertEqual(c.PITCH, 0, "PITCH")
  assertEqual(c.YAW, 1, "YAW")
  assertEqual(c.ROLL, 2, "ROLL")
  assertNear(c.ON_EPSILON, 0.1, "ON_EPSILON")
  assertEqual(c.SAVEGAME_COMMENT_LENGTH, 39, "SAVEGAME_COMMENT_LENGTH")
  assertEqual(c.MAX_STYLESTRING, 64, "MAX_STYLESTRING")
  assertEqual(c.MAX_SCOREBOARD, 16, "MAX_SCOREBOARD")
  assertEqual(c.MAX_SCOREBOARDNAME, 32, "MAX_SCOREBOARDNAME")
  assertEqual(c.SOUND_CHANNELS, 8, "SOUND_CHANNELS")
  assertEqual(c.RIT_SUPERHEALTH, 2147483648, "RIT_SUPERHEALTH")
  assertEqual(c.PROTOCOL_VERSION, 15, "PROTOCOL_VERSION")
  assertEqual(c.U_SIGNAL, 0x80, "U_SIGNAL")
  assertEqual(c.U_LONGENTITY, 0x4000, "U_LONGENTITY")
  assertEqual(c.SU_ITEMS, 0x0200, "SU_ITEMS")
  assertEqual(c.SND_VOLUME, 1, "SND_VOLUME")
  assertEqual(c.SND_ATTENUATION, 2, "SND_ATTENUATION")
  assertEqual(c.SND_LOOPING, 4, "SND_LOOPING")
  assertEqual(c.SVC_CUTSCENE, 34, "svc_cutscene")
  assertEqual(c.CLC_STRINGCMD, 4, "clc_stringcmd")
  assertEqual(c.TE_BEAM, 13, "TE_BEAM")

  sound = sz.alloc(64)
  msg.writeByte(sound, c.SVC_SOUND)
  msg.writeByte(sound, c.SND_VOLUME | c.SND_ATTENUATION)
  msg.writeByte(sound, 123)
  msg.writeByte(sound, 32)
  msg.writeShort(sound, (7 << 3) | 5)
  msg.writeByte(sound, 9)
  msg.writeCoord(sound, 1.0); msg.writeCoord(sound, 2.0); msg.writeCoord(sound, 3.0)
  parsed = protocol.parse(sz.dataSlice(sound))
  payload = parsed.events[0].payload
  assertEqual(payload[0], 3, "sound field mask")
  assertEqual(payload[1], 123, "sound explicit volume")
  assertNear(payload[2], 0.5, "sound explicit attenuation")
  assertEqual(payload[3], 61, "sound entity/channel packing")

  defaultSound = sz.alloc(64)
  msg.writeByte(defaultSound, c.SVC_SOUND)
  msg.writeByte(defaultSound, 0)
  msg.writeShort(defaultSound, 0)
  msg.writeByte(defaultSound, 1)
  msg.writeCoord(defaultSound, 0.0); msg.writeCoord(defaultSound, 0.0); msg.writeCoord(defaultSound, 0.0)
  defaults = protocol.parse(sz.dataSlice(defaultSound)).events[0].payload
  assertEqual(defaults[1], 255, "sound default volume")
  assertNear(defaults[2], 1.0, "sound default attenuation")

  assertTrue(try(protocol.parse(bytes([c.SVC_TIME, 1, 2]))) is error, "truncated svc payload")
  assertTrue(try(protocol.parse(bytes([c.SVC_SPAWNBINARY]))) is error, "unused svc_spawnbinary rejected")
  return true
end function

function main(args)
  print "[1/5] BSP29 header/layout ABI"
  testBspHeaderAbi()
  print "[2/5] MDL6 header/layout ABI"
  testModelHeaderAbi()
  print "[3/5] SPR1 header/layout ABI"
  testSpriteHeaderAbi()
  print "[4/5] QuakeC v6 ABI"
  testQuakeCHeaderAbi()
  print "[5/5] protocol 15 ABI"
  testProtocolHeaderAbi()
  print "MiniQuake core format/ABI tests passed: 5"
  return 0
end function
