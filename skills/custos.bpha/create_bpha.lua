--- Create a Battle Position Holding Area
-- @tool create_bpha
-- @description Create a BPHA (Battle Position Holding Area) as a rectangle on the map. Optionally subdivides into rows and columns for sector assignment.
-- @tparam number lat Center latitude
-- @tparam number lon Center longitude
-- @tparam number width_m Width in meters (east-west)
-- @tparam number height_m Height in meters (north-south)
-- @tparam string name BPHA name/label (default: BPHA)
-- @tparam integer rows Number of rows for grid subdivision (default: 1)
-- @tparam integer cols Number of columns for grid subdivision (default: 1)
-- @tparam string fill_color Fill color as hex ARGB (default: #3000FF00)
-- @tparam string stroke_color Stroke color as hex ARGB (default: #FF00FF00)
-- @impact PROCEDURAL
function create_bpha(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local DrawingShape = import("com.atakmap.android.drawing.mapItems.DrawingShape")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
  local Color = import("android.graphics.Color")
  local UUID = import("java.util.UUID")
  local Array = import("java.lang.reflect.Array")
  local Math = import("java.lang.Math")

  local lat = params.lat
  local lon = params.lon
  local widthM = params.width_m or 500
  local heightM = params.height_m or 500
  local name = params.name or "BPHA"
  local rows = params.rows or 1
  local cols = params.cols or 1

  if not lat or not lon then
    return { status = "error", message = "lat and lon are required" }
  end

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

  local fillColor = parseColor(params.fill_color, Color:argb(48, 0, 255, 0))
  local strokeColor = parseColor(params.stroke_color, Color:argb(255, 0, 255, 0))

  local rad = math.pi / 180
  local mPerDegLat = 111320
  local mPerDegLon = 111320 * Math:cos(lat * rad)

  local halfW = widthM / 2
  local halfH = heightM / 2
  local dLat = halfH / mPerDegLat
  local dLon = halfW / mPerDegLon

  local uids = {}

  runOnUiThread(function()
    local mapView = MapView:getMapView()
    local rootGroup = mapView:getRootGroup()
    local drawingGroup = rootGroup:findMapGroup("Drawing Objects") or rootGroup:addGroup("Drawing Objects")

    -- Create subdivided grid cells
    local cellW = widthM / cols
    local cellH = heightM / rows
    local cellDLat = cellH / mPerDegLat
    local cellDLon = cellW / mPerDegLon

    local topLat = lat + dLat
    local leftLon = lon - dLon

    for r = 0, rows - 1 do
      for c = 0, cols - 1 do
        local cellUid = UUID:randomUUID():toString()
        local cellTopLat = topLat - r * cellDLat
        local cellBotLat = cellTopLat - cellDLat
        local cellLeftLon = leftLon + c * cellDLon
        local cellRightLon = cellLeftLon + cellDLon

        local corners = Array:newInstance(GeoPoint, 4)
        Array:set(corners, 0, GeoPoint(cellTopLat, cellLeftLon))
        Array:set(corners, 1, GeoPoint(cellTopLat, cellRightLon))
        Array:set(corners, 2, GeoPoint(cellBotLat, cellRightLon))
        Array:set(corners, 3, GeoPoint(cellBotLat, cellLeftLon))

        local cellName = name
        if rows > 1 or cols > 1 then
          cellName = name .. "-" .. string.char(64 + r + 1) .. tostring(c + 1)
        end

        local shape = DrawingShape(mapView, drawingGroup, cellUid)
        shape:setTitle(cellName)
        shape:setPoints(corners)
        shape:setClosed(true)
        shape:setFillColor(fillColor)
        shape:setStrokeColor(strokeColor)
        shape:setStrokeWeight(3)
        shape:setStyle(shape:getStyle() + 4)

        drawingGroup:addItem(shape)
        shape:persist(mapView:getMapEventDispatcher(), nil, shape:getClass())

        table.insert(uids, cellUid)
      end
    end
  end)

  return {
    status = "success",
    name = name,
    lat = lat,
    lon = lon,
    width_m = widthM,
    height_m = heightM,
    rows = rows,
    cols = cols,
    cells = rows * cols,
    uids = uids,
  }
end
