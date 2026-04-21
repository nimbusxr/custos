---@class AffiliationCounts
---@field friendly integer
---@field hostile integer
---@field unknown integer
---@field neutral integer
---@field other integer

---@class DimensionCounts
---@field ground integer
---@field air integer
---@field surface integer
---@field subsurface integer
---@field other integer

---@class NearestHostile
---@field callsign string
---@field distance_m number
---@field bearing_deg number

---@class TacticalSummary
---@field scope string "all" or "<N>m from self"
---@field total integer total items counted
---@field by_affiliation AffiliationCounts
---@field by_dimension DimensionCounts
---@field by_team table<string,integer> map of team color → count (includes "unassigned")
---@field nearest_hostile NearestHostile|nil nil if no hostiles visible

--- Get a statistical summary of all map items
-- @tool tactical_summary
-- @description Get counts of map items by affiliation, dimension, and team color without returning individual items. Includes nearest hostile distance. Optionally scope to a radius from operator position. On error (radius given without GPS) returns { status="error", message=... } instead of TacticalSummary.
-- @tparam number radius_m Radius in meters from self-position to limit scope (omit for all items)
---@return TacticalSummary
-- @impact READ_ONLY
function tactical_summary(params)
    local MapView = import("com.atakmap.android.maps.MapView")

    local mapView = MapView:getMapView()
    local rootGroup = mapView:getRootGroup()
    local radiusFilter = params.radius_m

    local function parse_cot_type(cot_type)
        local aff_map = { f = "friendly", h = "hostile", u = "unknown", n = "neutral" }
        local dim_map = { G = "ground", A = "air", S = "surface", U = "subsurface" }
        local parts = {}
        for part in cot_type:gmatch("[^-]+") do table.insert(parts, part) end
        return {
            affiliation = parts[2] and aff_map[parts[2]] or "other",
            dimension = parts[3] and dim_map[parts[3]] or "other"
        }
    end

    local Math = import("java.lang.Math")
    local function calc_bearing(lat1, lon1, lat2, lon2)
        local rad = math.pi / 180
        local la1, la2 = lat1 * rad, lat2 * rad
        local dLon = (lon2 - lon1) * rad
        local y = math.sin(dLon) * math.cos(la2)
        local x = math.cos(la1) * math.sin(la2) - math.sin(la1) * math.cos(la2) * math.cos(dLon)
        return (Math:atan2(y, x) / rad + 360) % 360
    end

    -- Get self-marker for radius filter and nearest-hostile
    local selfMarker = mapView:getSelfMarker()
    local selfPoint = nil
    if selfMarker then
        selfPoint = selfMarker:getPoint()
    end

    if radiusFilter and not selfPoint then
        return { status = "error", message = "Cannot scope by radius without GPS fix" }
    end

    local by_aff = { friendly = 0, hostile = 0, unknown = 0, neutral = 0, other = 0 }
    local by_dim = { ground = 0, air = 0, surface = 0, subsurface = 0, other = 0 }
    local by_team = {}
    local total = 0

    local nearestHostile = nil
    local nearestHostileDist = math.huge

    local allItems = rootGroup:getItemsRecursive()
    local iter = allItems:iterator()
    while iter:hasNext() do
        local item = iter:next()

        local ok, title = pcall(function() return item:getTitle() end)
        if not ok or not title then goto continue end

        local ok2, point = pcall(function() return item:getPoint() end)
        if not ok2 or not point then goto continue end

        -- Apply radius filter
        if radiusFilter and selfPoint then
            local dist = selfPoint:distanceTo(point)
            if dist > radiusFilter then goto continue end
        end

        local itemType = item:getType() or ""
        local parsed = parse_cot_type(itemType)

        total = total + 1
        by_aff[parsed.affiliation] = (by_aff[parsed.affiliation] or 0) + 1
        by_dim[parsed.dimension] = (by_dim[parsed.dimension] or 0) + 1

        -- Team color
        local ok_team, team = pcall(function() return item:getMetaString("team", nil) end)
        if ok_team and team then
            by_team[team] = (by_team[team] or 0) + 1
        else
            by_team["unassigned"] = (by_team["unassigned"] or 0) + 1
        end

        -- Track nearest hostile
        if selfPoint and itemType:find("a-h", 1, true) == 1 then
            local dist = selfPoint:distanceTo(point)
            if dist < nearestHostileDist then
                nearestHostileDist = dist
                local brng = calc_bearing(
                    selfPoint:getLatitude(), selfPoint:getLongitude(),
                    point:getLatitude(), point:getLongitude()
                )
                nearestHostile = {
                    callsign = title,
                    distance_m = math.floor(dist * 10) / 10,
                    bearing_deg = math.floor(brng * 10) / 10
                }
            end
        end

        ::continue::
    end

    return {
        scope = radiusFilter and (radiusFilter .. "m from self") or "all",
        total = total,
        by_affiliation = by_aff,
        by_dimension = by_dim,
        by_team = by_team,
        nearest_hostile = nearestHostile
    }
end
