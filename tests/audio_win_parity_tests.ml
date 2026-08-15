/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-058: snd_win.c waveOut fallback, ring and lifecycle parity.
*/
import miniquake.sound.snd_win as bp058Win

// Assert exact equality and report both values on failure.
function bp058Equal(actual, expected, name)
  if actual != expected then return error(5800, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Assert that the condition holds and identify a failing test.
function bp058Yes(value, name)
  if not value then return error(5801, name + ": expected true") end if
  return true
end function
// Execute one named test case and record its pass/fail result.
function bp058Run(number, name, fn)
  print "[" + number + "/20] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function
// Exercise the state test scenario and verify its expected result.
function bp058State()
  state = bp058Win.create(true, 11025)
  bp058Win.SNDDMA_Init(state, ["-wavonly"])
  return state
end function
// Return constants for the active module state.
function bp058Constants()
  bp058Equal(bp058Win.WAV_BUFFERS, 64, "WAV buffers")
  bp058Equal(bp058Win.WAV_BUFFER_SIZE, 1024, "WAV buffer size")
  bp058Equal(bp058Win.SECONDARY_BUFFER_SIZE, 65536, "secondary size")
  return true
end function
// Exercise the header layout test scenario and verify its expected result.
function bp058HeaderLayout()
  state = bp058Win.create(true, 11025)
  bp058Equal(len(state.headers), 64, "header count")
  bp058Equal(state.headers[0].bufferOffset, 0, "header zero offset")
  bp058Equal(state.headers[1].bufferOffset, 1024, "header one offset")
  bp058Equal(state.headers[63].bufferOffset, 64512, "header final offset")
  return true
end function
// Exercise the fallback test scenario and verify its expected result.
function bp058Fallback()
  state = bp058Win.create(true, 11025)
  bp058Equal(bp058Win.SNDDMA_Init(state, []), 1, "fallback init")
  bp058Yes(state.directAttempted, "direct attempted")
  bp058Yes(state.waveAttempted, "wave attempted")
  bp058Yes(state.waveInitialized, "wave initialized")
  return true
end function
// Exercise the wav only test scenario and verify its expected result.
function bp058WavOnly()
  state = bp058Win.create(true, 11025)
  bp058Equal(bp058Win.SNDDMA_Init(state, ["-wavonly"]), 1, "wavonly init")
  bp058Equal(state.directAttempted, false, "direct skipped")
  bp058Equal(state.waveAttempted, true, "wave attempted")
  return true
end function
// Exercise the no sound test scenario and verify its expected result.
function bp058NoSound()
  state = bp058Win.create(true, 11025)
  bp058Equal(bp058Win.SNDDMA_Init(state, ["-nosound"]), 0, "nosound init")
  bp058Equal(state.waveAttempted, false, "nosound wave skipped")
  return true
end function
// Exercise the no fallback test scenario and verify its expected result.
function bp058NoFallback()
  state = bp058Win.create(true, 11025)
  state.forcedDirectStatus = bp058Win.SIS_NOTAVAIL
  bp058Equal(bp058Win.SNDDMA_Init(state, []), 0, "not available")
  bp058Equal(state.waveAttempted, false, "no fallback on allocated direct")
  return true
end function
// Exercise the prepared test scenario and verify its expected result.
function bp058Prepared()
  state = bp058State()
  bp058Yes(state.headers[0].prepared, "header prepared")
  bp058Equal(state.headers[0].queued, false, "header not queued")
  return true
end function
// Exercise the single block test scenario and verify its expected result.
function bp058SingleBlock()
  state = bp058State()
  block = bytes(1024, 7)
  bp058Yes(bp058Win.SNDDMA_Submit(state, block), "submit block")
  bp058Equal(state.sent, 8, "pre-roll headers")
  bp058Equal(state.buffer[0], 7, "first block")
  bp058Equal(state.buffer[1024], 7, "repeated convenience block")
  return true
end function
// Exercise the distinct ring test scenario and verify its expected result.
function bp058DistinctRing()
  state = bp058State()
  ring = bytes(bp058Win.SECONDARY_BUFFER_SIZE)
  index = 0
  while index < bp058Win.WAV_BUFFERS
    ring[index * bp058Win.WAV_BUFFER_SIZE] = index
    index = index + 1
  end while
  bp058Win.SNDDMA_Submit(state, ring)
  bp058Equal(state.buffer[0], 0, "ring region zero")
  bp058Equal(state.buffer[1024], 1, "ring region one")
  bp058Equal(state.buffer[7168], 7, "ring region seven")
  return true
end function
// Add bound to the destination state.
function bp058QueueBound()
  state = bp058State(); block = bytes(1024)
  bp058Win.SNDDMA_Submit(state, block)
  bp058Equal(bp058Win.queuedHeaders(state), 8, "queued headers")
  bp058Equal(bp058Win.SNDDMA_Submit(state, block), false, "queue already full")
  return true
end function
// Exercise the dma position test scenario and verify its expected result.
function bp058DmaPosition()
  state = bp058State(); bp058Win.SNDDMA_Submit(state, bytes(1024))
  bp058Equal(bp058Win.SNDDMA_GetDMAPos(state), 4096, "DMA position")
  return true
end function
// Exercise the complete test scenario and verify its expected result.
function bp058Complete()
  state = bp058State(); bp058Win.SNDDMA_Submit(state, bytes(1024))
  bp058Equal(bp058Win.completeHeaders(state, 3), 3, "three completed")
  bp058Equal(bp058Win.queuedHeaders(state), 5, "five queued")
  bp058Yes(state.headers[0].done, "first done")
  return true
end function
// Execute one named test case and record its pass/fail result.
function bp058Underrun()
  state = bp058State(); block = bytes(1024)
  bp058Win.SNDDMA_Submit(state, block)
  bp058Win.completeHeaders(state, 8)
  bp058Win.SNDDMA_Submit(state, block)
  bp058Equal(state.underruns, 1, "underrun count")
  return true
end function
// Exercise the block test scenario and verify its expected result.
function bp058Block()
  state = bp058State(); bp058Win.SNDDMA_Submit(state, bytes(1024))
  bp058Equal(bp058Win.S_BlockSound(state), 1, "first block")
  bp058Equal(bp058Win.queuedHeaders(state), 0, "queue flushed")
  bp058Equal(state.resetCount, 1, "reset once")
  return true
end function
// Exercise the nested block test scenario and verify its expected result.
function bp058NestedBlock()
  state = bp058State()
  bp058Equal(bp058Win.S_BlockSound(state), 1, "nested first")
  bp058Equal(bp058Win.S_BlockSound(state), 2, "nested second")
  bp058Equal(state.resetCount, 1, "one reset")
  bp058Equal(bp058Win.S_UnblockSound(state), 1, "unblock one")
  bp058Equal(bp058Win.S_UnblockSound(state), 0, "unblock zero")
  return true
end function
// Exercise the blocked submit test scenario and verify its expected result.
function bp058BlockedSubmit()
  state = bp058State(); bp058Win.S_BlockSound(state)
  bp058Equal(bp058Win.SNDDMA_Submit(state, bytes(1024)), false, "blocked submit")
  return true
end function
// Exercise the header generation test scenario and verify its expected result.
function bp058HeaderGeneration()
  state = bp058State(); block = bytes(1024)
  bp058Win.SNDDMA_Submit(state, block)
  bp058Win.completeHeaders(state, 8)
  bp058Win.SNDDMA_Submit(state, block)
  bp058Equal(state.headers[8].generation, 1, "next generation")
  return true
end function
// Exercise the byte counters test scenario and verify its expected result.
function bp058ByteCounters()
  state = bp058State(); bp058Win.SNDDMA_Submit(state, bytes(1024))
  bp058Equal(state.submittedBytes, 8192, "submitted bytes")
  bp058Win.completeHeaders(state, 2)
  bp058Equal(state.completedBytes, 2048, "completed bytes")
  return true
end function
// Release or remove state for the requested value.
function bp058Shutdown()
  state = bp058State()
  bp058Win.SNDDMA_Shutdown(state)
  bp058Equal(state.waveInitialized, false, "wave closed")
  bp058Equal(state.headers[0].prepared, false, "header unprepared")
  bp058Equal(state.shutdownCount, 1, "shutdown count")
  return true
end function
// Release or remove state for twice and short block.
function bp058ShutdownTwiceAndShortBlock()
  state = bp058State(); bp058Win.SNDDMA_Shutdown(state); bp058Win.SNDDMA_Shutdown(state)
  bp058Equal(state.shutdownCount, 2, "second shutdown")

  shortState = bp058State(); block = bytes(17, 9)
  bp058Win.SNDDMA_Submit(shortState, block)
  bp058Equal(shortState.headers[0].bufferLength, 17, "short header length")
  bp058Equal(shortState.buffer[16], 9, "short final byte")
  return true
end function

passed = 0
if bp058Run(1,"waveOut constants",bp058Constants) then passed=passed+1 end if
if bp058Run(2,"header layout",bp058HeaderLayout) then passed=passed+1 end if
if bp058Run(3,"DirectSound fallback",bp058Fallback) then passed=passed+1 end if
if bp058Run(4,"wavonly",bp058WavOnly) then passed=passed+1 end if
if bp058Run(5,"nosound",bp058NoSound) then passed=passed+1 end if
if bp058Run(6,"SIS_NOTAVAIL",bp058NoFallback) then passed=passed+1 end if
if bp058Run(7,"prepared headers",bp058Prepared) then passed=passed+1 end if
if bp058Run(8,"single-block pre-roll",bp058SingleBlock) then passed=passed+1 end if
if bp058Run(9,"distinct DMA ring regions",bp058DistinctRing) then passed=passed+1 end if
if bp058Run(10,"queue bound",bp058QueueBound) then passed=passed+1 end if
if bp058Run(11,"DMA position",bp058DmaPosition) then passed=passed+1 end if
if bp058Run(12,"header completion",bp058Complete) then passed=passed+1 end if
if bp058Run(13,"underrun accounting",bp058Underrun) then passed=passed+1 end if
if bp058Run(14,"block flush",bp058Block) then passed=passed+1 end if
if bp058Run(15,"nested block",bp058NestedBlock) then passed=passed+1 end if
if bp058Run(16,"blocked submit",bp058BlockedSubmit) then passed=passed+1 end if
if bp058Run(17,"header generation",bp058HeaderGeneration) then passed=passed+1 end if
if bp058Run(18,"byte counters",bp058ByteCounters) then passed=passed+1 end if
if bp058Run(19,"shutdown",bp058Shutdown) then passed=passed+1 end if
if bp058Run(20,"idempotent/short lifecycle",bp058ShutdownTwiceAndShortBlock) then passed=passed+1 end if
if passed != 20 then print "MiniQuake BP-058 audio Win32 tests failed: " + passed + "/20"; error(5899,"BP-058 audio Win32") end if
print "MiniQuake BP-058 audio Win32 tests passed: 20"
