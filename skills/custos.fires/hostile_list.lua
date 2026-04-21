---@class HostileSelfPos
---@field lat number operator latitude
---@field lon number operator longitude

---@class Hostile
---@field uid string map item UID
---@field callsign string hostile callsign
---@field lat number hostile latitude
---@field lon number hostile longitude
---@field type string full CoT type (always a-h prefix)
---@field distance_m number|nil meters from self-marker, nil if no GPS
---@field bearing_deg number|nil degrees from self (0=N), nil if no GPS
---@field bearing_dir string|nil 16-point compass direction, nil if no GPS

---@class HostileListResult
---@field count integer number of hostiles returned (after truncation)
---@field hostiles Hostile[] sorted by distance if GPS available, else by callsign
---@field self_position HostileSelfPos|nil nil if no self marker

--- List all hostile markers on the map
-- @tool hostile_list
-- @description List all hostile markers (CoT type prefix a-h) with callsign, position, type, distance and bearing from self position.
-- @tparam integer max_items Maximum number of hostile items to return (default: 50)
---@return HostileListResult
-- @impact READ_ONLY
function hostile_list(params)
    local MapView = import("com.atakmap.android.maps.MapView")
    local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
    local Math = import("java.lang.Math")

    local maxItems = params.max_items or 50

    local function calc_bearing(lat1, lon1, lat2, lon2)
        local rad = math.pi / 180
        local la1, la2 = lat1 * rad, lat2 * rad
        local dLon = (lon2 - lon1) * rad
        local y = math.sin(dLon) * math.cos(la2)
        local x = math.cos(la1) * math.sin(la2) - math.sin(la1) * math.cos(la2) * math.cos(dLon)
        return (Math:atan2(y, x) / rad + 360) % 360
    end

    local function compass_dir(deg)
        local dirs = {"N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW"}
        return dirs[math.floor((deg + 11.25) / 22.5) % 16 + 1]
    end

    local mapView = MapView:getMapView()
    local rootGroup = mapView:getRootGroup()

    -- Get self position for distance/bearing
    local selfMarker = mapView:getSelfMarker()
    local selfLat, selfLon, selfPoint
    if selfMarker then
        selfPoint = selfMarker:getPoint()
        selfLat = selfPoint:getLatitude()
        selfLon = selfPoint:getLongitude()
    end

    local hostiles = {}
    local allItems = rootGroup:getItemsRecursive()
    local iter = allItems:iterator()
    while iter:hasNext() do
        local item = iter:next()

        local itemType = item:getType() or ""
        if itemType:find("a-h", 1, true) ~= 1 then goto continue end

        local ok, title = pcall(function() return item:getTitle() end)
        if not ok or not title then goto continue end

        local ok2, point = pcall(function() return item:getPoint() end)
        if not ok2 or not point then goto continue end

        local entry = {
            uid = item:getUID(),
            callsign = title,
            lat = point:getLatitude(),
            lon = point:getLongitude(),
            type = itemType
        }

        if selfPoint then
            local dist = selfPoint:distanceTo(point)
            local brng = calc_bearing(selfLat, selfLon, point:getLatitude(), point:getLongitude())
            entry.distance_m = math.floor(dist * 10) / 10
            entry.bearing_deg = math.floor(brng * 10) / 10
            entry.bearing_dir = compass_dir(brng)
        end

        table.insert(hostiles, entry)
        ::continue::
    end

    -- Sort by distance ascending if self position available
    if selfPoint then
        table.sort(hostiles, function(a, b) return a.distance_m < b.distance_m end)
    else
        table.sort(hostiles, function(a, b) return a.callsign < b.callsign end)
    end

    -- Truncate
    local result = {}
    for i = 1, math.min(#hostiles, maxItems) do
        table.insert(result, hostiles[i])
    end

    return {
        count = #result,
        hostiles = result,
        self_position = selfPoint and { lat = selfLat, lon = selfLon } or nil
    }
end
