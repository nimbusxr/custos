-- find_nearby_test.lua
-- Tests that find_nearby() with defaults returns expected structure

local self_pos = get_self_position()
local result = find_nearby({lat = self_pos.lat, lon = self_pos.lon})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.radius_m) == "number", "Expected radius_m to be number, got " .. type(result.radius_m))
assert(type(result.items) == "table", "Expected items to be table, got " .. type(result.items))
assert(type(result.count) == "number", "Expected count to be number, got " .. type(result.count))
console.log("[find_nearby] radius_m=" .. result.radius_m .. " count=" .. result.count)
return "PASS"
