--- Convert bearing degrees to compass direction
-- @tool compass_dir
-- @description Convert a bearing in degrees to a 16-point compass direction (N, NNE, NE, etc.)
-- @tparam number deg Bearing in degrees (0-360)
-- @impact READ_ONLY
function compass_dir(params)
  local deg = params.deg
  local dirs = { "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW" }
  return { direction = dirs[math.floor((deg + 11.25) / 22.5) % 16 + 1] }
end
