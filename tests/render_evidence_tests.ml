/* BP-048: deterministic framebuffer evidence and TGA contract. */
import miniquake.render_evidence as evidence
import miniquake.screen as screen

function bp048Equal(actual, expected, name)
  if actual != expected then return error(4800, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
function bp048Yes(value, name)
  if not value then return error(4801, name + ": expected true") end if
  return true
end function
function bp048Run(number, name, fn)
  print "[" + number + "/18] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function
function fixturePixels()
  return bytes([
    0, 0, 0, 255,
    255, 0, 0, 255,
    0, 255, 0, 255,
    0, 0, 255, 255,
  ])
end function
function bp048EmptyHash()
  bp048Equal(evidence.hashBytes(bytes()), 2166136261, "empty FNV")
  return true
end function
function bp048KnownHash()
  bp048Equal(evidence.hashBytes(bytes("123456789")), 3146166556, "known FNV")
  return true
end function
function bp048PixelHash()
  bp048Equal(evidence.hashBytes(fixturePixels()), evidence.hashBytes(fixturePixels()), "pixel hash stable")
  return true
end function
function bp048PixelMutation()
  first = fixturePixels()
  second = fixturePixels()
  second[4] = 254
  bp048Yes(evidence.hashBytes(first) != evidence.hashBytes(second), "pixel mutation")
  return true
end function
function bp048SampleStable()
  bp048Equal(evidence.samplePixelHash(fixturePixels(), 2, 2, 2), evidence.samplePixelHash(fixturePixels(), 2, 2, 2), "sample stable")
  return true
end function
function bp048SampleMutation()
  first = fixturePixels()
  second = fixturePixels()
  second[9] = 254
  bp048Yes(evidence.samplePixelHash(first, 2, 2, 2) != evidence.samplePixelHash(second, 2, 2, 2), "sample mutation")
  return true
end function
function bp048BlackCount()
  bp048Equal(evidence.nonBlackPixels(bytes([0,0,0,255,0,0,0,0])), 0, "black count")
  return true
end function
function bp048ColorCount()
  bp048Equal(evidence.nonBlackPixels(fixturePixels()), 3, "color count")
  return true
end function
function bp048TgaPath()
  bp048Equal(evidence.tgaPath("build/frame"), "build/frame.tga", "TGA path")
  return true
end function
function bp048SummaryPath()
  bp048Equal(evidence.summaryPath("build/frame"), "build/frame-summary.json", "summary path")
  return true
end function
function bp048Configure()
  evidence.reset()
  configured = try(evidence.configure("build/frame", 7))
  if configured is error then return configured end if
  bp048Yes(evidence.shouldCapture(7), "capture target")
  return true
end function
function bp048BeforeTarget()
  evidence.reset()
  configured = try(evidence.configure("build/frame", 7))
  if configured is error then return configured end if
  bp048Equal(evidence.shouldCapture(6), false, "before target")
  return true
end function
function bp048Reset()
  evidence.reset()
  bp048Equal(evidence.shouldCapture(999), false, "reset")
  return true
end function
function bp048InvalidFrame()
  result = try(evidence.configure("build/frame", 0))
  bp048Equal(typeof(result), "error", "invalid frame")
  return true
end function
function bp048SummarySchema()
  text = evidence.summaryJson(7, 2, 2, 16, 30, 1, 2, 3, 3, "frame.tga")
  encoded = bytes(text)
  bp048Yes(len(encoded) >= 4, "summary JSON length")
  bp048Equal(encoded[0], 123, "summary object open")
  bp048Equal(encoded[1], 34, "summary first quote")
  bp048Equal(encoded[len(encoded) - 2], 125, "summary object close")
  bp048Equal(encoded[len(encoded) - 1], 10, "summary newline")
  return true
end function
function bp048TgaLength()
  tga = try(screen.BuildTga(2, 2, fixturePixels()))
  if tga is error then return tga end if
  bp048Equal(len(tga), 30, "TGA byte length")
  return true
end function
function bp048TgaHeader()
  tga = try(screen.BuildTga(2, 2, fixturePixels()))
  if tga is error then return tga end if
  bp048Equal(tga[2], 2, "TGA type")
  bp048Equal(tga[16], 24, "TGA depth")
  return true
end function
function bp048GridConstant()
  bp048Equal(evidence.SAMPLE_GRID, 16, "sample grid")
  return true
end function

passed = 0
if bp048Run(1, "empty FNV", bp048EmptyHash) then passed = passed + 1 end if
if bp048Run(2, "known FNV", bp048KnownHash) then passed = passed + 1 end if
if bp048Run(3, "pixel hash stability", bp048PixelHash) then passed = passed + 1 end if
if bp048Run(4, "pixel hash mutation", bp048PixelMutation) then passed = passed + 1 end if
if bp048Run(5, "sample hash stability", bp048SampleStable) then passed = passed + 1 end if
if bp048Run(6, "sample hash mutation", bp048SampleMutation) then passed = passed + 1 end if
if bp048Run(7, "black pixel count", bp048BlackCount) then passed = passed + 1 end if
if bp048Run(8, "non-black pixel count", bp048ColorCount) then passed = passed + 1 end if
if bp048Run(9, "TGA path", bp048TgaPath) then passed = passed + 1 end if
if bp048Run(10, "summary path", bp048SummaryPath) then passed = passed + 1 end if
if bp048Run(11, "capture configure", bp048Configure) then passed = passed + 1 end if
if bp048Run(12, "before capture target", bp048BeforeTarget) then passed = passed + 1 end if
if bp048Run(13, "capture reset", bp048Reset) then passed = passed + 1 end if
if bp048Run(14, "invalid capture frame", bp048InvalidFrame) then passed = passed + 1 end if
if bp048Run(15, "summary schema", bp048SummarySchema) then passed = passed + 1 end if
if bp048Run(16, "TGA byte length", bp048TgaLength) then passed = passed + 1 end if
if bp048Run(17, "TGA header", bp048TgaHeader) then passed = passed + 1 end if
if bp048Run(18, "sample grid", bp048GridConstant) then passed = passed + 1 end if

if passed != 18 then
  print "MiniQuake BP-048 render evidence tests failed: " + passed + "/18"
  error(4899, "BP-048 render evidence")
end if
print "MiniQuake BP-048 render evidence tests passed: 18"
