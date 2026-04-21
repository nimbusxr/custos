--- Remove a fact from persistent tactical memory
-- @tool forget
-- @description Remove a stored fact from persistent memory. Use when information is outdated or the operator asks to forget something.
-- @tparam string category Fact category: position, threat, status, preference, sop, reference, or general
-- @tparam string key The identifier of the fact to remove
-- @impact INFORMATIONAL
function forget(params)
  memory:deleteFact(params.category, params.key)
  return { status = "deleted", category = params.category, key = params.key }
end
