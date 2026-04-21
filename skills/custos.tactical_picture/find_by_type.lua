---@class TypeFilter
---@field affiliation string|nil f/h/u/n if specified
---@field dimension string|nil G/A/S/U if specified
---@field type_prefix string|nil raw CoT prefix if specified

---@class TypedItem
---@field uid string map item UID
---@field callsign string item title
---@field lat number item latitude
---@field lon number item longitude
---@field type string full CoT type
---@field distance_m number|nil meters from self-marker, nil if no GPS
---@field bearing_deg number|nil degrees from self-marker, nil if no GPS

---@class FindByTypeResult
---@field filter TypeFilter the filter criteria applied
---@field items TypedItem[] sorted by distance (or callsign if no GPS)
---@field count integer number of items returned

--- Find map items by CoT type pattern
-- @tool find_by_type
-- @description Search for map items matching a CoT type pattern. Filter by affiliation (f/h/u/n), dimension (G/A/S/U), or raw type prefix. On error (no filters provided) returns { status="error", message=... } instead of FindByTypeResult.
-- @tparam string affiliation Affiliation code: f=friendly, h=hostile, u=unknown, n=neutral
-- @tparam string dimension Dimension code: G=ground, A=air, S=surface, U=subsurface
-- @tparam string type_prefix Raw CoT type prefix to match (overrides affiliation/dimension)
-- @tparam integer max_items Maximum items to return (default: 20)
---@return FindByTypeResult
-- @impact READ_ONLY
function find_by_type(params)
    local MapView = import("com.atakmap.android.maps.MapView")

    local mapView = MapView:getMapView()
    local rootGroup = mapView:getRootGroup()
    local maxItems = params.max_items or 20

    local Math = import("java.lang.Math")
    local function calc_bearing(lat1, lon1, lat2, lon2)
        local rad = math.pi / 180
        local la1, la2 = lat1 * rad, lat2 * rad
        local dLon = (lon2 - lon1) * rad
        local y = math.sin(dLon) * math.cos(la2)
        local x = math.cos(la1) * math.sin(la2) - math.sin(la1) * math.cos(la2) * math.cos(dLon)
        return (Math:atan2(y, x) / rad + 360) % 360
    end

    -- Build type prefix filter
    local prefix = params.type_prefix
    if not prefix then
        if not params.affiliation and not params.dimension then
            return { status = "error", message = "Provide at least one filter: affiliation, dimension, or type_prefix" }
        end
        if params.affiliation and params.dimension then
            prefix = "a-" .. params.affiliation .. "-" .. params.dimension
        elseif params.affiliation then
            prefix = "a-" .. params.affiliation
        else
            prefix = nil -- dimension-only requires scanning type parts
        end
    end

    local dimFilter = not prefix and params.dimension or nil

    -- Get self-marker for distance/bearing enrichment
    local selfMarker = mapView:getSelfMarker()
    local selfPoint = nil
    if selfMarker then
        selfPoint = selfMarker:getPoint()
    end

    local items = {}
    local allItems = rootGroup:getItemsRecursive()
    local iter = allItems:iterator()
    while iter:hasNext() do
        local item = iter:next()

        local ok, title = pcall(function() return item:getTitle() end)
        if not ok or not title then goto continue end

        local ok2, point = pcall(function() return item:getPoint() end)
        if not ok2 or not point then goto continue end

        local itemType = item:getType() or ""

        -- Apply type filter
        if prefix then
            if itemType:find(prefix, 1, true) ~= 1 then goto continue end
        elseif dimFilter then
            -- Match dimension at position 5 (a-X-D where D is dimension)
            local parts = {}
            for part in itemType:gmatch("[^-]+") do table.insert(parts, part) end
            if not parts[3] or parts[3] ~= dimFilter then goto continue end
        end

        local entry = {
            uid = item:getUID(),
            callsign = title,
            lat = point:getLatitude(),
            lon = point:getLongitude(),
            type = itemType
        }

        if selfPoint then
            local dist = selfPoint:distanceTo(point)
            local brng = calc_bearing(
                selfPoint:getLatitude(), selfPoint:getLongitude(),
                point:getLatitude(), point:getLongitude()
            )
            entry.distance_m = math.floor(dist * 10) / 10
            entry.bearing_deg = math.floor(brng * 10) / 10
        end

        table.insert(items, entry)
        ::continue::
    end

    -- Sort by distance if available, otherwise by callsign
    if selfPoint then
        table.sort(items, function(a, b) return a.distance_m < b.distance_m end)
    else
        table.sort(items, function(a, b) return a.callsign < b.callsign end)
    end

    -- Truncate to max_items
    local result = {}
    for i = 1, math.min(#items, maxItems) do
        table.insert(result, items[i])
    end

    local filter = {}
    if params.affiliation then filter.affiliation = params.affiliation end
    if params.dimension then filter.dimension = params.dimension end
    if params.type_prefix then filter.type_prefix = params.type_prefix end

    return {
        filter = filter,
        items = result,
        count = #result
    }
end
