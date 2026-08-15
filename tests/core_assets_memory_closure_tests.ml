/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-074 zone/hunk/cache and frozen core asset/memory contract fixtures.
*/
import miniquake.zone as zone
import miniquake.memory as memory
import miniquake.protocol_text as quakeText
import miniquake.core_assets_memory_contract as contract

struct BP074CommandLine
  args
end struct

// Assert exact equality and report both values on failure.
function bp074Equal(actual, expected, name)
  if actual != expected then return error(10750, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Exercise the true test scenario and verify its expected result.
function bp074True(value, name)
  if value != true then return error(10751, name + ": expected true") end if
  return true
end function
// Exercise the case01 test scenario and verify its expected result.
function bp074Case01()
  bp074Equal(zone.align8(1),8,"zone align")
  bp074Equal(memory.align16(17),32,"hunk align")
  return true
end function
// Exercise the case02 test scenario and verify its expected result.
function bp074Case02()
  state=zone.create(512)
  bp074Equal(zone.Z_FreeMemory(state),480,"zone initial free")
  bp074Equal(zone.Z_CheckHeap(state),true,"zone check")
  return true
end function
// Exercise the case03 test scenario and verify its expected result.
function bp074Case03()
  state=zone.create(512)
  bp074True(try(zone.Z_TagMalloc(state,8,0)) is error,"tag zero")
  return true
end function
// Exercise the case04 test scenario and verify its expected result.
function bp074Case04()
  state=zone.create(512); first=zone.Z_TagMalloc(state,40,7); second=zone.Z_Malloc(state,32)
  bp074Equal(first.tag,7,"tag")
  bp074Equal(second.tag,1,"malloc tag")
  bp074Equal(first.start % 8,0,"zone alignment")
  return true
end function
// Exercise the case05 test scenario and verify its expected result.
function bp074Case05()
  state=zone.create(512); initial=zone.Z_FreeMemory(state); first=zone.Z_Malloc(state,32); second=zone.Z_Malloc(state,32)
  zone.Z_Free(first); zone.Z_Free(second)
  bp074Equal(len(state.blocks),1,"zone coalesce")
  bp074Equal(zone.Z_FreeMemory(state),initial,"zone free restored")
  return true
end function
// Exercise the case06 test scenario and verify its expected result.
function bp074Case06()
  state=zone.create(512); block=zone.Z_Malloc(state,16); zone.Z_Free(block)
  bp074True(try(zone.Z_Free(block)) is error,"double free")
  bp074True(try(zone.Z_Free(void)) is error,"null free")
  return true
end function
// Exercise the case07 test scenario and verify its expected result.
function bp074Case07()
  state=zone.create(512); block=zone.Z_Malloc(state,16); block.trashId=0
  bp074True(try(zone.Z_CheckHeap(state)) is error,"trash marker")
  return true
end function
// Exercise the case08 test scenario and verify its expected result.
function bp074Case08()
  state=memory.create(1024); block=memory.Hunk_AllocName(state,1,"123456789")
  bp074Equal(block.name,"12345678","hunk name")
  bp074Equal(memory.Hunk_LowMark(state),32,"hunk span")
  return true
end function
// Exercise the case09 test scenario and verify its expected result.
function bp074Case09()
  name=quakeText.decodeBytes(bytes([65,66,67,68,69,70,71,0xe9,90]))
  block=memory.Hunk_AllocName(memory.create(1024),1,name)
  bp074Equal(quakeText.encodeBytes(block.name)[7],0xe9,"hunk Quake byte")
  bp074Equal(len(quakeText.encodeBytes(block.name)),8,"hunk byte truncation")
  return true
end function
// Exercise the case10 test scenario and verify its expected result.
function bp074Case10()
  state=memory.create(1024); high=memory.Hunk_HighAllocName(state,1,"video"); base=memory.Hunk_HighMark(state)
  temp=memory.Hunk_TempAlloc(state,17)
  bp074Equal(state.highUsed,base+48,"temp span")
  memory.Hunk_HighMark(state)
  bp074True(not temp.alive,"temp freed")
  bp074True(high.alive,"high retained")
  return true
end function
// Exercise the case11 test scenario and verify its expected result.
function bp074Case11()
  state=memory.create(128); mark=memory.Hunk_LowMark(state); block=memory.Hunk_Alloc(state,16)
  memory.Hunk_FreeToLowMark(state,mark)
  bp074True(not block.alive,"low mark free")
  bp074True(try(memory.Hunk_FreeToLowMark(state,1)) is error,"bad low mark")
  return true
end function
// Exercise the case12 test scenario and verify its expected result.
function bp074Case12()
  state=memory.create(256); memory.Hunk_AllocName(state,16,"check")
  bp074Equal(memory.Hunk_Check(state),true,"hunk check")
  bp074True(len(bytes(memory.Hunk_Print(state,true)))>20,"hunk print")
  return true
end function
// Exercise the case13 test scenario and verify its expected result.
function bp074Case13()
  state=memory.create(512); first=memory.cacheAlloc(state,64,"first"); second=memory.cacheAlloc(state,64,"second")
  bp074Equal(first.block.start,0,"cache first")
  bp074Equal(second.block.start,112,"cache second")
  return true
end function
// Exercise the case14 test scenario and verify its expected result.
function bp074Case14()
  state=memory.create(512); first=memory.cacheAlloc(state,64,"first"); second=memory.cacheAlloc(state,64,"second"); third=memory.cacheAlloc(state,64,"third")
  memory.Cache_Check(state,first); large=memory.cacheAlloc(state,200,"large")
  bp074True(first.block is not void,"MRU retained")
  bp074Equal(second.block,void,"LRU purged")
  bp074Equal(third.block,void,"second purge")
  bp074Equal(large.block.start,112,"gap reused")
  return true
end function
// Exercise the case15 test scenario and verify its expected result.
function bp074Case15()
  state=memory.create(512); memory.cacheAlloc(state,64,"first"); memory.cacheAlloc(state,64,"second")
  tried=memory.Cache_TryAlloc(state,32,false)
  bp074Equal(tried.start,224,"Cache_TryAlloc")
  return true
end function
// Exercise the case16 test scenario and verify its expected result.
function bp074Case16()
  state=memory.create(512); first=memory.cacheAlloc(state,64,"move"); start=first.block.start
  memory.Cache_Move(first.block)
  bp074True(first.block.start>start,"Cache_Move")
  return true
end function
// Exercise the case17 test scenario and verify its expected result.
function bp074Case17()
  state=memory.create(512); first=memory.cacheAlloc(state,64,"first"); second=memory.cacheAlloc(state,64,"second")
  memory.Hunk_AllocName(state,32,"low")
  bp074True(first.block.start>=state.lowUsed,"low collision moved")
  bp074True(second.block is not void,"other cache retained")
  return true
end function
// Exercise the case18 test scenario and verify its expected result.
function bp074Case18()
  state=memory.create(512); first=memory.cacheAlloc(state,64,"first"); second=memory.cacheAlloc(state,64,"second")
  high=memory.Hunk_HighAllocName(state,160,"high")
  bp074True(high is not void,"high hunk")
  for each block in state.caches
    bp074True(block.start+block.span<=state.capacity-state.highUsed,"high collision")
  end for
  return true
end function
// Exercise the case19 test scenario and verify its expected result.
function bp074Case19()
  state=memory.create(512); first=memory.cacheAlloc(state,16,"first"); second=memory.cacheAlloc(state,16,"second")
  memory.Cache_Flush(state)
  bp074Equal(len(state.caches),0,"cache flush")
  bp074Equal(first.block,void,"first user clear")
  bp074Equal(second.block,void,"second user clear")
  return true
end function
// Exercise the case20 test scenario and verify its expected result.
function bp074Case20()
  state=memory.Memory_Init(4096,1024)
  bp074Equal(memory.Hunk_LowMark(state),1040,"zone backing span")
  bp074Equal(state.mainZone.capacity,1024,"zone capacity")
  return true
end function
// Exercise the case21 test scenario and verify its expected result.
function bp074Case21()
  state=memory.Memory_Init(4096,1024); block=memory.zoneTagMalloc(state,24,5,"tagged"); zero=memory.zoneMalloc(state,24,"zero")
  bp074Equal(block.tag,5,"zone wrapper tag")
  bp074Equal(zero.data[0],0,"zone wrapper zero")
  memory.zoneFree(block); memory.zoneFree(zero)
  bp074Equal(memory.zoneCheck(state),true,"zone wrapper check")
  return true
end function
// Exercise the case22 test scenario and verify its expected result.
function bp074Case22()
  state=memory.memoryInitArguments(8192,BP074CommandLine(["-zone","2"]))
  bp074Equal(state.mainZone.capacity,2048,"-zone kilobytes")
  bp074True(try(memory.memoryInitArguments(8192,BP074CommandLine(["-zone"]))) is error,"-zone missing")
  return true
end function
// Exercise the case23 test scenario and verify its expected result.
function bp074Case23()
  bp074Equal(contract.STATUS,"core_assets_memory_109_frozen_v1","contract status")
  bp074Equal(contract.FINGERPRINT,0x6c8d974d,"contract fingerprint")
  bp074Equal(contract.fnv1a32(contract.canonicalText()),contract.FINGERPRINT,"computed fingerprint")
  return true
end function
// Exercise the case24 test scenario and verify its expected result.
function bp074Case24()
  bp074Equal(contract.PAK_ENTRY_BYTES,64,"PACK entry")
  bp074Equal(contract.WAD_LUMPINFO_BYTES,32,"WAD lumpinfo")
  bp074Equal(contract.BSP_VERSION,29,"BSP version")
  bp074Equal(contract.ZONE_DYNAMIC_SIZE,0xc000,"zone dynamic size")
  bp074Equal(contract.verify(),true,"contract verify")
  return true
end function
// Execute one named test case and record its pass/fail result.
function bp074Run(index,name,callback)
  print "["+index+"/24] "+name
  result=try(callback()); if result is error then print "FAIL: "+result.message; return false end if
  return true
end function
// Parse command-line arguments and run the selected operation.
function main(args)
  callbacks=[bp074Case01,bp074Case02,bp074Case03,bp074Case04,bp074Case05,bp074Case06,bp074Case07,bp074Case08,bp074Case09,bp074Case10,bp074Case11,bp074Case12,bp074Case13,bp074Case14,bp074Case15,bp074Case16,bp074Case17,bp074Case18,bp074Case19,bp074Case20,bp074Case21,bp074Case22,bp074Case23,bp074Case24]
  names=["alignment","zone clear","zone tag zero","zone allocation","zone coalesce","zone free validation","zone sentinel","hunk allocation","hunk Quake name","high/temp hunk","hunk marks","hunk check","cache layout","cache LRU","cache try alloc","cache move","cache low collision","cache high collision","cache flush","Memory_Init","zone wrappers","-zone arguments","contract fingerprint","frozen closure"]
  index=0
  while index<len(callbacks)
    if not bp074Run(index+1,names[index],callbacks[index]) then return 1 end if
    index=index+1
  end while
  print "MiniQuake BP-074 core assets/memory closure tests passed: 24"
  return 0
end function
