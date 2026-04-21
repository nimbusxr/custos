--- Get the geographic bounds of the current GRG grid
-- @tool grg_bounds
-- @description Get the geographic bounds of the current GRG grid on the map
-- @impact READ_ONLY
function grg_bounds()
  local GridLines = import("com.atakmap.android.gridlines.GridLinesMapComponent")
  local Array = import("java.lang.reflect.Array")

  local grid = GridLines:getCustomGrid()
  if not grid or not grid:isValid() then
    return { status = "error", message = "No GRG grid is currently placed on the map" }
  end

  local corners = grid:getCorners()
  if not corners or Array:getLength(corners) < 4 then
    return { status = "error", message = "GRG grid has no valid corners" }
  end

  -- corners: TL, TR, BL, BR
  local tl = Array:get(corners, 0)
  local tr = Array:get(corners, 1)
  local bl = Array:get(corners, 2)
  local br = Array:get(corners, 3)

  local north = math.max(tl:getLatitude(), tr:getLatitude())
  local south = math.min(bl:getLatitude(), br:getLatitude())
  local east = math.max(tr:getLongitude(), br:getLongitude())
  local west = math.min(tl:getLongitude(), bl:getLongitude())

  return {
    north = north,
    south = south,
    east = east,
    west = west,
    center = {
      lat = (north + south) / 2.0,
      lon = (east + west) / 2.0,
    },
  }
end
