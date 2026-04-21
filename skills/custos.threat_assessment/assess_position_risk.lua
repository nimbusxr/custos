---@class ThreatEntry
---@field callsign string hostile callsign (or "UNKNOWN")
---@field distance_m integer meters from the evaluated position
---@field bearing_deg integer degrees from position to threat (0=N)
---@field bearing_dir string 16-point compass direction
---@field has_los boolean true if terrain does not block line of sight
---@field elevation_advantage_m integer meters (positive = position is higher)

---@class PositionRiskResult
---@field risk_level string LOW | MEDIUM | HIGH (by count of threats with LOS)
---@field position_elevation_m integer terrain elevation at evaluated position (m)
---@field total_hostiles integer hostiles found within radius
---@field hostiles_with_los integer subset of total that can see the position
---@field threats ThreatEntry[] sorted by distance ascending

--- Assess the risk of a position based on nearby threats and terrain
-- @tool assess_position_risk
-- @description Evaluate a position for threat exposure by checking line-of-sight to all nearby hostiles and analyzing terrain advantages. On error returns { status="error", message=... } instead of PositionRiskResult.
-- @tparam number lat Position latitude
-- @tparam number lon Position longitude
-- @tparam number radius_m Search radius for threats (default: 5000)
---@return PositionRiskResult
-- @impact READ_ONLY
function assess_position_risk(params)
  if not params.lat or not params.lon then
    return { status = "error", message = "lat and lon required" }
  end

  local MapView = import("com.atakmap.android.maps.MapView")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
  local ElevationManager = import("com.atakmap.map.elevation.ElevationManager")

  local rootGroup = MapView:getMapView():getRootGroup()
  local radius = params.radius_m or 5000
  local posPt = GeoPoint(params.lat, params.lon)
  local posElev = (ElevationManager:getElevation(params.lat, params.lon, nil) or 0) + 2

  local threats = {}
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
        local dist = posPt:distanceTo(pt)
        if dist <= radius then
          local ok2, title = pcall(function()
            return item:getTitle()
          end)
          local hLat, hLon = pt:getLatitude(), pt:getLongitude()
          local hElev = (ElevationManager:getElevation(hLat, hLon, nil) or 0) + 2

          -- LOS check
          local hasLOS = true
          for j = 1, 4 do
            local t = j / 5
            local sLat = params.lat + t * (hLat - params.lat)
            local sLon = params.lon + t * (hLon - params.lon)
            local te = ElevationManager:getElevation(sLat, sLon, nil)
            if te and te ~= -1 then
              local losAlt = posElev + t * (hElev - posElev)
              if te > losAlt then
                hasLOS = false
                break
              end
            end
          end

          local bearing =
            tools.call("calc_bearing", { lat1 = params.lat, lon1 = params.lon, lat2 = hLat, lon2 = hLon }).bearing_deg
          table.insert(threats, {
            callsign = (ok2 and title) or "UNKNOWN",
            distance_m = math.floor(dist),
            bearing_deg = math.floor(bearing),
            bearing_dir = tools.call("compass_dir", { deg = bearing }).direction,
            has_los = hasLOS,
            elevation_advantage_m = math.floor(posElev - hElev),
          })
        end
      end
    end
  end

  table.sort(threats, function(a, b)
    return a.distance_m < b.distance_m
  end)

  local losThreats = 0
  for _, t in ipairs(threats) do
    if t.has_los then
      losThreats = losThreats + 1
    end
  end

  local riskLevel = "LOW"
  if losThreats >= 3 then
    riskLevel = "HIGH"
  elseif losThreats >= 1 then
    riskLevel = "MEDIUM"
  end

  return {
    risk_level = riskLevel,
    position_elevation_m = math.floor(posElev - 2),
    total_hostiles = #threats,
    hostiles_with_los = losThreats,
    threats = threats,
  }
end
