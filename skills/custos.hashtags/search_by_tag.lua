--- Search for map items by hashtag
-- @tool search_by_tag
-- @description Search for map items that have a specific hashtag applied. Uses ATAK's HashtagManager.
-- @tparam string tag Hashtag to search for (with or without # prefix)
-- @tparam integer max_items Maximum items to return (default: 20)
-- @impact READ_ONLY
function search_by_tag(params)
  local MapView = import("com.atakmap.android.maps.MapView")

  local tag = params.tag
  local maxItems = params.max_items or 20

  if not tag or tag == "" then
    return { status = "error", message = "tag is required" }
  end

  -- Ensure tag has # prefix
  if tag:sub(1, 1) ~= "#" then
    tag = "#" .. tag
  end

  local results = {}

  -- Try HashtagManager first
  local ok, err = pcall(function()
    local HashtagManager = import("com.atakmap.android.hashtags.HashtagManager")
    local hm = HashtagManager:getInstance()
    if not hm then
      return
    end

    local items = hm:search(tag)
    if not items then
      return
    end

    local iter = items:iterator()
    while iter:hasNext() and #results < maxItems do
      local item = iter:next()
      local entry = {}

      local ok2, uid = pcall(function()
        return item:getUID()
      end)
      if ok2 then
        entry.uid = uid
      end

      local ok3, title = pcall(function()
        return item:getTitle()
      end)
      if ok3 and title then
        entry.callsign = title
      end

      local ok4, point = pcall(function()
        return item:getPoint()
      end)
      if ok4 and point then
        entry.lat = point:getLatitude()
        entry.lon = point:getLongitude()
      end

      entry.type = item:getType() or ""

      table.insert(results, entry)
    end
  end)

  -- Fallback: scan all items for hashtag in metadata
  if #results == 0 then
    pcall(function()
      local mapView = MapView:getMapView()
      local rootGroup = mapView:getRootGroup()
      local allItems = rootGroup:getItemsRecursive()
      local iter = allItems:iterator()
      while iter:hasNext() and #results < maxItems do
        local item = iter:next()
        local ok2, hashtags = pcall(function()
          return item:getMetaString("hashtags", "")
        end)
        if ok2 and hashtags and hashtags:find(tag, 1, true) then
          local entry = { uid = item:getUID() }
          local ok3, title = pcall(function()
            return item:getTitle()
          end)
          if ok3 then
            entry.callsign = title
          end
          local ok4, point = pcall(function()
            return item:getPoint()
          end)
          if ok4 and point then
            entry.lat = point:getLatitude()
            entry.lon = point:getLongitude()
          end
          entry.type = item:getType() or ""
          table.insert(results, entry)
        end
      end
    end)
  end

  return {
    tag = tag,
    items = results,
    count = #results,
  }
end
