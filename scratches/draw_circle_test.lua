-- draw_circle_test.lua
-- Tests that draw_circle() creates a circle on the map

local pos = get_self_position()

local result = draw_circle({
  title = "TEST_CIRCLE",
  center_lat = pos.lat,
  center_lon = pos.lon,
  radius_m = 200,
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
assert(type(result.uid) == "string", "Expected uid to be string, got " .. type(result.uid))
console.log("[draw_circle] uid=" .. result.uid .. " (manual cleanup required)")
return "PASS"
