---@class NearbyReference
---@field lat number reference latitude used
---@field lon number reference longitude used

---@class NearbyItem
---@field uid string map item UID
---@field callsign string item title
---@field lat number item latitude
---@field lon number item longitude
---@field type string full CoT type
---@field distance_m number meters from reference point
---@field bearing_deg number degrees from reference point (0=N, clockwise)

---@class NearbyResult
---@field reference NearbyReference the reference point used for measurements
---@field radius_m number search radius in meters
---@field items NearbyItem[] sorted by distance ascending
---@field count integer number of items returned (may be truncated by max_items)

--- Find map items within a radius of a reference point
-- @tool find_nearby
-- @description Find map items within a specified radius, with distance and bearing from the reference point. Defaults to operator position if no lat/lon provided. On error (no GPS) returns { status="error", message=... } instead of NearbyResult.
-- @tparam number radius_m Search radius in meters (default: 5000)
-- @tparam number lat Reference latitude (defaults to self-marker position)
-- @tparam number lon Reference longitude (defaults to self-marker position)
-- @tparam string affiliation Filter: friendly, hostile, unknown, neutral, or all (default: all)
-- @tparam integer max_items Maximum items to return (default: 20)
---@return NearbyResult
-- @impact READ_ONLY
function find_nearby(params)
    local MapView = import("com.atakmap.android.maps.MapView")
    local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")

    local mapView = MapView:getMapView()
    local rootGroup = mapView:getRootGroup()
    local radius = params.radius_m or 5000
    local maxItems = params.max_items or 20
    local affFilter = params.affiliation or "all"

    local Math = import("java.lang.Math")
    local function calc_bearing(lat1, lon1, lat2, lon2)
        local rad = math.pi / 180
        local la1, la2 = lat1 * rad, lat2 * rad
        local dLon = (lon2 - lon1) * rad
        local y = math.sin(dLon) * math.cos(la2)
        local x = math.cos(la1) * math.sin(la2) - math.sin(la1) * math.cos(la2) * math.cos(dLon)
        return (Math:atan2(y, x) / rad + 360) % 360
    end

    -- Resolve reference point
    local refLat = params.lat
    local refLon = params.lon
    if not refLat or not refLon then
        local selfMarker = mapView:getSelfMarker()
        if not selfMarker then
            return { status = "error", message = "No reference point: provide lat/lon or wait for GPS fix" }
        end
        local sp = selfMarker:getPoint()
        refLat = sp:getLatitude()
        refLon = sp:getLongitude()
    end

    local refPoint = GeoPoint(refLat, refLon)

    -- Map affiliation filter to CoT prefix
    local affPrefix = nil
    if affFilter == "friendly" then affPrefix = "a-f"
    elseif affFilter == "hostile" then affPrefix = "a-h"
    elseif affFilter == "unknown" then affPrefix = "a-u"
    elseif affFilter == "neutral" then affPrefix = "a-n"
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

        -- Apply affiliation filter
        if affPrefix and itemType:find(affPrefix, 1, true) ~= 1 then
            goto continue
        end

        local dist = refPoint:distanceTo(point)
        if dist <= radius then
            local brng = calc_bearing(refLat, refLon, point:getLatitude(), point:getLongitude())
            table.insert(items, {
                uid = item:getUID(),
                callsign = title,
                lat = point:getLatitude(),
                lon = point:getLongitude(),
                type = itemType,
                distance_m = math.floor(dist * 10) / 10,
                bearing_deg = math.floor(brng * 10) / 10
            })
        end

        ::continue::
    end

    -- Sort by distance ascending
    table.sort(items, function(a, b) return a.distance_m < b.distance_m end)

    -- Truncate to max_items
    local result = {}
    for i = 1, math.min(#items, maxItems) do
        table.insert(result, items[i])
    end

    return {
        reference = { lat = refLat, lon = refLon },
        radius_m = radius,
        items = result,
        count = #result
    }
end
