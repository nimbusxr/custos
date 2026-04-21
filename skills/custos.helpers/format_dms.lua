--- Format coordinates as DMS string
-- @tool format_dms
-- @description Convert decimal degree coordinates to Degrees Minutes Seconds (DMS) format
-- @tparam number lat Latitude in decimal degrees
-- @tparam number lon Longitude in decimal degrees
-- @impact READ_ONLY
function format_dms(params)
  local function to_dms(deg, pos, neg)
    local d = math.abs(deg)
    local degrees = math.floor(d)
    local minutes = math.floor((d - degrees) * 60)
    local seconds = ((d - degrees) * 60 - minutes) * 60
    local dir = deg >= 0 and pos or neg
    return string.format("%d°%02d'%05.2f\"%s", degrees, minutes, seconds, dir)
  end
  return { dms = to_dms(params.lat, "N", "S") .. " " .. to_dms(params.lon, "E", "W") }
end
