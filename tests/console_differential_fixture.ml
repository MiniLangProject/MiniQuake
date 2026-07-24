import miniquake.console as con
import miniquake.filesystem as qfs
import miniquake.native as native

function boolNumber(value)
  if value then return 1 end if
  return 0
end function

function main(args)
  state = con.create(512)
  commands = con.Con_Init(state, void, 320, false)
  print "{\"function\":\"Con_Init\",\"case\":\"startup\",\"width\":" +
    state.lineWidth + ",\"total\":" + state.totalLines + ",\"current\":" +
    state.currentLine + ",\"commands\":" + len(commands) +
    ",\"cvars\":1,\"initialized\":" + boolNumber(state.initialized) + "}"

  state.active = true
  state.inputText = "a"
  destination = con.Con_ToggleConsole_f(state, true)
  game = 0
  if destination == "game" then game = 1 end if
  print "{\"function\":\"Con_ToggleConsole_f\",\"case\":\"connected\",\"game\":" +
    game + ",\"line_empty\":" + boolNumber(state.inputText == "") +
    ",\"linepos\":1,\"plaque\":1,\"menu\":0,\"notify_zero\":" +
    boolNumber(state.notifyTimes == [0.0, 0.0, 0.0, 0.0]) + "}"

  state.textBuffer[0] = 88
  con.Con_Clear_f(state)
  spaces = 1
  index = 0
  while index < len(state.textBuffer)
    if state.textBuffer[index] != 32 then spaces = 0; break end if
    index = index + 1
  end while
  print "{\"function\":\"Con_Clear_f\",\"case\":\"buffer\",\"spaces\":" +
    spaces + "}"

  state.notifyTimes = [1.0, 0.0, 0.0, 2.0]
  con.Con_ClearNotify(state)
  print "{\"function\":\"Con_ClearNotify\",\"case\":\"times\",\"zero\":" +
    boolNumber(state.notifyTimes == [0.0, 0.0, 0.0, 0.0]) + "}"

  publicMode = con.Con_MessageMode_f(state)
  print "{\"function\":\"Con_MessageMode_f\",\"case\":\"public\",\"team\":" +
    boolNumber(publicMode) + "}"
  teamMode = con.Con_MessageMode2_f(state)
  print "{\"function\":\"Con_MessageMode2_f\",\"case\":\"team\",\"team\":" +
    boolNumber(teamMode) + "}"

  con.setBackscroll(5)
  con.Con_CheckResize(state, 640)
  print "{\"function\":\"Con_CheckResize\",\"case\":\"wider\",\"width\":" +
    state.lineWidth + ",\"total\":" + state.totalLines + ",\"current\":" +
    state.currentLine + ",\"back\":" + con.backscroll() +
    ",\"notify_zero\":" +
    boolNumber(state.notifyTimes == [0.0, 0.0, 0.0, 0.0]) + "}"

  state.cursorX = 5
  con.Con_Linefeed(state)
  print "{\"function\":\"Con_Linefeed\",\"case\":\"blank\",\"current\":" +
    state.currentLine + ",\"x\":" + state.cursorX + ",\"empty\":" +
    boolNumber(con.printableLine(con.lineBytes(state, state.currentLine)) == "") +
    "}"

  con.Con_Clear_f(state)
  state.currentLine = state.totalLines - 1
  state.cursorX = 0
  con.Con_Print(state, "hello\nnext", 2.0)
  print "{\"function\":\"Con_Print\",\"case\":\"lines\",\"previous\":\"" +
    con.printableLine(con.lineBytes(state, state.currentLine - 1)) +
    "\",\"current\":\"" +
    con.printableLine(con.lineBytes(state, state.currentLine)) + "\",\"x\":" +
    state.cursorX + ",\"time\":" +
    native.floatText(state.notifyTimes[state.currentLine % 4]) + "}"

  logSystem = qfs.create(args[0], "game")
  state.filesystem = logSystem
  logged = con.Con_DebugLog(state, "fixture.log", "debug")
  print "{\"function\":\"Con_DebugLog\",\"case\":\"append\",\"exact\":" +
    boolNumber(logged) + ",\"length\":5}"

  state.updateRequested = false
  con.Con_Printf(state, "printf line\n", false, false)
  print "{\"function\":\"Con_Printf\",\"case\":\"visible\",\"line\":\"" +
    con.printableLine(con.lineBytes(state, state.currentLine)) +
    "\",\"updates\":" + boolNumber(state.updateRequested) + "}"

  con.Con_DPrintf(state, "developer line\n", true, false, false)
  print "{\"function\":\"Con_DPrintf\",\"case\":\"enabled\",\"line\":\"" +
    con.printableLine(con.lineBytes(state, state.currentLine)) + "\"}"

  state.updateRequested = false
  con.Con_SafePrintf(state, "safe line\n", false)
  print "{\"function\":\"Con_SafePrintf\",\"case\":\"loading\",\"line\":\"" +
    con.printableLine(con.lineBytes(state, state.currentLine)) +
    "\",\"updates\":" + boolNumber(state.updateRequested) +
    ",\"disabled\":0}"

  state.inputText = "abc"
  state.active = true
  state.forcedUp = false
  state.visiblePixelLines = 200
  inputDraw = con.Con_DrawInput(state, 0.25)
  print "{\"function\":\"Con_DrawInput\",\"case\":\"cursor\",\"prefix\":[" +
    inputDraw[0] + "," + inputDraw[1] + "," + inputDraw[2] + "," +
    inputDraw[3] + "],\"cursor\":" + inputDraw[4] +
    ",\"semantic_length\":5}"

  con.Con_Clear_f(state)
  con.Con_ClearNotify(state)
  state.currentLine = state.totalLines - 1
  state.cursorX = 0
  con.Con_Print(state, "notify", 5.0)
  state.notifyPixelLines = 0
  notify = con.Con_DrawNotify(state, 6.0, 3.0, false, "")
  print "{\"function\":\"Con_DrawNotify\",\"case\":\"fresh\",\"rows\":" +
    len(notify) + ",\"pixels\":" + state.notifyPixelLines +
    ",\"first\":" + notify[0][3][0] + "}"

  consoleDraw = con.Con_DrawConsole(state, 64, false, 6.0)
  print "{\"function\":\"Con_DrawConsole\",\"case\":\"rows\",\"background\":" +
    consoleDraw[0][1] + ",\"rows\":" + (len(consoleDraw) - 1) +
    ",\"visible\":" + state.visiblePixelLines + "}"

  notified = con.Con_NotifyBox(state, "notice\n")
  print "{\"function\":\"Con_NotifyBox\",\"case\":\"notice\",\"result\":" +
    boolNumber(notified) + ",\"stored\":" +
    boolNumber(state.notifyBoxText == "notice\n") +
    ",\"destination\":0,\"realtime\":" + native.floatText(state.realtime) + "}"
  return 0
end function
