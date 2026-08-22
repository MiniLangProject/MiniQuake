/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.types.
*/
package miniquake.types

// Store one three-dimensional vector in Quake world coordinates.
struct Vec3
  x
  y
  z
end struct

// Group the fields that describe one link.
struct Link
  previous
  next
end struct

// Group the fields that describe one common file handle.
struct CommonFileHandle
  data
  position
  length
  persistent
  closed
  source
end struct

// Group the fields that describe one plane.
struct Plane
  normal
  dist
  type
  signBits
end struct

// Track storage and runtime state for one size buffer.
struct SizeBuffer
  data
  maxSize
  curSize
  allowOverflow
  overflowed
end struct

// Group the fields that describe one message reader.
struct MessageReader
  data
  readCount
  badRead
end struct

// Group the fields that describe one cvar.
struct Cvar
  name
  string
  value
  archive
  server
end struct

// Own the coordinated data required by the cvar registry.
struct CvarRegistry
  variables
  serverChanges
  lookup
end struct

// Group the fields that describe one command alias.
struct CommandAlias
  name
  value
end struct

// Own the coordinated data required by the command system.
struct CommandSystem
  commands
  aliases
  arguments
  rawArgs
  text
  wait
end struct

// Group the fields that describe one pack file.
struct PackFile
  name
  offset
  length
end struct

// Store the parsed data and relationships for one pack archive.
struct PackArchive
  filename
  data
  files
  numFiles
end struct

// Group the fields that describe one WAD lump.
struct WadLump
  filePosition
  diskSize
  size
  type
  compression
  name
end struct

// Store the parsed data and relationships for one WAD archive.
struct WadArchive
  filename
  data
  lumps
  numLumps
end struct

// Track storage and runtime state for one loop socket.
struct LoopSocket
  peer
  messages
  messageTypes
  canSend
  disconnected
  transport
  udp
  address
  port
  channel
  lastReceiveTime
  connectTime
  lastSendTime
  driver
  landriver
end struct

// Track mutable loop state across subsystem calls.
struct LoopState
  client
  server
  pending
  listener
  pendingRemote
  hostName
  mapName
  currentPlayers
  maxPlayers
  remoteSockets
  hostCache
  banAddress
  banMask
  playerInfo
  serverRules
  lanEnabled
end struct

// Group the fields that describe one memory block.
struct MemoryBlock
  kind
  name
  data
  size
  alive
  allocationIndex
end struct

// Track mutable memory state across subsystem calls.
struct MemoryState
  capacity
  blocks
  totalAllocated
end struct

// Group the fields that describe one cache user.
struct CacheUser
  block
end struct

// Group the fields that describe one hull.
struct Hull
  mins
  maxs
end struct

// Group the fields that describe one trace.
struct Trace
  allSolid
  startSolid
  inOpen
  inWater
  fraction
  endPosition
  plane
  entity
end struct

// Group the fields that describe one entity pair.
struct EntityPair
  key
  value
end struct

// Group the fields that describe one entity.
struct Entity
  pairs
end struct

// Group the fields that describe one lump.
struct Lump
  offset
  length
end struct

// Describe one BSP plane consumed by the renderer or asset loader.
struct BspPlane
  normal
  dist
  type
end struct

// Describe one BSP vertex consumed by the renderer or asset loader.
struct BspVertex
  position
end struct

// Describe one BSP edge consumed by the renderer or asset loader.
struct BspEdge
  vertex0
  vertex1
end struct

// Group the fields that describe one BSP node.
struct BspNode
  planeIndex
  child0
  child1
  mins
  maxs
  firstFace
  numFaces
end struct

// Group the fields that describe one BSP clip node.
struct BspClipNode
  planeIndex
  child0
  child1
end struct

// Group the fields that describe one BSP tex info.
struct BspTexInfo
  s
  t
  textureIndex
  flags
end struct

// Describe one BSP face consumed by the renderer or asset loader.
struct BspFace
  planeIndex
  side
  firstEdge
  numEdges
  texInfo
  styles
  lightOffset
end struct

