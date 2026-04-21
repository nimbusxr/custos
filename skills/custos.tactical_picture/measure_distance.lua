---@class LabeledPoint
---@field label string "coordinates", "self", or the resolved item title
---@field lat number latitude in decimal degrees
---@field lon number longitude in decimal degrees

---@class DistanceMeasurement
---@field from LabeledPoint starting point
---@field to LabeledPoint destination point
---@field distance_m number great-circle distance in meters
---@field bearing_deg number bearing from `from` to `to` (0=N, clockwise)

--- Measure distance and bearing between two points or map items
-- @tool measure_distance
-- @description Calculate distance and bearing between two points. Each point can be lat/lon coordinates or a map item UID/callsign. Defaults to operator position if from is omitted. On error returns { status="error", message=... } instead of DistanceMeasurement.
-- @tparam string from_id UID or callsign of the starting item
-- @tparam number from_lat Starting latitude (used if from_id not provided)
-- @tparam number from_lon Starting longitude (used if from_id not provided)
-- @tparam string to_id UID or callsign of the destination item
-- @tparam number to_lat Destination latitude (used if to_id not provided)
-- @tparam number to_lon Destination longitude (used if to_id not provided)
---@return DistanceMeasurement
-- @impact READ_ONLY
function measure_distance(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")

  local mapView = MapView:getMapView()
  local rootGroup = mapView:getRootGroup()

  local function resolve_item(id)
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
      local candidate = iter:next()
      local s, title = pcall(function()
        return candidate:getTitle()
      end)
      if s and title and title:lower():find(query, 1, true) then
        return candidate
      end
    end
    return nil
  end

  local Math = import("java.lang.Math")
  local function calc_bearing(lat1, lon1, lat2, lon2)
    local rad = math.pi / 180
    local la1, la2 = lat1 * rad, lat2 * rad
    local dLon = (lon2 - lon1) * rad
    local y = math.sin(dLon) * math.cos(la2)
    local x = math.cos(la1) * math.sin(la2) - math.sin(la1) * math.cos(la2) * math.cos(dLon)
    return (Math:atan2(y, x) / rad + 360) % 360
  end

  -- Resolve "from" point
  local fromLabel, fromLat, fromLon
  if params.from_id then
    local item = resolve_item(params.from_id)
    if not item then
      return { status = "error", message = "From item not found: '" .. params.from_id .. "'" }
    end
    local ok, p = pcall(function()
      return item:getPoint()
    end)
    if not ok or not p then
      return { status = "error", message = "From item has no position" }
    end
    local ok_t, t = pcall(function()
      return item:getTitle()
    end)
    fromLabel = ok_t and t or params.from_id
    fromLat = p:getLatitude()
    fromLon = p:getLongitude()
  elseif params.from_lat and params.from_lon then
    fromLabel = "coordinates"
    fromLat = params.from_lat
    fromLon = params.from_lon
  else
    local selfMarker = mapView:getSelfMarker()
    if not selfMarker then
      return { status = "error", message = "No from point: provide from_id, from_lat/from_lon, or wait for GPS fix" }
    end
    local sp = selfMarker:getPoint()
    local ok_t, t = pcall(function()
      return selfMarker:getTitle()
    end)
    fromLabel = ok_t and t or "self"
    fromLat = sp:getLatitude()
    fromLon = sp:getLongitude()
  end

  -- Resolve "to" point
  local toLabel, toLat, toLon
  if params.to_id then
    local item = resolve_item(params.to_id)
    if not item then
      return { status = "error", message = "To item not found: '" .. params.to_id .. "'" }
    end
    local ok, p = pcall(function()
      return item:getPoint()
    end)
    if not ok or not p then
      return { status = "error", message = "To item has no position" }
    end
    local ok_t, t = pcall(function()
      return item:getTitle()
    end)
    toLabel = ok_t and t or params.to_id
    toLat = p:getLatitude()
    toLon = p:getLongitude()
  elseif params.to_lat and params.to_lon then
    toLabel = "coordinates"
    toLat = params.to_lat
    toLon = params.to_lon
  else
    return { status = "error", message = "No destination: provide to_id or to_lat/to_lon" }
  end

  local fromPoint = GeoPoint(fromLat, fromLon)
  local toPoint = GeoPoint(toLat, toLon)
  local dist = fromPoint:distanceTo(toPoint)
  local brng = calc_bearing(fromLat, fromLon, toLat, toLon)

  return {
    from = { label = fromLabel, lat = fromLat, lon = fromLon },
    to = { label = toLabel, lat = toLat, lon = toLon },
    distance_m = math.floor(dist * 10) / 10,
    bearing_deg = math.floor(brng * 10) / 10,
  }
end
