---@class SitrepEntry
---@field callsign string contact callsign
---@field distance_m integer meters from operator
---@field bearing_dir string 16-point compass direction from operator
---@field mgrs string MGRS grid string of the contact

---@class Sitrep
---@field dtg string coordinated DTG string of the report
---@field own_position string MGRS grid string of the operator
---@field area_radius_m number AOI radius used (m)
---@field friendly_count integer friendlies within AOI
---@field hostile_count integer hostiles within AOI
---@field unknown_count integer unknowns within AOI
---@field friendly SitrepEntry[] sorted by distance ascending
---@field hostile SitrepEntry[] sorted by distance ascending
---@field unknown SitrepEntry[] sorted by distance ascending

--- Generate a situation report from the current tactical picture
-- @tool generate_sitrep
-- @description Gather current tactical data and compile a SITREP with friendly positions, hostile contacts, significant activity, and operational status. On error (no GPS) returns { status="error", message=... } instead of Sitrep.
-- @tparam number radius_m Area of interest radius from self position (default: 10000)
---@return Sitrep
-- @impact READ_ONLY
function generate_sitrep(params)
    local MapView = import("com.atakmap.android.maps.MapView")
    local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
    local CoordinatedTime = import("com.atakmap.coremap.maps.time.CoordinatedTime")

    local mapView = MapView:getMapView()
    local rootGroup = mapView:getRootGroup()
    local radius = params.radius_m or 10000

    -- Get self position
    local selfMarker = mapView:getSelfMarker()
    if not selfMarker then
        return { status = "error", message = "No self position — cannot generate SITREP" }
    end
    local selfPt = selfMarker:getPoint()
    local selfLat, selfLon = selfPt:getLatitude(), selfPt:getLongitude()
    local selfGeo = GeoPoint(selfLat, selfLon)
    local selfMgrs = tools.call("format_mgrs", {lat=selfLat, lon=selfLon}).mgrs

    -- Enumerate items in radius
    local friendly = {}
    local hostile = {}
    local unknown = {}
    local allItems = rootGroup:getItemsRecursive()
    local iter = allItems:iterator()
    while iter:hasNext() do
        local item = iter:next()
        local ok, pt = pcall(function() return item:getPoint() end)
        if not ok or not pt then goto continue end
        local dist = selfGeo:distanceTo(pt)
        if dist > radius then goto continue end

        local ok2, title = pcall(function() return item:getTitle() end)
        if not ok2 or not title then goto continue end

        local itemType = item:getType() or ""
        local info = tools.call("parse_cot_type", {cot_type=itemType})
        local bearing = tools.call("calc_bearing", {lat1=selfLat, lon1=selfLon, lat2=pt:getLatitude(), lon2=pt:getLongitude()}).bearing_deg

        local entry = {
            callsign = title,
            distance_m = math.floor(dist),
            bearing_dir = tools.call("compass_dir", {deg=bearing}).direction,
            mgrs = tools.call("format_mgrs", {lat=pt:getLatitude(), lon=pt:getLongitude()}).mgrs,
        }

        if info.affiliation == "friendly" then
            table.insert(friendly, entry)
        elseif info.affiliation == "hostile" then
            table.insert(hostile, entry)
        elseif info.affiliation == "unknown" then
            table.insert(unknown, entry)
        end

        ::continue::
    end

    -- Sort each by distance
    local function by_dist(a, b) return a.distance_m < b.distance_m end
    table.sort(friendly, by_dist)
    table.sort(hostile, by_dist)
    table.sort(unknown, by_dist)

    -- DTG
    local now = CoordinatedTime()
    local dtg = tostring(now)

    return {
        dtg = dtg,
        own_position = selfMgrs,
        area_radius_m = radius,
        friendly_count = #friendly,
        hostile_count = #hostile,
        unknown_count = #unknown,
        friendly = friendly,
        hostile = hostile,
        unknown = unknown,
    }
end