// Group the fields that describe one BSP leaf.
struct BspLeaf
  contents
  visibilityOffset
  mins
  maxs
  firstMarkSurface
  numMarkSurfaces
  ambient
end struct

// Store the parsed data and relationships for one BSP model.
struct BspModel
  mins
  maxs
  origin
  headNodes
  visibleLeafs
  firstFace
  numFaces
end struct

// Describe one BSP texture consumed by the renderer or asset loader.
struct BspTexture
  name
  width
  height
  mipOffsets
  pixels
end struct

// Store the parsed data and relationships for one BSP map.
struct BspMap
  filename
  data
  version
  lumps
  entityText
  entities
  planes
  textures
  vertices
  visibility
  nodes
  texInfo
  faces
  lighting
  clipNodes
  leafs
  markSurfaces
  edges
  surfEdges
  models
end struct

// Group the fields that describe one MDL skin.
struct MdlSkin
  grouped
  intervals
  images
end struct

// Group the fields that describe one MDL tex coord.
struct MdlTexCoord
  onSeam
  s
  t
end struct

// Group the fields that describe one MDL triangle.
struct MdlTriangle
  facesFront
  vertex0
  vertex1
  vertex2
end struct

// Describe one MDL vertex consumed by the renderer or asset loader.
struct MdlVertex
  x
  y
  z
  normalIndex
end struct

// Describe one runtime MDL frame and its observable Quake state.
struct MdlFrame
  name
  mins
  maxs
  vertices
end struct

// Group the fields that describe one MDL frame set.
struct MdlFrameSet
  grouped
  intervals
  frames
end struct

// Store the parsed data and relationships for one MDL model.
struct MdlModel
  filename
  data
  version
  scale
  scaleOrigin
  boundingRadius
  eyePosition
  numSkins
  skinWidth
  skinHeight
  numVertices
  numTriangles
  numFrames
  syncType
  flags
  size
  skins
  texCoords
  triangles
  frames
end struct

// Describe one runtime sprite frame and its observable Quake state.
struct SpriteFrame
  originX
  originY
  width
  height
  pixels
end struct

// Group the fields that describe one sprite frame set.
struct SpriteFrameSet
  grouped
  intervals
  frames
end struct

// Store the parsed data and relationships for one sprite model.
struct SpriteModel
  filename
  data
  version
  type
  boundingRadius
  width
  height
  numFrames
  beamLength
  syncType
  frames
end struct

// Group the fields that describe one QuakeC statement.
struct QuakeCStatement
  op
  a
  b
  c
end struct

// Group the fields that describe one QuakeC def.
struct QuakeCDef
  type
  offset
  nameOffset
  name
end struct

// Group the fields that describe one QuakeC function.
struct QuakeCFunction
  firstStatement
  parmStart
  locals
  profile
  name
  file
  numParms
  parmSize
end struct

// Store the parsed data and relationships for one QuakeC program.
struct QuakeCProgram
  filename
  data
  version
  crc
  statements
  globalDefs
  fieldDefs
  functions
  strings
  globals
  entityFields
end struct

// Describe one runtime QuakeC call frame and its observable Quake state.
struct QuakeCCallFrame
  statement
  functionIndex
  savedLocals
end struct

// Group the fields that describe one QuakeC machine.
struct QuakeCMachine
  program
  globals
  callStack
  currentFunction
  statement
  returnWord
  argCount
  edicts
  builtins
  runaway
  context
  edictFree
  dynamicStrings
  temporaryString
  randomSeed
  trace
  fastStatements
  fastFunctions
  fastLocalBases
  fastLocalCounts
  fastSavedLocals
  fastDepth
  fastLocalDepth
  fastExecutionDepth
end struct

// Group the fields that describe one wave info.
struct WaveInfo
  rate
  width
  channels
  samples
  loopStart
  dataOffset
  dataLength
end struct

// Group the fields that describe one demo message.
struct DemoMessage
  viewAngles
  payload
end struct

// Group the fields that describe one demo.
struct Demo
  forcedTrack
  messages
  trackHeader
end struct

// Group the fields that describe one save game.
struct SaveGame
  version
  comment
  spawnParms
  skill
  mapName
  time
  lightStyles
  globalState
  entities
