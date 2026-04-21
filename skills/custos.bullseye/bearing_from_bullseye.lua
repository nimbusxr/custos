---@class BullseyePoint
---@field label string resolved title or "coordinates"
---@field lat number latitude used
---@field lon number longitude used

---@class BullseyeBearing
---@field bullseye BullseyePoint reference point
---@field target BullseyePoint target point
---@field range_m number meters from bullseye to target
---@field bearing_deg number degrees bullseye→target (0=N, clockwise)
---@field bearing_dir string 16-point compass direction
---@field callout string "<bullseye-label> <bearing>/<range>" brevity string

--- Get range and bearing from a bullseye to a target
-- @tool bearing_from_bullseye
-- @description Compute range (meters) and bearing (degrees) from a bullseye reference point to a target. Both can be specified by name/UID or lat/lon coordinates. On error returns { status="error", message=... } instead of BullseyeBearing.
-- @tparam string bullseye_id Bullseye name or UID
-- @tparam number bullseye_lat Bullseye latitude (used if bullseye_id not provided)
-- @tparam number bullseye_lon Bullseye longitude (used if bullseye_id not provided)
-- @tparam string target_id Target name or UID
-- @tparam number target_lat Target latitude (used if target_id not provided)
-- @tparam number target_lon Target longitude (used if target_id not provided)
---@return BullseyeBearing
-- @impact READ_ONLY
function bearing_from_bullseye(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
  local Math = import("java.lang.Math")

  local function calc_bearing(lat1, lon1, lat2, lon2)
    local rad = math.pi / 180
    local la1, la2 = lat1 * rad, lat2 * rad
    local dLon = (lon2 - lon1) * rad
    local y = math.sin(dLon) * math.cos(la2)
    local x = math.cos(la1) * math.sin(la2) - math.sin(la1) * math.cos(la2) * math.cos(dLon)
    return (Math:atan2(y, x) / rad + 360) % 360
  end

  local function compass_dir(deg)
    local dirs = { "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW" }
    return dirs[math.floor((deg + 11.25) / 22.5) % 16 + 1]
  end

  local mapView = MapView:getMapView()
  local rootGroup = mapView:getRootGroup()

  local function resolve(id)
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
      local item = iter:next()
      local s, title = pcall(function()
        return item:getTitle()
      end)
      if s and title and title:lower():find(query, 1, true) then
        return item
      end
    end
    return nil
  end

  -- Resolve bullseye
  local bLat, bLon, bLabel
  if params.bullseye_id then
    local item = resolve(params.bullseye_id)
    if not item then
      return { status = "error", message = "Bullseye not found: " .. params.bullseye_id }
    end
    local ok, pt = pcall(function()
      return item:getPoint()
    end)
    if not ok or not pt then
      return { status = "error", message = "Bullseye has no position" }
    end
    local ok2, t = pcall(function()
      return item:getTitle()
    end)
    bLabel = ok2 and t or params.bullseye_id
    bLat = pt:getLatitude()
    bLon = pt:getLongitude()
  elseif params.bullseye_lat and params.bullseye_lon then
    bLat = params.bullseye_lat
    bLon = params.bullseye_lon
    bLabel = "coordinates"
  else
    return { status = "error", message = "Provide bullseye_id or bullseye_lat/bullseye_lon" }
  end

  -- Resolve target
  local tLat, tLon, tLabel
  if params.target_id then
    local item = resolve(params.target_id)
    if not item then
      return { status = "error", message = "Target not found: " .. params.target_id }
    end
    local ok, pt = pcall(function()
      return item:getPoint()
    end)
    if not ok or not pt then
      return { status = "error", message = "Target has no position" }
    end
    local ok2, t = pcall(function()
      return item:getTitle()
    end)
    tLabel = ok2 and t or params.target_id
    tLat = pt:getLatitude()
    tLon = pt:getLongitude()
  elseif params.target_lat and params.target_lon then
    tLat = params.target_lat
    tLon = params.target_lon
    tLabel = "coordinates"
  else
    return { status = "error", message = "Provide target_id or target_lat/target_lon" }
  end

  local bPoint = GeoPoint(bLat, bLon)
  local tPoint = GeoPoint(tLat, tLon)
  local dist = bPoint:distanceTo(tPoint)
  local brng = calc_bearing(bLat, bLon, tLat, tLon)

  return {
    bullseye = { label = bLabel, lat = bLat, lon = bLon },
    target = { label = tLabel, lat = tLat, lon = tLon },
    range_m = math.floor(dist * 10) / 10,
    bearing_deg = math.floor(brng * 10) / 10,
    bearing_dir = compass_dir(brng),
    callout = string.format("%s %03d/%d", bLabel, math.floor(brng), math.floor(dist)),
  }
end
