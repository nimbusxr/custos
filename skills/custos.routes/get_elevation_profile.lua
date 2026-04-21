--- Get elevation profile between two points
-- @tool get_elevation_profile
-- @description Get elevation samples along a line between two points. Useful for route planning and terrain analysis. Returns min/max elevation, total gain/loss, and per-sample data.
-- @tparam number start_lat Start latitude
-- @tparam number start_lon Start longitude
-- @tparam number end_lat End latitude
-- @tparam number end_lon End longitude
-- @tparam integer samples Number of elevation samples along the line (default: 20)
-- @impact READ_ONLY
function get_elevation_profile(params)
  if not params.start_lat or not params.start_lon or not params.end_lat or not params.end_lon then
    return { status = "error", message = "start_lat, start_lon, end_lat, end_lon required" }
  end

  local ElevationManager = import("com.atakmap.map.elevation.ElevationManager")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
  local numSamples = params.samples or 20

  local profile = {}
  local minElev = 99999
  local maxElev = -99999
  local totalGain = 0
  local totalLoss = 0
  local prevElev = nil

  for i = 0, numSamples - 1 do
    local t = i / (numSamples - 1)
    local lat = params.start_lat + t * (params.end_lat - params.start_lat)
    local lon = params.start_lon + t * (params.end_lon - params.start_lon)

    local elev = ElevationManager:getElevation(lat, lon, nil)
    if elev and elev ~= -1 then
      if elev < minElev then
        minElev = elev
      end
      if elev > maxElev then
        maxElev = elev
      end
      if prevElev then
        local diff = elev - prevElev
        if diff > 0 then
          totalGain = totalGain + diff
        else
          totalLoss = totalLoss + math.abs(diff)
        end
      end
      prevElev = elev
    else
      elev = nil
    end

    table.insert(profile, {
      lat = math.floor(lat * 1000000) / 1000000,
      lon = math.floor(lon * 1000000) / 1000000,
      elevation_m = elev and (math.floor(elev * 10) / 10) or "no_data",
      distance_pct = math.floor(t * 100),
    })
  end

  local startPt = GeoPoint(params.start_lat, params.start_lon)
  local endPt = GeoPoint(params.end_lat, params.end_lon)
  local totalDist = startPt:distanceTo(endPt)

  return {
    total_distance_m = math.floor(totalDist),
    min_elevation_m = minElev < 99999 and (math.floor(minElev * 10) / 10) or "no_data",
    max_elevation_m = maxElev > -99999 and (math.floor(maxElev * 10) / 10) or "no_data",
    total_gain_m = math.floor(totalGain * 10) / 10,
    total_loss_m = math.floor(totalLoss * 10) / 10,
    samples = profile,
  }
end
