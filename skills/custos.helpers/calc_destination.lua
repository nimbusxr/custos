--- Project a destination point from a starting lat/lon along a bearing for a distance.
-- @tool calc_destination
-- @description Given a starting lat/lon, a bearing in degrees (0=north, 90=east, 180=south, 270=west), and a distance in meters, returns the destination lat/lon. Use for prompts like "100m north of my position" or "a waypoint 500m at bearing 270 from that contact". This is the inverse of calc_bearing.
-- @tparam number lat Starting latitude (decimal degrees)
-- @tparam number lon Starting longitude (decimal degrees)
-- @tparam number bearing_deg Bearing in degrees from true north (0–360)
-- @tparam number distance_m Distance in meters
-- @impact READ_ONLY
function calc_destination(params)
  if not params.lat or not params.lon then
    return { status = "error", message = "lat and lon are required" }
  end
  if not params.bearing_deg then
    return { status = "error", message = "bearing_deg is required (0=north, 90=east, 180=south, 270=west)" }
  end
  if not params.distance_m then
    return { status = "error", message = "distance_m is required" }
  end

  local rad = math.pi / 180
  local R = 6371000 -- Earth mean radius in meters

  -- LuaJ's math stdlib is missing asin/atan2; use java.lang.Math throughout
  -- for consistency (sin/cos work in LuaJ but we route them the same way).
  local M = import("java.lang.Math")

  local lat1 = params.lat * rad
  local lon1 = params.lon * rad
  local hdg = params.bearing_deg * rad
  local d = params.distance_m

  local sinLat1 = M:sin(lat1)
  local cosLat1 = M:cos(lat1)
  local sinDR = M:sin(d / R)
  local cosDR = M:cos(d / R)

  local lat2 = M:asin(sinLat1 * cosDR + cosLat1 * sinDR * M:cos(hdg))
  local lon2 = lon1 + M:atan2(M:sin(hdg) * sinDR * cosLat1, cosDR - sinLat1 * M:sin(lat2))

  local destLat = lat2 / rad
  local destLon = lon2 / rad

  -- round to 6 decimal places (~11cm precision, keeps response compact)
  destLat = math.floor(destLat * 1000000) / 1000000
  destLon = math.floor(destLon * 1000000) / 1000000

  return {
    lat = destLat,
    lon = destLon,
    bearing_deg = params.bearing_deg,
    distance_m = params.distance_m,
  }
end
