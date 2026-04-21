---@class BlockPoint
---@field lat number latitude of worst terrain obstruction
---@field lon number longitude of worst terrain obstruction
---@field terrain_m integer terrain elevation at the block point (m MSL)
---@field los_m integer required LOS altitude at the block point (m MSL)

---@class LineOfSightResult
---@field clear boolean true if no terrain blocks the line
---@field distance_m integer great-circle distance observer→target (m)
---@field bearing_deg number bearing observer→target (0=N)
---@field bearing_dir string 16-point compass direction
---@field observer_elevation_m integer terrain elevation at observer (m MSL)
---@field target_elevation_m integer terrain elevation at target (m MSL)
---@field max_obstruction_m number worst terrain protrusion above the LOS line (m), 0 if clear
---@field block_point BlockPoint|nil nil if clear; otherwise the worst obstruction location

--- Check line of sight between two points
-- @tool line_of_sight
-- @description Check if there is clear line of sight between two positions, accounting for terrain. Samples elevation along the line to detect obstructions. On error returns { status="error", message=... } instead of LineOfSightResult.
-- @tparam number observer_lat Observer latitude
-- @tparam number observer_lon Observer longitude
-- @tparam number observer_height_m Observer height above ground in meters
-- @tparam number target_lat Target latitude
-- @tparam number target_lon Target longitude
-- @tparam number target_height_m Target height above ground in meters (default: 2)
---@return LineOfSightResult
-- @impact READ_ONLY
function line_of_sight(params)
  if not params.observer_lat or not params.observer_lon or not params.target_lat or not params.target_lon then
    return { status = "error", message = "observer and target lat/lon required" }
  end

  local ElevationManager = import("com.atakmap.map.elevation.ElevationManager")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")

  local obsHeight = params.observer_height_m or 2
  local tgtHeight = params.target_height_m or 2
  local samples = 50

  -- Get terrain elevation at observer and target
  local obsElev = ElevationManager:getElevation(params.observer_lat, params.observer_lon, nil) or 0
  local tgtElev = ElevationManager:getElevation(params.target_lat, params.target_lon, nil) or 0

  local obsAlt = obsElev + obsHeight
  local tgtAlt = tgtElev + tgtHeight

  local obsPt = GeoPoint(params.observer_lat, params.observer_lon)
  local tgtPt = GeoPoint(params.target_lat, params.target_lon)
  local totalDist = obsPt:distanceTo(tgtPt)

  local blocked = false
  local blockPoint = nil
  local maxObstruction = 0

  -- Sample terrain along the line between observer and target
  for i = 1, samples - 1 do
    local t = i / samples
    local lat = params.observer_lat + t * (params.target_lat - params.observer_lat)
    local lon = params.observer_lon + t * (params.target_lon - params.observer_lon)
    local terrainElev = ElevationManager:getElevation(lat, lon, nil)

    if terrainElev and terrainElev ~= -1 then
      -- Expected LOS altitude at this fraction (linear interpolation)
      local losAlt = obsAlt + t * (tgtAlt - obsAlt)
      if terrainElev > losAlt then
        blocked = true
        local obstruction = terrainElev - losAlt
        if obstruction > maxObstruction then
          maxObstruction = obstruction
          blockPoint = {
            lat = math.floor(lat * 1000000) / 1000000,
            lon = math.floor(lon * 1000000) / 1000000,
            terrain_m = math.floor(terrainElev),
            los_m = math.floor(losAlt),
          }
        end
      end
    end
  end

  local bearing = tools.call(
    "calc_bearing",
    { lat1 = params.observer_lat, lon1 = params.observer_lon, lat2 = params.target_lat, lon2 = params.target_lon }
  ).bearing_deg

  return {
    clear = not blocked,
    distance_m = math.floor(totalDist),
    bearing_deg = math.floor(bearing * 10) / 10,
    bearing_dir = tools.call("compass_dir", { deg = bearing }).direction,
    observer_elevation_m = math.floor(obsElev),
    target_elevation_m = math.floor(tgtElev),
    max_obstruction_m = blocked and (math.floor(maxObstruction * 10) / 10) or 0,
    block_point = blockPoint,
  }
end
