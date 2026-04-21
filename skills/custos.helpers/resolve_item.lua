--- Resolve a map item by UID or callsign
-- @tool resolve_item
-- @description Find a map item by UID or callsign (case-insensitive partial match)
-- @tparam string identifier UID or callsign to search for
-- @impact READ_ONLY
function resolve_item(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local mapView = MapView:getMapView()
  local rootGroup = mapView:getRootGroup()
  local identifier = params.identifier

  -- Try UID first
  local ok, found = pcall(function()
    return rootGroup:deepFindUID(identifier)
  end)
  if ok and found then
    local pt = found:getPoint()
    return {
      uid = found:getUID(),
      callsign = found:getTitle() or "",
      lat = pt:getLatitude(),
      lon = pt:getLongitude(),
      item = found,
    }
  end

  -- Fallback: search by callsign/title
  local allItems = rootGroup:getItemsRecursive()
  local iter = allItems:iterator()
  local query = identifier:lower()
  while iter:hasNext() do
    local item = iter:next()
    local ok2, title = pcall(function()
      return item:getTitle()
    end)
    if ok2 and title and title:lower():find(query, 1, true) then
      local pt = item:getPoint()
      return {
        uid = item:getUID(),
        callsign = title,
        lat = pt:getLatitude(),
        lon = pt:getLongitude(),
        item = item,
      }
    end
  end
  return { status = "error", message = "Item not found: " .. identifier }
end
