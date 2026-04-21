--- List attachments on a map item
-- @tool list_attachments
-- @description List all files attached to a map item (photos, documents, etc). Resolves by callsign or UID.
-- @tparam string identifier Callsign or UID of the map item
-- @impact READ_ONLY
function list_attachments(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local File = import("java.io.File")

  local identifier = params.identifier
  if not identifier or identifier == "" then
    return { status = "error", message = "identifier is required" }
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

  local attachments = {}

  -- ATAK stores attachments under /sdcard/atak/attachments/<uid>/
  local attachDir = File("/sdcard/atak/attachments/" .. targetUid)
  if attachDir:exists() and attachDir:isDirectory() then
    local Array = import("java.lang.reflect.Array")
    local files = attachDir:listFiles()
    if files then
      local len = Array:getLength(files)
      for i = 0, len - 1 do
        local f = Array:get(files, i)
        if f:isFile() then
          table.insert(attachments, {
            name = f:getName(),
            path = f:getAbsolutePath(),
            size_bytes = f:length(),
          })
        end
      end
    end
  end

  return {
    uid = targetUid,
    callsign = callsign,
    attachments = attachments,
    count = #attachments,
  }
end
