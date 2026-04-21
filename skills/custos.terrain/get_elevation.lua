---@class ElevationReading
---@field lat number queried latitude
---@field lon number queried longitude
---@field elevation_m number elevation in meters MSL
---@field elevation_ft number elevation in feet MSL

--- Get elevation at a point
-- @tool get_elevation
-- @description Get the terrain elevation at a latitude/longitude point in meters and feet above sea level. On missing data returns { status="no_data", message=... } or { status="error", ... } instead of ElevationReading.
-- @tparam number lat Latitude
-- @tparam number lon Longitude
---@return ElevationReading
-- @impact READ_ONLY
function get_elevation(params)
  if not params.lat or not params.lon then
    return { status = "error", message = "lat and lon required" }
  end

  local ElevationManager = import("com.atakmap.map.elevation.ElevationManager")
  local elev = ElevationManager:getElevation(params.lat, params.lon, nil)

  if not elev or elev == -1 then
    return { status = "no_data", message = "No elevation data available at this location" }
  end

  return {
    lat = params.lat,
    lon = params.lon,
    elevation_m = math.floor(elev * 10) / 10,
    elevation_ft = math.floor(elev * 3.28084 * 10) / 10,
  }
end
