import miniquake.types as t
import miniquake.constants as c
import miniquake.input as input
import miniquake.client as client
import miniquake.net_loop as netloop
import miniquake.net_main as netmain
import miniquake.native as native

function emit(name, caseName, i0, i1, f0, f1, f2, f3)
  print "{\"function\":\"" + name + "\",\"case\":\"" + caseName +
    "\",\"i0\":" + i0 + ",\"i1\":" + i1 +
    ",\"f0\":" + native.floatText(f0) + ",\"f1\":" + native.floatText(f1) +
    ",\"f2\":" + native.floatText(f2) + ",\"f3\":" + native.floatText(f3) + "}"
end function

function intBool(value)
  if value then return 1 end if
  return 0
end function

function dataChecksum(data)
  result = 0
  index = 0
  while index < len(data)
    result = result + (index + 1) * data[index]
    index = index + 1
  end while
  return result
end function

function resetInput()
  input.IN_ClearStates()
  input.setLookSpring(false)
  input.consumePitchDriftRequests()
end function

function wrapperEvent(name, downFunction, upFunction, button, release)
  resetInput()
  if release then
    downFunction(17)
    upFunction(17)
  else
    downFunction(17)
  end if
  caseName = "press"
  if release then caseName = "release" end if
  emit(name, caseName, button[0], button[2], 0, 0, 0, 0)
end function

function registeredChecksum(names)
  result = 0
  commandIndex = 0
  while commandIndex < len(names)
    data = bytes(names[commandIndex])
    byteIndex = 0
    while byteIndex < len(data)
      result = result + (commandIndex + 1 + byteIndex) * data[byteIndex]
      byteIndex = byteIndex + 1
    end while
    commandIndex = commandIndex + 1
  end while
  return result
end function

function connectedClient()
  state = netloop.createState()
  socket = netloop.connect(state, "local")
  netmain.NET_TrackSocket(socket)
  localClient = client.create(void)
  localClient.connected = true
  localClient.spawned = true
  localClient.signon = c.SIGNONS
  localClient.socket = socket
  return [localClient, state]
end function

