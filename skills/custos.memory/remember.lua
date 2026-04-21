--- Save a fact to persistent tactical memory
-- @tool remember
-- @description Save a fact to persistent memory that survives across conversations. Use when the operator says "remember" or shares important tactical information.
-- @tparam string category Fact category: position, threat, status, preference, sop, reference, or general
-- @tparam string key Short identifier for the fact (e.g., "alpha_team", "roe_active")
-- @tparam string value The information to remember
-- @impact INFORMATIONAL
function remember(params)
  memory:saveFact(params.category, params.key, params.value)
  return { status = "saved", category = params.category, key = params.key }
end
