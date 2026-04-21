--- Draw a closed polygon on the map from a list of lat/lon points
-- @tool draw_polygon
-- @description Draw a closed polygon (filled shape) on the ATAK map from a list of coordinate points. Use for sectors, boundaries, areas of interest, or any custom shape. Points are connected in order and the shape is automatically closed.
-- @tparam string title Display name for the shape
-- @tparam array points Array of {lat, lon} coordinate pairs defining the polygon vertices in order
-- @tparam string fill_color Fill color as hex ARGB (e.g., #40FF0000 for semi-transparent red) (default: #40FF0000)
-- @tparam string stroke_color Stroke/outline color as hex ARGB (default: #FFFF0000)
-- @tparam number stroke_weight Stroke width in pixels (default: 3)
-- @impact PROCEDURAL
function draw_polygon(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local DrawingShape = import("com.atakmap.android.drawing.mapItems.DrawingShape")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
  local Color = import("android.graphics.Color")
  local UUID = import("java.util.UUID")
  local Array = import("java.lang.reflect.Array")

  if not params.points or #params.points < 3 then
    return { status = "error", message = "At least 3 points required for a polygon" }
  end

  local title = params.title or "Polygon"
  local uid = UUID:randomUUID():toString()

  -- Parse hex ARGB color string to integer
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

  local fillColor = parseColor(params.fill_color, Color:argb(64, 255, 0, 0))
  local strokeColor = parseColor(params.stroke_color, Color:argb(255, 255, 0, 0))
  local strokeWeight = params.stroke_weight or 3

  -- Build GeoPoint array
  local numPoints = #params.points
  local geoPoints = Array:newInstance(GeoPoint, numPoints)
  for i = 1, numPoints do
    local pt = params.points[i]
    Array:set(geoPoints, i - 1, GeoPoint(pt.lat, pt.lon))
  end

  runOnUiThread(function()
    local mapView = MapView:getMapView()
    local rootGroup = mapView:getRootGroup()
    local drawingGroup = rootGroup:findMapGroup("Drawing Objects") or rootGroup:addGroup("Drawing Objects")

    local shape = DrawingShape(mapView, drawingGroup, uid)
    shape:setTitle(title)
    shape:setPoints(geoPoints)
    shape:setClosed(true)
    shape:setFillColor(fillColor)
    shape:setStrokeColor(strokeColor)
    shape:setStrokeWeight(strokeWeight)
    shape:setStyle(shape:getStyle() + 4) -- STYLE_FILLED_MASK

    drawingGroup:addItem(shape)
    shape:persist(mapView:getMapEventDispatcher(), nil, shape:getClass())
  end)

  return {
    status = "success",
    uid = uid,
    title = title,
    points = numPoints,
  }
end
