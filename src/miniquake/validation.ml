package miniquake.validation

import miniquake.filesystem as qfs
import miniquake.format.bsp as bsp
import miniquake.format.progs as progs
import miniquake.render.world as renderer
import miniquake.world_bsp as world
import miniquake.constants as c

function validateMap(filesystem, mapName, palette)
  path = "maps/" + mapName + ".bsp"
  data = qfs.readFile(filesystem, path)
  map = bsp.parse(data, path)
  if map.version != c.BSP_VERSION then return error(3100, path + ": wrong BSP version") end if
  if len(map.models) == 0 then return error(3101, path + ": no world model") end if
  if len(map.faces) == 0 then return error(3102, path + ": no world faces") end if
  hull = world.createHull(map, 1)
  built = renderer.create(map, palette)
  print path + ":"
  print "  entities=" + len(map.entities) + " models=" + len(map.models) + " faces=" + len(map.faces)
  print "  vertices=" + len(map.vertices) + " textures=" + len(map.textures) + " surfaces=" + len(built.surfaces)
  print "  player-hull=" + hull.firstClipNode + ".." + hull.lastClipNode
  return map
end function

function run(baseDirectory, preferredMap)
  filesystem = qfs.standard(baseDirectory, "id1")
  palette = qfs.readFile(filesystem, "gfx/palette.lmp")
  if len(palette) < 768 then return error(3103, "gfx/palette.lmp is truncated") end if
  programData = qfs.readFile(filesystem, "progs.dat")
  program = progs.parse(programData, "progs.dat")
  print "MiniQuake game-data validation"
  print "  base directory: " + baseDirectory
  print "  palette: " + len(palette) + " bytes"
  print "  progs.dat: " + len(program.functions) + " functions, " + len(program.statements) + " statements"
  print "  progs crc: " + program.crc
  print "  search paths:" + qfs.describe(filesystem)

  mapName = preferredMap
  if mapName == "" then mapName = "start" end if
  validateMap(filesystem, mapName, palette)
  if mapName != "e1m1" and qfs.fileExists(filesystem, "maps/e1m1.bsp") then validateMap(filesystem, "e1m1", palette) end if
  print "Validation passed. Run --gl-smoke next, then -basedir \"" + baseDirectory + "\" +map " + mapName
  return 0
end function
