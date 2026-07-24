import miniquake.types as t
import miniquake.constants as c
import miniquake.input as input
import miniquake.client as client
import miniquake.net_loop as netloop
import miniquake.net_main as netmain
import miniquake.sizebuf as sz
import miniquake.message as msg

function require(value, name)
  if not value then return error(9880, name) end if
  return true
end function

function equal(actual, expected, name)
  if actual != expected then return error(9881, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function buildWithoutDevices(command, signon, noclip)
  return input.buildOriginalMove(
    command, signon, 20.0,
    3.0, 0.022, 0.022, false,
    200.0, 200.0, 350.0, 200.0,
    noclip, false, false, false,
  )
end function

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
  buildWithoutDevices(command, demoClient.signon, false)
  equal(command.forwardMove, 200.0, "demo held forward")
  equal(command.buttons, c.BUTTON_ATTACK | c.BUTTON_JUMP, "demo button bits")
  equal(command.impulse, 9, "demo impulse snapshot")
  equal(input.inAttack[2], 1, "demo attack edge consumed")
  equal(input.inJump[2], 1, "demo jump edge consumed")
  equal(input.inImpulse, 0, "demo impulse consumed")
  client.CL_SetMoveMessageCount(7)
  equal(client.CL_SendCmd(demoClient, command), 0, "demo send command skips network")
  equal(client.CL_MoveMessageCount(), 7, "demo does not advance movemessages")
  equal(demoClient.outgoing.curSize, 0, "demo clears reliable buffer")
  equal(demoClient.command.forwardMove, 200.0, "demo command snapshot")
  return true
end function

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

function testNoclipStrafeVerticalMouse()
  input.IN_ClearStates()
  input.inStrafe[2] = 1
  command = input.createCommand()
  input.IN_MoveDelta(command, 0.0, 10.0, 1.0, 0.022, 0.022, 0.8, 1.0, false, true)
  equal(command.forwardMove, 0.0, "noclip strafe leaves forward")
  equal(command.upMove, -10.0, "noclip strafe maps mouse Y to upmove")
  return true
end function

function main(args)
  result = try(testDemoConsumesWithoutNetwork())
  if result is error then print "FAIL demo input consumption: " + result.message; return 1 end if
  print "[1/3] demo command snapshot / edge consumption"
  result = try(testUiDestinationStillBuildsMove())
  if result is error then print "FAIL UI input consumption: " + result.message; return 1 end if
  print "[2/3] console/menu held move / edge consumption"
  result = try(testNoclipStrafeVerticalMouse())
  if result is error then print "FAIL noclip mouse branch: " + result.message; return 1 end if
  print "[3/3] noclip strafe vertical mouse"
  print "CL_INPUT PRODUCTION TESTS PASSED (3/3)"
  return 0
end function
