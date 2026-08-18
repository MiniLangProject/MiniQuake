/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/cl_input_production_tests.ml.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.input as input
import miniquake.client as client
import miniquake.net_loop as netloop
import miniquake.net_main as netmain
import miniquake.sizebuf as sz
import miniquake.message as msg

// Assert that the condition holds and identify a failing test.
function require(value, name)
  if not value then return error(9880, name) end if
  return true
end function

// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(9881, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Create and initialize without devices.
function buildWithoutDevices(command, signon, noclip)
  return input.buildOriginalMove(
    command, signon, 20.0,
    3.0, 0.022, 0.022, false,
    200.0, 200.0, 350.0, 200.0,
    noclip, false, false, false,
  )
end function

// Verify demo consumes without network against the expected Quake behavior.
function testDemoConsumesWithoutNetwork()
  input.IN_ClearStates()
  demoClient = client.create(void)
  demoClient.demoPlayback = true
  demoClient.spawned = true
  demoClient.signon = c.SIGNONS
  msg.writeByte(demoClient.outgoing, c.CLC_NOP)
  input.inForward[2] = 1
  input.inAttack[2] = 3
  input.inJump[2] = 3
  input.IN_Impulse(9)
  command = input.createCommand()
  command.viewAngles = t.Vec3(11.0, 22.0, 33.0)
  buildWithoutDevices(command, demoClient.signon, false)
  equal(command.forwardMove, 200.0, "demo held forward")
  equal(command.buttons, c.BUTTON_ATTACK | c.BUTTON_JUMP, "demo button bits")
  equal(command.impulse, 9, "demo impulse snapshot")
  equal(input.inAttack[2], 1, "demo attack edge consumed")
  equal(input.inJump[2], 1, "demo jump edge consumed")
  equal(input.inImpulse, 0, "demo impulse consumed")
  client.CL_SetMoveMessageCount(7)
  snapshotIdentity = nativeRawValue(demoClient.command.viewAngles)
  equal(client.CL_SendCmd(demoClient, command), 0, "demo send command skips network")
  equal(client.CL_MoveMessageCount(), 7, "demo does not advance movemessages")
  equal(demoClient.outgoing.curSize, 0, "demo clears reliable buffer")
  equal(demoClient.command.forwardMove, 200.0, "demo command snapshot")
  equal(nativeRawValue(demoClient.command.viewAngles), snapshotIdentity, "demo view snapshot vector reused")
  command.viewAngles.x = 99.0
  equal(demoClient.command.viewAngles.x, 11.0, "demo view snapshot remains independent")
  return true
end function

// Verify ui destination still builds move against the expected Quake behavior.
function testUiDestinationStillBuildsMove()
  input.IN_ClearStates()
  network = netloop.createState()
  wireClient = netloop.Loop_Connect(network, "local")
  wireServer = netloop.Loop_CheckNewConnections(network)
  remoteClient = client.create(void)
  remoteClient.connected = true
  remoteClient.spawned = true
  remoteClient.signon = c.SIGNONS
  remoteClient.socket = wireClient
  remoteClient.serverTime = 2.0
  input.inForward[2] = 1
  input.inAttack[2] = 3
  input.IN_Impulse(4)
  command = input.createCommand()
  // pollButtonBindings=false is the console/menu path: do not turn typed keys
  // into bindings, but preserve/consume kbutton_t state exactly as CL_BaseMove
  // and CL_SendMove do every connected frame.
  buildWithoutDevices(command, remoteClient.signon, false)
  client.CL_SetMoveMessageCount(2)
  equal(client.CL_SendCmd(remoteClient, command), 0, "UI destination empty reliable result")
  equal(command.forwardMove, 200.0, "held move survives UI destination")
  equal(input.inAttack[2], 1, "UI destination attack edge consumed")
  equal(input.inImpulse, 0, "UI destination impulse consumed")
  incoming = sz.alloc(c.MAX_MSGLEN)
  equal(netmain.NET_GetMessage(wireServer, incoming, 300.0), 2, "UI destination movement wire type")
  reader = msg.beginReading(incoming)
  equal(msg.readByte(reader), c.CLC_MOVE, "UI destination movement opcode")
  netloop.Loop_Close(wireClient)
  return true
end function

// Verify noclip strafe vertical mouse against the expected Quake behavior.
function testNoclipStrafeVerticalMouse()
  input.IN_ClearStates()
  input.inStrafe[2] = 1
  command = input.createCommand()
  input.IN_MoveDelta(command, 0.0, 10.0, 1.0, 0.022, 0.022, 0.8, 1.0, false, true)
  equal(command.forwardMove, 0.0, "noclip strafe leaves forward")
  equal(command.upMove, -10.0, "noclip strafe maps mouse Y to upmove")
  return true
end function

