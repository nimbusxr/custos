-- draw_rectangle_test.lua
-- Tests that draw_rectangle() creates a rectangle on the map

local pos = get_self_position()

local result = draw_rectangle({
  title = "TEST_RECT",
  center_lat = pos.lat,
  center_lon = pos.lon,
  width_m = 100,
  height_m = 100,
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
assert(type(result.uid) == "string", "Expected uid to be string, got " .. type(result.uid))
console.log("[draw_rectangle] uid=" .. result.uid)
return "PASS"
