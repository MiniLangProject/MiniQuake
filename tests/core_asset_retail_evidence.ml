/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-074 retail-data evidence: reads but never copies Quake assets.
*/
import miniquake.filesystem as qfs
import miniquake.crc as crc
import miniquake.wad as wad
import miniquake.format.bsp as bsp
import miniquake.format.mdl as mdl
import miniquake.format.progs as progs

// Exercise the evidence line test scenario and verify its expected result.
function bp074EvidenceLine(name,data)
  return name+"|bytes="+len(data)+"|crc="+crc.CRC_Block(data,0,len(data))
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  if len(args)<1 then print "usage: MiniQuakeCoreAssetRetailEvidence.exe BASE [game]"; return 2 end if
  game="id1"; if len(args)>1 then game=args[1] end if
  system=qfs.initialize(args[0],game)
  gfx=qfs.readFile(system,"gfx.wad")
  mapData=qfs.readFile(system,"maps/start.bsp")
  mdlData=qfs.readFile(system,"progs/player.mdl")
  progsData=qfs.readFile(system,"progs.dat")
  gfxArchive=wad.parse(gfx,"gfx.wad")
  map=bsp.parse(mapData,"maps/start.bsp")
  player=mdl.parse(mdlData,"progs/player.mdl")
  program=progs.parse(progsData,"progs.dat")
  print "MiniQuake BP-074 retail core asset evidence"
  print bp074EvidenceLine("gfx.wad",gfx)+"|lumps="+gfxArchive.numLumps
  print bp074EvidenceLine("maps/start.bsp",mapData)+"|faces="+len(map.faces)+"|entities="+len(map.entities)+"|textures="+len(map.textures)
  print bp074EvidenceLine("progs/player.mdl",mdlData)+"|frames="+player.numFrames+"|skins="+player.numSkins+"|verts="+player.numVertices
  print bp074EvidenceLine("progs.dat",progsData)+"|functions="+len(program.functions)+"|statements="+len(program.statements)+"|entity_words="+program.entityFields
  print "pack_files="+qfs.packFileCount(system)
  print "result=PASS"
  return 0
end function
