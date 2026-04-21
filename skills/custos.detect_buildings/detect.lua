--- Capture map imagery and run building detection
-- @tool detect_buildings
-- @description Capture map imagery and run building detection via vision model. Geolocates detections and optionally places markers.
-- @tparam number north North boundary latitude (default: current map view)
-- @tparam number south South boundary latitude (default: current map view)
-- @tparam number east East boundary longitude (default: current map view)
-- @tparam number west West boundary longitude (default: current map view)
-- @tparam number confidence Minimum detection confidence 0-1 (default: 0.5)
-- @tparam boolean place_markers Place markers at detection locations (default: true)
-- @impact PROCEDURAL
function detect_buildings(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
  local GeoBounds = import("com.atakmap.coremap.maps.coords.GeoBounds")
  local TileCapture = import("com.atakmap.android.tilecapture.TileCapture")
  local TileCaptureParams = import("com.atakmap.android.tilecapture.TileCaptureParams")
  local Bitmap = import("android.graphics.Bitmap")
  local Canvas = import("android.graphics.Canvas")
  local Matrix = import("android.graphics.Matrix")
  local Paint = import("android.graphics.Paint")
  local ByteArrayOutputStream = import("java.io.ByteArrayOutputStream")
  local Marker = import("com.atakmap.android.maps.Marker")
  local CotEvent = import("com.atakmap.coremap.cot.event.CotEvent")
  local CotPoint = import("com.atakmap.coremap.cot.event.CotPoint")
  local CotDetail = import("com.atakmap.coremap.cot.event.CotDetail")
  local CotMapComponent = import("com.atakmap.android.cot.CotMapComponent")
  local CoordinatedTime = import("com.atakmap.coremap.maps.time.CoordinatedTime")
  local UUID = import("java.util.UUID")

  local mapView = MapView:getMapView()
  local confidence = params.confidence or 0.5
  local placeMarkers = params.place_markers ~= false

  -- Resolve bounds
  local north = params.north
  local south = params.south
  local east = params.east
  local west = params.west

  if not north or not south or not east or not west then
    local viewBounds = mapView:getBounds()
    north = north or viewBounds:getNorth()
    south = south or viewBounds:getSouth()
    east = east or viewBounds:getEast()
    west = west or viewBounds:getWest()
  end

  -- Check vision provider
  local adapter = vision:getDetectionAdapter()
  if not adapter then
    return { status = "error", message = "No detection provider configured" }
  end

  -- Capture map imagery
  local tl = GeoPoint(north, west)
  local tr = GeoPoint(north, east)
  local br = GeoPoint(south, east)
  local bl = GeoPoint(south, west)

  -- LuaJava can't auto-convert Lua tables to Java arrays
  local Array = import("java.lang.reflect.Array")
  local cornerPoints = Array:newInstance(GeoPoint, 4)
  Array:set(cornerPoints, 0, tl)
  Array:set(cornerPoints, 1, tr)
  Array:set(cornerPoints, 2, br)
  Array:set(cornerPoints, 3, bl)

  local geoBounds = GeoBounds:createFromPoints(cornerPoints)
  local tileCapture = TileCapture:create(geoBounds) or TileCapture:createBasemapReader(mapView)
  if not tileCapture then
    return { status = "error", message = "Failed to create tile capture" }
  end

  local captureParams = TileCaptureParams()
  captureParams.points = cornerPoints
  captureParams.closedPoints = true
  captureParams.fitToQuad = true
  captureParams.mapResolution = mapView:getMapResolution()
  captureParams.captureResolution = 2
  captureParams.minImageSize = 640

  local tcBounds = tileCapture:getBounds(captureParams)
  local fullWidth = tcBounds.imageWidth
  local fullHeight = tcBounds.imageHeight
  local tileToPixel = tcBounds.tileToPixel

  if fullWidth <= 0 or fullHeight <= 0 then
    tileCapture:dispose()
    return { status = "error", message = "Invalid capture bounds: " .. fullWidth .. "x" .. fullHeight }
  end

  local outputBitmap = Bitmap:createBitmap(fullWidth, fullHeight, Bitmap.Config.ARGB_8888)
  local canvas = Canvas(outputBitmap)
  local tilePaint = Paint(Paint.FILTER_BITMAP_FLAG)
  local stdTileW = 0
  local stdTileH = 0

  tileCapture:capture(captureParams, {
    onStartCapture = function(self, tileCount, tw, th, fw, fh)
      stdTileW = tw
      stdTileH = th
      return true
    end,
    onCaptureTile = function(self, tile, tileNum, tileColumn, tileRow)
      if tile then
        local drawMatrix = Matrix()
        drawMatrix:postTranslate(tileColumn * stdTileW, tileRow * stdTileH)
        drawMatrix:postConcat(tileToPixel)
        canvas:drawBitmap(tile, drawMatrix, tilePaint)
        tile:recycle()
      end
      return true
    end,
  })
  tileCapture:dispose()

  local baos = ByteArrayOutputStream()
  outputBitmap:compress(Bitmap.CompressFormat.JPEG, 90, baos)
  local imageBytes = baos:toByteArray()
  outputBitmap:recycle()

  -- Run detection
  local detectionResult = adapter:detect(imageBytes, confidence)
  local detections = detectionResult:getDetections()
  local count = detections:size()

  if count == 0 then
    return {
      status = "success",
      detected = 0,
    }
  end

  -- Geolocate detections
  local markerCount = 0
  local minConf = math.huge
  local maxConf = -math.huge
  for i = 0, count - 1 do
    local det = detections:get(i)

    local u = ((det:getX1() + det:getX2()) / 2.0) / fullWidth
    local v = ((det:getY1() + det:getY2()) / 2.0) / fullHeight
    local lat = north + v * (south - north)
    local lon = west + u * (east - west)

    markerCount = markerCount + 1
    local label = "BLD-" .. markerCount

    local conf = det:getConfidence()
    if conf < minConf then
      minConf = conf
    end
    if conf > maxConf then
      maxConf = conf
    end

    if placeMarkers then
      local uid = UUID:randomUUID():toString()
      local now = CoordinatedTime()
      local stale = CoordinatedTime(now:getMilliseconds() + 300000)

      -- Build CoT event
      local event = CotEvent()
      event:setUID(uid)
      event:setType("a-n-G")
      event:setHow(CotEvent.HOW_MACHINE_GENERATED)
      event:setPoint(CotPoint(lat, lon, 0, 0, 0))
      event:setTime(now)
      event:setStart(now)
      event:setStale(stale)

      local detail = CotDetail()
      local contact = CotDetail("contact")
      contact:setAttribute("callsign", label)
      detail:addChild(contact)
      event:setDetail(detail)

      -- processCotEvent is SYNCHRONOUS — marker exists in group tree when it returns
      local Bundle = import("android.os.Bundle")
      runOnUiThread(function()
        CotMapComponent:getInstance():processCotEvent(event, Bundle())

        -- Marker is now in the group tree — set render flags immediately
        local placed = mapView:getRootGroup():deepFindUID(uid)
        if placed then
          placed:setIconVisibility(Marker.ICON_GONE)
          placed:setTextRenderFlag(Marker.TEXT_STATE_ALWAYS_SHOW)
          placed:setShowLabel(true)
        end
      end)
    end
  end

  return {
    status = "success",
    detected = markerCount,
    placed = placeMarkers and markerCount or 0,
    labels = placeMarkers and ("BLD-1..BLD-" .. markerCount) or nil,
    confidence_range = string.format("%.2f-%.2f", minConf, maxConf),
  }
end
