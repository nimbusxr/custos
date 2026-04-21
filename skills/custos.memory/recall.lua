--- Search persistent tactical memory for relevant facts
-- @tool recall
-- @description Search persistent memory by keyword. Returns matching facts across all categories.
-- @tparam string query Search keyword to match against stored fact keys and values
-- @tparam number limit Maximum number of results to return (default: 10)
-- @impact READ_ONLY
function recall(params)
  local limit = params.limit or 10
  local facts = memory:recallRelevant(params.query, limit)
  local results = {}
  for i = 0, facts:size() - 1 do
    local fact = facts:get(i)
    results[#results + 1] = {
      category = fact:getCategory(),
      key = fact:getKey(),
      value = fact:getValue(),
    }
  end
  return { facts = results, count = #results }
end
