/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

BP-024 stock progs.dat compatibility gate. Requires user-owned Quake data.
*/

import miniquake.filesystem as qfs
import miniquake.format.progs as progs
import miniquake.quakec.contract as contract

function fail(message)
  print "MiniQuake BP-024 stock QuakeC test: FAIL"
  print "  " + message
  return 1
end function

function main(args)
  if len(args) < 1 then
    print "usage: MiniQuakeQuakeCStockTests.exe BASEDIR [GAME]"
    return 2
  end if
  game = "id1"
  if len(args) > 1 then game = args[1] end if
  filesystem = try(qfs.initialize(args[0], game))
  if filesystem is error then return fail(filesystem.message) end if
  data = try(qfs.readFile(filesystem, "progs.dat"))
  if data is error then qfs.release(filesystem); return fail(data.message) end if
  program = try(progs.parse(data, game + "/progs.dat"))
  if program is error then qfs.release(filesystem); return fail(program.message) end if
  audited = try(progs.validateProgram(program))
  if audited is error then qfs.release(filesystem); return fail(audited.message) end if
  checked = try(contract.validate(program))
  if checked is error then qfs.release(filesystem); return fail(checked.message) end if
  summary = contract.summary(program)
  print "MiniQuake BP-024 stock QuakeC contract"
  print "  status=" + summary[0]
  print "  contract_fingerprint=" + summary[1]
  print "  program_fingerprint=" + summary[2]
  print "  statements=" + summary[3] + " functions=" + summary[4]
  print "  globaldefs=" + summary[5] + " fielddefs=" + summary[6] + " globals=" + summary[7]
  print "  entity_fields=" + summary[8] + " builtin_refs=" + summary[9] + " max_builtin=" + summary[10]
  qfs.release(filesystem)
  print "MiniQuake BP-024 stock QuakeC test: PASS"
  return 0
end function
