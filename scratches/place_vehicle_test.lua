-- place_vehicle_test.lua
-- Tests that place_vehicle() creates a vehicle marker

local pos = get_self_position()

local result = place_vehicle({
  lat = pos.lat,
  lon = pos.lon,
  callsign = "TEST_VEH",
  vehicle_type = "HMMWV",
  heading_deg = 90,
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
assert(type(result.uid) == "string", "Expected uid to be string, got " .. type(result.uid))
console.log("[place_vehicle] uid=" .. result.uid .. " type=" .. tostring(result.vehicle_type))
return "PASS"
