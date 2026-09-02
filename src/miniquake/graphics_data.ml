/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.graphics_data.
*/
package miniquake.graphics_data

import miniquake.filesystem as qfs
import miniquake.wad as wad

/// Read and validate console characters from wad.
/// @param filesystem The filesystem input consumed by `readConsoleCharactersFromWad`.
function readConsoleCharactersFromWad(filesystem)
  wadData = qfs.readFile(filesystem, "gfx.wad")
  archive = wad.parse(wadData, "gfx.wad")
  return wad.readLump(archive, "conchars")
end function

/// Stock Quake stores the console font as the "conchars" lump in gfx.wad.
/// Some repackaged data sets expose gfx/conchars.lmp directly; keep that path
/// only as a compatibility fallback.
/// @param filesystem The filesystem input consumed by `readConsoleCharacters`.
function readConsoleCharacters(filesystem)
  packed = try(readConsoleCharactersFromWad(filesystem))
  if packed is not error then return packed end if
  return qfs.readFile(filesystem, "gfx/conchars.lmp")
end function
