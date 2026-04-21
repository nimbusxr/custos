-- create_sensor_fov_test.lua
-- Tests that create_sensor_fov() creates a sensor FOV cone on the map

local pos = get_self_position()

local result = create_sensor_fov({
  lat = pos.lat,
  lon = pos.lon,
  azimuth_deg = 0,
  fov_deg = 60,
  range_m = 1000,
  name = "TEST_FOV",
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
assert(type(result.uid) == "string", "Expected uid to be string, got " .. type(result.uid))
console.log("[create_sensor_fov] uid=" .. result.uid)
return "PASS"
