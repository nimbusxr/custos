--- Parse hex color strings into Android ARGB integers
-- @tool parse_color
-- @description Parse a hex color string (#RRGGBB or #AARRGGBB) into an Android ARGB integer
-- @tparam string hex Hex color string
-- @tparam number default Default ARGB value if hex is nil or invalid
-- @impact READ_ONLY
function parse_color(params)
  local hex = params.hex
  local default = params.default
  if not hex then
    return { color = default }
  end
  local Color = import("android.graphics.Color")
  hex = hex:gsub("^#", "")
  if #hex == 6 then
    hex = "FF" .. hex
  end
  if #hex == 8 then
    local a = tonumber(hex:sub(1, 2), 16) or 255
    local r = tonumber(hex:sub(3, 4), 16) or 0
    local g = tonumber(hex:sub(5, 6), 16) or 0
    local b = tonumber(hex:sub(7, 8), 16) or 0
    return { color = Color:argb(a, r, g, b) }
  end
  return { color = default }
end
