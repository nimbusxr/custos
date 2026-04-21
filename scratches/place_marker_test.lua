-- place_marker_test.lua
-- Tests that place_marker() creates a marker and delete_markers() cleans it up

local pos = get_self_position()
local callsign = "TEST_MKR_" .. tostring(math.random(100000, 999999))

local result = place_marker({
  callsign = callsign,
  lat = pos.lat,
  lon = pos.lon,
  type = "a-f-G",
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
assert(type(result.uid) == "string", "Expected uid to be string, got " .. type(result.uid))
console.log("[place_marker] placed " .. callsign .. " uid=" .. result.uid)

-- Cleanup
local cleanup = delete_markers({ query = callsign })
assert(type(cleanup) == "table", "Cleanup must return a table")
console.log("[place_marker] cleanup status=" .. tostring(cleanup.status) .. " deleted=" .. tostring(cleanup.deleted))

return "PASS"
