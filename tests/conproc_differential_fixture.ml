/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/conproc_differential_fixture.ml.
*/
import miniquake.conproc as conproc

// Return bool number derived from the active module state.
function boolNumber(value)
  if value then return 1 end if
  return 0
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  conproc.InitConProc(10, 20, 30, false)
  state = conproc.ConProc_State()
  print "{\"function\":\"InitConProc\",\"case\":\"valid\",\"file\":" +
    boolNumber(state.fileBuffer == 10) + ",\"parent\":" +
    boolNumber(state.parentSend == 20) + ",\"child\":" +
    boolNumber(state.childSend == 30) + ",\"done\":" +
    boolNumber(state.eventDone != 0) + ",\"stdout\":1,\"stdin\":1," +
    "\"width\":" + state.screenWidth + ",\"height\":" + state.screenHeight + "}"

  conproc.DeinitConProc()
  print "{\"function\":\"DeinitConProc\",\"case\":\"active\",\"signals\":1}"

  conproc.InitConProc(10, 20, 30, false)
  state = conproc.ConProc_State()
  conproc.ConProc_SetTestBuffer([conproc.CCOM_SET_SCR_LINES, 33])
  requestResult = conproc.RequestProc(false)
  print "{\"function\":\"RequestProc\",\"case\":\"set-lines\",\"result\":0," +
    "\"response\":" + boolNumber(conproc.ConProc_RequestBuffer()[0]) +
    ",\"height\":" + state.screenHeight + ",\"maps\":1,\"unmaps\":1," +
    "\"signals\":1}"

  buffer = [conproc.CCOM_GET_SCR_LINES]
  conproc.ConProc_SetTestBuffer(buffer)
  mapped = conproc.GetMappedBuffer(10)
  print "{\"function\":\"GetMappedBuffer\",\"case\":\"valid\",\"mapped\":" +
    boolNumber(mapped == buffer) + ",\"maps\":1}"

  released = conproc.ReleaseMappedBuffer(mapped)
  print "{\"function\":\"ReleaseMappedBuffer\",\"case\":\"valid\",\"unmaps\":" +
    boolNumber(released) + "}"

  state.screenHeight = 47
  lines = conproc.GetScreenBufferLines()
  print "{\"function\":\"GetScreenBufferLines\",\"case\":\"success\",\"result\":1," +
    "\"lines\":" + lines + "}"

  resized = conproc.SetScreenBufferLines(31)
  print "{\"function\":\"SetScreenBufferLines\",\"case\":\"resize\",\"result\":" +
    boolNumber(resized) + ",\"width\":" + state.screenWidth +
    ",\"height\":" + state.screenHeight + "}"

  firstLine = "ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZAB"
  secondLine = "CDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCD"
  state.consoleLines = ["", firstLine, secondLine]
  text = conproc.ReadText(1, 2)
  raw = bytes(text)
  print "{\"function\":\"ReadText\",\"case\":\"inclusive\",\"result\":1," +
    "\"length\":" + len(raw) + ",\"first\":" + raw[0] +
    ",\"last\":" + raw[159] + "}"

  state.inputEvents = []
  written = conproc.WriteText("aB\n")
  events = state.inputEvents
  print "{\"function\":\"WriteText\",\"case\":\"keys\",\"result\":" +
    boolNumber(written) + ",\"events\":" + len(events) +
    ",\"first_char\":" + events[0][0] + ",\"first_vk\":" + events[0][1] +
    ",\"first_scan\":" + events[0][2] + ",\"upper_shift\":" +
    boolNumber(events[2][3]) + ",\"return_char\":" + events[4][0] +
    ",\"return_scan\":" + events[4][2] + "}"

  print "{\"function\":\"CharToCode\",\"case\":\"classes\",\"return\":" +
    conproc.CharToCode(13) + ",\"lower\":" + conproc.CharToCode(97) +
    ",\"upper\":" + conproc.CharToCode(90) + ",\"zero\":" +
    conproc.CharToCode(48) + ",\"nine\":" + conproc.CharToCode(57) +
    ",\"punct\":" + conproc.CharToCode(33) + "}"

  state.screenWidth = 100
  state.screenHeight = 40
  state.maximumWidth = 90
  state.maximumHeight = 35
  clamped = conproc.SetConsoleCXCY(0, 120, 80)
  print "{\"function\":\"SetConsoleCXCY\",\"case\":\"clamp-shrink\",\"result\":" +
    boolNumber(clamped) + ",\"width\":" + state.screenWidth +
    ",\"height\":" + state.screenHeight + "}"
  return 0
end function
