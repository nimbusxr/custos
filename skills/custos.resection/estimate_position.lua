--- Estimate position from bearings to known landmarks
-- @tool estimate_position
-- @description Estimate your position using resection — provide bearings to two or more known landmarks (map items). Computes the intersection of bearing lines and returns estimated lat/lon with error estimate.
-- @tparam table observations Array of observations, each with 'landmark' (name/UID) and 'bearing_deg' (bearing FROM observer TO landmark in degrees)
-- @impact READ_ONLY
function estimate_position(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
  local Math = import("java.lang.Math")

  local observations = params.observations
  if not observations or #observations < 2 then
    return { status = "error", message = "At least 2 observations required (each with landmark and bearing_deg)" }
  end

  local mapView = MapView:getMapView()
  local rootGroup = mapView:getRootGroup()

  local function resolve(id)
    local ok, found = pcall(function()
      return rootGroup:deepFindUID(id)
    end)
    if ok and found then
      return found
    end
    local query = id:lower()
    local allItems = rootGroup:getItemsRecursive()
    local iter = allItems:iterator()
    while iter:hasNext() do
      local item = iter:next()
      local s, title = pcall(function()
        return item:getTitle()
      end)
      if s and title and title:lower():find(query, 1, true) then
        return item
      end
    end
    return nil
  end

  -- Resolve all landmarks
  local resolved = {}
  for i, obs in ipairs(observations) do
    if not obs.landmark or not obs.bearing_deg then
      return { status = "error", message = "Observation " .. i .. " missing landmark or bearing_deg" }
    end

    local item = resolve(obs.landmark)
    if not item then
      return { status = "error", message = "Landmark not found: " .. obs.landmark }
    end

    local ok, pt = pcall(function()
      return item:getPoint()
    end)
    if not ok or not pt then
      return { status = "error", message = "Landmark has no position: " .. obs.landmark }
    end

    local ok2, title = pcall(function()
      return item:getTitle()
    end)
    table.insert(resolved, {
      name = ok2 and title or obs.landmark,
      lat = pt:getLatitude(),
      lon = pt:getLongitude(),
      bearing = obs.bearing_deg,
    })
  end

  -- Resection algorithm: least-squares intersection of bearing lines
  -- The bearing FROM observer TO landmark means the back-bearing is bearing + 180
  -- So the line from the landmark toward the observer is at (bearing + 180) degrees
  local rad = math.pi / 180
  local mPerDegLat = 111320

  -- Convert to local Cartesian (meters) centered on first landmark
  local refLat = resolved[1].lat
  local refLon = resolved[1].lon
  local mPerDegLon = 111320 * Math:cos(refLat * rad)

  -- For each pair of observations, compute intersection
  local intersections = {}
  for i = 1, #resolved do
    for j = i + 1, #resolved do
      local obs1 = resolved[i]
      local obs2 = resolved[j]

      -- Back-bearings: from landmark toward observer
      local bb1 = (obs1.bearing + 180) % 360
      local bb2 = (obs2.bearing + 180) % 360

      -- Convert landmarks to local coords
      local x1 = (obs1.lon - refLon) * mPerDegLon
      local y1 = (obs1.lat - refLat) * mPerDegLat
      local x2 = (obs2.lon - refLon) * mPerDegLon
      local y2 = (obs2.lat - refLat) * mPerDegLat

      -- Direction vectors (bearing: 0=N, 90=E)
      local dx1 = Math:sin(bb1 * rad)
      local dy1 = Math:cos(bb1 * rad)
      local dx2 = Math:sin(bb2 * rad)
      local dy2 = Math:cos(bb2 * rad)

      -- Line intersection: P1 + t1*D1 = P2 + t2*D2
      local denom = dx1 * dy2 - dy1 * dx2
      if math.abs(denom) > 0.0001 then
        local t1 = ((x2 - x1) * dy2 - (y2 - y1) * dx2) / denom
        local ix = x1 + t1 * dx1
        local iy = y1 + t1 * dy1
        table.insert(intersections, { x = ix, y = iy })
      end
    end
  end

  if #intersections == 0 then
    return { status = "error", message = "Bearing lines are parallel — cannot compute intersection" }
  end

  -- Average all intersection points
  local sumX, sumY = 0, 0
  for _, pt in ipairs(intersections) do
    sumX = sumX + pt.x
    sumY = sumY + pt.y
  end
  local avgX = sumX / #intersections
  local avgY = sumY / #intersections

  -- Convert back to lat/lon
  local estLat = refLat + avgY / mPerDegLat
  local estLon = refLon + avgX / mPerDegLon

  -- Compute error estimate (max distance from any intersection to the average)
  local maxError = 0
  for _, pt in ipairs(intersections) do
    local dx = pt.x - avgX
    local dy = pt.y - avgY
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist > maxError then
      maxError = dist
    end
  end

  -- Build landmark summary
  local landmarks = {}
  for _, r in ipairs(resolved) do
    table.insert(landmarks, {
      name = r.name,
      lat = r.lat,
      lon = r.lon,
      bearing_to_landmark = r.bearing,
    })
  end

  return {
    status = "success",
    estimated_position = {
      lat = math.floor(estLat * 1000000) / 1000000,
      lon = math.floor(estLon * 1000000) / 1000000,
    },
    error_estimate_m = math.floor(maxError * 10) / 10,
    num_intersections = #intersections,
    landmarks_used = landmarks,
    warning = maxError > 500 and "High error — bearings may be inaccurate" or nil,
  }
end
