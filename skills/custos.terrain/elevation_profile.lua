---@class ProfileSample
---@field pct integer percent along the line (0–100)
---@field elev_m integer terrain elevation at this sample (m MSL)

---@class ElevationProfileResult
---@field distance_m integer great-circle distance start→end (m)
---@field min_m integer|nil lowest sampled elevation (m), nil if no samples returned data
---@field max_m integer|nil highest sampled elevation (m), nil if no samples returned data
---@field gain_m integer cumulative elevation gain (m)
---@field loss_m integer cumulative elevation loss (m)
---@field profile ProfileSample[] ordered samples start→end

--- Get elevation profile along a line
-- @tool elevation_profile
-- @description Get elevation samples along a line between two points with gain/loss statistics. Useful for terrain analysis and movement planning. On error returns { status="error", message=... } instead of ElevationProfileResult.
-- @tparam number start_lat Start latitude
-- @tparam number start_lon Start longitude
-- @tparam number end_lat End latitude
-- @tparam number end_lon End longitude
-- @tparam integer samples Number of elevation samples (default: 20)
---@return ElevationProfileResult
-- @impact READ_ONLY
function elevation_profile(params)
  if not params.start_lat or not params.start_lon or not params.end_lat or not params.end_lon then
    return { status = "error", message = "start and end lat/lon required" }
  end

  local ElevationManager = import("com.atakmap.map.elevation.ElevationManager")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
  local numSamples = params.samples or 20

  local profile = {}
  local minE, maxE = 99999, -99999
  local gain, loss, prev = 0, 0, nil

  for i = 0, numSamples - 1 do
    local t = i / (numSamples - 1)
    local lat = params.start_lat + t * (params.end_lat - params.start_lat)
    local lon = params.start_lon + t * (params.end_lon - params.start_lon)
    local e = ElevationManager:getElevation(lat, lon, nil)

    if e and e ~= -1 then
      if e < minE then
        minE = e
      end
      if e > maxE then
        maxE = e
      end
      if prev then
        local d = e - prev
        if d > 0 then
          gain = gain + d
        else
          loss = loss - d
        end
      end
      prev = e
      table.insert(profile, { pct = math.floor(t * 100), elev_m = math.floor(e) })
    end
  end

  local d = GeoPoint(params.start_lat, params.start_lon):distanceTo(GeoPoint(params.end_lat, params.end_lon))

  return {
    distance_m = math.floor(d),
    min_m = minE < 99999 and math.floor(minE) or nil,
    max_m = maxE > -99999 and math.floor(maxE) or nil,
    gain_m = math.floor(gain),
    loss_m = math.floor(loss),
    profile = profile,
  }
end
