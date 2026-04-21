--- Decode a MIL-STD-2525 Symbol Identification Code
-- @tool decode_sidc
-- @description Decode a 15-character MIL-STD-2525B/C SIDC into human-readable fields: coding scheme, affiliation, battle dimension, status, function ID, and symbol modifier.
-- @tparam string sidc The SIDC string (15 characters for 2525B/C)
-- @impact READ_ONLY
function decode_sidc(params)
  local sidc = params.sidc
  if not sidc or sidc == "" then
    return { status = "error", message = "sidc is required" }
  end

  -- Pad to 15 if needed
  while #sidc < 15 do
    sidc = sidc .. "-"
  end

  -- Position 1: Coding Scheme
  local schemeMap = {
    S = "War Fighting",
    I = "Intelligence",
    O = "Stability Operations",
    E = "Emergency Management",
    W = "Weather",
    G = "Tactical Graphics",
  }
  local scheme = schemeMap[sidc:sub(1, 1)] or "Unknown (" .. sidc:sub(1, 1) .. ")"

  -- Position 2: Affiliation
  local affMap = {
    P = "Pending",
    U = "Unknown",
    A = "Assumed Friend",
    F = "Friend",
    N = "Neutral",
    S = "Suspect",
    H = "Hostile",
    G = "Exercise Pending",
    W = "Exercise Unknown",
    D = "Exercise Friend",
    L = "Exercise Neutral",
    M = "Exercise Assumed Friend",
    J = "Joker",
    K = "Faker",
    O = "None Specified",
  }
  local affiliation = affMap[sidc:sub(2, 2)] or "Unknown (" .. sidc:sub(2, 2) .. ")"

  -- Position 3: Battle Dimension
  local dimMap = {
    P = "Space",
    A = "Air",
    G = "Ground",
    S = "Sea Surface",
    U = "Subsurface",
    F = "SOF",
    X = "Other",
  }
  local dimension = dimMap[sidc:sub(3, 3)] or "Unknown (" .. sidc:sub(3, 3) .. ")"

  -- Position 4: Status
  local statusMap = {
    A = "Anticipated/Planned",
    P = "Present",
    C = "Present/Fully Capable",
    D = "Present/Damaged",
    X = "Present/Destroyed",
    F = "Present/Full to Capacity",
  }
  local status = statusMap[sidc:sub(4, 4)] or "Unknown (" .. sidc:sub(4, 4) .. ")"

  -- Positions 5-10: Function ID
  local functionId = sidc:sub(5, 10)

  -- Positions 11-12: Symbol Modifier
  local modifier1 = sidc:sub(11, 11)
  local modifier2 = sidc:sub(12, 12)

  -- Positions 13-14: Country Code
  local countryCode = sidc:sub(13, 14)

  -- Position 15: Order of Battle
  local obMap = {
    A = "Air OB",
    E = "Electronic OB",
    C = "Civilian OB",
    G = "Ground OB",
    N = "Maritime OB",
    S = "Strategic Force Related",
  }
  local orderOfBattle = obMap[sidc:sub(15, 15)] or sidc:sub(15, 15)

  return {
    sidc = sidc,
    coding_scheme = scheme,
    affiliation = affiliation,
    battle_dimension = dimension,
    status = status,
    function_id = functionId,
    modifier_1 = modifier1,
    modifier_2 = modifier2,
    country_code = countryCode,
    order_of_battle = orderOfBattle,
  }
end