end struct

// Group the fields that describe one protocol event.
struct ProtocolEvent
  command
  payload
end struct

// Collect the outcome and diagnostics for one protocol result.
struct ProtocolResult
  events
  bytesRead
end struct

// Canonical input record for the stock Protocol-15 svc_clientdata writer.
// Keeping the wire state separate from PlayerState makes the C field ordering
// and mission-pack active-weapon rule directly testable.
struct ProtocolClientData
  viewHeight
  idealPitch
  punch
  velocity
  flags
  waterLevel
  weaponFrame
  armor
  weaponModel
  health
  currentAmmo
  shells
  nails
  rockets
  cells
  items
  activeWeapon
  standardQuake
end struct

// Group the fields that describe one search path.
struct SearchPath
  directory
  archive
end struct

// Own the coordinated data required by the file system.
struct FileSystem
  baseDirectory
  gameDirectory
  searchPaths
  cacheDirectory
  modified
  registered
  staticRegistered
  progsHack
end struct

// Own the coordinated data required by the model registry.
struct ModelRegistry
  names
  models
  needLoad
  types
  touched
  noVis
end struct

// Group the fields that describe one user command.
struct UserCommand
  viewAngles
  forwardMove
  sideMove
  upMove
  buttons
  impulse
  msec
end struct

// Track mutable chase state across subsystem calls.
struct ChaseState
  active
  back
  up
  right
end struct


// Track mutable client state across subsystem calls.
struct ClientState
  protocol
  time
  viewEntity
  viewAngles
  entities
  stats
  messages
end struct

// Track mutable server state across subsystem calls.
struct ServerState
  active
  time
  mapName
  clients
  entities
  reliableDatagram
end struct

// Group the fields that describe one particle.
struct Particle
  origin
  velocity
  die
  color
  ramp
  type
end struct

// Describe one runtime temporary entity and its observable Quake state.
struct TemporaryEntity
  type
  origin
  endPosition
  entity
end struct

// Track mutable audio state across subsystem calls.
struct AudioState
  opened
  rate
  channels
  width
end struct

// -----------------------------------------------------------------------------
// Playable-engine milestone state.  The original lightweight structs above are
// kept for the format/protocol tools; these structs mirror the long-lived host,
// server, client, collision and renderer state used by the real game loop.
// -----------------------------------------------------------------------------

struct CommandLine
  args
  commandLine
  safeMode
  rogue
  hipnotic
  standardQuake
end struct

// Group the fields that describe one host timing.
struct HostTiming
  realtime
  oldRealtime
  frameTime
  frameCount
  filteredFrames
end struct

// Group the fields that describe one entity baseline.
struct EntityBaseline
  modelIndex
  frame
  colormap
  skin
  effects
  origin
  angles
end struct

// Describe one runtime quake edict and its observable Quake state.
struct QuakeEdict
  number
  free
  freeTime
  fields
  keyValues
  className
  model
  modelHandle
  modelIndex
  frame
  skin
  colormap
  effects
  origin
  angles
  velocity
  mins
  maxs
  moveType
  solid
  flags
  health
  viewOffset
  onGround
  groundEntity
  baseline
  leafNums
end struct

// Group the fields that describe one server client.
struct ServerClient
  active
  spawned
  sendSignon
  signonStage
  name
  colors
  privileged
  edictIndex
  socket
  message
  spawnParms
  command
  pingTimes
  numPings
  oldFrags
  lastMessage
  dropAsap
  playerState
  datagramBuffer
end struct

// Group the fields that describe one game server.
struct GameServer
  active
  loading
  loadGame
  paused
  time
  mapName
  modelName
  levelName
  worldModel
  progs
  machine
  edicts
  numEdicts
  maxEdicts
  clients
  maxClients
  modelPrecache
  soundPrecache
  lightStyles
  datagram
  reliableDatagram
  signon
  collisionHull
  spawnPoint
  spawnAngles
  skill
  deathmatch
  coop
  serverFlags
  cdTrack
  standardQuake
  randomSeed
  diagnostics
