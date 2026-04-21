-- create_bpha_test.lua
-- Tests that create_bpha() creates a battle position holding area

local pos = get_self_position()

local result = create_bpha({
  lat = pos.lat,
  lon = pos.lon,
  width_m = 100,
  height_m = 100,
  name = "TEST_BPHA",
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
console.log("[create_bpha] cells=" .. tostring(result.cells))
return "PASS"
