-- create_range_circle_test.lua
-- Tests that create_range_circle() creates a range circle on the map

local pos = get_self_position()

local result = create_range_circle({
  lat = pos.lat,
  lon = pos.lon,
  radius_m = 500,
  name = "TEST_RC",
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
assert(type(result.uid) == "string", "Expected uid to be string, got " .. type(result.uid))
console.log("[create_range_circle] uid=" .. result.uid)
return "PASS"