end struct

// Group the fields that describe one local client.
struct LocalClient
  connected
  signon
  spawned
  socket
  outgoing
  incoming
  protocol
  maxClients
  gameType
  levelName
  modelPrecache
  soundPrecache
  viewEntity
  serverTime
  messages
  printLog
  entities
  staticEntities
  player
  lastMessageTime
  command
  name
  colors
  localAuthoritative
  scores
  stats
  itemGetTime
  completedTime
  faceAnimTime
  items
  idealPitch
  time
  oldTime
  messageTimes
  velocitySamples
  viewAngleSamples
  spawnParms
  visibleEntities
  initialized
  demoPlayback
  timedemo
  noLerp
  lightStyles
  paused
  intermission
  intermissionText
  cdTrack
  loopTrack
  sellScreen
  standardQuake
end struct

// Group the fields that describe one client score.
struct ClientScore
  name
  enterTime
  frags
  colors
end struct

// Track mutable player state across subsystem calls.
struct PlayerState
  origin
  velocity
  viewAngles
  renderAngles
  mins
  maxs
  viewHeight
  onGround
  waterLevel
  moveType
  health
  armor
  ammo
  shells
  nails
  rockets
  cells
  items
  activeWeapon
  weaponFrame
  weapon
  noclip
  jumpHeld
  flags
  groundEntity
  waterType
  punchAngle
  fixAngle
  teleportTime
  moveDir
  oldOrigin
  deadFlag
end struct

// Store the parsed data and relationships for one BSP collision hull.
struct BspCollisionHull
  map
  clipNodes
  planes
  firstClipNode
  lastClipNode
  clipMins
  clipMaxs
end struct

// Describe one render vertex consumed by the renderer or asset loader.
struct RenderVertex
  position
  s
  t
  lightS
  lightT
end struct

// Describe one render surface consumed by the renderer or asset loader.
struct RenderSurface
  faceIndex
  textureIndex
  textureMins
  extents
  lightWidth
  lightHeight
  lightOffset
  flags
  vertices
  lightmapId
end struct

// Describe one render texture consumed by the renderer or asset loader.
struct RenderTexture
  name
  width
  height
  glId
  pixels
  transparent
end struct

// Group the fields that describe one world renderer.
struct WorldRenderer
  map
  palette
  textures
  surfaces
  lightmaps
  uploaded
  noTextureId
  fullbright
  wireframe
  viewLeaf
  visibleFaces
  frameCount
  waterAlpha
end struct

// Own the coordinated data required by the game session.
struct GameSession
  arguments
  filesystem
  commands
  cvars
  timing
  server
  client
  network
  player
  renderer
  entityRenderer
  running
  initialized
  windowCreated
  basedir
  gameDirectory
  startMap
  width
  height
  fullscreen
  headless
  maxFrames
  lastTicks
  consoleVisible
  statusMessage
  console
  menu
  view
  mixer
  particles
  temporaryEntities
  qcEnabled
  noSound
  audioStarted
  renderedFrames
  simulatedFrames
  demoName
  demoRecording
  demoPlayback
  timedemoActive
  timedemoStartFrame
  timedemoStartTime
  timedemoLastFrame
  lastRemoteHost
  demoLoop
  demoNumber
  hostTime
  shutdownStarted
  inError
  frameTrace
  profileTime
  profileCount
  diagnosticContextPath
  diagnosticFrame
  diagnosticLastStage
  diagnosticWriteError
end struct

// -----------------------------------------------------------------------------
// Integrated engine services added after the first compiler-stable milestone.
// These keep platform resources at the boundary while host/game state stays in
// MiniLang, matching the ownership split of WinQuake's common/host subsystems.
// -----------------------------------------------------------------------------

struct LaunchOptions
  originalArgs
  basedir
  gameDirectory
  width
  height
  fullscreen
  noSound
  developer
  dedicated
  skill
  startMap
  plusCommands
  maxFrames
  validateOnly
  headless
  timedemo
end struct

// Collect the outcome and diagnostics for one game validation.
struct GameValidation
  ok
  messages
  packFiles
  mapFaces
  mapTextures
  mapEntities
  progsFunctions
