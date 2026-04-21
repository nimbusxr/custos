---@class MovementAnalysis
---@field callsign string contact callsign
---@field track_points integer number of track points analyzed
---@field avg_speed_mps number average speed across the track (m/s)
---@field avg_speed_kph number average speed (km/h)
---@field max_speed_kph number peak speed observed (km/h)
---@field stops_detected integer number of samples with speed < 0.5 m/s
---@field direction_changes integer count of consecutive bearings differing by >45°
---@field current_heading_dir string 16-point direction of the latest bearing
---@field movement_type string "consistent" | "erratic" | "intermittent"

--- Analyze a contact's movement patterns from track history
-- @tool analyze_movement
-- @description Analyze a contact's recent movement for speed changes, direction changes, stops, and patterns. Uses breadcrumb track data. With insufficient track history (<2 points), returns a simpler snapshot { callsign, track_points=0, current_speed_mps, current_heading_deg, current_heading_dir, status, message } instead of the full MovementAnalysis. On error returns { status="error", message=... }.
-- @tparam string identifier Contact callsign or UID
-- @tparam integer max_points Maximum track points to analyze (default: 100)
---@return MovementAnalysis
-- @impact READ_ONLY
function analyze_movement(params)
  if not params.identifier then
    return { status = "error", message = "identifier required" }
  end

  local resolved = tools.call("resolve_item", { identifier = params.identifier })
  if resolved.status == "error" then
    return { status = "error", message = "Contact not found: " .. params.identifier }
  end
  local item = resolved.item

  local ok, pt = pcall(function()
    return item:getPoint()
  end)
  if not ok or not pt then
    return { status = "error", message = "Contact has no position" }
  end

  local uid = item:getUID()
  local maxPoints = params.max_points or 100

  -- Try to get track data from CrumbDatabase
  local trackPoints = {}
  local ok2, err = pcall(function()
    local MapView = import("com.atakmap.android.maps.MapView")
    local context = MapView:getMapView():getContext()
    local CrumbDatabase = import("com.atakmap.android.track.crumb.CrumbDatabase")
    local db = CrumbDatabase:instance()
    if db then
      local crumbs = db:getCrumbsForTrack(uid, maxPoints)
      if crumbs then
        local iter = crumbs:iterator()
        while iter:hasNext() do
          local crumb = iter:next()
          table.insert(trackPoints, {
            lat = crumb:getLatitude(),
            lon = crumb:getLongitude(),
            timestamp = crumb:getTimestamp(),
            speed = crumb:getSpeed(),
            bearing = crumb:getBearing(),
          })
        end
      end
    end
  end)

  if #trackPoints < 2 then
    -- Fallback: just report current state
    local speed = 0
    local heading = 0
    pcall(function()
      speed = item:getMetaDouble("Speed", 0)
      heading = item:getMetaDouble("Course", 0)
    end)

    return {
      callsign = item:getTitle() or params.identifier,
      track_points = 0,
      current_speed_mps = math.floor(speed * 10) / 10,
      current_heading_deg = math.floor(heading),
      current_heading_dir = tools.call("compass_dir", { deg = heading }).direction,
      status = speed > 0.5 and "moving" or "stationary",
      message = "Insufficient track history for pattern analysis — only current state available",
    }
  end

  -- Analyze the track
  local totalDist = 0
  local maxSpeed = 0
  local minSpeed = 999
  local stops = 0
  local directionChanges = 0
  local prevBearing = nil
  local speeds = {}

  for i = 2, #trackPoints do
    local prev = trackPoints[i - 1]
    local curr = trackPoints[i]

    local spd = curr.speed or 0
    table.insert(speeds, spd)
    if spd > maxSpeed then
      maxSpeed = spd
    end
    if spd < minSpeed then
      minSpeed = spd
    end
    if spd < 0.5 then
      stops = stops + 1
    end

    local brg = curr.bearing
      or tools.call("calc_bearing", { lat1 = prev.lat, lon1 = prev.lon, lat2 = curr.lat, lon2 = curr.lon }).bearing_deg
    if prevBearing then
      local diff = math.abs(brg - prevBearing)
      if diff > 180 then
        diff = 360 - diff
      end
      if diff > 45 then
        directionChanges = directionChanges + 1
      end
    end
    prevBearing = brg
  end

  -- Average speed
  local avgSpeed = 0
  for _, s in ipairs(speeds) do
    avgSpeed = avgSpeed + s
  end
  if #speeds > 0 then
    avgSpeed = avgSpeed / #speeds
  end

  return {
    callsign = item:getTitle() or params.identifier,
    track_points = #trackPoints,
    avg_speed_mps = math.floor(avgSpeed * 10) / 10,
    avg_speed_kph = math.floor(avgSpeed * 3.6 * 10) / 10,
    max_speed_kph = math.floor(maxSpeed * 3.6 * 10) / 10,
    stops_detected = stops,
    direction_changes = directionChanges,
    current_heading_dir = tools.call("compass_dir", { deg = (prevBearing or 0) }).direction,
    movement_type = stops > #trackPoints * 0.3 and "intermittent"
      or (directionChanges > #trackPoints * 0.2 and "erratic" or "consistent"),
  }
end
