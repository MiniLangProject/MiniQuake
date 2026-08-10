/* BP-071 filesystem and PACK compatibility fixtures. */
import miniquake.filesystem as qfs
import miniquake.pak as pak
import miniquake.byteio as bio
import miniquake.protocol_text as quakeText
import miniquake.types as t
import std.fs as fs

function bp071Equal(actual, expected, name)
  if actual != expected then return error(10710, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
function bp071True(value, name)
  if value != true then return error(10711, name + ": expected true") end if
  return true
end function
function bp071Bytes(actual, expected, name)
  bp071Equal(len(actual), len(expected), name + " length")
  index=0
  while index < len(expected)
    bp071Equal(actual[index], expected[index], name + " byte " + index); index=index+1
  end while
  return true
end function
function bp071PutName(data, offset, nameBytes)
  count=len(nameBytes); if count>56 then count=56 end if
  copyBytes(data, offset, nameBytes, 0, count)
end function
function bp071MakePak(firstName, firstData, secondName, secondData)
  payloadOffset=12
  secondOffset=payloadOffset+len(firstData)
  directoryOffset=secondOffset+len(secondData)
  data=bytes(directoryOffset+128)
  copyBytes(data,0,bytes("PACK"),0,4)
  bio.putI32(data,4,directoryOffset); bio.putI32(data,8,128)
  copyBytes(data,payloadOffset,firstData,0,len(firstData))
  copyBytes(data,secondOffset,secondData,0,len(secondData))
  bp071PutName(data,directoryOffset,firstName)
  bio.putI32(data,directoryOffset+56,payloadOffset); bio.putI32(data,directoryOffset+60,len(firstData))
  bp071PutName(data,directoryOffset+64,secondName)
  bio.putI32(data,directoryOffset+120,secondOffset); bio.putI32(data,directoryOffset+124,len(secondData))
  return data
end function
function inline bp071FixtureRoot()
  return "build\\bp071-filesystem"
end function
function bp071PrepareLoose()
  path=qfs.join(bp071FixtureRoot(),"id1\\loose.bin")
  qfs.COM_CreatePath(path); fs.writeAllBytes(path,bytes([9,8,7])); return path
end function
function bp071Archives()
  nameExtended=bytes([109,111,100,115,47,99,97,102,0xe9,46,100,97,116])
  first=pak.parse(bp071MakePak(bytes("same.dat"),bytes([1]),nameExtended,bytes([2,3])),"pak0.pak")
  second=pak.parse(bp071MakePak(bytes("same.dat"),bytes([4]),bytes("progs.dat"),bytes([5,6])),"pak1.pak")
  return [first,second]
end function
function bp071Run(index,name,callback)
  print "["+index+"/24] "+name
  result=try(callback()); if result is error then print "FAIL: "+result.message; return false end if
  return true
end function
function bp071Case01()
  a=bp071Archives()[0]; bp071Equal(a.numFiles,2,"PACK count"); return true
end function
function bp071Case02()
  a=bp071Archives()[0]; bp071Equal(a.files[0].name,"same.dat","first name"); return true
end function
function bp071Case03()
  a=bp071Archives()[0]; bp071Bytes(quakeText.encodeBytes(a.files[1].name),bytes([109,111,100,115,47,99,97,102,0xe9,46,100,97,116]),"extended name"); return true
end function
function bp071Case04()
  a=bp071Archives()[0]; bp071True(pak.find(a,"same.dat") is not void,"case exact"); return true
end function
function bp071Case05()
  a=bp071Archives()[0]; bp071Equal(pak.find(a,"SAME.DAT"),void,"case sensitive lookup"); return true
end function
function bp071Case06()
  a=bp071Archives()[0]; bp071Bytes(pak.readFile(a,"same.dat"),bytes([1]),"payload"); return true
end function
function bp071Case07()
  a=bp071Archives()[0]; r=pak.directoryRange(a); bp071Equal(r[1],128,"directory length"); return true
end function
function bp071Case08()
  a=bp071Archives()[0]; bp071Equal(pak.directoryCrc(a),pak.directoryCrc(a),"directory CRC stable"); return true
end function
function bp071Case09()
  data=bp071MakePak(bytes("a"),bytes([1]),bytes("b"),bytes([2])); data[0]=88
  bp071True(try(pak.parse(data,"bad.pak")) is error,"bad magic"); return true
end function
function bp071Case10()
  data=bp071MakePak(bytes("a"),bytes([1]),bytes("b"),bytes([2])); bio.putI32(data,8,65)
  bp071True(try(pak.parse(data,"bad-dir.pak")) is error,"bad directory length"); return true
end function
function bp071Case11()
  data=bp071MakePak(bytes("a"),bytes([1]),bytes("b"),bytes([2])); directory=bio.i32(data,4); bio.putI32(data,directory+56,len(data)+1)
  bp071True(try(pak.parse(data,"bad-entry.pak")) is error,"bad entry"); return true
end function
function bp071Case12()
  data=bytes(12+2049*64); copyBytes(data,0,bytes("PACK"),0,4); bio.putI32(data,4,12); bio.putI32(data,8,2049*64)
  bp071True(try(pak.parse(data,"too-many.pak")) is error,"MAX_FILES_IN_PACK"); return true
end function
function bp071Case13()
  archives=bp071Archives(); system=qfs.create(bp071FixtureRoot(),"id1")
  system.searchPaths=[t.SearchPath("",archives[1]),t.SearchPath("",archives[0])]
  bp071Bytes(qfs.readFile(system,"same.dat"),bytes([4]),"higher pak wins"); return true
end function
function bp071Case14()
  loose=bp071PrepareLoose(); archives=bp071Archives(); system=qfs.create(bp071FixtureRoot(),"id1")
  system.staticRegistered=true; system.searchPaths=[t.SearchPath("",archives[0]),t.SearchPath(qfs.join(bp071FixtureRoot(),"id1"),void)]
  bp071Bytes(qfs.readFile(system,"same.dat"),bytes([1]),"pak overrides loose"); return true
end function
function bp071Case15()
  loose=bp071PrepareLoose(); system=qfs.create(bp071FixtureRoot(),"id1"); system.staticRegistered=true; qfs.addDirectory(system,qfs.join(bp071FixtureRoot(),"id1"))
  bp071Bytes(qfs.readFile(system,"loose.bin"),bytes([9,8,7]),"loose fallback"); return true
end function
function bp071Case16()
  system=qfs.create(bp071FixtureRoot(),"id1"); qfs.addDirectory(system,qfs.join(bp071FixtureRoot(),"id1")); system.staticRegistered=false
  bp071True(try(qfs.readFile(system,"dir/file.dat")) is error,"shareware subdirectory block"); return true
end function
function bp071Case17()
  path=qfs.join(bp071FixtureRoot(),"id1\\dir\\file.dat"); qfs.COM_CreatePath(path); fs.writeAllBytes(path,bytes([7]))
  system=qfs.create(bp071FixtureRoot(),"id1"); qfs.addDirectory(system,qfs.join(bp071FixtureRoot(),"id1")); system.staticRegistered=true
  bp071Bytes(qfs.readFile(system,"dir/file.dat"),bytes([7]),"registered subdirectory"); return true
end function
function bp071Case18()
  archives=bp071Archives(); system=qfs.create(bp071FixtureRoot(),"id1"); system.progsHack=true
  system.searchPaths=[t.SearchPath("",archives[1]),t.SearchPath("",archives[0])]
  bp071True(try(qfs.readFile(system,"progs.dat")) is error,"proghack skips first path"); return true
end function
function bp071Case19()
  archives=bp071Archives(); system=qfs.create(bp071FixtureRoot(),"id1"); system.searchPaths=[t.SearchPath("",archives[0])]
  data=qfs.loadFile(system,"same.dat"); bp071Bytes(data,bytes([1,0]),"COM_LoadFile NUL"); return true
end function
function bp071Case20()
  archives=bp071Archives(); system=qfs.create(bp071FixtureRoot(),"id1"); system.searchPaths=[t.SearchPath("",archives[0])]
  buffer=bytes(8,0xaa); data=qfs.loadStackFile(system,"same.dat",buffer)
  bp071True(data==buffer,"stack buffer reused"); bp071Equal(data[1],0,"stack NUL"); return true
end function
function bp071Case21()
  archives=bp071Archives(); system=qfs.create(bp071FixtureRoot(),"id1"); system.searchPaths=[t.SearchPath("",archives[0])]
  data=qfs.loadStackFile(system,"same.dat",bytes())
  bp071Equal(len(data),2,"stack fallback size"); return true
end function
function bp071Case22()
  root=bp071FixtureRoot(); path=qfs.join(root,"id1\\text.cfg"); qfs.COM_CreatePath(path)
  system=qfs.create(root,"id1"); qfs.writeText(system,"text.cfg","café")
  qfs.addDirectory(system,qfs.join(root,"id1")); system.staticRegistered=true
  bp071Bytes(quakeText.encodeBytes(qfs.readText(system,"text.cfg")),bytes([99,97,102,0xe9]),"Quake text roundtrip"); return true
end function
function bp071Case23()
  archives=bp071Archives(); system=qfs.create(bp071FixtureRoot(),"id1"); system.searchPaths=[t.SearchPath("",archives[0])]
  opened=qfs.openFile(system,"same.dat"); handle=opened[1]; qfs.closeFile(handle)
  bp071Equal(handle.closed,false,"PACK handle remains open"); return true
end function
function bp071Case24()
  data=bp071MakePak(bytes("a"),bytes([1]),bytes("b"),bytes([2])); path=qfs.join(bp071FixtureRoot(),"synthetic.pak")
  qfs.COM_CreatePath(path); fs.writeAllBytes(path,data); system=qfs.create(bp071FixtureRoot(),"id1"); qfs.addPack(system,path)
  bp071Equal(system.modified,true,"nonstock pak marks modified"); return true
end function
function main(args)
  callbacks=[bp071Case01,bp071Case02,bp071Case03,bp071Case04,bp071Case05,bp071Case06,bp071Case07,bp071Case08,bp071Case09,bp071Case10,bp071Case11,bp071Case12,bp071Case13,bp071Case14,bp071Case15,bp071Case16,bp071Case17,bp071Case18,bp071Case19,bp071Case20,bp071Case21,bp071Case22,bp071Case23,bp071Case24]
  names=["PACK count","PACK first name","PACK extended name","PACK exact lookup","PACK case sensitivity","PACK payload","PACK directory range","PACK directory CRC","PACK magic","PACK directory validation","PACK entry validation","PACK file limit","search path precedence","PAK overrides directory","loose file fallback","shareware path restriction","registered subdirectory","proghack skip","COM_LoadFile termination","COM_LoadStackFile buffer","COM_LoadStackFile fallback","Quake byte text I/O","persistent PACK handle","modified detection"]
  index=0
  while index<len(callbacks)
    if not bp071Run(index+1,names[index],callbacks[index]) then return 1 end if
    index=index+1
  end while
  print "MiniQuake BP-071 filesystem/PAK tests passed: 24"
  return 0
end function
