-- create_spot_report_test.lua
-- Tests that create_spot_report() creates a SPOTREP marker

local pos = get_self_position()

local ok, result = pcall(create_spot_report, {
  lat = pos.lat,
  lon = pos.lon,
  type = "contact",
  description = "TEST spot report",
  size = "squad",
  activity = "stationary",
})
if not ok then
    console.error("SCRIPT BUG: " .. tostring(result))
    return "FAIL (script bug: " .. tostring(result) .. ")"
end
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
assert(type(result.uid) == "string", "Expected uid to be string, got " .. type(result.uid))
console.log("[create_spot_report] uid=" .. result.uid .. " callsign=" .. tostring(result.callsign))
return "PASS"
