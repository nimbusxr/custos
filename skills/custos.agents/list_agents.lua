---@class AgentProfile
---@field name string exact agent name (case-sensitive, pass to delegate as-is)
---@field role string one-line description of what the agent IS
---@field goal string what the agent is TRYING to do
---@field backstory string why it behaves the way it does
---@field provider string provider key from custos.yaml

---@class ListAgentsResult
---@field agents AgentProfile[] configured specialist agents
---@field count integer number of agents available

--- List available specialist agents
-- @tool list_agents
-- @description List all configured specialist agents with their roles, goals, and capabilities
---@return ListAgentsResult
-- @impact READ_ONLY
function list_agents(params)
  local agents = delegation:listAgents()
  local results = {}
  local count = agents:size()
  for i = 0, count - 1 do
    local agent = agents:get(i)
    table.insert(results, {
      name = agent:get("name"),
      role = agent:get("role"),
      goal = agent:get("goal"),
      backstory = agent:get("backstory"),
      provider = agent:get("provider"),
    })
  end
  return { agents = results, count = #results }
end
