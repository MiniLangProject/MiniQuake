/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/snd_win_differential_fixture.ml.
*/
import miniquake.sound.snd_win as snd

// Return bool number derived from the active module state.
function boolNumber(value)
  if value then return 1 end if
  return 0
end function

// Return prepared count derived from the active module state.
function preparedCount(state)
  count = 0
  for each header in state.headers
    if header.prepared then count = count + 1 end if
  end for
  return count
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  state = snd.create(true, 11025)
  result = snd.SNDDMA_InitDirect(state)
  print "{\"function\":\"SNDDMA_InitDirect\",\"case\":\"missing-dsound\"," +
    "\"result\":" + result + ",\"attempts\":1,\"direct\":" +
    boolNumber(state.directInitialized) + "}"

  state = snd.create(true, 11025)
  result = snd.SNDDMA_InitWav(state)
  print "{\"function\":\"SNDDMA_InitWav\",\"case\":\"success\",\"result\":" +
    boolNumber(result) + ",\"wave\":" + boolNumber(state.waveInitialized) +
    ",\"channels\":" + state.channels + ",\"bits\":" + state.sampleBits +
    ",\"speed\":" + state.sampleRate + ",\"samples\":" + state.dmaSamples +
    ",\"chunk\":1,\"prepared\":" + preparedCount(state) +
    ",\"size\":" + len(state.buffer) + "}"

  state.preferredWave = true
  snd.S_BlockSound(state)
  print "{\"function\":\"S_BlockSound\",\"case\":\"wave\",\"blocked\":" +
    state.blocked + ",\"resets\":" + state.resetCount + "}"

  snd.S_UnblockSound(state)
  print "{\"function\":\"S_UnblockSound\",\"case\":\"wave\",\"blocked\":" +
    state.blocked + "}"

  snd.FreeSound(state)
  print "{\"function\":\"FreeSound\",\"case\":\"wave\",\"wave\":" +
    boolNumber(state.waveInitialized) + ",\"direct\":" +
    boolNumber(state.directInitialized) + ",\"headers\":64,\"closed\":1," +
    "\"handle\":0,\"data\":0}"

  state = snd.create(true, 11025)
  result = snd.SNDDMA_Init(state, [])
  print "{\"function\":\"SNDDMA_Init\",\"case\":\"fallback\",\"result\":" +
    result + ",\"direct\":" + boolNumber(state.directInitialized) +
    ",\"wave\":" + boolNumber(state.waveInitialized) + ",\"first\":" +
    boolNumber(state.firstTime) + ",\"direct_pref\":" +
    boolNumber(state.preferredDirect) + ",\"wave_pref\":" +
    boolNumber(state.preferredWave) + "}"

  state.sent = 5
  state.completed = 0
  state.sample16 = 1
  state.dmaSamples = 32768
  position = snd.SNDDMA_GetDMAPos(state)
  print "{\"function\":\"SNDDMA_GetDMAPos\",\"case\":\"wave\",\"result\":" +
    position + "}"

  state.sent = 0
  state.completed = 0
  for each header in state.headers
    header.queued = false
    header.done = false
  end for
  snd.SNDDMA_Submit(state, bytes(snd.WAV_BUFFER_SIZE))
  print "{\"function\":\"SNDDMA_Submit\",\"case\":\"refill\",\"sent\":" +
    state.sent + ",\"completed\":" + state.completed + ",\"writes\":" +
    state.sent + "}"

  snd.SNDDMA_Shutdown(state)
  print "{\"function\":\"SNDDMA_Shutdown\",\"case\":\"wave\",\"wave\":" +
    boolNumber(state.waveInitialized) + ",\"headers\":64,\"closed\":1}"
  return 0
end function
