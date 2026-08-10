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
  values
  count
end struct

function makeFilledArray(count, value)
  if count < 0 then return error(1180, "negative array size") end if
  // MiniLang now exposes exact-sized native array allocation.  Avoid the
  // historical chunk-concatenation fallback and allocate the final array once.
  return array(count, value)
end function

function makeEmptyArray(count)
  return makeFilledArray(count, void)
end function

function copyArrayLinear(source)
  sourceCount = len(source)
  result = makeEmptyArray(sourceCount)
  index = 0
  while index < sourceCount
    result[index] = source[index]
    index = index + 1
  end while
  return result
end function

function copyArrayPrefix(source, count)
  if count < 0 or count > len(source) then return error(1181, "array prefix outside source") end if
  result = makeEmptyArray(count)
  index = 0
  while index < count
    result[index] = source[index]
    index = index + 1
  end while
  return result
end function

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
  index = 0
  while index < sourceCount
    result[index] = source[index]
    index = index + 1
  end while
  return result
end function

function createArrayBuilder(initialCapacity)
  capacity = initialCapacity
  if capacity < 1 then capacity = 1 end if
  return ArrayBuilder(makeEmptyArray(capacity), 0)
end function

function pushArrayBuilder(builder, value)
  if builder.count >= len(builder.values) then
    builder.values = builder.values + builder.values
  end if
  builder.values[builder.count] = value
  builder.count = builder.count + 1
  return builder.count
end function

function finishArrayBuilder(builder)
  return copyArrayPrefix(builder.values, builder.count)
end function
