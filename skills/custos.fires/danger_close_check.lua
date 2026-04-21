---@class DangerTarget
---@field lat number|nil target latitude (nil if not provided)
---@field lon number|nil target longitude (nil if not provided)

---@class FriendlyAtRisk
---@field uid string map item UID
---@field callsign string friendly unit callsign
---@field lat number friendly latitude
---@field lon number friendly longitude
---@field distance_m number meters from target impact point
---@field bearing_deg number degrees from target to friendly (0=N, clockwise)
---@field bearing_dir string 16-point compass direction
---@field type string CoT type (always a-f prefix)

---@class DangerCloseResult
---@field danger_close boolean true if any friendly is within radius
---@field self_in_danger boolean true if operator is within radius
---@field self_distance_m number|nil meters from operator to target, nil if no GPS
---@field target DangerTarget the target impact point
---@field radius_m number danger close radius used
---@field friendlies_at_risk FriendlyAtRisk[] sorted by distance ascending
---@field count integer number of friendlies at risk
---@field error string|nil present only when inputs invalid

--- Check for friendlies within danger close range of a target
-- @tool danger_close_check
-- @description Check if friendly markers are within danger close range of a target location. Returns all friendlies within the specified radius with their distance from the target.
-- @tparam number target_lat Target latitude
-- @tparam number target_lon Target longitude
-- @tparam number radius_m Danger close radius in meters (default 600m) (default: 600)
---@return DangerCloseResult
-- @impact READ_ONLY
function danger_close_check(params)
    local MapView = import("com.atakmap.android.maps.MapView")
    local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
    local Math = import("java.lang.Math")

    local targetLat = params.target_lat
    local targetLon = params.target_lon
    if not targetLat or not targetLon then
        return {
            danger_close = false,
            self_in_danger = false,
            target = { lat = targetLat, lon = targetLon },
            radius_m = params.radius_m or 600,
            friendlies_at_risk = {},
            count = 0,
            error = "target_lat and target_lon are required"
        }
    end
    local radius = params.radius_m or 600

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
    local targetPoint = GeoPoint(targetLat, targetLon)

    -- Also check self marker
    local selfMarker = mapView:getSelfMarker()
    local selfDist = nil
    if selfMarker then
        local sp = selfMarker:getPoint()
        selfDist = targetPoint:distanceTo(sp)
    end

    local friendlies = {}
    local allItems = rootGroup:getItemsRecursive()
    local iter = allItems:iterator()
    while iter:hasNext() do
        local item = iter:next()

        local itemType = item:getType() or ""
        -- Filter for friendly items (a-f prefix)
        if itemType:find("a-f", 1, true) ~= 1 then goto continue end

        local ok, title = pcall(function() return item:getTitle() end)
        if not ok or not title then goto continue end

        local ok2, point = pcall(function() return item:getPoint() end)
        if not ok2 or not point then goto continue end

        local dist = targetPoint:distanceTo(point)
        if dist <= radius then
            local brng = calc_bearing(targetLat, targetLon, point:getLatitude(), point:getLongitude())
            table.insert(friendlies, {
                uid = item:getUID(),
                callsign = title,
                lat = point:getLatitude(),
                lon = point:getLongitude(),
                distance_m = math.floor(dist * 10) / 10,
                bearing_deg = math.floor(brng * 10) / 10,
                bearing_dir = compass_dir(brng),
                type = itemType
            })
        end

        ::continue::
    end

    -- Sort by distance ascending (closest friendlies first = most at risk)
    table.sort(friendlies, function(a, b) return a.distance_m < b.distance_m end)

    local dangerClose = #friendlies > 0
    local selfInDanger = selfDist and selfDist <= radius

    return {
        danger_close = dangerClose,
        self_in_danger = selfInDanger,
        self_distance_m = selfDist and math.floor(selfDist * 10) / 10 or nil,
        target = { lat = targetLat, lon = targetLon },
        radius_m = radius,
        friendlies_at_risk = friendlies,
        count = #friendlies
    }
end
