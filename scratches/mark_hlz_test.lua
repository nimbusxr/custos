-- mark_hlz_test.lua
-- Tests that mark_hlz() creates a helicopter landing zone marker

local pos = get_self_position()

local result = mark_hlz({
  lat = pos.lat,
  lon = pos.lon,
  name = "TEST_HLZ",
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
assert(type(result.uid) == "string", "Expected uid to be string, got " .. type(result.uid))
console.log("[mark_hlz] uid=" .. result.uid .. " name=" .. tostring(result.name))
return "PASS"
