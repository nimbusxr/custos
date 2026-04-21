--- Delete markers from the map by name and/or geographic bounds
-- @tool delete_markers
-- @description Delete map markers matching a callsign/label (partial match) and/or within geographic bounds. At least one filter (query or bounds) is required. Returns the list of deleted markers.
-- @tparam string query Callsign or partial name to match (case-insensitive)
-- @tparam number north Northern latitude bound
-- @tparam number south Southern latitude bound
-- @tparam number east Eastern longitude bound
-- @tparam number west Western longitude bound
-- @impact SIGNIFICANT
function delete_markers(params)
    local MapView = import("com.atakmap.android.maps.MapView")

    local query = params.query
    local north = params.north
    local south = params.south
    local east = params.east
    local west = params.west

    local hasBounds = north and south and east and west
    local hasQuery = query and query ~= ""

    if not hasBounds and not hasQuery then
        return { status = "error", message = "Provide a query, bounds (north/south/east/west), or both" }
    end

    local mapView = MapView:getMapView()
    local rootGroup = mapView:getRootGroup()
    local selfUid = mapView:getSelfMarker() and mapView:getSelfMarker():getUID() or nil

    -- Collect matching items first (don't modify during iteration)
    local toDelete = {}
    local queryLower = hasQuery and query:lower() or nil

    local allItems = rootGroup:getItemsRecursive()
    local iter = allItems:iterator()
    while iter:hasNext() do
        local item = iter:next()

        -- Never delete the self-marker
        local uid = item:getUID()
        if uid == selfUid then goto continue end

        local ok, title = pcall(function() return item:getTitle() end)
        if not ok or not title then goto continue end

        local ok2, point = pcall(function() return item:getPoint() end)
        if not ok2 or not point then goto continue end

        -- Apply query filter
        if hasQuery and not title:lower():find(queryLower, 1, true) then
            goto continue
        end

        -- Apply bounds filter
        if hasBounds then
            local lat = point:getLatitude()
            local lon = point:getLongitude()
            if lat < south or lat > north or lon < west or lon > east then
                goto continue
            end
        end

        table.insert(toDelete, {
            item = item,
            uid = uid,
            callsign = title,
            lat = point:getLatitude(),
            lon = point:getLongitude(),
            type = item:getType() or ""
        })

        ::continue::
    end

    if #toDelete == 0 then
        return { status = "success", message = "No matching markers found", deleted = 0 }
    end

    -- Delete on UI thread
    runOnUiThread(function()
        for _, entry in ipairs(toDelete) do
            local ok, parent = pcall(function() return entry.item:getGroup() end)
            if ok and parent then
                pcall(function() parent:removeItem(entry.item) end)
            end
        end
    end)

    -- Build response (without item references)
    local deleted = {}
    for _, entry in ipairs(toDelete) do
        table.insert(deleted, {
            uid = entry.uid,
            callsign = entry.callsign,
            lat = entry.lat,
            lon = entry.lon,
            type = entry.type
        })
    end

    return {
        status = "success",
        deleted = #deleted,
        items = deleted
    }
end
