---@class SelfPosition
---@field lat number
---@field lon number

---@class TacticalContact
---@field callsign string
---@field lat number
---@field lon number
---@field type string CoT type code (e.g. "a-f-G-U-C")

---@class TacticalPicture
---@field self_position SelfPosition|nil nil if no self marker is set
---@field friendly TacticalContact[]
---@field hostile TacticalContact[]
---@field unknown TacticalContact[] unknown-affiliation units
---@field points_of_interest TacticalContact[] non-unit map items
---@field total integer count across friendly + hostile + unknown + points_of_interest

--- Get a summary of the current tactical picture
-- @tool get_tactical_picture
-- @description Get a summary of the current tactical picture with nearby units and points of interest
-- @tparam integer max_items Maximum items to return (default: 20)
---@return TacticalPicture
-- @impact READ_ONLY
function get_tactical_picture(params)
    local MapView = import("com.atakmap.android.maps.MapView")

    local mapView = MapView:getMapView()
    local rootGroup = mapView:getRootGroup()
    local maxItems = params.max_items or 20

    local selfMarker = mapView:getSelfMarker()
    local selfLat = selfMarker and selfMarker:getPoint():getLatitude() or nil
    local selfLon = selfMarker and selfMarker:getPoint():getLongitude() or nil

    local friendly = {}
    local hostile = {}
    local unknown = {}
    local points = {}

    local allItems = rootGroup:getItemsRecursive()
    local iter = allItems:iterator()
    while iter:hasNext() do
        if #friendly + #hostile + #unknown + #points >= maxItems then break end

        local item = iter:next()
        local ok, title = pcall(function() return item:getTitle() end)
        if not ok or not title then goto continue end

        local ok2, point = pcall(function() return item:getPoint() end)
        if not ok2 or not point then goto continue end

        local itemType = item:getType() or ""

        local entry = {
            callsign = title,
            lat = point:getLatitude(),
            lon = point:getLongitude(),
            type = itemType
        }

        if itemType:find("a-f", 1, true) == 1 then
            table.insert(friendly, entry)
        elseif itemType:find("a-h", 1, true) == 1 then
            table.insert(hostile, entry)
        elseif itemType:find("a-u", 1, true) == 1 then
            table.insert(unknown, entry)
        else
            table.insert(points, entry)
        end

        ::continue::
    end

    return {
        self_position = selfLat and { lat = selfLat, lon = selfLon } or nil,
        friendly = friendly,
        hostile = hostile,
        unknown = unknown,
        points_of_interest = points,
        total = #friendly + #hostile + #unknown + #points
    }
end
