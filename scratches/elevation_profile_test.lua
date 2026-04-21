-- elevation_profile_test.lua
-- Tests that elevation_profile() returns expected structure

local self_pos = get_self_position()
local result = elevation_profile({
    start_lat = self_pos.lat,
    start_lon = self_pos.lon,
    end_lat = self_pos.lat + 0.005,
    end_lon = self_pos.lon + 0.005
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.distance_m) == "number", "Expected distance_m to be number, got " .. type(result.distance_m))
assert(type(result.min_m) == "number", "Expected min_m to be number, got " .. type(result.min_m))
assert(type(result.max_m) == "number", "Expected max_m to be number, got " .. type(result.max_m))
assert(type(result.profile) == "table", "Expected profile to be table, got " .. type(result.profile))
console.log("[elevation_profile] distance_m=" .. result.distance_m .. " min_m=" .. result.min_m .. " max_m=" .. result.max_m)
return "PASS"
