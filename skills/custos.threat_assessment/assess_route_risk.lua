---@class RouteThreat
---@field callsign string hostile callsign (or "UNKNOWN")
---@field bearing_deg integer degrees from route midpoint to threat (0=N)
---@field bearing_dir string 16-point compass direction
---@field closest_m integer meters from nearest route sample
---@field exposure_pct integer percent of sampled route points exposed (with LOS)

---@class RouteRiskResult
---@field risk_level string LOW | MEDIUM | HIGH (by max exposure_pct across threats)
---@field hostile_count integer hostiles considered (within 1.5× check_radius of midpoint)
---@field route_distance_m integer great-circle distance from start to end in meters
---@field threats RouteThreat[] sorted by exposure_pct descending
---@field summary string|nil present only when no threats found

--- Assess threat exposure along a route or line between two points
-- @tool assess_route_risk
-- @description Analyze a route for exposure to known hostile positions using terrain and line-of-sight. Returns threat summary with exposed segments and recommended mitigations. On error returns { status="error", message=... } instead of RouteRiskResult.
-- @tparam number start_lat Route start latitude
-- @tparam number start_lon Route start longitude
-- @tparam number end_lat Route end latitude
-- @tparam number end_lon Route end longitude
-- @tparam number check_radius_m Radius to search for hostiles around the route (default: 5000)
-- @tparam integer route_samples Number of points along route to check (default: 10)
---@return RouteRiskResult
-- @impact READ_ONLY
function assess_route_risk(params)
  if not params.start_lat or not params.start_lon or not params.end_lat or not params.end_lon then
    return { status = "error", message = "start and end lat/lon required" }
  end

  local MapView = import("com.atakmap.android.maps.MapView")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
  local ElevationManager = import("com.atakmap.map.elevation.ElevationManager")

  local rootGroup = MapView:getMapView():getRootGroup()
  local checkRadius = params.check_radius_m or 5000
  local numSamples = params.route_samples or 10

  -- Find all hostiles within check_radius of the route midpoint
  local midLat = (params.start_lat + params.end_lat) / 2
  local midLon = (params.start_lon + params.end_lon) / 2
  local midPt = GeoPoint(midLat, midLon)

  local hostiles = {}
  local allItems = rootGroup:getItemsRecursive()
  local iter = allItems:iterator()
  while iter:hasNext() do
    local item = iter:next()
    local itemType = item:getType() or ""
    if itemType:find("a-h", 1, true) == 1 then
      local ok, pt = pcall(function()
        return item:getPoint()
      end)
      if ok and pt then
        local dist = midPt:distanceTo(pt)
        if dist <= checkRadius * 1.5 then
          local ok2, title = pcall(function()
            return item:getTitle()
          end)
          table.insert(hostiles, {
            callsign = (ok2 and title) or "UNKNOWN",
            lat = pt:getLatitude(),
            lon = pt:getLongitude(),
            uid = item:getUID(),
          })
        end
      end
    end
  end

  if #hostiles == 0 then
    local totalDist = GeoPoint(params.start_lat, params.start_lon):distanceTo(GeoPoint(params.end_lat, params.end_lon))
    return {
      risk_level = "LOW",
      hostile_count = 0,
      route_distance_m = math.floor(totalDist),
      summary = "No hostile positions detected within " .. checkRadius .. "m of route",
      threats = {},
    }
  end

  -- Sample points along route and check LOS to each hostile
  local threats = {}
  for _, hostile in ipairs(hostiles) do
    local exposedSegments = 0
    local minDist = 999999
    local hostileElev = ElevationManager:getElevation(hostile.lat, hostile.lon, nil) or 0

    for i = 0, numSamples - 1 do
      local t = i / (numSamples - 1)
      local routeLat = params.start_lat + t * (params.end_lat - params.start_lat)
      local routeLon = params.start_lon + t * (params.end_lon - params.start_lon)
      local routePt = GeoPoint(routeLat, routeLon)
      local dist = routePt:distanceTo(GeoPoint(hostile.lat, hostile.lon))

      if dist < minDist then
        minDist = dist
      end

      -- Simple LOS check: sample terrain between route point and hostile
      local routeElev = (ElevationManager:getElevation(routeLat, routeLon, nil) or 0) + 2
      local hostileAlt = hostileElev + 2
      local blocked = false

      for j = 1, 4 do
        local lt = j / 5
        local sLat = routeLat + lt * (hostile.lat - routeLat)
        local sLon = routeLon + lt * (hostile.lon - routeLon)
        local terrainE = ElevationManager:getElevation(sLat, sLon, nil)
        if terrainE and terrainE ~= -1 then
          local losAlt = routeElev + lt * (hostileAlt - routeElev)
          if terrainE > losAlt then
            blocked = true
            break
          end
        end
      end

      if not blocked then
        exposedSegments = exposedSegments + 1
      end
    end

    local bearing =
      tools.call("calc_bearing", { lat1 = midLat, lon1 = midLon, lat2 = hostile.lat, lon2 = hostile.lon }).bearing_deg
    local exposure = math.floor(exposedSegments / numSamples * 100)

    table.insert(threats, {
      callsign = hostile.callsign,
      bearing_deg = math.floor(bearing),
      bearing_dir = tools.call("compass_dir", { deg = bearing }).direction,
      closest_m = math.floor(minDist),
      exposure_pct = exposure,
    })
  end

  -- Sort by exposure (most dangerous first)
  table.sort(threats, function(a, b)
    return a.exposure_pct > b.exposure_pct
  end)

  local maxExposure = threats[1] and threats[1].exposure_pct or 0
  local riskLevel = "LOW"
  if maxExposure > 60 then
    riskLevel = "HIGH"
  elseif maxExposure > 30 then
    riskLevel = "MEDIUM"
  end

  local totalDist = GeoPoint(params.start_lat, params.start_lon):distanceTo(GeoPoint(params.end_lat, params.end_lon))

  return {
    risk_level = riskLevel,
    hostile_count = #hostiles,
    route_distance_m = math.floor(totalDist),
    threats = threats,
  }
end
