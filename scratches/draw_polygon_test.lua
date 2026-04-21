-- draw_polygon_test.lua
-- Tests that draw_polygon() creates a triangle around self position

local pos = get_self_position()

-- Offset ~100m in three directions to form a triangle
local offset = 0.001 -- roughly 111m at equator
local points = {
  { lat = pos.lat + offset, lon = pos.lon },
  { lat = pos.lat - offset / 2, lon = pos.lon + offset },
  { lat = pos.lat - offset / 2, lon = pos.lon - offset },
}

local result = draw_polygon({
  title = "TEST_POLY",
  points = points,
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
assert(type(result.uid) == "string", "Expected uid to be string, got " .. type(result.uid))
console.log("[draw_polygon] uid=" .. result.uid)
return "PASS"
