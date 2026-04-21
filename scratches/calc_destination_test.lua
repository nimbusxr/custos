-- calc_destination_test.lua
-- Verifies that calc_destination(lat, lon, bearing_deg, distance_m) projects
-- along a great-circle path and returns a sensible destination point.
-- Reference: at lat 41.63°N, one degree of latitude ≈ 110,950 m, so 100 m
-- due north shifts latitude by about +0.000901°. Longitude tracks ~cos(lat).

local START_LAT = 41.63
local START_LON = -93.85

local function nearly(a, b, eps)
    return math.abs(a - b) < eps
end

-- 1. Basic shape + happy path at bearing 0° (due north, 100m)
local ok, north = pcall(calc_destination, {
    lat = START_LAT, lon = START_LON,
    bearing_deg = 0, distance_m = 100,
})
if not ok then
    console.error("SCRIPT BUG: " .. tostring(north))
    return "FAIL (script bug: " .. tostring(north) .. ")"
end
assert(type(north) == "table", "Expected table, got " .. type(north))
assert(type(north.lat) == "number", "lat missing or not number")
assert(type(north.lon) == "number", "lon missing or not number")
assert(north.bearing_deg == 0, "bearing_deg echo wrong: " .. tostring(north.bearing_deg))
assert(north.distance_m == 100, "distance_m echo wrong: " .. tostring(north.distance_m))

-- Due north: latitude should increase by ~0.0009°, longitude essentially unchanged
local expectedDLat = 100 / 110950  -- ~0.000901
assert(
    nearly(north.lat - START_LAT, expectedDLat, 0.00005),
    string.format("N 100m expected dLat ~%.6f, got %.6f", expectedDLat, north.lat - START_LAT)
)
assert(
    nearly(north.lon, START_LON, 0.00005),
    string.format("N 100m expected lon ~%.6f, got %.6f", START_LON, north.lon)
)
console.log(string.format("[calc_destination] N 100m: %.6f, %.6f", north.lat, north.lon))

-- 2. Due east (bearing 90°, 100m): longitude should increase, latitude ~unchanged.
-- At lat 41.63°N, one degree lon ≈ 110950 * cos(41.63°) ≈ 82,980 m, so 100m ≈ +0.001205°.
local ok2, east = pcall(calc_destination, {
    lat = START_LAT, lon = START_LON,
    bearing_deg = 90, distance_m = 100,
})
if not ok2 then
    console.error("SCRIPT BUG: " .. tostring(east))
    return "FAIL (script bug: " .. tostring(east) .. ")"
end
assert(
    nearly(east.lat, START_LAT, 0.00005),
    string.format("E 100m expected lat ~%.6f, got %.6f", START_LAT, east.lat)
)
local expectedDLon = 100 / (110950 * math.cos(START_LAT * math.pi / 180))  -- ~0.00120
assert(
    nearly(east.lon - START_LON, expectedDLon, 0.00010),
    string.format("E 100m expected dLon ~%.6f, got %.6f", expectedDLon, east.lon - START_LON)
)
console.log(string.format("[calc_destination] E 100m: %.6f, %.6f", east.lat, east.lon))

-- 3. Due south (bearing 180°, 500m)
local ok3, south = pcall(calc_destination, {
    lat = START_LAT, lon = START_LON,
    bearing_deg = 180, distance_m = 500,
})
if not ok3 then
    console.error("SCRIPT BUG: " .. tostring(south))
    return "FAIL (script bug: " .. tostring(south) .. ")"
end
assert(south.lat < START_LAT, "S should decrease lat, got " .. tostring(south.lat))
assert(nearly(south.lon, START_LON, 0.00005), "S should not change lon")

-- 4. Error handling — missing required params
local ok4, missingBearing = pcall(calc_destination, { lat = START_LAT, lon = START_LON, distance_m = 100 })
assert(ok4, "pcall should succeed even for error returns")
assert(missingBearing.status == "error", "missing bearing_deg should return error status")

local ok5, missingDist = pcall(calc_destination, { lat = START_LAT, lon = START_LON, bearing_deg = 45 })
assert(ok5, "pcall should succeed even for error returns")
assert(missingDist.status == "error", "missing distance_m should return error status")

local ok6, missingLat = pcall(calc_destination, { lon = START_LON, bearing_deg = 45, distance_m = 100 })
assert(ok6, "pcall should succeed even for error returns")
assert(missingLat.status == "error", "missing lat should return error status")

return "PASS"