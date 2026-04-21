---@class ItemPosition
---@field lat number latitude in decimal degrees
---@field lon number longitude in decimal degrees
---@field alt number altitude in meters HAE

---@class FromSelf
---@field distance_m number distance in meters from operator
---@field bearing_deg number bearing in degrees from operator (0=N, clockwise)

---@class ItemDetail
---@field uid string map item UID
---@field callsign string|nil item title (nil if untitled)
---@field type string full CoT type string (e.g. "a-f-G-U-C")
---@field affiliation string friendly|hostile|unknown|neutral|other (parsed from type)
---@field dimension string ground|air|surface|subsurface|other (parsed from type)
---@field position ItemPosition
---@field speed_mps number|nil speed metadata in m/s, nil if not set
---@field course_deg number|nil heading metadata in degrees, nil if not set
---@field team string|nil ATAK team color, nil if not set
---@field role string|nil ATAK role type, nil if not set
---@field remarks string|nil freeform remarks metadata, nil if not set
---@field how string|nil CoT how attribute, nil if not set
---@field ce number|nil circular error (m), nil if not set
---@field le number|nil linear error (m), nil if not set
---@field from_self FromSelf|nil distance+bearing from operator, nil if no self marker

--- Get detailed information about a specific map item
-- @tool get_item_detail
-- @description Get all available metadata for a map item by UID or callsign. Returns position, type, affiliation, speed, heading, team, remarks, and distance/bearing from operator. On error returns { status="error", message=... } instead of ItemDetail.
-- @tparam string identifier UID or callsign to look up (partial match supported)
---@return ItemDetail
-- @impact READ_ONLY
function get_item_detail(params)
  local MapView = import("com.atakmap.android.maps.MapView")

  local mapView = MapView:getMapView()
  local rootGroup = mapView:getRootGroup()
  local identifier = params.identifier

  local function resolve_item(id)
    local ok, found = pcall(function()
      return rootGroup:deepFindUID(id)
    end)
    if ok and found then
      return found
    end

    local query = id:lower()
    local allItems = rootGroup:getItemsRecursive()
    local iter = allItems:iterator()
    while iter:hasNext() do
      local candidate = iter:next()
      local s, title = pcall(function()
        return candidate:getTitle()
      end)
      if s and title and title:lower():find(query, 1, true) then
        return candidate
      end
    end
    return nil
  end

  local function parse_cot_type(cot_type)
    local aff_map = { f = "friendly", h = "hostile", u = "unknown", n = "neutral" }
    local dim_map = { G = "ground", A = "air", S = "surface", U = "subsurface" }
    local parts = {}
    for part in cot_type:gmatch("[^-]+") do
      table.insert(parts, part)
    end
    return {
      affiliation = parts[2] and aff_map[parts[2]] or "other",
      dimension = parts[3] and dim_map[parts[3]] or "other",
    }
  end

  local function meta_str(item, key)
    local ok, val = pcall(function()
      return item:getMetaString(key, nil)
    end)
    if ok and val then
      return tostring(val)
    end
    return nil
  end

  local function meta_dbl(item, key)
    local ok, val = pcall(function()
      return item:getMetaDouble(key, 0)
    end)
    if ok and val and val ~= 0 then
      return val
    end
    return nil
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

  local item = resolve_item(identifier)
  if not item then
    return { status = "error", message = "No item found matching '" .. identifier .. "'" }
  end

  local ok, point = pcall(function()
    return item:getPoint()
  end)
  if not ok or not point then
    return { status = "error", message = "Item found but has no position" }
  end

  local ok_title, title = pcall(function()
    return item:getTitle()
  end)
  local itemType = item:getType() or ""
  local parsed = parse_cot_type(itemType)

  local result = {
    uid = item:getUID(),
    callsign = ok_title and title or nil,
    type = itemType,
    affiliation = parsed.affiliation,
    dimension = parsed.dimension,
    position = {
      lat = point:getLatitude(),
      lon = point:getLongitude(),
      alt = point:getAltitude(),
    },
    speed_mps = meta_dbl(item, "Speed"),
    course_deg = meta_dbl(item, "Course"),
    team = meta_str(item, "team"),
    role = meta_str(item, "atakRoleType"),
    remarks = meta_str(item, "remarks"),
    how = meta_str(item, "how"),
    ce = meta_dbl(item, "ce"),
    le = meta_dbl(item, "le"),
  }

  local selfMarker = mapView:getSelfMarker()
  if selfMarker then
    local sp = selfMarker:getPoint()
    if sp then
      local dist = sp:distanceTo(point)
      local brng = calc_bearing(sp:getLatitude(), sp:getLongitude(), point:getLatitude(), point:getLongitude())
      result.from_self = {
        distance_m = math.floor(dist * 10) / 10,
        bearing_deg = math.floor(brng * 10) / 10,
      }
    end
  end

  return result
end
