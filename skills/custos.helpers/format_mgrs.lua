--- Format coordinates as MGRS string
-- @tool format_mgrs
-- @description Convert decimal degree coordinates to Military Grid Reference System (MGRS) format
-- @tparam number lat Latitude in decimal degrees
-- @tparam number lon Longitude in decimal degrees
-- @impact READ_ONLY
function format_mgrs(params)
  local MGRSPoint = import("com.atakmap.coremap.maps.coords.MGRSPoint")
  local mgrs = MGRSPoint(params.lat, params.lon)
  return { mgrs = mgrs:toString() }
end
