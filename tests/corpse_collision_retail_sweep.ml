/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Retail sweep for monster corpse solidity after completed death animations.
*/
import miniquake.host as host
import miniquake.server as server
import miniquake.quakec.vm as vm
import miniquake.quakec.opcodes as op

// Report whether the classname belongs to a Quake monster entity.
function monsterClass(name)
  data = bytes(name)
  return len(data) >= 8 and decode(slice(data, 0, 8)) == "monster_"
end function

// Apply non-gib lethal damage through the stock T_Damage QuakeC function.
function killMonster(machine, functionIndex, entityIndex, health)
  vm.setWord(machine, op.OFS_PARM0, entityIndex)
  vm.setWord(machine, op.OFS_PARM1, 1)
  vm.setWord(machine, op.OFS_PARM2, 1)
  vm.setGlobalFloat(machine, op.OFS_PARM3, health + 10.0)
  return vm.execute(machine, functionIndex)
end function

// Kill every monster on one map and find corpses that remain solid after 3 s.
function main(args)
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  if len(args) < 2 then print "usage: sweep BASE MAP"; return 2 end if
  session = host.create([
    "-basedir", args[0], "-game", "id1", "-nosound", "-noinput",
    "-window", "-width", "640", "-height", "480", "+map", args[1],
  ])
  initialized = try(host.initialize(session))
  if initialized is error then print initialized.message; return 1 end if
  machine = session.server.machine
  damage = vm.functionIndex(machine, "T_Damage")
  killedIndexes = []
  index = session.server.maxClients + 1
  while index < machine.context.edicts.numEdicts
    name = server.qcString(machine, index, "classname", "")
    health = server.qcFloat(machine, index, "health", 0.0)
    if monsterClass(name) and health > 0.0 then
      result = try(killMonster(machine, damage, index, health))
      if result is error then print result.message; host.shutdown(session); return 3 end if
      killedIndexes = killedIndexes + [index]
    end if
    index = index + 1
  end while

  frameIndex = 0
  while frameIndex < 60
    frameResult = try(host.frame(session, 0.05))
    if frameResult is error then print frameResult.message; host.shutdown(session); return 4 end if
    frameIndex = frameIndex + 1
  end while

  blocked = 0
  for each entityIndex in killedIndexes
    if entityIndex < machine.context.edicts.numEdicts and not machine.context.edicts.freeFlags[entityIndex] then
      health = server.qcFloat(machine, entityIndex, "health", 0.0)
      solid = server.qcFloat(machine, entityIndex, "solid", 0.0)
      if health <= 0.0 and solid != 0.0 then
        blocked = blocked + 1
        print "solid corpse entity=" + entityIndex +
          " class=" + server.qcString(machine, entityIndex, "classname", "") +
          " health=" + health + " solid=" + solid +
          " think=" + server.qcWord(machine, entityIndex, "think", 0) +
          " nextthink=" + server.qcFloat(machine, entityIndex, "nextthink", 0.0)
      end if
    end if
  end for
  print "corpse sweep map=" + args[1] + " killed=" + len(killedIndexes) + " solid_after_3s=" + blocked
  host.shutdown(session)
  if blocked != 0 then return 5 end if
  return 0
end function
