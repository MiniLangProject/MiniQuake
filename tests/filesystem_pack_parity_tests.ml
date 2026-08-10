/* BP-071 common.c PACK/search-path/file-lifecycle compatibility fixtures. */
import miniquake.types as t
import miniquake.filesystem as qfs
import miniquake.pak as pak
import miniquake.byteio as bio
import miniquake.crc as crc
import miniquake.protocol_text as quakeText
import std.fs as fs

function bp071Equal(actual, expected, name)
  if actual != expected then return error(10710, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
function bp071True(value, name)
  if value != true then return error(10711, name + ": expected true") end if
  return true
end function
function bp071BytesEqual(actual, expected, name)
  bp071Equal(len(actual), len(expected), name + " length")
  index=0
  while index < len(expected)
    bp071Equal(actual[index], expected[index], name + " byte " + index)
    index=index+1
  end while
  return true
end function
function bp071Run(index,name,callback)
  print "[" + index + "/24] " + name
  result=try(callback())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function
function inline bp071Root()
  return "build\\bp071_fs"
end function
function bp071Game()
  return qfs.join(bp071Root(), "id1")
end function
function bp071Write(path,data)
  qfs.COM_CreatePath(path)
  result=fs.writeAllBytes(path,data)
  if result is error then return result end if
  return true
end function
function bp071Pack(name,payload)
  directoryOffset=12+len(payload)
  data=bytes(directoryOffset+64)
  data[0]=80; data[1]=65; data[2]=67; data[3]=75
  bio.putI32(data,4,directoryOffset); bio.putI32(data,8,64)
  if len(payload)>0 then bio.copyInto(data,12,payload,0,len(payload)) end if
  nameBytes=bytes(name); count=len(nameBytes); if count>56 then count=56 end if
  if count>0 then bio.copyInto(data,directoryOffset,nameBytes,0,count) end if
  bio.putI32(data,directoryOffset+56,12); bio.putI32(data,directoryOffset+60,len(payload))
  return data
end function
function bp071Prepare()
  pak0=qfs.join(bp071Game(),"pak0.pak")
  pak1=qfs.join(bp071Game(),"pak1.pak")
  loose=qfs.join(bp071Game(),"same.bin")
  bp071Write(loose,bytes([1]))
  bp071Write(pak0,bp071Pack("same.bin",bytes([2])))
  bp071Write(pak1,bp071Pack("same.bin",bytes([3])))
  bp071Write(qfs.join(bp071Game(),"sub\\loose.bin"),bytes([4,5]))
  return true
end function
function bp071Case01()
  archive=pak.parse(bp071Pack("inside.bin",bytes([9,8,7])),"synthetic.pak")
  bp071Equal(archive.numFiles,1,"PACK count"); return true
end function
function bp071Case02()
  archive=pak.parse(bp071Pack("Inside.bin",bytes([1])),"synthetic.pak")
  bp071True(pak.find(archive,"Inside.bin") is not void,"PACK exact name")
  bp071True(pak.find(archive,"inside.bin") is void,"PACK case-sensitive"); return true
end function
function bp071Case03()
  data=bp071Pack("x",bytes([1])); data[0]=88
  bp071True(try(pak.parse(data,"bad.pak")) is error,"PACK magic"); return true
end function
function bp071Case04()
  data=bp071Pack("x",bytes([1])); bio.putI32(data,8,63)
  bp071True(try(pak.parse(data,"bad.pak")) is error,"PACK directory multiple"); return true
end function
function bp071Case05()
  archive=pak.parse(bp071Pack("inside.bin",bytes([9,8,7])),"synthetic.pak")
  bp071BytesEqual(pak.readFile(archive,"inside.bin"),bytes([9,8,7]),"PACK read"); return true
end function
function bp071Case06()
  data=bp071Pack("inside.bin",bytes([9,8,7])); archive=pak.parse(data,"synthetic.pak")
  range=pak.directoryRange(archive)
  bp071Equal(pak.directoryCrc(archive),crc.CRC_Block(data,range[0],range[1]),"PACK directory CRC"); return true
end function
function bp071Case07()
  bp071Prepare(); system=qfs.create(bp071Root(),"id1"); qfs.addGameDirectory(system,bp071Game())
  bp071Equal(len(system.searchPaths),3,"search path count"); return true
end function
function bp071Case08()
  bp071Prepare(); system=qfs.create(bp071Root(),"id1"); qfs.addGameDirectory(system,bp071Game())
  bp071BytesEqual(qfs.readFile(system,"same.bin"),bytes([3]),"pak1 precedence"); return true
end function
function bp071Case09()
  system=qfs.create(bp071Root(),"id1"); qfs.addDirectory(system,bp071Game()); system.staticRegistered=true
  bp071BytesEqual(qfs.readFile(system,"same.bin"),bytes([1]),"loose directory"); return true
end function
function bp071Case10()
  bp071Prepare(); system=qfs.create(bp071Root(),"id1"); qfs.addDirectory(system,bp071Game())
  // qfs.create mirrors common.c's startup static_registered=1.  This fixture
  // targets the post-COM_CheckRegistered shareware state, so make that state
  // explicit before exercising the loose-subdirectory restriction.
  system.staticRegistered = false
  bp071True(try(qfs.readFile(system,"sub/loose.bin")) is error,"shareware loose subdirectory"); return true
end function
function bp071Case11()
  system=qfs.create(bp071Root(),"id1"); qfs.addDirectory(system,bp071Game()); system.staticRegistered=true
  bp071BytesEqual(qfs.readFile(system,"sub/loose.bin"),bytes([4,5]),"registered loose subdirectory"); return true
end function
function bp071Case12()
  system=qfs.create(bp071Root(),"id1")
  archive=pak.parse(bp071Pack("sub/inside.bin",bytes([6])),"synthetic.pak")
  system.searchPaths=[t.SearchPath("",archive)]
  bp071BytesEqual(qfs.readFile(system,"sub/inside.bin"),bytes([6]),"shareware packed subdirectory"); return true
end function
function bp071Case13()
  low=qfs.join(bp071Root(),"low"); high=qfs.join(bp071Root(),"high")
  bp071Write(qfs.join(low,"progs.dat"),bytes([1])); bp071Write(qfs.join(high,"progs.dat"),bytes([2]))
  system=qfs.create(bp071Root(),"id1"); qfs.addDirectory(system,low); qfs.addDirectory(system,high); system.staticRegistered=true; system.progsHack=true
  bp071BytesEqual(qfs.readFile(system,"progs.dat"),bytes([1]),"proghack skips first path"); return true
end function
function bp071Case14()
  archive=pak.parse(bp071Pack("inside.bin",bytes([9,8,7])),"synthetic.pak")
  system=qfs.create(bp071Root(),"id1"); system.searchPaths=[t.SearchPath("",archive)]
  opened=qfs.openFile(system,"inside.bin"); bp071True(opened[1].persistent,"PACK persistent handle")
  qfs.closeFile(opened[1]); bp071True(not opened[1].closed,"PACK close keeps handle"); return true
end function
function bp071Case15()
  system=qfs.create(bp071Root(),"id1"); qfs.addDirectory(system,bp071Game()); system.staticRegistered=true
  opened=qfs.fOpenFile(system,"same.bin"); qfs.closeFile(opened[1]); bp071True(opened[1].closed,"FILE close"); return true
end function
function bp071Case16()
  archive=pak.parse(bp071Pack("inside.bin",bytes([9,8,7])),"synthetic.pak")
  system=qfs.create(bp071Root(),"id1"); system.searchPaths=[t.SearchPath("",archive)]
  handle=qfs.openFile(system,"inside.bin")[1]; qfs.handleSeek(handle,1)
  bp071BytesEqual(qfs.handleRead(handle,8),bytes([8,7]),"seek/read clamp"); return true
end function
function bp071Case17()
  archive=pak.parse(bp071Pack("inside.bin",bytes([9,8,7])),"synthetic.pak")
  system=qfs.create(bp071Root(),"id1"); system.searchPaths=[t.SearchPath("",archive)]
  loaded=qfs.loadFile(system,"inside.bin"); bp071Equal(len(loaded),4,"load NUL length"); bp071Equal(loaded[3],0,"load NUL"); return true
end function
function bp071Case18()
  archive=pak.parse(bp071Pack("inside.bin",bytes([9,8,7])),"synthetic.pak")
  system=qfs.create(bp071Root(),"id1"); system.searchPaths=[t.SearchPath("",archive)]
  buffer=bytes(16,0xcc); loaded=qfs.loadStackFile(system,"inside.bin",buffer)
  bp071Equal(len(loaded),16,"stack buffer reuse"); bp071Equal(loaded[3],0,"stack terminator"); return true
end function
function bp071Case19()
  archive=pak.parse(bp071Pack("inside.bin",bytes([9,8,7])),"synthetic.pak")
  system=qfs.create(bp071Root(),"id1"); system.searchPaths=[t.SearchPath("",archive)]
  loaded=qfs.loadStackFile(system,"inside.bin",bytes(2)); bp071Equal(len(loaded),4,"stack fallback"); return true
end function
function bp071Case20()
  system=qfs.create(bp071Root(),"id1")
  text=quakeText.decodeBytes(bytes([99,97,102,0xe9])); qfs.writeText(system,"latin.txt",text)
  bp071BytesEqual(fs.readAllBytes(qfs.gamePath(system,"latin.txt")),bytes([99,97,102,0xe9]),"writeText Quake bytes"); return true
end function
function bp071Case21()
  system=qfs.create(bp071Root(),"id1"); qfs.addDirectory(system,bp071Game()); system.staticRegistered=true
  bp071Equal(qfs.readText(system,"latin.txt"),quakeText.decodeBytes(bytes([99,97,102,0xe9])),"readText Quake bytes"); return true
end function
function bp071Case22()
  bp071Prepare(); system=qfs.create(bp071Root(),"id1"); qfs.addGameDirectory(system,bp071Game())
  bp071Equal(len(qfs.searchPathSummary(system)),3,"path summary"); return true
end function
function bp071Case23()
  bp071Prepare(); system=qfs.create(bp071Root(),"id1"); qfs.addGameDirectory(system,bp071Game())
  bp071True(qfs.isModified(system),"non-retail PACK marks modified"); return true
end function
function bp071Case24()
  bp071Prepare(); system=qfs.create(bp071Root(),"id1"); qfs.addGameDirectory(system,bp071Game()); qfs.release(system)
  bp071Equal(len(system.searchPaths),0,"release paths"); return true
end function
function main(args)
  bp071Prepare()
  callbacks=[bp071Case01,bp071Case02,bp071Case03,bp071Case04,bp071Case05,bp071Case06,bp071Case07,bp071Case08,bp071Case09,bp071Case10,bp071Case11,bp071Case12,bp071Case13,bp071Case14,bp071Case15,bp071Case16,bp071Case17,bp071Case18,bp071Case19,bp071Case20,bp071Case21,bp071Case22,bp071Case23,bp071Case24]
  names=["PACK parse","PACK case sensitivity","PACK magic","PACK directory bounds","PACK read","PACK directory CRC","search path order","pak1 precedence","loose file","shareware loose restriction","registered loose path","shareware packed path","proghack","persistent PACK handle","FILE close","seek/read","load NUL","stack reuse","stack fallback","write Quake text","read Quake text","search summary","modified flag","release"]
  index=0
  while index<len(callbacks)
    if not bp071Run(index+1,names[index],callbacks[index]) then return 1 end if
    index=index+1
  end while
  print "MiniQuake BP-071 filesystem/PACK tests passed: 24"
  return 0
end function
