--- List all routes on the map
-- @tool list_routes
-- @description List all route polylines currently on the map with their names, UIDs, and type codes
-- @impact READ_ONLY
function list_routes(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local rootGroup = MapView:getMapView():getRootGroup()

  local routes = {}
  local allItems = rootGroup:getItemsRecursive()
  local iter = allItems:iterator()
  while iter:hasNext() do
    local item = iter:next()
    local ok, itemType = pcall(function()
      return item:getType()
    end)
    if not ok then
      itemType = ""
    end
    itemType = itemType or ""

    -- Routes have type "b-m-r" or contain "route" in metadata
    local isRoute = itemType == "b-m-r" or itemType:find("route", 1, true) ~= nil
    if not isRoute then
      local ok2, meta = pcall(function()
        return item:getMetaString("shapeName", nil)
      end)
      if ok2 and meta then
        -- Check if it's a polyline that acts as a route
        local ok3, isR = pcall(function()
          return item:getMetaBoolean("route", false)
        end)
        if ok3 and isR then
          isRoute = true
        end
      end
    end

    if isRoute then
      local ok3, title = pcall(function()
        return item:getTitle()
      end)
      if ok3 and title then
        local entry = {
          uid = item:getUID(),
          name = title,
          type = itemType,
        }
        -- Try to get point count if it's a polyline
        local ok4, numPts = pcall(function()
          return item:getNumPoints()
        end)
        if ok4 and numPts then
          entry.point_count = numPts
        end
        table.insert(routes, entry)
      end
    end
  end

  return { routes = routes, count = #routes }
end
