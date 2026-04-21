-- get_self_position_test.lua
-- Tests that get_self_position() returns a table with lat, lon, uid

local result = get_self_position()
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.lat) == "number", "Expected lat to be number, got " .. type(result.lat))
assert(type(result.lon) == "number", "Expected lon to be number, got " .. type(result.lon))
assert(type(result.uid) == "string", "Expected uid to be string, got " .. type(result.uid))
console.log("[get_self_position] lat=" .. result.lat .. " lon=" .. result.lon .. " uid=" .. result.uid)
return "PASS"
