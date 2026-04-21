--- Create a sensor field-of-view cone on the map
-- @tool create_sensor_fov
-- @description Create a sensor FOV visualization showing the observation cone. Draws a filled arc on the map representing the sensor's coverage area.
-- @tparam number lat Sensor latitude
-- @tparam number lon Sensor longitude
-- @tparam number azimuth_deg Center azimuth of the FOV in degrees from north
-- @tparam number fov_deg Field of view angle in degrees
-- @tparam number range_m Sensor range in meters
-- @tparam string name Sensor name/label (default: Sensor FOV)
-- @tparam string fill_color Fill color as hex ARGB (default: #4000FFFF)
-- @tparam string stroke_color Stroke color as hex ARGB (default: #FF00FFFF)
-- @impact PROCEDURAL
function create_sensor_fov(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local DrawingShape = import("com.atakmap.android.drawing.mapItems.DrawingShape")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
  local Color = import("android.graphics.Color")
  local UUID = import("java.util.UUID")
  local Array = import("java.lang.reflect.Array")
  local Math = import("java.lang.Math")

  local lat = params.lat
  local lon = params.lon
  local azimuth = params.azimuth_deg
  local fov = params.fov_deg
  local range = params.range_m
  local name = params.name or "Sensor FOV"

  if not lat or not lon or not azimuth or not fov or not range then
    return { status = "error", message = "lat, lon, azimuth_deg, fov_deg, and range_m are required" }
  end

  local uid = UUID:randomUUID():toString()

  local function parseColor(hex, default)
    if not hex then
      return default
    end
    hex = hex:gsub("^#", "")
    if #hex == 8 then
      local a = tonumber(hex:sub(1, 2), 16) or 0
      local r = tonumber(hex:sub(3, 4), 16) or 0
      local g = tonumber(hex:sub(5, 6), 16) or 0
      local b = tonumber(hex:sub(7, 8), 16) or 0
      return Color:argb(a, r, g, b)
    end
    return default
  end

  local fillColor = parseColor(params.fill_color, Color:argb(64, 0, 255, 255))
  local strokeColor = parseColor(params.stroke_color, Color:argb(255, 0, 255, 255))

  -- Build FOV polygon: sensor point + arc points along the FOV boundary
  local rad = math.pi / 180
  local startAngle = azimuth - fov / 2
  local endAngle = azimuth + fov / 2

  -- Calculate arc points (destination point given bearing and distance)
  local mPerDegLat = 111320
  local mPerDegLon = 111320 * Math:cos(lat * rad)

  local arcPoints = {}
  -- Start with sensor location
  table.insert(arcPoints, { lat = lat, lon = lon })

  -- Generate arc points (every 2 degrees along the FOV)
  local step = 2
  if fov <= 10 then
    step = 1
  end
  local angle = startAngle
  while angle <= endAngle do
    local bearingRad = angle * rad
    local dLat = range * Math:cos(bearingRad) / mPerDegLat
    local dLon = range * Math:sin(bearingRad) / mPerDegLon
    table.insert(arcPoints, { lat = lat + dLat, lon = lon + dLon })
    angle = angle + step
  end
  -- Ensure end angle is included
  local bearingRad = endAngle * rad
  local dLat = range * Math:cos(bearingRad) / mPerDegLat
  local dLon = range * Math:sin(bearingRad) / mPerDegLon
  table.insert(arcPoints, { lat = lat + dLat, lon = lon + dLon })

  local numPoints = #arcPoints
  local geoPoints = Array:newInstance(GeoPoint, numPoints)
  for i = 1, numPoints do
    Array:set(geoPoints, i - 1, GeoPoint(arcPoints[i].lat, arcPoints[i].lon))
  end

  runOnUiThread(function()
    local mapView = MapView:getMapView()
    local rootGroup = mapView:getRootGroup()
    local drawingGroup = rootGroup:findMapGroup("Drawing Objects") or rootGroup:addGroup("Drawing Objects")

    local shape = DrawingShape(mapView, drawingGroup, uid)
    shape:setTitle(name)
    shape:setPoints(geoPoints)
    shape:setClosed(true)
    shape:setFillColor(fillColor)
    shape:setStrokeColor(strokeColor)
    shape:setStrokeWeight(2)
    shape:setStyle(shape:getStyle() + 4)

    drawingGroup:addItem(shape)
    shape:persist(mapView:getMapEventDispatcher(), nil, shape:getClass())
  end)

  return {
    status = "success",
    uid = uid,
    name = name,
    lat = lat,
    lon = lon,
    azimuth_deg = azimuth,
    fov_deg = fov,
    range_m = range,
    arc_points = numPoints,
  }
end
