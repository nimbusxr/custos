-- list_geofences_test.lua
-- Tests that list_geofences() returns geofences table and count

local result = list_geofences()
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.geofences) == "table", "Expected geofences to be table, got " .. type(result.geofences))
assert(type(result.count) == "number", "Expected count to be number, got " .. type(result.count))
console.log("[list_geofences] count=" .. result.count)
return "PASS"
