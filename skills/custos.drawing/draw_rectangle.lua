--- Draw a rectangle on the map from corner coordinates
-- @tool draw_rectangle
-- @description Draw a filled rectangle on the ATAK map. Provide the center point and dimensions, or four corner points.
-- @tparam string title Display name for the rectangle
-- @tparam number center_lat Center latitude
-- @tparam number center_lon Center longitude
-- @tparam number width_m Width in meters (east-west)
-- @tparam number height_m Height in meters (north-south)
-- @tparam string fill_color Fill color as hex ARGB (default: #4000FF00)
-- @tparam string stroke_color Stroke color as hex ARGB (default: #FF00FF00)
-- @tparam number stroke_weight Stroke width in pixels (default: 3)
-- @impact PROCEDURAL
function draw_rectangle(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local DrawingShape = import("com.atakmap.android.drawing.mapItems.DrawingShape")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
  local Color = import("android.graphics.Color")
  local UUID = import("java.util.UUID")
  local Array = import("java.lang.reflect.Array")
  local Math = import("java.lang.Math")

  local title = params.title or "Rectangle"
  local uid = UUID:randomUUID():toString()

  -- Approximate meter offsets to lat/lon degrees
  local lat = params.center_lat
  local lon = params.center_lon
  local halfW = (params.width_m or 100) / 2
  local halfH = (params.height_m or 100) / 2

  local mPerDegLat = 111320
  local mPerDegLon = 111320 * Math:cos(Math:toRadians(lat))

  local dLat = halfH / mPerDegLat
  local dLon = halfW / mPerDegLon

  -- Four corners: NW, NE, SE, SW
  local corners = {
    { lat = lat + dLat, lon = lon - dLon },
    { lat = lat + dLat, lon = lon + dLon },
    { lat = lat - dLat, lon = lon + dLon },
    { lat = lat - dLat, lon = lon - dLon },
  }

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

  local fillColor = parseColor(params.fill_color, Color:argb(64, 0, 255, 0))
  local strokeColor = parseColor(params.stroke_color, Color:argb(255, 0, 255, 0))
  local strokeWeight = params.stroke_weight or 3

  local geoPoints = Array:newInstance(GeoPoint, 4)
  for i = 1, 4 do
    Array:set(geoPoints, i - 1, GeoPoint(corners[i].lat, corners[i].lon))
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
    shape:setStyle(shape:getStyle() + 4)

    drawingGroup:addItem(shape)
    shape:persist(mapView:getMapEventDispatcher(), nil, shape:getClass())
  end)

  return {
    status = "success",
    uid = uid,
    title = title,
    width_m = params.width_m or 100,
    height_m = params.height_m or 100,
  }
end