function main(args)
  // The production client receives its qsocket from NET_Connect after
  // NET_Init has sized the pool.  This fixture creates several isolated loop
  // pairs, so size the same public pool before tracking them.
  netmain.NET_SetMaximumClients(16)
  resetInput()
  input.KeyDown(input.inForward, 11)
  input.KeyDown(input.inForward, 12)
  input.KeyDown(input.inForward, 13)
  emit("KeyDown", "two_owner_limit", input.inForward[0], input.inForward[1], input.inForward[2], 1, 0, 0)

  resetInput()
  input.KeyDown(input.inForward, 11)
  input.KeyDown(input.inForward, 12)
  input.KeyUp(input.inForward, 11)
  input.KeyUp(input.inForward, 12)
  emit("KeyUp", "last_owner_release", input.inForward[0], input.inForward[1], input.inForward[2], 0, 0, 0)

  resetInput()
  input.inForward[0] = 11
  input.inForward[2] = 1
  input.KeyUp(input.inForward, void)
  emit("KeyUp", "manual_unstick", input.inForward[0], input.inForward[1], input.inForward[2], 0, 0, 0)

  wrapperEvent("IN_KLookDown", input.IN_KLookDown, input.IN_KLookUp, input.inKLook, false)
  wrapperEvent("IN_KLookUp", input.IN_KLookDown, input.IN_KLookUp, input.inKLook, true)

  resetInput()
  input.setLookSpring(true)
  input.IN_MLookDown(17)
  emit("IN_MLookDown", "press", input.inMLook[0], 0, input.inMLook[2], 0, 0, 0)
  input.IN_MLookUp(17)
  requests = input.consumePitchDriftRequests()
  emit("IN_MLookUp", "lookspring", input.inMLook[0], intBool(requests[1]), input.inMLook[2], 0, 0, 0)

  wrapperEvent("IN_UpDown", input.IN_UpDown, input.IN_UpUp, input.inUp, false)
  wrapperEvent("IN_UpUp", input.IN_UpDown, input.IN_UpUp, input.inUp, true)
  wrapperEvent("IN_DownDown", input.IN_DownDown, input.IN_DownUp, input.inDown, false)
  wrapperEvent("IN_DownUp", input.IN_DownDown, input.IN_DownUp, input.inDown, true)
  wrapperEvent("IN_LeftDown", input.IN_LeftDown, input.IN_LeftUp, input.inLeft, false)
  wrapperEvent("IN_LeftUp", input.IN_LeftDown, input.IN_LeftUp, input.inLeft, true)
  wrapperEvent("IN_RightDown", input.IN_RightDown, input.IN_RightUp, input.inRight, false)
  wrapperEvent("IN_RightUp", input.IN_RightDown, input.IN_RightUp, input.inRight, true)
  wrapperEvent("IN_ForwardDown", input.IN_ForwardDown, input.IN_ForwardUp, input.inForward, false)
  wrapperEvent("IN_ForwardUp", input.IN_ForwardDown, input.IN_ForwardUp, input.inForward, true)
  wrapperEvent("IN_BackDown", input.IN_BackDown, input.IN_BackUp, input.inBack, false)
  wrapperEvent("IN_BackUp", input.IN_BackDown, input.IN_BackUp, input.inBack, true)
  wrapperEvent("IN_LookupDown", input.IN_LookupDown, input.IN_LookupUp, input.inLookup, false)
  wrapperEvent("IN_LookupUp", input.IN_LookupDown, input.IN_LookupUp, input.inLookup, true)
  wrapperEvent("IN_LookdownDown", input.IN_LookdownDown, input.IN_LookdownUp, input.inLookdown, false)
  wrapperEvent("IN_LookdownUp", input.IN_LookdownDown, input.IN_LookdownUp, input.inLookdown, true)
  wrapperEvent("IN_MoveleftDown", input.IN_MoveleftDown, input.IN_MoveleftUp, input.inMoveleft, false)
  wrapperEvent("IN_MoveleftUp", input.IN_MoveleftDown, input.IN_MoveleftUp, input.inMoveleft, true)
  wrapperEvent("IN_MoverightDown", input.IN_MoverightDown, input.IN_MoverightUp, input.inMoveright, false)
  wrapperEvent("IN_MoverightUp", input.IN_MoverightDown, input.IN_MoverightUp, input.inMoveright, true)
  wrapperEvent("IN_SpeedDown", input.IN_SpeedDown, input.IN_SpeedUp, input.inSpeed, false)
  wrapperEvent("IN_SpeedUp", input.IN_SpeedDown, input.IN_SpeedUp, input.inSpeed, true)
  wrapperEvent("IN_StrafeDown", input.IN_StrafeDown, input.IN_StrafeUp, input.inStrafe, false)
  wrapperEvent("IN_StrafeUp", input.IN_StrafeDown, input.IN_StrafeUp, input.inStrafe, true)
  wrapperEvent("IN_AttackDown", input.IN_AttackDown, input.IN_AttackUp, input.inAttack, false)
  wrapperEvent("IN_AttackUp", input.IN_AttackDown, input.IN_AttackUp, input.inAttack, true)
  wrapperEvent("IN_UseDown", input.IN_UseDown, input.IN_UseUp, input.inUse, false)
  wrapperEvent("IN_UseUp", input.IN_UseDown, input.IN_UseUp, input.inUse, true)
  wrapperEvent("IN_JumpDown", input.IN_JumpDown, input.IN_JumpUp, input.inJump, false)
  wrapperEvent("IN_JumpUp", input.IN_JumpDown, input.IN_JumpUp, input.inJump, true)

  resetInput()
  input.IN_Impulse("0x10")
  emit("IN_Impulse", "q_atoi", input.inImpulse, 0, 0, 0, 0, 0)

  resetInput()
  input.inAttack[2] = 7
  stateBefore = input.inAttack[2]
  keyValue = input.CL_KeyState(input.inAttack)
  emit("CL_KeyState", "both_edges", stateBefore, 0, keyValue, input.inAttack[2], 0, 0)

  resetInput()
  input.inAttack[2] = 0
  key0 = input.CL_KeyState(input.inAttack)
  input.inAttack[2] = 1
  key1 = input.CL_KeyState(input.inAttack)
  input.inAttack[2] = 3
  key3 = input.CL_KeyState(input.inAttack)
  input.inAttack[2] = 6
  key6 = input.CL_KeyState(input.inAttack)
  emit("CL_KeyState", "state_matrix", 0, 0, key0, key1, key3, key6)

  resetInput()
  command = input.createCommand()
  command.viewAngles = t.Vec3(0, 10, 70)
  input.inSpeed[2] = 1
  input.inRight[2] = 1
  input.inLookup[2] = 3
  input.CL_AdjustAngles(command, 0.1, 140, 150, 1.5)
  requests = input.consumePitchDriftRequests()
  emit("CL_AdjustAngles", "speed_turn_look", intBool(requests[0]), 0, command.viewAngles.x, command.viewAngles.y, command.viewAngles.z, input.inLookup[2])

  resetInput()
  command = input.createCommand()
  input.inStrafe[2] = 1
  input.inRight[2] = 1
  input.inMoveright[2] = 3
  input.inUp[2] = 1
  input.inForward[2] = 1
  input.inSpeed[2] = 1
  input.CL_BaseMove(command, c.SIGNONS, 0.1, 200, 200, 350, 200, 2, 140, 150, 1.5)
  emit("CL_BaseMove", "strafe_speed", input.inRight[2], input.inMoveright[2], command.forwardMove, command.sideMove, command.upMove, command.viewAngles.y)

  resetInput()
  command = input.createCommand()
  command.forwardMove = 9
  command.sideMove = 8
  command.upMove = 7
  input.CL_BaseMove(command, 2, 0.1, 200, 200, 350, 200, 2, 140, 150, 1.5)
  emit("CL_BaseMove", "unsigned", 0, 0, command.forwardMove, command.sideMove, command.upMove, 0)

  resetInput()
  connection = connectedClient()
  localClient = connection[0]
  network = connection[1]
  command = t.UserCommand(t.Vec3(10, 20, 30), 123.75, -45.5, 7.9, 0, 0, 0)
  localClient.serverTime = 12.5
  input.inAttack[2] = 3
  input.inJump[2] = 3
  input.IN_Impulse(7)
  input.CL_FinishMove(command)
  client.CL_SetMoveMessageCount(2)
  result = client.CL_SendMove(localClient, command)
  packet = network.server.messages[0]
  emit("CL_SendMove", "wire", intBool(result == 1), len(packet), dataChecksum(packet), input.inAttack[2], input.inJump[2], input.inImpulse)

  resetInput()
  connection = connectedClient()
  localClient = connection[0]
  network = connection[1]
  command = input.createCommand()
  client.CL_SetMoveMessageCount(0)
  client.CL_SendMove(localClient, command)
  client.CL_SendMove(localClient, command)
  emit("CL_SendMove", "stale", len(network.server.messages), client.CL_MoveMessageCount(), 0, 0, 0, 0)

  resetInput()
  connection = connectedClient()
  localClient = connection[0]
  network = connection[1]
  network.server.messages = [bytes(8180)]
  network.server.messageTypes = [2]
  client.CL_SetMoveMessageCount(2)
  result = client.CL_SendMove(localClient, input.createCommand())
  emit("CL_SendMove", "backpressure", intBool(result == 0), intBool(not localClient.connected), client.CL_MoveMessageCount(), 0, 0, 0)

  resetInput()
  connection = connectedClient()
  localClient = connection[0]
  // Exercise a real driver send failure while the qsocket is still tracked.
  // Marking the qsocket itself disconnected would model a socket that has
  // already been freed, which is not the CL_SendMove failure contract.
  localClient.socket.peer = void
  client.CL_SetMoveMessageCount(2)
  command = input.createCommand()
  result = client.CL_SendMove(localClient, command)
  emit("CL_SendMove", "lost", intBool(result == -1), intBool(not localClient.connected), client.CL_MoveMessageCount(), 0, 0, 0)

  resetInput()
  connection = connectedClient()
  localClient = connection[0]
  network = connection[1]
  localClient.demoPlayback = true
  input.inAttack[2] = 3
  input.IN_Impulse(9)
  command = input.createCommand()
  input.CL_FinishMove(command)
  client.CL_SetMoveMessageCount(0)
  client.CL_SendMove(localClient, command)
  emit("CL_SendMove", "demo", len(network.server.messages), client.CL_MoveMessageCount(), input.inAttack[2], input.inImpulse, 0, 0)

  names = input.CL_InitInput()
  emit("CL_InitInput", "register", len(names), registeredChecksum(names), 0, 0, 0, 0)
  return 0
end function