end struct

// Group the fields that describe one lightmap page.
struct LightmapPage
  glId
  pixels
  allocated
  dirty
end struct

// Own the coordinated data required by the edict runtime.
struct EdictRuntime
  maxEdicts
  numEdicts
  freeFlags
  freeTimes
end struct

// Own the coordinated data required by the QuakeC context.
struct QuakeCContext
  filesystem
  worldMap
  collisionHull
  cvars
  commands
  edicts
  modelPrecache
  soundPrecache
  lightStyles
  datagram
  reliableDatagram
  signon
  consoleLines
  staticEntities
  staticSounds
  soundEvents
  particles
  serverTime
  randomSeed
  changeLevel
  traceEntity
  server
  clientMessages
  clientSpawnParms
  lastCheckClient
  lastCheckTime
  checkPvs
end struct

// Describe one runtime dynamic light and its observable Quake state.
struct DynamicLight
  origin
  radius
  die
  decay
  minLight
  key
end struct

// Track mutable client entity state across subsystem calls.
struct ClientEntityState
  number
  modelIndex
  frame
  colormap
  skin
  effects
  origin
  angles
  messageTime
  messageOrigin
  previousMessageOrigin
  messageAngles
  previousMessageAngles
  forceLink
  baseline
  syncBase
end struct

// Group the fields that describe one sound effect.
struct SoundEffect
  name
  samples
  rate
  width
  channels
  loopStart
end struct

// Track storage and runtime state for one mixer channel.
struct MixerChannel
  entityNumber
  channelNumber
  effect
  origin
  volume
  attenuation
  sample
  looping
  active
  endTime
end struct

// Group the fields that describe one music track.
struct MusicTrack
  number
  source
  samples
  rate
  channels
  frames
  position
  looping
  playing
  paused
  sampleBase
  sampleFrames
end struct

// Group the fields that describe one sound mixer.
struct SoundMixer
  audioState
  filesystem
  effects
  channels
  sampleRate
  masterVolume
  listenerOrigin
  listenerForward
  listenerRight
  listenerEntity
  enabled
  underruns
  submittedBuffers
  music
  musicVolume
  paintedTime
  blockDepth
  staticAllocations
  playHash
  playVolumeHash
end struct

// Track mutable console state across subsystem calls.
struct ConsoleState
  lines
  maxLines
  inputText
  active
  notifyUntil
  textureId
  toggleLatch
  centerText
  centerUntil
  textBuffer
  lineWidth
  totalLines
  currentLine
  cursorX
  carriageReturn
  notifyTimes
  realtime
  visiblePixelLines
  forcedUp
  initialized
  notifyPixelLines
  debugLog
  debugLogName
  filesystem
  lineCount
  talkSoundRequested
  drawTrace
  updateRequested
  safePrintDepth
  notifyBoxText
  dedicated
end struct

// Group the fields that describe one menu picture.
struct MenuPicture
  name
  width
  height
  textureId
end struct

// Track mutable menu state across subsystem calls.
struct MenuState
  active
  selection
  items
  title
  pausedByMenu
  page
  previousPage
  helpPage
  pictures
  initialized
  statusText
  waitingForKey
  pageSelections
  drawTrace
  action
  setupHostname
  setupName
  setupTop
  setupBottom
  setupOldTop
  setupOldBottom
  lanPort
  lanPortText
  lanJoinName
  joiningGame
  tcpAvailable
  localAddress
  maxPlayers
  maxPlayersLimit
  startEpisode
  startLevel
  missionPack
  searchComplete
  searchCompleteTime
  servers
  serverListSorted
  returnReason
  enterSound
  excludedPaths
  videoDrawCallback
  videoKeyCallback
  loadable
end struct

// Track mutable view state across subsystem calls.
struct ViewState
  origin
  angles
  forward
  right
  up
  bob
  roll
  damageKick
  blend
  oldZ
  oldZValid
  gunOrigin
  gunAngles
  pitchVelocity
  noDrift
  driftMove
  lastStop
  damageTime
  damageRoll
  damagePitch
  cshifts
  previousCshifts
  gammaTable
  ramps
  oldGamma
  oldGunYaw
  oldGunPitch
  intermission
  viewModelVisible
  commandTrace
  lastInputPitch
  lastInputPitchValid
  emptyCshift
