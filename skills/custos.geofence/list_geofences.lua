--- List all active geofences
-- @tool list_geofences
-- @description List all geofences currently configured with their status, trigger type, and dimensions
-- @impact READ_ONLY
function list_geofences(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local rootGroup = MapView:getMapView():getRootGroup()

  local fences = {}
  local allItems = rootGroup:getItemsRecursive()
  local iter = allItems:iterator()
  while iter:hasNext() do
    local item = iter:next()

    -- Check for geofence metadata markers
    local ok, hasGeo = pcall(function()
      return item:getMetaString("geofenceMonitor", nil) ~= nil or item:getMetaBoolean("geofence", false)
    end)

    if ok and hasGeo then
      local title = item:getTitle() or item:getUID()
      local entry = {
        uid = item:getUID(),
        name = title,
      }

      -- Get center point if available
      local okPt, pt = pcall(function()
        return item:getPoint()
      end)
      if okPt and pt then
        entry.lat = pt:getLatitude()
        entry.lon = pt:getLongitude()
      end

      -- Get radius if it's a circle
      local okR, radius = pcall(function()
        return item:getRadius()
      end)
      if okR and radius then
        entry.radius_m = math.floor(radius)
      end

      -- Get trigger type from metadata
      local okT, trigger = pcall(function()
        return item:getMetaString("geofenceTrigger", "entry")
      end)
      if okT and trigger then
        entry.trigger = trigger
      end

      table.insert(fences, entry)
    end
  end

  return { geofences = fences, count = #fences }
end
