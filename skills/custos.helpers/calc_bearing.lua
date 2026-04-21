--- Calculate bearing between two geographic points
-- @tool calc_bearing
-- @description Calculate the bearing in degrees from one lat/lon to another
-- @tparam number lat1 Origin latitude
-- @tparam number lon1 Origin longitude
-- @tparam number lat2 Destination latitude
-- @tparam number lon2 Destination longitude
-- @impact READ_ONLY
function calc_bearing(params)
  local Math = import("java.lang.Math")
  local rad = math.pi / 180
  local la1, la2 = params.lat1 * rad, params.lat2 * rad
  local dLon = (params.lon2 - params.lon1) * rad
  local y = math.sin(dLon) * math.cos(la2)
  local x = math.cos(la1) * math.sin(la2) - math.sin(la1) * math.cos(la2) * math.cos(dLon)
  return { bearing_deg = (Math:atan2(y, x) / rad + 360) % 360 }
end
