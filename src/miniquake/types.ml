package miniquake.types

struct Vec3
  x
  y
  z
end struct

struct Plane
  normal
  dist
  type
  signBits
end struct

struct SizeBuffer
  data
  maxSize
  curSize
  allowOverflow
  overflowed
end struct

struct MessageReader
  data
  readCount
  badRead
end struct

struct Cvar
  name
  string
  value
  archive
  server
end struct

struct CvarRegistry
  variables
end struct

struct CommandAlias
  name
  value
end struct

struct CommandSystem
  commands
  aliases
  arguments
  text
  wait
end struct

struct PackFile
  name
  offset
  length
end struct

struct PackArchive
  filename
  data
  files
  numFiles
end struct

struct WadLump
  filePosition
  diskSize
  size
  type
  compression
  name
end struct

struct WadArchive
  filename
  data
  lumps
  numLumps
end struct

struct LoopSocket
  peer
  messages
  messageTypes
  canSend
  disconnected
end struct

struct LoopState
  client
  server
  pending
end struct

struct MemoryBlock
  kind
  name
  data
  size
  alive
  allocationIndex
end struct

struct MemoryState
  capacity
  blocks
  totalAllocated
end struct

struct CacheUser
  block
end struct

struct Hull
  mins
  maxs
end struct

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

struct EntityPair
  key
  value
end struct

struct Entity
  pairs
end struct

struct Lump
  offset
  length
end struct

struct BspPlane
  normal
  dist
  type
end struct

struct BspVertex
  position
end struct

struct BspEdge
  vertex0
  vertex1
end struct

struct BspNode
  planeIndex
  child0
  child1
  mins
  maxs
  firstFace
  numFaces
end struct

struct BspClipNode
  planeIndex
  child0
  child1
end struct

struct BspTexInfo
  s
  t
  textureIndex
  flags
end struct

struct BspFace
  planeIndex
  side
  firstEdge
  numEdges
  texInfo
  styles
  lightOffset
end struct

struct BspLeaf
  contents
  visibilityOffset
  mins
  maxs
  firstMarkSurface
  numMarkSurfaces
  ambient
end struct

struct BspModel
  mins
  maxs
  origin
  headNodes
  visibleLeafs
  firstFace
  numFaces
end struct

struct BspTexture
  name
  width
  height
  mipOffsets
  pixels
end struct

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

struct MdlSkin
  grouped
  intervals
  images
end struct

struct MdlTexCoord
  onSeam
  s
  t
end struct

struct MdlTriangle
  facesFront
  vertex0
  vertex1
  vertex2
end struct

struct MdlVertex
  x
  y
  z
  normalIndex
end struct

struct MdlFrame
  name
  mins
  maxs
  vertices
end struct

struct MdlFrameSet
  grouped
  intervals
  frames
end struct

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

struct SpriteFrame
  originX
  originY
  width
  height
  pixels
end struct

struct SpriteFrameSet
  grouped
  intervals
  frames
end struct

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

struct QuakeCStatement
  op
  a
  b
  c
end struct

struct QuakeCDef
  type
  offset
  nameOffset
  name
end struct

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

struct QuakeCCallFrame
  statement
  functionIndex
  savedLocals
end struct

struct QuakeCMachine
  program
  globals
  callStack
  currentFunction
  statement
  returnWord
  edicts
  builtins
  runaway
  context
  edictFree
  dynamicStrings
  randomSeed
end struct

struct WaveInfo
  rate
  width
  channels
  samples
  loopStart
  dataOffset
  dataLength
end struct

struct DemoMessage
  viewAngles
  payload
end struct

struct Demo
  forcedTrack
  messages
end struct

struct ProtocolEvent
  command
  payload
end struct

struct ProtocolResult
  events
  bytesRead
end struct

struct SearchPath
  directory
  archive
end struct

struct FileSystem
  baseDirectory
  gameDirectory
  searchPaths
end struct

struct ModelRegistry
  names
  models
end struct

struct UserCommand
  viewAngles
  forwardMove
  sideMove
  upMove
  buttons
  impulse
  msec
end struct

struct ChaseState
  active
  back
  up
  right
end struct


struct ClientState
  protocol
  time
  viewEntity
  viewAngles
  entities
  stats
  messages
end struct

struct ServerState
  active
  time
  mapName
  clients
  entities
  reliableDatagram
end struct

struct Particle
  origin
  velocity
  die
  color
  ramp
  type
end struct

struct TemporaryEntity
  type
  origin
  endPosition
  entity
end struct

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

struct HostTiming
  realtime
  oldRealtime
  frameTime
  frameCount
  filteredFrames
end struct

struct EntityBaseline
  modelIndex
  frame
  colormap
  skin
  origin
  angles
end struct

struct QuakeEdict
  number
  free
  freeTime
  fields
  keyValues
  className
  model
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
end struct

struct ServerClient
  active
  spawned
  sendSignon
  signonStage
  name
  colors
  edictIndex
  socket
  message
  spawnParms
  command
end struct

struct GameServer
  active
  loading
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
  diagnostics
end struct

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
  player
  lastMessageTime
  command
  localAuthoritative
end struct

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

struct BspCollisionHull
  map
  clipNodes
  planes
  firstClipNode
  lastClipNode
  clipMins
  clipMaxs
end struct

struct RenderVertex
  position
  s
  t
  lightS
  lightT
end struct

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

struct RenderTexture
  name
  width
  height
  glId
  pixels
  transparent
end struct

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

struct GameValidation
  ok
  messages
  packFiles
  mapFaces
  mapTextures
  mapEntities
  progsFunctions
end struct

struct LightmapPage
  glId
  pixels
  allocated
  dirty
end struct

struct EdictRuntime
  maxEdicts
  numEdicts
  freeFlags
  freeTimes
end struct

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
end struct

struct DynamicLight
  origin
  radius
  die
  decay
  minLight
  key
end struct

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
end struct

struct SoundEffect
  name
  samples
  rate
  width
  channels
  loopStart
end struct

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
end struct

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
end struct

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
end struct

struct MenuPicture
  name
  width
  height
  textureId
end struct

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
end struct

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
end struct

struct AliasGpuModel
  source
  textureIds
  uploaded
end struct

struct SpriteGpuModel
  source
  textureIds
  uploaded
end struct


struct ClientRenderModel
  name
  kind
  aliasModel
  spriteModel
  textureIds
  uploaded
end struct

struct EntityRenderer
  filesystem
  palette
  models
  renderedEntities
end struct

struct UdpSocket
  handle
  port
  address
  open
end struct

struct HostSoakResult
  frames
  liveBefore
  liveAfter
  bytesBefore
  bytesAfter
  stable
end struct


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

struct DemoPlayback
  recording
  client
  index
  eventCount
  payloadBytes
  complete
  errors
end struct

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

struct DatagramPacket
  flags
  sequence
  payload
end struct

struct DatagramChannel
  sendSequence
  receiveSequence
  unreliableSendSequence
  unreliableReceiveSequence
  droppedUnreliable
end struct
