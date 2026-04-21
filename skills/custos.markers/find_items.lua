---@class FoundItem
---@field uid string map item UID
---@field callsign string item title
---@field lat number item latitude
---@field lon number item longitude
---@field type string full CoT type

---@class FindItemsResult
---@field count integer number of items returned (max 5)
---@field items FoundItem[] matching items
---@field scanned integer total items scanned before stopping

--- Search for map items by callsign
-- @tool find_items
-- @description Search for map items by callsign (case-insensitive, max 5 results)
-- @tparam string query Callsign or partial name to search for
---@return FindItemsResult
-- @impact READ_ONLY
function find_items(params)
  local MapView = import("com.atakmap.android.maps.MapView")

  local mapView = MapView:getMapView()
  local rootGroup = mapView:getRootGroup()
  local results = {}
  local query = params.query:lower()
  local totalScanned = 0

  local allItems = rootGroup:getItemsRecursive()
  local iter = allItems:iterator()
  while iter:hasNext() do
    local item = iter:next()
    totalScanned = totalScanned + 1
    if #results >= 5 then
      break
    end

    local ok, title = pcall(function()
      return item:getTitle()
    end)
    if ok and title and title:lower():find(query, 1, true) then
      local ok2, point = pcall(function()
        return item:getPoint()
      end)
      if ok2 and point then
        table.insert(results, {
          uid = item:getUID(),
          callsign = title,
          lat = point:getLatitude(),
          lon = point:getLongitude(),
          type = item:getType(),
        })
      end
    end
  end

  return { count = #results, items = results, scanned = totalScanned }
end
