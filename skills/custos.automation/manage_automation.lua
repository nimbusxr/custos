---@class ManagedAutomation
---@field name string automation file name (without .lua)
---@field type string SCHEDULE | INTERVAL | EVENT
---@field condition string raw trigger expression
---@field session string MAIN | ISOLATED
---@field enabled boolean current enabled state
---@field lastStatus string|nil last run status, nil if never fired
---@field lastResult string|nil last run result preview (≤100 chars), nil if never fired

---@class ManageAutomationListResult
---@field automations ManagedAutomation[] all registered automations
---@field count integer total automation count

--- Manage automations: list, toggle, or delete
-- @tool manage_automation
-- @description List all automations, toggle enable/disable, or delete an automation by name. Return shape depends on action: action="list" returns ManageAutomationListResult; action="toggle" returns { status="success", name, enabled }; action="delete" returns { status="success"|"error", message }; on error returns { status="error", message }.
-- @tparam string action "list", "toggle", or "delete"
-- @tparam string name Automation name (required for toggle/delete)
-- @tparam boolean enabled Enable or disable (required for toggle)
---@return ManageAutomationListResult
-- @impact PROCEDURAL
function manage_automation(params)
  local action = params.action

  if action == "list" then
    local automations = scheduling:listAutomations()
    local results = {}
    local listSize = automations:size()
    for i = 0, listSize - 1 do
      local pair = automations:get(i)
      local def = pair:getFirst()
      local state = pair:getSecond()
      local entry = {
        name = def:getName(),
        type = def:getConditionType():name(),
        condition = def:getConditionExpr(),
        session = def:getSessionType():name(),
        enabled = state and state:getEnabled() or true,
      }
      if state then
        entry.lastStatus = state:getLastStatus()
        entry.lastResult = state:getLastResult() and state:getLastResult():sub(1, 100) or nil
      end
      table.insert(results, entry)
    end
    return { automations = results, count = #results }
  elseif action == "toggle" then
    if not params.name then
      return { status = "error", message = "name is required for toggle" }
    end
    local enabled = params.enabled
    if enabled == nil then
      enabled = true
    end
    scheduling:toggleAutomation(params.name, enabled)
    return { status = "success", name = params.name, enabled = enabled }
  elseif action == "delete" then
    if not params.name then
      return { status = "error", message = "name is required for delete" }
    end
    local deleted = scheduling:deleteAutomation(params.name)
    if deleted then
      return { status = "success", message = "Deleted automation: " .. params.name }
    else
      return { status = "error", message = "Automation not found: " .. params.name }
    end
  else
    return { status = "error", message = "Unknown action: " .. tostring(action) .. ". Use list, toggle, or delete." }
  end
end
