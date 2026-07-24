/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Deterministic snd_win.c lifecycle tests plus an opt-in real waveOut smoke.
*/

import miniquake.sound.snd_win as sndwin
import miniquake.sound.snd_mem as sndmem
import miniquake.native as native
import miniquake.filesystem as qfs
import miniquake.byteio as bio

function assertEqual(actual, expected, name)
  if actual != expected then return error(9500, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function assertTrue(value, name)
  if value != true then return error(9501, name + ": expected true") end if
  return true
end function

function testHasArgument(arguments, wanted)
  for each argument in arguments
    if argument == wanted then return true end if
  end for
  return false
end function

function argumentAfter(arguments, wanted)
  index = 0
  while index + 1 < len(arguments)
    if arguments[index] == wanted then return arguments[index + 1] end if
    index = index + 1
  end while
  return ""
end function

function testFallbackSelection()
  regular = sndwin.create(true, 11025)
  assertEqual(sndwin.SNDDMA_Init(regular, []), 1, "SNDDMA_Init fallback")
  assertEqual(regular.directAttempted, true, "DirectSound attempted first")
  assertEqual(regular.waveAttempted, true, "waveOut fallback attempted")
  assertEqual(regular.directInitialized, false, "modern DirectSound unavailable")
  assertEqual(regular.waveInitialized, true, "waveOut initialized")
  assertEqual(regular.preferredWave, true, "waveOut preference retained")
  assertEqual(len(regular.headers), sndwin.WAV_BUFFERS, "WAV header count")
  assertEqual(regular.headers[0].prepared, true, "header prepared")

  wavOnly = sndwin.create(true, 11025)
  assertEqual(sndwin.SNDDMA_Init(wavOnly, ["-wavonly"]), 1, "-wavonly initializes")
  assertEqual(wavOnly.directAttempted, false, "-wavonly skips DirectSound")
  assertEqual(wavOnly.waveAttempted, true, "-wavonly waveOut")

  noSound = sndwin.create(true, 11025)
  assertEqual(sndwin.SNDDMA_Init(noSound, ["-nosound"]), 0, "-nosound")
  assertEqual(noSound.directAttempted, false, "-nosound skips DirectSound")
  assertEqual(noSound.waveAttempted, false, "-nosound skips waveOut")

  busy = sndwin.create(true, 11025)
  busy.forcedDirectStatus = sndwin.SIS_NOTAVAIL
  assertEqual(sndwin.SNDDMA_Init(busy, []), 0, "allocated DirectSound declines audio")
  assertEqual(busy.directAttempted, true, "allocated DirectSound attempted")
  assertEqual(busy.waveAttempted, false, "SIS_NOTAVAIL suppresses fallback")
  return true
end function

function testHeaderLifecycleAndPosition()
  state = sndwin.create(true, 11025)
  sndwin.SNDDMA_Init(state, ["-wavonly"])
  block = bytes(sndwin.WAV_BUFFER_SIZE)
  block[0] = 7
  assertEqual(sndwin.SNDDMA_Submit(state, block), true, "initial refill")
  assertEqual(sndwin.SNDDMA_Submit(state, block), false, "full pre-roll needs no refill")
  assertEqual(state.sent, 8, "original waveOut pre-roll headers")
  assertEqual(sndwin.queuedHeaders(state), 8, "queued headers")
  assertEqual(state.headers[0].queued, true, "header zero queued")
  assertEqual(state.headers[1].queued, true, "header one queued")
  assertEqual(state.buffer[0], 7, "header data copied")
  assertEqual(state.buffer[sndwin.WAV_BUFFER_SIZE], 7, "second header data copied")
  assertEqual(sndwin.SNDDMA_GetDMAPos(state), 4096, "legacy mono-sample DMA position")

  assertEqual(sndwin.completeHeaders(state, 1), 1, "complete first header")
  assertEqual(state.completed, 1, "completed count")
  assertEqual(state.headers[0].done, true, "WHDR_DONE lifecycle")
  assertEqual(state.headers[0].queued, false, "completed header not queued")
  assertEqual(sndwin.queuedHeaders(state), 7, "seven outstanding headers")

  sndwin.completeHeaders(state, 7)
  assertEqual(sndwin.queuedHeaders(state), 0, "queue drained")
  assertEqual(sndwin.SNDDMA_Submit(state, block), true, "submit after drain")
  assertEqual(state.underruns, 1, "deterministic underrun count")
  assertEqual(state.headers[8].generation, 1, "next header generation")
  return true
end function

function testRingOverrun()
  state = sndwin.create(true, 11025)
  sndwin.SNDDMA_Init(state, ["-wavonly"])
  block = bytes(sndwin.WAV_BUFFER_SIZE)
  assertEqual(sndwin.SNDDMA_Submit(state, block), true, "fill original pre-roll")
  assertEqual(sndwin.queuedHeaders(state), 8, "bounded pre-roll")
  assertEqual(sndwin.SNDDMA_Submit(state, block), false, "pre-roll already full")
  assertEqual(state.overruns, 0, "bounded queue avoids overwrite")
  sndwin.completeHeaders(state, 8)
  assertEqual(sndwin.queuedHeaders(state), 0, "pre-roll completion")
  return true
end function

function testBlockAndShutdown()
  state = sndwin.create(true, 11025)
  sndwin.SNDDMA_Init(state, ["-wavonly"])
  block = bytes(sndwin.WAV_BUFFER_SIZE)
  sndwin.SNDDMA_Submit(state, block)
  sndwin.SNDDMA_Submit(state, block)
  assertEqual(sndwin.S_BlockSound(state), 1, "first S_BlockSound")
  assertEqual(state.resetCount, 1, "waveOut reset once")
  assertEqual(sndwin.queuedHeaders(state), 0, "reset completes headers")
  assertEqual(sndwin.S_BlockSound(state), 2, "nested S_BlockSound")
  assertEqual(state.resetCount, 1, "nested block does not reset")
  assertEqual(sndwin.SNDDMA_Submit(state, block), false, "blocked submit")
  assertEqual(sndwin.S_UnblockSound(state), 1, "nested S_UnblockSound")
  assertEqual(sndwin.S_UnblockSound(state), 0, "final S_UnblockSound")

  assertEqual(sndwin.SNDDMA_Shutdown(state), true, "SNDDMA_Shutdown")
  assertEqual(state.waveInitialized, false, "waveOut cleared")
  assertEqual(state.headers[0].prepared, false, "header unprepared")
  assertEqual(state.shutdownCount, 1, "shutdown count")
  assertEqual(sndwin.SNDDMA_Shutdown(state), true, "idempotent shutdown")
  assertEqual(state.shutdownCount, 2, "idempotent shutdown tracked")
  return true
end function

function testRealWaveOut()
  state = sndwin.create(false, 22050)
  initialized = sndwin.SNDDMA_Init(state, ["-wavonly"])
  if initialized == 0 then return error(9502, "real waveOut device did not initialize") end if
  assertEqual(native.audioIsOpen(), 1, "native waveOut open")
  assertEqual(native.audioCapacity(), 8, "native header capacity")
  block = bytes(2048)
  index = 0
  while index < len(block)
    block[index] = 0
    index = index + 1
  end while
  assertEqual(sndwin.SNDDMA_Submit(state, block), true, "real waveOut submit")
  assertTrue(native.audioSubmitted() >= 1, "native submitted counter")
  assertTrue(native.audioQueued() <= native.audioCapacity(), "native queued bound")
  position = sndwin.SNDDMA_GetDMAPos(state)
  assertTrue(position >= 0 and position < state.dmaSamples, "native DMA position bound")
  assertEqual(sndwin.S_BlockSound(state), 1, "real waveOut reset")
  assertEqual(sndwin.S_UnblockSound(state), 0, "real waveOut unblock")
  assertEqual(sndwin.SNDDMA_Shutdown(state), true, "real waveOut shutdown")
  assertEqual(native.audioIsOpen(), 0, "native waveOut closed")
  return true
end function

function testRetailWaveOut(baseDirectory)
  filesystem = qfs.initialize(baseDirectory, "id1")
  descriptor = sndmem.createDescriptor("misc/menu1.wav")
  cache = sndmem.S_LoadSound(filesystem, descriptor, 22050, false)
  assertTrue(cache.length >= 512, "retail menu sound frames")
  pcm = bytes(512 * 4)
  frame = 0
  while frame < 512
    sample = 0
    if cache.width == 1 then
      sample = cache.data[frame]
      if sample >= 128 then sample = sample - 256 end if
      sample = sample << 8
    else
      sample = bio.i16(cache.data, frame * 2)
    end if
    bio.putI16(pcm, frame * 4, sample)
    bio.putI16(pcm, frame * 4 + 2, sample)
    frame = frame + 1
  end while

  state = sndwin.create(false, 22050)
  assertEqual(sndwin.SNDDMA_Init(state, ["-wavonly"]), 1, "retail waveOut init")
  assertEqual(sndwin.SNDDMA_Submit(state, pcm), true, "retail PCM submit")
  native.winSleep(25)
  assertTrue(native.audioSubmitted() >= 1, "retail submitted counter")
  assertTrue(sndwin.SNDDMA_GetDMAPos(state) < state.dmaSamples, "retail DMA position")
  sndwin.SNDDMA_Shutdown(state)
  qfs.release(filesystem)
  return true
end function

function main(args)
  print "[1/4] DirectSound/waveOut fallback"
  testFallbackSelection()
  print "[2/4] header lifecycle/DMA position"
  testHeaderLifecycleAndPosition()
  print "[3/4] ring overrun/underrun"
  testRingOverrun()
  print "[4/4] block/reset/shutdown"
  testBlockAndShutdown()
  if testHasArgument(args, "--real") then
    print "[real] native waveOut smoke"
    testRealWaveOut()
  end if
  retailBase = argumentAfter(args, "--retail")
  if retailBase != "" then
    print "[retail] menu1.wav through native waveOut"
    testRetailWaveOut(retailBase)
  end if
  print "MiniQuake snd_win compatibility tests passed: 4"
  return 0
end function
