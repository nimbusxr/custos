--- Parse CoT type strings into structured affiliation and dimension info
-- @tool parse_cot_type
-- @description Parse a CoT type string (e.g., a-f-G) into affiliation and dimension
-- @tparam string cot_type CoT type string
-- @impact READ_ONLY
function parse_cot_type(params)
  local cot_type = params.cot_type
  if not cot_type or cot_type == "" then
    return {}
  end
  local aff_map = { f = "friendly", h = "hostile", u = "unknown", n = "neutral" }
  local dim_map = { G = "ground", A = "air", S = "surface", U = "subsurface", P = "space", F = "SOF" }
  local parts = {}
  for part in cot_type:gmatch("[^-]+") do
    table.insert(parts, part)
  end
  return {
    affiliation = parts[2] and aff_map[parts[2]] or "other",
    dimension = parts[3] and dim_map[parts[3]] or "unknown",
    raw = cot_type,
  }
end
