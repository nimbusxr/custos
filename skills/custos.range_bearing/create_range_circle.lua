--- Create a range circle on the map
-- @tool create_range_circle
-- @description Create a visible range circle (DrawingCircle) centered at the specified location with a given radius. Useful for standoff distances, weapon ranges, and communication ranges.
-- @tparam number lat Center latitude
-- @tparam number lon Center longitude
-- @tparam number radius_m Radius in meters
-- @tparam string name Circle label/name (default: Range Circle)
-- @tparam string fill_color Fill color as hex ARGB (default: #40FFFF00)
-- @tparam string stroke_color Stroke color as hex ARGB (default: #FFFFFF00)
-- @impact PROCEDURAL
function create_range_circle(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local DrawingCircle = import("com.atakmap.android.drawing.mapItems.DrawingCircle")
  local GeoPointMetaData = import("com.atakmap.coremap.maps.coords.GeoPointMetaData")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
  local Color = import("android.graphics.Color")
  local UUID = import("java.util.UUID")

  local lat = params.lat
  local lon = params.lon
  local radius = params.radius_m
  local name = params.name or "Range Circle"

  if not lat or not lon or not radius then
    return { status = "error", message = "lat, lon, and radius_m are required" }
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

  local fillColor = parseColor(params.fill_color, Color:argb(64, 255, 255, 0))
  local strokeColor = parseColor(params.stroke_color, Color:argb(255, 255, 255, 0))

  runOnUiThread(function()
    local mapView = MapView:getMapView()
    local rootGroup = mapView:getRootGroup()
    local drawingGroup = rootGroup:findMapGroup("Drawing Objects") or rootGroup:addGroup("Drawing Objects")

    local circle = DrawingCircle(mapView, uid, "", drawingGroup)
    circle:setTitle(name)
    circle:setCenterPoint(GeoPointMetaData(GeoPoint(lat, lon)))
    circle:setRadius(radius)
    circle:setFillColor(fillColor)
    circle:setStrokeColor(strokeColor)
    circle:setStrokeWeight(3)
    circle:setStyle(circle:getStyle() + 4)

    drawingGroup:addItem(circle)
    circle:persist(mapView:getMapEventDispatcher(), nil, circle:getClass())
  end)

  return {
    status = "success",
    uid = uid,
    name = name,
    lat = lat,
    lon = lon,
    radius_m = radius,
  }
end
