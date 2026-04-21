---@class MgrsCoord
---@field lat number decimal degrees
---@field lon number decimal degrees
---@field mgrs string MGRS grid string

---@class PredictedPosition
---@field callsign string contact callsign
---@field current MgrsCoord current position in DD + MGRS
---@field predicted MgrsCoord extrapolated position at +minutes_ahead
---@field speed_mps number contact speed in m/s
---@field speed_kph number contact speed in km/h
---@field heading_deg integer heading in degrees (0=N)
---@field heading_dir string 16-point compass direction
---@field minutes_ahead number minutes projected into the future
---@field distance_m integer meters traveled over the projection window

--- Predict where a moving contact will be at a future time
-- @tool predict_position
-- @description Estimate the future position of a moving contact based on current speed and heading using dead reckoning. On error or stationary contact returns { status=..., callsign, message, ... } instead of PredictedPosition.
-- @tparam string identifier Contact callsign or UID
-- @tparam number minutes_ahead Minutes into the future to predict
---@return PredictedPosition
-- @impact READ_ONLY
function predict_position(params)
  if not params.identifier or not params.minutes_ahead then
    return { status = "error", message = "identifier and minutes_ahead required" }
  end

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

  -- Get speed and heading from metadata
  local speed = 0
  local heading = 0
  pcall(function()
    speed = item:getMetaDouble("Speed", 0)
    heading = item:getMetaDouble("Course", 0)
  end)

  if speed <= 0 then
    return {
      status = "stationary",
      callsign = item:getTitle() or params.identifier,
      message = "Contact is stationary or has no speed data",
      current_lat = pt:getLatitude(),
      current_lon = pt:getLongitude(),
    }
  end

  -- Dead reckoning: project position along heading at speed for given time
  local distanceM = speed * params.minutes_ahead * 60 -- speed in m/s * seconds
  local rad = math.pi / 180
  local lat1 = pt:getLatitude() * rad
  local lon1 = pt:getLongitude() * rad
  local hdg = heading * rad
  local R = 6371000 -- Earth radius in meters

  local lat2 =
    math.asin(math.sin(lat1) * math.cos(distanceM / R) + math.cos(lat1) * math.sin(distanceM / R) * math.cos(hdg))
  local lon2 = lon1
    + import("java.lang.Math"):atan2(
      math.sin(hdg) * math.sin(distanceM / R) * math.cos(lat1),
      math.cos(distanceM / R) - math.sin(lat1) * math.sin(lat2)
    )

  local predLat = lat2 / rad
  local predLon = lon2 / rad

  return {
    callsign = item:getTitle() or params.identifier,
    current = {
      lat = pt:getLatitude(),
      lon = pt:getLongitude(),
      mgrs = tools.call("format_mgrs", { lat = pt:getLatitude(), lon = pt:getLongitude() }).mgrs,
    },
    predicted = {
      lat = math.floor(predLat * 1000000) / 1000000,
      lon = math.floor(predLon * 1000000) / 1000000,
      mgrs = tools.call("format_mgrs", { lat = predLat, lon = predLon }).mgrs,
    },
    speed_mps = math.floor(speed * 10) / 10,
    speed_kph = math.floor(speed * 3.6 * 10) / 10,
    heading_deg = math.floor(heading),
    heading_dir = tools.call("compass_dir", { deg = heading }).direction,
    minutes_ahead = params.minutes_ahead,
    distance_m = math.floor(distanceM),
  }
end
