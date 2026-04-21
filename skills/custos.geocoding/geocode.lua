--- Geocode a street address to coordinates
-- @tool geocode
-- @description Convert a street address or place name to lat/lon coordinates using ATAK's GeocodeManager.
-- @tparam string address Address or place name to geocode
-- @impact READ_ONLY
function geocode(params)
  local address = params.address
  if not address or address == "" then
    return { status = "error", message = "address is required" }
  end

  local results = {}

  -- Try ATAK's GeocodeManager
  local ok, err = pcall(function()
    local GeocodeManager = import("com.atakmap.android.user.geocode.GeocodeManager")
    local gm = GeocodeManager:getInstance()
    if not gm then
      return
    end

    local MapView = import("com.atakmap.android.maps.MapView")
    local mapView = MapView:getMapView()

    -- Get map center as bias point for geocoding
    local center = mapView:getMapController():getPoint()
    local centerLat = center:getLatitude()
    local centerLon = center:getLongitude()

    local hits = gm:geocode(address)
    if not hits then
      return
    end

    local iter = hits:iterator()
    while iter:hasNext() do
      local hit = iter:next()
      local entry = {}

      pcall(function()
        local pt = hit:getPoint()
        entry.lat = pt:getLatitude()
        entry.lon = pt:getLongitude()
      end)

      pcall(function()
        entry.formatted_address = hit:getDescription()
      end)

      if entry.lat and entry.lon then
        table.insert(results, entry)
      end
    end
  end)

  -- Fallback: try Android Geocoder
  if #results == 0 then
    pcall(function()
      local Geocoder = import("android.location.Geocoder")
      local MapView = import("com.atakmap.android.maps.MapView")
      local context = MapView:getMapView():getContext()

      local geocoder = Geocoder(context)
      local addresses = geocoder:getFromLocationName(address, 5)
      if addresses then
        local iter = addresses:iterator()
        while iter:hasNext() do
          local addr = iter:next()
          local entry = {
            lat = addr:getLatitude(),
            lon = addr:getLongitude(),
          }
          pcall(function()
            local parts = {}
            local maxIdx = addr:getMaxAddressLineIndex()
            for i = 0, maxIdx do
              local line = addr:getAddressLine(i)
              if line then
                table.insert(parts, line)
              end
            end
            entry.formatted_address = table.concat(parts, ", ")
          end)
          table.insert(results, entry)
        end
      end
    end)
  end

  if #results == 0 then
    return { status = "error", message = "No results found for: " .. address }
  end

  return {
    query = address,
    results = results,
    count = #results,
  }
end
