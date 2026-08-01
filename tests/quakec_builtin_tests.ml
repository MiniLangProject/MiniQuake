/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

BP-023 source-guided QuakeC builtin parity fixtures for pr_cmds.c.
*/

import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native
import miniquake.array_util as arrayutil
import miniquake.sizebuf as sz
import miniquake.cvar as cvar
import miniquake.cmd as cmd
import miniquake.server as server
import miniquake.quakec.opcodes as op
import miniquake.quakec.vm as vm
import miniquake.quakec.builtins as qc

function equal(actual, expected, name)
  if actual != expected then return error(10030, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function yes(value, name)
  if value != true then return error(10031, name + ": expected true") end if
  return true
end function

function run(number, name, fn)
  print "  [" + number + "/22] " + name
  result = try(fn())
  if result is error then
    print "    FAIL: " + result.message
    return false
  end if
  return true
end function

function definition(typeValue, offset, name)
  return t.QuakeCDef(typeValue, offset, 0, name)
end function

function fields()
  return [
    definition(c.EV_VOID, 0, ""),
    definition(c.EV_VECTOR, 1, "origin"),
    definition(c.EV_VECTOR, 4, "mins"),
    definition(c.EV_VECTOR, 7, "maxs"),
    definition(c.EV_FLOAT, 10, "solid"),
    definition(c.EV_ENTITY, 11, "chain"),
    definition(c.EV_STRING, 12, "classname"),
  ]
end function

function globals()
  result = [
    definition(c.EV_VOID, 0, ""),
    definition(c.EV_ENTITY, 80, "self"),
    definition(c.EV_ENTITY, 81, "msg_entity"),
  ]
  index = 1
  while index <= 16
    result = result + [definition(c.EV_FLOAT, 81 + index, "parm" + index)]
    index = index + 1
  end while
  return result
end function

function noCommand(name)
  return false
end function

function fresh()
  dummy = t.QuakeCFunction(0, 0, 0, 0, "", "", 0, [])
  program = t.QuakeCProgram(
    "bp023-builtins.dat",
    bytes(),
    c.PROG_VERSION,
    c.PROGHEADER_CRC,
    [],
    globals(),
    fields(),
    [dummy],
    bytes(1),
    vm.zeroArray(160),
    16,
  )
  machine = vm.create(program, 16)
  freeFlags = arrayutil.makeFilledArray(16, true)
  freeTimes = arrayutil.makeFilledArray(16, 0.0)
  freeFlags[0] = false
  freeFlags[1] = false
  freeFlags[2] = false
  machine.edictFree = freeFlags
  runtime = t.EdictRuntime(16, 8, freeFlags, freeTimes)
  registry = cvar.createRegistry()
  cvar.register(registry, cvar.create("skill", "2", false, false), noCommand)
  styles = arrayutil.makeFilledArray(64, "")
  contextValue = t.QuakeCContext(
    void,
    void,
    void,
    registry,
    cmd.create(),
    runtime,
    [],
    [],
    styles,
    sz.allocOverflowing(4096),
    sz.allocOverflowing(4096),
    sz.alloc(4096),
    [],
    [],
    [],
    [],
    [],
    0.0,
    1,
    "",
    0,
    void,
    [sz.alloc(1024), sz.alloc(1024)],
    [arrayutil.makeFilledArray(16, 0.0), arrayutil.makeFilledArray(16, 0.0)],
    0,
    0.0,
    bytes(),
  )
  vm.setContext(machine, contextValue)
  qc.install(machine, contextValue)
  return [machine, contextValue]
end function

function setParmWord(machine, index, value)
  qc.setWord(machine, op.OFS_PARM0 + index * 3, value)
end function

function setParmFloat(machine, index, value)
  qc.setFloat(machine, op.OFS_PARM0 + index * 3, value)
end function

function setParmVector(machine, index, value)
  qc.setVectorValue(machine, op.OFS_PARM0 + index * 3, value)
end function

function setParmString(machine, index, value)
  setParmWord(machine, index, vm.internString(machine, value))
end function

function returnStringValue(machine)
  return qc.stringAt(machine, qc.word(machine, op.OFS_RETURN))
end function

function testBuiltinTable()
  state = fresh()
  machine = state[0]
  equal(len(machine.builtins), 79, "stock builtin count")
  yes(try(machine.builtins[5](machine)) is error, "slot 5 is PF_Fixme")
  yes(try(machine.builtins[66](machine)) is error, "slot 66 is PF_Fixme")
  return true
end function

function testFtosInteger()
  state = fresh(); machine = state[0]
  setParmFloat(machine, 0, -12.0)
  qc.PF_ftos(machine)
  equal(returnStringValue(machine), "-12", "integer formatting")
  return true
end function

function testFtosPositiveTieEven()
  state = fresh(); machine = state[0]
  setParmFloat(machine, 0, 1.25)
  qc.PF_ftos(machine)
  equal(returnStringValue(machine), "  1.2", "positive half-even")
  return true
end function

function testFtosNegativeTieEven()
  state = fresh(); machine = state[0]
  setParmFloat(machine, 0, -1.25)
  qc.PF_ftos(machine)
  equal(returnStringValue(machine), " -1.2", "negative half-even")
  return true
end function

function testFtosBinary32BelowTie()
  state = fresh(); machine = state[0]
  setParmFloat(machine, 0, native.bitsFloat(0x40166666))
  qc.PF_ftos(machine)
  equal(returnStringValue(machine), "  2.3", "binary32 below decimal tie")
  return true
end function

function testFtosNegativeZeroAfterRounding()
  state = fresh(); machine = state[0]
  setParmFloat(machine, 0, -0.04)
  qc.PF_ftos(machine)
  equal(returnStringValue(machine), " -0.0", "negative rounded zero")
  return true
end function

function testVtosFormatting()
  state = fresh(); machine = state[0]
  setParmVector(machine, 0, t.Vec3(1.25, -1.25, -0.04))
  qc.PF_vtos(machine)
  equal(returnStringValue(machine), "'  1.2  -1.2  -0.0'", "vector formatting")
  return true
end function


function testTemporaryStringHandleStable()
  state = fresh(); machine = state[0]
  setParmFloat(machine, 0, 3.5)
  qc.PF_ftos(machine)
  firstHandle = qc.word(machine, op.OFS_RETURN)
  setParmVector(machine, 0, t.Vec3(1, 2, 3))
  qc.PF_vtos(machine)
  secondHandle = qc.word(machine, op.OFS_RETURN)
  equal(firstHandle, vm.TEMP_STRING_HANDLE, "ftos temporary handle")
  equal(secondHandle, firstHandle, "shared pr_string_temp handle")
  return true
end function

function testTemporaryStringOverwrite()
  state = fresh(); machine = state[0]
  setParmFloat(machine, 0, 3.5)
  qc.PF_ftos(machine)
  handle = qc.word(machine, op.OFS_RETURN)
  equal(qc.stringAt(machine, handle), "  3.5", "first temporary text")
  setParmVector(machine, 0, t.Vec3(1, 2, 3))
  qc.PF_vtos(machine)
  equal(qc.stringAt(machine, handle), "'  1.0   2.0   3.0'", "temporary buffer overwritten")
  return true
end function

function testFindSkipsNullString()
  state = fresh(); machine = state[0]
  setParmWord(machine, 0, 0)
  setParmWord(machine, 1, qc.fieldOffset(machine, "classname"))
  setParmString(machine, 2, "")
  qc.PF_Find(machine)
  equal(qc.word(machine, op.OFS_RETURN), 0, "unset string does not match empty")
  return true
end function

function testFindLatin1Exact()
  state = fresh(); machine = state[0]
  value = decode(bytes([0xc3, 0xa9]))
  qc.setEntityWord(machine, 2, "classname", vm.internString(machine, value))
  setParmWord(machine, 0, 0)
  setParmWord(machine, 1, qc.fieldOffset(machine, "classname"))
  setParmString(machine, 2, value)
  qc.PF_Find(machine)
  equal(qc.word(machine, op.OFS_RETURN), 2, "Latin-1 byte match")
  return true
end function

function testFindRadiusChainOrder()
  state = fresh(); machine = state[0]
  qc.setEntityFloat(machine, 1, "solid", 1)
  qc.setEntityFloat(machine, 2, "solid", 1)
  qc.setEntityVector(machine, 1, "origin", t.Vec3(2, 0, 0))
  qc.setEntityVector(machine, 2, "origin", t.Vec3(4, 0, 0))
  setParmVector(machine, 0, t.Vec3(0, 0, 0))
  setParmFloat(machine, 1, 8)
  qc.PF_findradius(machine)
  equal(qc.word(machine, op.OFS_RETURN), 2, "last matching entity is chain head")
  equal(qc.entityWord(machine, 2, "chain"), 1, "head links previous entity")
  equal(qc.entityWord(machine, 1, "chain"), 0, "tail links world")
  return true
end function

function testPrecacheSoundIdentityAndDuplicate()
  state = fresh(); machine = state[0]; contextValue = state[1]
  setParmString(machine, 0, "sound/test.wav")
  original = qc.parmWord(machine, 0)
  qc.PF_precache_sound(machine)
  qc.PF_precache_sound(machine)
  equal(len(contextValue.soundPrecache), 1, "duplicate sound")
  equal(qc.word(machine, op.OFS_RETURN), original, "sound string identity")
  return true
end function

function testPrecacheModelIdentityAndDuplicate()
  state = fresh(); machine = state[0]; contextValue = state[1]
  setParmString(machine, 0, "progs/test.mdl")
  original = qc.parmWord(machine, 0)
  qc.PF_precache_model(machine)
  qc.PF_precache_model(machine)
  equal(len(contextValue.modelPrecache), 1, "duplicate model")
  equal(qc.word(machine, op.OFS_RETURN), original, "model string identity")
  return true
end function

function testPrecacheRequiresLoading()
  state = fresh(); machine = state[0]; contextValue = state[1]
  contextValue.server = server.create(1)
  contextValue.server.loading = false
  setParmString(machine, 0, "sound/late.wav")
  yes(try(qc.PF_precache_sound(machine)) is error, "late precache rejected")
  return true
end function

function testPrecacheRejectsLeadingSpace()
  state = fresh(); machine = state[0]
  setParmString(machine, 0, " bad.wav")
  yes(try(qc.PF_precache_sound(machine)) is error, "leading space rejected")
  return true
end function

function testWriteDestinations()
  state = fresh(); machine = state[0]; contextValue = state[1]
  setParmFloat(machine, 0, 0); yes(qc.WriteDest(machine) == contextValue.datagram, "MSG_BROADCAST")
  setParmFloat(machine, 0, 2); yes(qc.WriteDest(machine) == contextValue.reliableDatagram, "MSG_ALL")
  setParmFloat(machine, 0, 3); yes(qc.WriteDest(machine) == contextValue.signon, "MSG_INIT")
  setParmFloat(machine, 0, 1); qc.setGlobalWord(machine, "msg_entity", 2)
  yes(qc.WriteDest(machine) == contextValue.clientMessages[1], "MSG_ONE")
  return true
end function

function testWriteDestinationErrors()
  state = fresh(); machine = state[0]
  setParmFloat(machine, 0, 4)
  yes(try(qc.WriteDest(machine)) is error, "bad destination")
  setParmFloat(machine, 0, 1)
  qc.setGlobalWord(machine, "msg_entity", 0)
  yes(try(qc.WriteDest(machine)) is error, "non-client destination")
  return true
end function

function testChangeLevelOneShot()
  state = fresh(); machine = state[0]; contextValue = state[1]
  setParmString(machine, 0, "e1m2")
  qc.PF_changelevel(machine)
  firstText = contextValue.commands.text
  setParmString(machine, 0, "e1m3")
  qc.PF_changelevel(machine)
  equal(contextValue.changeLevel, "e1m2", "first level retained")
  equal(contextValue.commands.text, firstText, "second command suppressed")
  return true
end function

function testSetSpawnParms()
  state = fresh(); machine = state[0]; contextValue = state[1]
  values = arrayutil.makeFilledArray(16, 0.0)
  index = 0
  while index < 16
    values[index] = index + 1
    index = index + 1
  end while
  contextValue.clientSpawnParms[0] = values
  setParmWord(machine, 0, 1)
  qc.PF_setspawnparms(machine)
  equal(qc.floatValue(machine, qc.globalOffset(machine, "parm1")), 1.0, "parm1")
  equal(qc.floatValue(machine, qc.globalOffset(machine, "parm16")), 16.0, "parm16")
  return true
end function

function testNextEntitySkipsFree()
  state = fresh(); machine = state[0]
  machine.edictFree[1] = true
  machine.edictFree[2] = false
  setParmWord(machine, 0, 0)
  qc.PF_nextent(machine)
  equal(qc.word(machine, op.OFS_RETURN), 2, "next non-free edict")
  return true
end function

function testRandomMsvcSequence()
  state = fresh(); machine = state[0]; contextValue = state[1]
  contextValue.randomSeed = 1
  qc.PF_random(machine)
  first = qc.floatValue(machine, op.OFS_RETURN)
  expectedWord = ((1 * 214013 + 2531011) >> 16) & 0x7fff
  equal(native.floatBits(first), native.floatBits(expectedWord / 32767.0), "MSVC rand first value")
  return true
end function

function main(args)
  print "MiniQuake BP-023 QuakeC builtin tests"
  passed = 0
  if run(1, "builtin table", testBuiltinTable) then passed = passed + 1 end if
  if run(2, "ftos integer", testFtosInteger) then passed = passed + 1 end if
  if run(3, "ftos positive tie-even", testFtosPositiveTieEven) then passed = passed + 1 end if
  if run(4, "ftos negative tie-even", testFtosNegativeTieEven) then passed = passed + 1 end if
  if run(5, "ftos binary32 below tie", testFtosBinary32BelowTie) then passed = passed + 1 end if
  if run(6, "ftos negative rounded zero", testFtosNegativeZeroAfterRounding) then passed = passed + 1 end if
  if run(7, "vtos formatting", testVtosFormatting) then passed = passed + 1 end if
  if run(8, "temporary handle", testTemporaryStringHandleStable) then passed = passed + 1 end if
  if run(9, "temporary overwrite", testTemporaryStringOverwrite) then passed = passed + 1 end if
  if run(10, "find skips null string", testFindSkipsNullString) then passed = passed + 1 end if
  if run(11, "find Latin-1 exact", testFindLatin1Exact) then passed = passed + 1 end if
  if run(12, "findradius chain order", testFindRadiusChainOrder) then passed = passed + 1 end if
  if run(13, "precache sound identity", testPrecacheSoundIdentityAndDuplicate) then passed = passed + 1 end if
  if run(14, "precache model identity", testPrecacheModelIdentityAndDuplicate) then passed = passed + 1 end if
  if run(15, "precache loading gate", testPrecacheRequiresLoading) then passed = passed + 1 end if
  if run(16, "precache empty-string gate", testPrecacheRejectsLeadingSpace) then passed = passed + 1 end if
  if run(17, "WriteDest routes", testWriteDestinations) then passed = passed + 1 end if
  if run(18, "WriteDest errors", testWriteDestinationErrors) then passed = passed + 1 end if
  if run(19, "changelevel one-shot", testChangeLevelOneShot) then passed = passed + 1 end if
  if run(20, "setspawnparms", testSetSpawnParms) then passed = passed + 1 end if
  if run(21, "nextent", testNextEntitySkipsFree) then passed = passed + 1 end if
  if run(22, "MSVC random", testRandomMsvcSequence) then passed = passed + 1 end if
  if passed != 22 then return 1 end if
  print "MiniQuake BP-023 QuakeC builtin tests passed: 22"
  return 0
end function