// Verify backward move keeps signed wire value against the expected Quake behavior.
function testBackwardMoveKeepsSignedWireValue()
  input.IN_ClearStates()
  input.inBack[2] = 1
  command = input.createCommand()
  buildWithoutDevices(command, c.SIGNONS, false)
  equal(command.forwardMove, -200.0, "held back command")

  network = netloop.createState()
  wireClient = netloop.Loop_Connect(network, "local")
  wireServer = netloop.Loop_CheckNewConnections(network)
  localClient = client.create(void)
  localClient.connected = true
  localClient.spawned = true
  localClient.signon = c.SIGNONS
  localClient.socket = wireClient
  client.CL_SetMoveMessageCount(2)
  equal(client.CL_SendMove(localClient, command), 1, "backward move sent")

  incoming = sz.alloc(c.MAX_MSGLEN)
  equal(netmain.NET_GetMessage(wireServer, incoming, 300.0), 2, "backward wire type")
  reader = msg.beginReading(incoming)
  equal(msg.readByte(reader), c.CLC_MOVE, "backward move opcode")
  msg.readFloat(reader)
  msg.readAngle(reader); msg.readAngle(reader); msg.readAngle(reader)
  equal(msg.readShort(reader), -200, "backward signed wire value")
  netloop.Loop_Close(wireClient)
  input.IN_ClearStates()
  return true
end function

// Verify gameplay transition consumes queued actions against the expected Quake behavior.
function testGameplayTransitionConsumesQueuedActions()
  input.IN_ClearStates()
  input.IN_AttackDown(200)
  input.IN_JumpDown(32)
  input.IN_Impulse(7)
  input.IN_BlockGameplayTransition()
  require(input.IN_GameplayTransitionBlocked(), "transition latch armed")
  equal(input.inAttack[2], 0, "transition clears attack")
  equal(input.inJump[2], 0, "transition clears jump")
  equal(input.inImpulse, 0, "transition clears impulse")
  require(input.IN_ReleaseGameplayTransitionIfNeutral(), "neutral transition release")
  require(not input.IN_GameplayTransitionBlocked(), "transition latch released")
  return true
end function

// Verify gameplay transition ignores new movement against the expected Quake behavior.
function testGameplayTransitionIgnoresNewMovement()
  input.IN_ClearStates()
  input.setBindingCode(203, "+forward")
  input.setBindingCode(204, "+back")
  axes = [32768, 32768, 32768, 32768, 32768, 32768]
  input.setJoystickSnapshot(axes, 1, 65535, 2, false)
  input.IN_Commands()
  input.IN_BlockGameplayTransition()
  require(input.IN_GameplayTransitionControlHeld(), "captured forward control holds transition")

  // Back is pressed only after the transition began. Once the originally held
  // forward control is released, this new movement must not keep input blocked.
  input.updateJoystickSnapshot(axes, 3, 65535)
  input.IN_Commands()
  require(input.IN_GameplayTransitionControlHeld(), "original control remains held")
  input.updateJoystickSnapshot(axes, 2, 65535)
  input.IN_Commands()
  require(not input.IN_GameplayTransitionControlHeld(), "new back input does not extend transition")
  require(input.IN_ReleaseGameplayTransitionIfNeutral(), "transition releases with new movement held")
  input.clearJoystickSnapshot()
  input.IN_ClearStates()
  return true
end function

// Verify that a menu key whose release is lost during synchronous loading
// cannot leave every gameplay control behind the transition latch forever.
function testGameplayTransitionDropsStaleMenuEvent()
  input.IN_ClearStates()
  previous = input.commandForKey("ENTER")
  input.bindKey("ENTER", "+jump")
  input.setEventKeyState(13, true)
  input.IN_BlockGameplayTransition()
  require(input.IN_GameplayTransitionBlocked(), "stale menu transition armed")
  require(not input.IN_GameplayTransitionControlHeld(), "stale event is not a physical hold")
  require(input.IN_ReleaseGameplayTransitionIfNeutral(), "stale menu transition releases")
  command = input.createCommand()
  buildWithoutDevices(command, c.SIGNONS, false)
  equal(command.buttons & c.BUTTON_JUMP, 0, "stale menu jump does not enter game")
  if previous == "" then input.unbindKey("ENTER") else input.bindKey("ENTER", previous) end if
  input.IN_ClearStates()
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  result = try(testDemoConsumesWithoutNetwork())
  if result is error then print "FAIL demo input consumption: " + result.message; return 1 end if
  print "[1/7] demo command snapshot / edge consumption"
  result = try(testUiDestinationStillBuildsMove())
  if result is error then print "FAIL UI input consumption: " + result.message; return 1 end if
  print "[2/7] console/menu held move / edge consumption"
  result = try(testNoclipStrafeVerticalMouse())
  if result is error then print "FAIL noclip mouse branch: " + result.message; return 1 end if
  print "[3/7] noclip strafe vertical mouse"
  result = try(testBackwardMoveKeepsSignedWireValue())
  if result is error then print "FAIL backward input/wire path: " + result.message; return 1 end if
  print "[4/7] backward input / signed Protocol 15 move"
  result = try(testGameplayTransitionConsumesQueuedActions())
  if result is error then print "FAIL gameplay-transition input gate: " + result.message; return 1 end if
  print "[5/7] menu/map transition input gate"
  result = try(testGameplayTransitionIgnoresNewMovement())
  if result is error then print "FAIL gameplay-transition movement snapshot: " + result.message; return 1 end if
  print "[6/7] post-transition movement cannot extend input gate"
  result = try(testGameplayTransitionDropsStaleMenuEvent())
  if result is error then print "FAIL stale menu-transition event: " + result.message; return 1 end if
  print "[7/7] stale menu key cannot retain transition gate"
  print "CL_INPUT PRODUCTION TESTS PASSED (7/7)"
  return 0
end function
