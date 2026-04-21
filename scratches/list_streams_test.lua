-- list_streams_test.lua
-- Tests that list_streams() returns streams table and count

local result = list_streams()
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.streams) == "table", "Expected streams to be table, got " .. type(result.streams))
assert(type(result.count) == "number", "Expected count to be number, got " .. type(result.count))
console.log("[list_streams] count=" .. result.count)
return "PASS"
