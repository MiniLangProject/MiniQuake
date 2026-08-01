/* BP-072 WAD2, qpic and graphics-data compatibility fixtures. */
import miniquake.wad as wad
import miniquake.graphics_data as graphics
import miniquake.filesystem as qfs
import miniquake.byteio as bio
import miniquake.protocol_text as quakeText
import std.fs as fs

function bp072Equal(actual, expected, name)
  if actual != expected then return error(10720, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
function bp072True(value, name)
  if value != true then return error(10721, name + ": expected true") end if
  return true
end function
function bp072Bytes(actual, expected, name)
  bp072Equal(len(actual),len(expected),name+" length")
  index=0
  while index<len(expected)
    bp072Equal(actual[index],expected[index],name+" byte "+index); index=index+1
  end while
  return true
end function
function bp072PutName(data,offset,name)
  source=name
  if name is not bytes then source=quakeText.encodeBytes(name) end if
  count=len(source); if count>16 then count=16 end if
  copyBytes(data,offset,source,0,count)
end function
function bp072MakeWad(compressed)
  // qpic at 12 (12 bytes), conchars/raw at 24 (16 bytes), directory at 40.
  data=bytes(104)
  copyBytes(data,0,bytes("WAD2"),0,4); bio.putI32(data,4,2); bio.putI32(data,8,40)
  bio.putI32(data,12,64); bio.putI32(data,16,32); data[20]=1; data[21]=2; data[22]=3; data[23]=4
  index=0
  while index<16
    data[24+index]=index; index=index+1
  end while
  bio.putI32(data,40,12); bio.putI32(data,44,12); bio.putI32(data,48,12); data[52]=wad.TYP_QPIC; data[53]=wad.CMP_NONE
  bp072PutName(data,56,bytes([77,73,88,0xc9,68]))
  bio.putI32(data,72,24); bio.putI32(data,76,16); bio.putI32(data,80,16); data[84]=wad.TYP_LUMPY
  if compressed then data[85]=wad.CMP_LZSS else data[85]=wad.CMP_NONE end if
  bp072PutName(data,88,"CONCHARS")
  return data
end function
function bp072Root()
  return "build\\bp072-wad"
end function
function bp072SystemWithFiles(wadData, fallback)
  root=bp072Root(); gfxWad=qfs.join(root,"id1\\gfx.wad"); qfs.COM_CreatePath(gfxWad)
  if wadData is not void then
    fs.writeAllBytes(gfxWad,wadData)
  else if fs.exists(gfxWad) then
    fs.delete(gfxWad)
  end if
  if fallback is not void then
    path=qfs.join(root,"id1\\gfx\\conchars.lmp"); qfs.COM_CreatePath(path); fs.writeAllBytes(path,fallback)
  end if
  system=qfs.create(root,"id1"); qfs.addDirectory(system,qfs.join(root,"id1")); system.staticRegistered=true
  return system
end function
function bp072Run(index,name,callback)
  print "["+index+"/20] "+name
  result=try(callback()); if result is error then print "FAIL: "+result.message; return false end if
  return true
end function
function bp072Case01()
  clean=wad.W_CleanupName("ABCdef"); bp072Bytes(slice(clean,0,6),bytes("abcdef"),"cleanup lower"); return true
end function
function bp072Case02()
  exact=wad.W_CleanupName("ABCDEFGHIJKLMNOP"); trunc=wad.W_CleanupName("ABCDEFGHIJKLMNOP-extra"); bp072Bytes(exact,trunc,"cleanup truncation"); return true
end function
function bp072Case03()
  clean=wad.W_CleanupName(bytes([65,66,0,90])); bp072Equal(clean[0],97,"embedded first"); bp072Equal(clean[2],0,"embedded stop"); bp072Equal(clean[3],0,"embedded pad"); return true
end function
function bp072Case04()
  clean=wad.W_CleanupName("MIXÉD"); bp072Bytes(slice(clean,0,5),bytes([109,105,120,0xc9,100]),"extended byte"); return true
end function
function bp072Case05()
  archive=wad.W_LoadWadData(bp072MakeWad(false),"synthetic.wad"); bp072Equal(archive.numLumps,2,"WAD count"); return true
end function
function bp072Case06()
  archive=wad.W_LoadWadData(bp072MakeWad(false),"synthetic.wad"); bp072Equal(archive.lumps[1].name,"conchars","directory lowercase"); return true
end function
function bp072Case07()
  archive=wad.W_LoadWadData(bp072MakeWad(false),"synthetic.wad")
  info=wad.W_GetLumpinfo(archive,"mixÉd"); bp072Bytes(quakeText.encodeBytes(info.name),bytes([109,105,120,0xc9,100]),"extended lookup"); return true
end function
function bp072Case08()
  archive=wad.W_LoadWadData(bp072MakeWad(false),"synthetic.wad"); dims=wad.pictureDimensions(archive,"MIXÉD"); bp072Equal(dims[0],64,"qpic width"); bp072Equal(dims[1],32,"qpic height"); return true
end function
function bp072Case09()
  archive=wad.W_LoadWadData(bp072MakeWad(false),"synthetic.wad"); data=wad.W_GetLumpNum(archive,1); bp072Equal(len(data),16,"lump number"); return true
end function
function bp072Case10()
  archive=wad.W_LoadWadData(bp072MakeWad(true),"compressed.wad"); bp072Equal(len(wad.W_GetLumpName(archive,"conchars")),16,"compressed pointer lookup"); return true
end function
function bp072Case11()
  archive=wad.W_LoadWadData(bp072MakeWad(true),"compressed.wad"); bp072True(try(wad.readLump(archive,"conchars")) is error,"compressed read rejection"); return true
end function
function bp072Case12()
  archive=wad.W_LoadWadData(bp072MakeWad(false),"synthetic.wad"); bp072True(try(wad.W_GetLumpinfo(archive,"missing")) is error,"missing lump"); return true
end function
function bp072Case13()
  data=bp072MakeWad(false); data[0]=88; bp072True(try(wad.parse(data,"bad.wad")) is error,"bad magic"); return true
end function
function bp072Case14()
  data=bp072MakeWad(false); bio.putI32(data,8,100); bp072True(try(wad.parse(data,"bad-dir.wad")) is error,"bad directory"); return true
end function
function bp072Case15()
  data=bp072MakeWad(false); bio.putI32(data,40,100); bp072True(try(wad.parse(data,"bad-lump.wad")) is error,"bad lump"); return true
end function
function bp072Case16()
  data=bp072MakeWad(false); bio.putI32(data,44,4); bio.putI32(data,48,4); bp072True(try(wad.parse(data,"short-qpic.wad")) is error,"short qpic"); return true
end function
function bp072Case17()
  system=bp072SystemWithFiles(bp072MakeWad(false),void); data=graphics.readConsoleCharacters(system); bp072Equal(len(data),16,"conchars from WAD"); bp072Equal(data[15],15,"conchars last byte"); return true
end function
function bp072Case18()
  system=bp072SystemWithFiles(void,bytes([9,8,7])); data=graphics.readConsoleCharacters(system); bp072Bytes(data,bytes([9,8,7]),"conchars fallback"); return true
end function
function bp072Case19()
  path=qfs.join(bp072Root(),"file.wad"); qfs.COM_CreatePath(path); fs.writeAllBytes(path,bp072MakeWad(false)); archive=wad.W_LoadWadFile(path); bp072Equal(archive.numLumps,2,"W_LoadWadFile"); return true
end function
function bp072Case20()
  archive=wad.W_LoadWadData(bp072MakeWad(false),"synthetic.wad"); bp072Equal(wad.find(archive,"unknown"),void,"find missing"); bp072True(try(wad.W_GetLumpNum(archive,2)) is error,"one-past rejection"); return true
end function
function main(args)
  callbacks=[bp072Case01,bp072Case02,bp072Case03,bp072Case04,bp072Case05,bp072Case06,bp072Case07,bp072Case08,bp072Case09,bp072Case10,bp072Case11,bp072Case12,bp072Case13,bp072Case14,bp072Case15,bp072Case16,bp072Case17,bp072Case18,bp072Case19,bp072Case20]
  names=["cleanup lowercase","cleanup truncation","cleanup embedded NUL","cleanup extended byte","WAD parse count","directory normalization","extended lookup","qpic dimensions","lump number","compressed pointer","compressed read policy","missing lookup","WAD magic","WAD directory bounds","WAD lump bounds","qpic bounds","conchars from gfx.wad","conchars fallback","W_LoadWadFile","safe lump bounds"]
  index=0
  while index<len(callbacks)
    if not bp072Run(index+1,names[index],callbacks[index]) then return 1 end if
    index=index+1
  end while
  print "MiniQuake BP-072 WAD/graphics tests passed: 20"
  return 0
end function
