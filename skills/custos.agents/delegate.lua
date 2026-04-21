---@class DelegateResultShape
---@field status string SUCCESS | FAILURE | TIMEOUT (from DelegateStatus)
---@field agent string the agent name the task was routed to
---@field response string the sub-agent's final text response
---@field tokens_used integer total input + output tokens consumed
---@field tools_called string stringified list of tool names the sub-agent invoked
---@field duration_ms integer wall-clock ms spent inside the sub-agent loop

--- Delegate a task to a specialist agent
-- @tool delegate
-- @description Hand off a task to a named specialist agent. REQUIRED WORKFLOW: call list_agents() FIRST to enumerate the configured agents, then call delegate with the EXACT name string from that list. Do NOT guess or invent agent names (e.g. do not pass "author agent" — pass the literal name field). The sub-agent executes with its own persona and provider and returns its result.
-- @tparam string agent_name The exact `name` field of an agent returned by list_agents(). Case-sensitive, no added words.
-- @tparam string task Describe the GOAL in plain language — what the operator needs, not how to do it. Do NOT reference specific tool names (e.g. don't write "use the get_tactical_picture tool"). The sub-agent has its own tool list and will choose the correct tools; naming tools in the task causes it to chase hallucinated names. Good: "Log the current tactical picture every 30 seconds." Bad: "Call get_tactical_picture every 30 seconds."
---@return DelegateResultShape
-- @impact PROCEDURAL
function delegate(params)
  if not params.agent_name then
    return { status = "error", message = "agent_name is required" }
  end
  if not params.task then
    return { status = "error", message = "task is required" }
  end

  local result = delegation:delegate(params.agent_name, params.task)
  return {
    status = tostring(result:getStatus()),
    agent = params.agent_name,
    response = result:getResponse(),
    tokens_used = result:getTokenUsage():getTotalTokens(),
    tools_called = tostring(result:getToolsCalled()),
    duration_ms = result:getDurationMs(),
  }
end
