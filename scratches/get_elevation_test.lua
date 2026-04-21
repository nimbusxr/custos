-- get_elevation_test.lua
-- Tests that get_elevation() returns elevation_m as number

local self_pos = get_self_position()
local result = get_elevation({lat = self_pos.lat, lon = self_pos.lon})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.elevation_m) == "number", "Expected elevation_m to be number, got " .. type(result.elevation_m))
console.log("[get_elevation] elevation_m=" .. result.elevation_m)
return "PASS"
