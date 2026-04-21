---@class TrackTarget
---@field uid string target UID
---@field callsign string target callsign
---@field lat number target latitude
---@field lon number target longitude
---@field type string full CoT type

---@class TrackSelf
---@field lat number operator latitude
---@field lon number operator longitude

---@class TrackingData
---@field distance_m number meters from self to target
---@field bearing_deg number degrees from self to target (0=N, clockwise)
---@field bearing_dir string 16-point compass direction
---@field target_speed_mps number|nil target speed metadata, nil if not set
---@field target_heading_deg number|nil target heading metadata in degrees, nil if not set
---@field target_heading_dir string|nil target heading 16-point direction, nil if not set

---@class TrackTargetResult
---@field status string "success" on success
---@field target TrackTarget target location and identity
---@field self_position TrackSelf operator location
---@field tracking TrackingData distance, bearing, and optional kinematics

--- Get real-time tracking data for a target
-- @tool track_target
-- @description Resolve a target by callsign or UID and return current bearing, distance, speed, and heading from self position. Provides pursuit-relevant tracking data. On error returns { status="error", message=... } instead of TrackTargetResult.
-- @tparam string target Callsign or UID of the target to track
---@return TrackTargetResult
-- @impact READ_ONLY
function track_target(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
  local Math = import("java.lang.Math")

  local function calc_bearing(lat1, lon1, lat2, lon2)
    local rad = math.pi / 180
    local la1, la2 = lat1 * rad, lat2 * rad
    local dLon = (lon2 - lon1) * rad
    local y = math.sin(dLon) * math.cos(la2)
    local x = math.cos(la1) * math.sin(la2) - math.sin(la1) * math.cos(la2) * math.cos(dLon)
    return (Math:atan2(y, x) / rad + 360) % 360
  end

  local function compass_dir(deg)
    local dirs = { "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW" }
    return dirs[math.floor((deg + 11.25) / 22.5) % 16 + 1]
  end

  local mapView = MapView:getMapView()
  local rootGroup = mapView:getRootGroup()

  -- Resolve target
  local target = nil
  local identifier = params.target
  local ok, found = pcall(function()
    return rootGroup:deepFindUID(identifier)
  end)
  if ok and found then
    target = found
  else
    local query = identifier:lower()
    local allItems = rootGroup:getItemsRecursive()
    local iter = allItems:iterator()
    while iter:hasNext() do
      local item = iter:next()
      local s, title = pcall(function()
        return item:getTitle()
      end)
      if s and title and title:lower():find(query, 1, true) then
        target = item
        break
      end
    end
  end

  if not target then
    return { status = "error", message = "Target not found: " .. identifier }
  end

  local ok2, targetPoint = pcall(function()
    return target:getPoint()
  end)
  if not ok2 or not targetPoint then
    return { status = "error", message = "Target has no position" }
  end

  local ok3, targetTitle = pcall(function()
    return target:getTitle()
  end)
  local targetCallsign = ok3 and targetTitle or identifier

  local targetLat = targetPoint:getLatitude()
  local targetLon = targetPoint:getLongitude()

  -- Get self position
  local selfMarker = mapView:getSelfMarker()
  if not selfMarker then
    return { status = "error", message = "No self-marker — GPS fix required for tracking" }
  end
  local selfPoint = selfMarker:getPoint()
  local selfLat = selfPoint:getLatitude()
  local selfLon = selfPoint:getLongitude()

  -- Compute tracking data
  local distance = selfPoint:distanceTo(targetPoint)
  local bearing = calc_bearing(selfLat, selfLon, targetLat, targetLon)

  -- Try to get target speed and heading from metadata
  local targetSpeed = nil
  local targetHeading = nil
  pcall(function()
    local s = target:getMetaDouble("Speed", -1)
    if s >= 0 then
      targetSpeed = s
    end
  end)
  pcall(function()
    local h = target:getMetaDouble("Course", -1)
    if h >= 0 then
      targetHeading = h
    end
  end)

  local result = {
    status = "success",
    target = {
      uid = target:getUID(),
      callsign = targetCallsign,
      lat = targetLat,
      lon = targetLon,
      type = target:getType() or "",
    },
    self_position = { lat = selfLat, lon = selfLon },
    tracking = {
      distance_m = math.floor(distance * 10) / 10,
      bearing_deg = math.floor(bearing * 10) / 10,
      bearing_dir = compass_dir(bearing),
    },
  }

  if targetSpeed then
    result.tracking.target_speed_mps = math.floor(targetSpeed * 10) / 10
  end
  if targetHeading then
    result.tracking.target_heading_deg = math.floor(targetHeading * 10) / 10
    result.tracking.target_heading_dir = compass_dir(targetHeading)
  end

  return result
end
