--- Apply a hashtag to a map item
-- @tool tag_item
-- @description Apply a hashtag to a map item identified by callsign or UID. Uses ATAK's HashtagManager.
-- @tparam string identifier Callsign or UID of the item to tag
-- @tparam string tag Hashtag to apply (with or without # prefix)
-- @impact PROCEDURAL
function tag_item(params)
  local MapView = import("com.atakmap.android.maps.MapView")

  local identifier = params.identifier
  local tag = params.tag

  if not identifier or identifier == "" then
    return { status = "error", message = "identifier is required" }
  end
  if not tag or tag == "" then
    return { status = "error", message = "tag is required" }
  end

  -- Ensure tag has # prefix
  if tag:sub(1, 1) ~= "#" then
    tag = "#" .. tag
  end

  local mapView = MapView:getMapView()
  local rootGroup = mapView:getRootGroup()

  -- Resolve item
  local target = nil
  local ok, found = pcall(function()
    return rootGroup:deepFindUID(identifier)
  end)
  if ok and found then
    target = found
  else
    local query = identifier:lower()
    local allItems = rootGroup:getItemsRecursive()
    local iter = allItems:iterator()
    while iter:hasNext() do
      local item = iter:next()
      local s, title = pcall(function()
        return item:getTitle()
      end)
      if s and title and title:lower():find(query, 1, true) then
        target = item
        break
      end
    end
  end

  if not target then
    return { status = "error", message = "Item not found: " .. identifier }
  end

  local targetUid = target:getUID()
  local ok2, targetTitle = pcall(function()
    return target:getTitle()
  end)
  local callsign = ok2 and targetTitle or identifier

  -- Apply hashtag via HashtagManager
  local tagged = false
  local ok3, err = pcall(function()
    local HashtagManager = import("com.atakmap.android.hashtags.HashtagManager")
    local hm = HashtagManager:getInstance()
    if hm then
      hm:addTag(target, tag)
      tagged = true
    end
  end)

  -- Fallback: set hashtag via metadata
  if not tagged then
    pcall(function()
      local existing = target:getMetaString("hashtags", "")
      if existing == "" then
        target:setMetaString("hashtags", tag)
      else
        -- Avoid duplicates
        if not existing:find(tag, 1, true) then
          target:setMetaString("hashtags", existing .. " " .. tag)
        end
      end
      tagged = true
    end)
  end

  return {
    status = tagged and "success" or "error",
    uid = targetUid,
    callsign = callsign,
    tag = tag,
    message = tagged and ("Tagged " .. callsign .. " with " .. tag) or "Failed to apply tag",
  }
end
