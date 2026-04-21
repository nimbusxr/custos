-- build_grg_test.lua
-- Tests that build_grg() places a 3x3 GRG grid

local pos = get_self_position()

local result = build_grg({
  lat = pos.lat,
  lon = pos.lon,
  rows = 3,
  cols = 3,
  spacing = 50,
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
console.log("[build_grg] rows=" .. tostring(result.rows) .. " cols=" .. tostring(result.cols) .. " spacing=" .. tostring(result.spacing))
return "PASS"
