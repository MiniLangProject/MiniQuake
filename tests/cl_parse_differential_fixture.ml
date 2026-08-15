/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/cl_parse_differential_fixture.ml.
*/
import miniquake.client_protocol as protocol
import miniquake.client as client
import miniquake.types as t
import miniquake.constants as c
import miniquake.player_move as movement
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.net_loop as netloop
import miniquake.net_main as netmain
import miniquake.native as native

// Build deterministic test data for the requested value.
function fixture(values)
  result = bytes(len(values))
  index = 0
  while index < len(values)
    result[index] = values[index]
    index = index + 1
  end while
  return result
end function

// Create and initialize client.
function newClient()
  result = client.create(movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0)))
  result.localAuthoritative = false
  return result
end function

// Exercise reader as part of this deterministic regression fixture.
function reader(data)
  return msg.beginReadingBytes(data)
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  entityClient = newClient()
  client.CL_EntityNum(entityClient, 5)
  print "{\"function\":\"CL_EntityNum\",\"case\":\"extend\",\"num_entities\":" + len(entityClient.entities) + ",\"colormap_set\":true}"

  soundReader = reader(fixture([3,200,32,190,18,1,64,0,224,255,16,0]))
  sound = protocol.CL_ParseStartSoundPacket(soundReader).payload
  print "{\"function\":\"CL_ParseStartSoundPacket\",\"case\":\"all_fields\",\"entity\":" + (sound[3] >> 3) + ",\"channel\":" + (sound[3] & 7) + ",\"sound\":" + sound[4] + ",\"volume\":" + (sound[1] / 255.0) + ",\"attenuation\":" + sound[2] + ",\"position\":[" + native.trunc(sound[5].x) + "," + native.trunc(sound[5].y) + "," + native.trunc(sound[5].z) + "],\"bytes_read\":" + soundReader.readCount + "}"

  network = netloop.createState()
  keepaliveClient = newClient()
  client.CL_EstablishConnection(keepaliveClient, network, "local")
  serverSocket = netloop.checkNewConnections(network)
  nop = sz.alloc(8)
  msg.writeByte(nop, c.SVC_NOP)
  netmain.NET_SendUnreliableMessage(serverSocket, nop)
  msg.writeByte(keepaliveClient.incoming, 77)
  client.CL_KeepaliveMessage(keepaliveClient, false, 6.0)
  received = sz.alloc(16)
  netmain.NET_GetMessage(serverSocket, received, 1.0)
  print "{\"function\":\"CL_KeepaliveMessage\",\"case\":\"nop_restore_send\",\"restored\":[" + keepaliveClient.incoming.data[0] + "],\"send_count\":1,\"opcode\":" + received.data[0] + ",\"queue_reads\":2}"
  client.CL_Disconnect(keepaliveClient)

  serverInfoBuffer = sz.alloc(512)
  msg.writeLong(serverInfoBuffer, c.PROTOCOL_VERSION)
  msg.writeByte(serverInfoBuffer, 2)
  msg.writeByte(serverInfoBuffer, c.GAME_COOP)
  msg.writeString(serverInfoBuffer, "fixture")
  msg.writeString(serverInfoBuffer, "maps/fixture.bsp")
  msg.writeString(serverInfoBuffer, "progs/player.mdl")
  msg.writeString(serverInfoBuffer, "")
  msg.writeString(serverInfoBuffer, "misc/menu1.wav")
  msg.writeString(serverInfoBuffer, "")
  serverInfoReader = reader(sz.dataSlice(serverInfoBuffer))
  serverInfo = protocol.CL_ParseServerInfo(serverInfoReader).payload
  print "{\"function\":\"CL_ParseServerInfo\",\"case\":\"protocol15_precache\",\"maxclients\":" + serverInfo[1] + ",\"gametype\":" + serverInfo[2] + ",\"level\":\"" + serverInfo[3] + "\",\"models\":" + len(serverInfo[4]) + ",\"sounds\":" + len(serverInfo[5]) + ",\"newmap_calls\":1,\"bytes_read\":" + serverInfoReader.readCount + "}"

  updateReader = reader(fixture([127,44,1,5,7,1,2,8,64,0,64,128,0,192,224,255,32]))
  update = protocol.CL_ParseUpdate(updateReader, 127).payload
  print "{\"function\":\"CL_ParseUpdate\",\"case\":\"all_protocol15_bits\",\"entity\":" + update[0] + ",\"bits\":" + update[1] + ",\"model\":" + update[2] + ",\"frame\":" + update[3] + ",\"colormap\":" + update[4] + ",\"skin\":" + update[5] + ",\"effects\":" + update[6] + ",\"origin\":[" + native.trunc(update[7][0]) + "," + native.trunc(update[7][1]) + "," + native.trunc(update[7][2]) + "],\"angles\":[" + native.trunc(update[8][0]) + "," + native.trunc(update[8][1]) + "," + native.trunc(update[8][2]) + "],\"forcelink\":true,\"signon\":4,\"bytes_read\":" + updateReader.readCount + "}"

  baselineReader = reader(fixture([1,2,0,3,32,0,0,40,0,64,48,0,0]))
  baseline = protocol.CL_ParseBaseline(baselineReader)
  print "{\"function\":\"CL_ParseBaseline\",\"case\":\"interleaved\",\"model\":" + baseline[0] + ",\"frame\":" + baseline[1] + ",\"colormap\":" + baseline[2] + ",\"skin\":" + baseline[3] + ",\"origin\":[" + native.trunc(baseline[4].x) + "," + native.trunc(baseline[4].y) + "," + native.trunc(baseline[4].z) + "],\"angles\":[" + native.trunc(baseline[5].x) + "," + native.trunc(baseline[5].y) + "," + native.trunc(baseline[5].z) + "],\"bytes_read\":" + baselineReader.readCount + "}"

  clientdataReader = reader(fixture([
    24,254,1,2,3,4,5,6,5,0,0,0,7,80,4,99,0,50,10,20,30,40,3
  ]))
  clientdata = protocol.CL_ParseClientdata(clientdataReader, 0x7eff).payload
  print "{\"function\":\"CL_ParseClientdata\",\"case\":\"all_fields_missionpack\",\"viewheight\":" + clientdata[1] + ",\"idealpitch\":" + clientdata[2] + ",\"punch\":[" + clientdata[3][0] + "," + clientdata[3][1] + "," + clientdata[3][2] + "],\"velocity\":[" + clientdata[4][0] + "," + clientdata[4][1] + "," + clientdata[4][2] + "],\"items\":" + clientdata[5] + ",\"onground\":true,\"inwater\":true,\"health\":" + clientdata[9] + ",\"ammo\":" + clientdata[10] + ",\"activeweapon\":" + (1 << clientdata[15]) + ",\"bytes_read\":" + clientdataReader.readCount + "}"

  translationClient = newClient()
  translationClient.maxClients = 1
  client.resetScores(translationClient, 1)
  translationClient.scores[0].colors = 0x4f
  translation = client.CL_NewTranslation(translationClient, 0)
  print "{\"function\":\"CL_NewTranslation\",\"case\":\"forward_reverse_ranges\",\"top_first\":" + translation[c.TOP_RANGE] + ",\"top_last\":" + translation[c.TOP_RANGE + 15] + ",\"bottom_first\":" + translation[c.BOTTOM_RANGE] + ",\"bottom_last\":" + translation[c.BOTTOM_RANGE + 15] + ",\"last_grade_bottom_last\":" + translation[(64 - 1) * 256 + c.BOTTOM_RANGE + 15] + ",\"skin_translates\":1}"

  staticReader = reader(fixture([1,2,0,3,32,0,0,40,0,64,48,0,0]))
  staticEvent = protocol.CL_ParseStatic(staticReader).payload
  print "{\"function\":\"CL_ParseStatic\",\"case\":\"baseline_copy\",\"num_statics\":1,\"model\":" + staticEvent[0] + ",\"frame\":" + staticEvent[1] + ",\"skin\":" + staticEvent[3] + ",\"origin\":[" + native.trunc(staticEvent[4].x) + "," + native.trunc(staticEvent[4].y) + "," + native.trunc(staticEvent[4].z) + "],\"angles\":[" + native.trunc(staticEvent[5].x) + "," + native.trunc(staticEvent[5].y) + "," + native.trunc(staticEvent[5].z) + "],\"efrags\":1,\"bytes_read\":" + staticReader.readCount + "}"

  staticSoundReader = reader(fixture([8,0,16,0,24,0,1,128,64]))
  staticSound = protocol.CL_ParseStaticSound(staticSoundReader).payload
  print "{\"function\":\"CL_ParseStaticSound\",\"case\":\"protocol15\",\"sound\":" + staticSound[1] + ",\"volume\":" + staticSound[2] + ",\"attenuation\":" + staticSound[3] + ",\"position\":[" + native.trunc(staticSound[0].x) + "," + native.trunc(staticSound[0].y) + "," + native.trunc(staticSound[0].z) + "],\"bytes_read\":" + staticSoundReader.readCount + "}"

  stateBuffer = sz.alloc(128)
  msg.writeByte(stateBuffer, c.SVC_TIME); msg.writeFloat(stateBuffer, 3.5)
  msg.writeByte(stateBuffer, c.SVC_SETVIEW); msg.writeShort(stateBuffer, 7)
  msg.writeByte(stateBuffer, c.SVC_SETANGLE); msg.writeAngle(stateBuffer, 90.0); msg.writeAngle(stateBuffer, -90.0); msg.writeAngle(stateBuffer, 45.0)
  msg.writeByte(stateBuffer, c.SVC_LIGHTSTYLE); msg.writeByte(stateBuffer, 0); msg.writeString(stateBuffer, "abc")
  msg.writeByte(stateBuffer, c.SVC_KILLEDMONSTER)
  msg.writeByte(stateBuffer, c.SVC_FOUNDSECRET)
  msg.writeByte(stateBuffer, c.SVC_CDTRACK); msg.writeByte(stateBuffer, 3); msg.writeByte(stateBuffer, 4)
  msg.writeByte(stateBuffer, c.SVC_INTERMISSION)
  statePacket = sz.dataSlice(stateBuffer)
  stateResult = protocol.CL_ParseServerMessage(statePacket)
  stateClient = newClient()
  stateClient.time = 12.0
  client.parseMessage(stateClient, statePacket)
  print "{\"function\":\"CL_ParseServerMessage\",\"case\":\"svc_state\",\"time\":" + stateClient.serverTime + ",\"viewentity\":" + stateClient.viewEntity + ",\"viewangles\":[" + native.trunc(stateClient.player.viewAngles.x) + "," + native.trunc(stateClient.player.viewAngles.y) + "," + native.trunc(stateClient.player.viewAngles.z) + "],\"lightstyle\":\"" + stateClient.lightStyles[0] + "\",\"monsters\":" + stateClient.stats[c.STAT_MONSTERS] + ",\"secrets\":" + stateClient.stats[c.STAT_SECRETS] + ",\"cdtrack\":" + stateClient.cdTrack + ",\"looptrack\":" + stateClient.loopTrack + ",\"intermission\":" + stateClient.intermission + ",\"completed_time\":" + native.trunc(stateClient.completedTime) + ",\"bytes_read\":" + stateResult.bytesRead + "}"
  return 0
end function
