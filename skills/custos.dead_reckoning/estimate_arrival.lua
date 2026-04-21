---@class ArrivalEstimate
---@field callsign string contact callsign
---@field distance_m integer meters from contact to destination
---@field speed_mps number contact speed in m/s
---@field speed_kph number contact speed in km/h
---@field bearing_to_dest_deg integer bearing from contact to destination (0=N)
---@field bearing_dir string 16-point compass direction
---@field eta_minutes number estimated minutes to arrival
---@field eta_display string human-readable "Xm Ys" string

--- Estimate when a moving contact will reach a destination
-- @tool estimate_arrival
-- @description Calculate estimated time of arrival for a moving contact to reach a target location based on current speed and heading. On error or stationary contact returns { status=..., callsign, message } instead of ArrivalEstimate.
-- @tparam string identifier Contact callsign or UID
-- @tparam number dest_lat Destination latitude
-- @tparam number dest_lon Destination longitude
---@return ArrivalEstimate
-- @impact READ_ONLY
function estimate_arrival(params)
  if not params.identifier or not params.dest_lat or not params.dest_lon then
    return { status = "error", message = "identifier, dest_lat, dest_lon required" }
  end

  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")

  local resolved = tools.call("resolve_item", { identifier = params.identifier })
  if resolved.status == "error" then
    return { status = "error", message = "Contact not found: " .. params.identifier }
  end
  local item = resolved.item

  local ok, pt = pcall(function()
    return item:getPoint()
  end)
  if not ok or not pt then
    return { status = "error", message = "Contact has no position" }
  end

  local speed = 0
  pcall(function()
    speed = item:getMetaDouble("Speed", 0)
  end)

  if speed <= 0 then
    return {
      status = "stationary",
      callsign = item:getTitle() or params.identifier,
      message = "Contact is stationary — cannot estimate arrival",
    }
  end

  local destPt = GeoPoint(params.dest_lat, params.dest_lon)
  local distanceM = pt:distanceTo(destPt, nil)
  local bearing = tools.call(
    "calc_bearing",
    { lat1 = pt:getLatitude(), lon1 = pt:getLongitude(), lat2 = params.dest_lat, lon2 = params.dest_lon }
  ).bearing_deg
  local etaSeconds = distanceM / speed
  local etaMinutes = etaSeconds / 60

  return {
    callsign = item:getTitle() or params.identifier,
    distance_m = math.floor(distanceM),
    speed_mps = math.floor(speed * 10) / 10,
    speed_kph = math.floor(speed * 3.6 * 10) / 10,
    bearing_to_dest_deg = math.floor(bearing),
    bearing_dir = tools.call("compass_dir", { deg = bearing }).direction,
    eta_minutes = math.floor(etaMinutes * 10) / 10,
    eta_display = string.format("%d min %d sec", math.floor(etaMinutes), math.floor(etaSeconds % 60)),
  }
end