end struct

// Store the parsed data and relationships for one alias GPU model.
struct AliasGpuModel
  source
  textureIds
  uploaded
end struct

// Store the parsed data and relationships for one sprite GPU model.
struct SpriteGpuModel
  source
  textureIds
  uploaded
end struct


// Store the parsed data and relationships for one client render model.
struct ClientRenderModel
  name
  kind
  aliasModel
  spriteModel
  brushRenderer
  textureIds
  uploaded
end struct

// Group the fields that describe one entity renderer.
struct EntityRenderer
  filesystem
  palette
  models
  renderedEntities
end struct

// Track storage and runtime state for one UDP socket.
struct UdpSocket
  handle
  port
  address
  open
  bindAddress
  broadcast
end struct

// Group the fields that describe one WinSock address.
struct WinSockAddress
  family
  address
  port
end struct

// Collect the outcome and diagnostics for one host soak result.
struct HostSoakResult
  frames
  liveBefore
  liveAfter
  bytesBefore
  bytesAfter
  stable
end struct


// Collect the outcome and diagnostics for one UDP smoke result.
struct UdpSmokeResult
  ok
  senderPort
  receiverPort
  bytesSent
  bytesReceived
  payload
  remoteAddress
  remotePort
  errorCode
end struct

// Collect the outcome and diagnostics for one compatibility trace result.
struct CompatibilityTraceResult
  ok
  framesRequested
  framesWritten
  acceptedFrames
  rollingHash
  tracePath
  snapshotPath
  contextPath
  summaryPath
  lastStage
  errorMessage
  cleanShutdown
end struct

// Collect the outcome and diagnostics for one runtime validation.
struct RuntimeValidation
  ok
  messages
  mapName
  signon
  spawned
  edicts
  modelPrecache
  soundPrecache
  worldFaces
  renderSurfaces
  simulatedFrames
  traceFraction
  heapLiveBefore
  heapLiveAfter
  heapBytesBefore
  heapBytesAfter
  cleanShutdown
end struct

// Group the fields that describe one demo playback.
struct DemoPlayback
  recording
  client
  index
  eventCount
  payloadBytes
  complete
  errors
  timedemo
  startFrame
  startTime
  lastFrame
  stopped
  finishResult
end struct

// Collect the outcome and diagnostics for one demo verification.
struct DemoVerification
  ok
  messages
  eventCount
  payloadBytes
  signon
  serverTime
  viewEntity
  entities
  prints
end struct

// Group the fields that describe one datagram packet.
struct DatagramPacket
  flags
  sequence
  payload
end struct

// Track storage and runtime state for one datagram channel.
struct DatagramChannel
  sendSequence
  receiveSequence
  unreliableSendSequence
  unreliableReceiveSequence
  droppedUnreliable
  ackSequence
  sendMessage
  receiveMessage
  canSend
  sendNext
  lastSendTime
  packetsReSent
end struct

// MiniLang's native backend returns package-qualified concrete type names for
// packaged structs (for example "miniquake.types.Vec3"), while older
// backends and package-free fixtures may return the short name.  Accept both
// spellings so runtime type guards remain backend-independent.
function concreteTypeNameMatches(value, shortName, qualifiedName)
  kind = typeName(value)
  return kind == shortName or kind == qualifiedName
end function

// Report whether is vec3 value.
function isVec3Value(value)
  return concreteTypeNameMatches(value, "Vec3", "miniquake.types.Vec3")
end function

// Report whether is entity baseline value.
function isEntityBaselineValue(value)
  return concreteTypeNameMatches(
    value,
    "EntityBaseline",
    "miniquake.types.EntityBaseline",
  )
end function

// Report whether is quake edict value.
function isQuakeEdictValue(value)
  return concreteTypeNameMatches(
    value,
    "QuakeEdict",
    "miniquake.types.QuakeEdict",
  )
end function
