--- Draw a circle on the map at a given center point with a radius
-- @tool draw_circle
-- @description Draw a filled circle on the ATAK map at the specified center point with a radius in meters. Useful for standoff distances, blast radii, communication ranges, or area designations.
-- @tparam string title Display name for the circle
-- @tparam number center_lat Center latitude
-- @tparam number center_lon Center longitude
-- @tparam number radius_m Radius in meters
-- @tparam string fill_color Fill color as hex ARGB (default: #400000FF)
-- @tparam string stroke_color Stroke color as hex ARGB (default: #FF0000FF)
-- @tparam number stroke_weight Stroke width in pixels (default: 3)
-- @impact PROCEDURAL
function draw_circle(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local DrawingCircle = import("com.atakmap.android.drawing.mapItems.DrawingCircle")
  local GeoPointMetaData = import("com.atakmap.coremap.maps.coords.GeoPointMetaData")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
  local Color = import("android.graphics.Color")
  local UUID = import("java.util.UUID")

  local title = params.title or "Circle"
  local uid = UUID:randomUUID():toString()
  local radius = params.radius_m or 100

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

  local fillColor = parseColor(params.fill_color, Color:argb(64, 0, 0, 255))
  local strokeColor = parseColor(params.stroke_color, Color:argb(255, 0, 0, 255))
  local strokeWeight = params.stroke_weight or 3

  runOnUiThread(function()
    local mapView = MapView:getMapView()
    local rootGroup = mapView:getRootGroup()
    local drawingGroup = rootGroup:findMapGroup("Drawing Objects") or rootGroup:addGroup("Drawing Objects")

    local circle = DrawingCircle(mapView, uid, "", drawingGroup)
    circle:setTitle(title)
    circle:setCenterPoint(GeoPointMetaData(GeoPoint(params.center_lat, params.center_lon)))
    circle:setRadius(radius)
    circle:setFillColor(fillColor)
    circle:setStrokeColor(strokeColor)
    circle:setStrokeWeight(strokeWeight)
    circle:setStyle(circle:getStyle() + 4)

    drawingGroup:addItem(circle)
    circle:persist(mapView:getMapEventDispatcher(), nil, circle:getClass())
  end)

  return {
    status = "success",
    uid = uid,
    title = title,
    radius_m = radius,
  }
end
