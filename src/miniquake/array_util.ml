/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.array_util.
*/
package miniquake.array_util

/*
  MiniLang arrays have a fixed length.  Repeatedly growing an array with
  `values = values + [item]` copies the complete prefix on every iteration,
  which turns binary-format parsing into O(n^2) allocation traffic.

  These helpers create exact-sized arrays in O(n) total copying and provide a
  geometrically growing builder for records whose final count is not known in
  advance.
*/

struct ArrayBuilder
  /// Stores the accumulated values in `miniquake.array_util.ArrayBuilder`.
  values
  /// Stores the count value in `miniquake.array_util.ArrayBuilder`.
  count
end struct

/// Create an array prefilled with one value.
/// @param count Number of entries or units to process.
/// @param value Value consumed by `makeFilledArray`.
function makeFilledArray(count, value)
  if count < 0 then return error(1180, "negative array size") end if
  // MiniLang now exposes exact-sized native array allocation.  Avoid the
  // historical chunk-concatenation fallback and allocate the final array once.
  return array(count, value)
end function

/// Create an exact-sized array initialized with void slots.
/// @param count Number of entries or units to process.
function makeEmptyArray(count)
  return makeFilledArray(count, void)
end function

/// Copy every source element into a new linear array.
/// @param source Source value or collection to read.
function copyArrayLinear(source)
  sourceCount = len(source)
  result = makeEmptyArray(sourceCount)
  // The destination is new and therefore cannot overlap the source.  Use the
  // native bulk copy instead of dispatching one MiniLang assignment per item.
  copyArray(result, 0, source, 0, sourceCount)
  return result
end function

/// Copy the requested source prefix into a new array.
/// @param source Source value or collection to read.
/// @param count Number of entries or units to process.
function copyArrayPrefix(source, count)
  if count < 0 or count > len(source) then return error(1181, "array prefix outside source") end if
  result = makeEmptyArray(count)
  // Keep the explicit bounds check above so callers retain the original
  // MiniQuake error instead of relying on copyArray's clamping behavior.
  copyArray(result, 0, source, 0, count)
  return result
end function

/// Ensure sufficient storage or state for array to.
/// @param source Source value or collection to read.
/// @param requiredCount Number of entries or units to process.
/// @param fillValue The fill value input consumed by `growArrayTo`.
function growArrayTo(source, requiredCount, fillValue)
  if requiredCount < 0 then return error(1182, "negative required array size") end if
  if len(source) >= requiredCount then return source end if

  capacity = len(source)
  if capacity < 1 then capacity = 1 end if
  while capacity < requiredCount
    capacity = capacity * 2
  end while

  result = makeFilledArray(capacity, fillValue)
  sourceCount = len(source)
  copyArray(result, 0, source, 0, sourceCount)
  return result
end function

/// Create and initialize array builder.
/// @param initialCapacity The initial capacity input consumed by `createArrayBuilder`.
function createArrayBuilder(initialCapacity)
  capacity = initialCapacity
  if capacity < 1 then capacity = 1 end if
  return ArrayBuilder(makeEmptyArray(capacity), 0)
end function

/// Add state for push array builder.
/// @param builder The builder input consumed by `pushArrayBuilder`.
/// @param value Value consumed by `pushArrayBuilder`.
function pushArrayBuilder(builder, value)
  if builder.count >= len(builder.values) then
    oldValues = builder.values
    grownValues = makeEmptyArray(len(oldValues) * 2)
    // Only the populated prefix is observable.  A native shallow copy keeps
    // record/array identity while avoiding concatenation's duplicate tail.
    copyArray(grownValues, 0, oldValues, 0, builder.count)
    builder.values = grownValues
  end if
  builder.values[builder.count] = value
  builder.count = builder.count + 1
  return builder.count
end function

/// Finalize state for finish array builder.
/// @param builder The builder input consumed by `finishArrayBuilder`.
function finishArrayBuilder(builder)
  return copyArrayPrefix(builder.values, builder.count)
end function
