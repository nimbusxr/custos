---@class WriteAutomationResult
---@field status string "created" on success
---@field name string automation name written
---@field trigger string the trigger expression used
---@field ctx_param string name of the ctx parameter generated in run(ctx): "schedule" | "interval" | "event"
---@field file string absolute path of the written .lua file

--- Create a new automation .lua file with a trigger and a Lua run() function.
-- @tool write_automation
-- @description Creates an automation in /sdcard/atak/custos/automations/. Every automation fires a deterministic Lua function — NOT an LLM prompt. If reasoning is needed, the body must explicitly call tools.call("delegate", {agent_name=..., task=...}). The trigger type (schedule / interval / event) is auto-detected from the trigger expression shape. On error returns { status="error", error_type, message, unknown_tools? } instead of WriteAutomationResult.
-- @tparam string name Automation name (used as filename and @automation value)
-- @tparam string trigger Trigger expression: cron ("0 */6 * * *"), duration ("30m", "5s"), one-shot ("in 20m"), or broadcast action ("com.atakmap.android.maps.COT_RECD")
-- @tparam string body Lua code for the run() function body. This is the code executed when the trigger fires. Use tools.call(name, args) to invoke skills. For LLM reasoning, call tools.call("delegate", {agent_name=..., task=...}).
-- @tparam string description Human-readable description of what this automation does
-- @tparam string session Session type: "MAIN" (operator chat) or "ISOLATED" (background) (default: ISOLATED)
---@return WriteAutomationResult
-- @impact SIGNIFICANT
function write_automation(params)
  local File = import("java.io.File")
  local FileWriter = import("java.io.FileWriter")

  local automationsDir = "/sdcard/atak/custos/automations"

  if not params.name or params.name == "" then
    return { status = "error", message = "name is required" }
  end
  if not params.trigger or params.trigger == "" then
    return { status = "error", message = "trigger is required (cron / duration / broadcast action)" }
  end
  if not params.body or params.body == "" then
    return { status = "error", message = "body is required (Lua code for the run() function)" }
  end

  -- Auto-detect trigger type from expression shape and pick the matching
  -- ctx parameter name so the generated signature is self-documenting.
  local trigger = params.trigger
  local paramName
  if trigger:match("^%s*in%s+%d+%s*[smhdSMHD]%s*$") then
    paramName = "schedule" -- oneshot → schedule
  elseif trigger:match("^%d+%s*[smhdSMHD]$") or trigger:match("^%d+%s*(ms|sec|secs|min|mins|hour|hours|day|days)$") then
    paramName = "interval"
  elseif trigger:match("^[%a][%w_%.]*$") and trigger:find("%.") then
    -- Broadcast action: Java package-style identifier (e.g. com.atakmap.android.maps.COT_RECD).
    -- Starts with a letter (any case), contains at least one dot, no spaces.
    paramName = "event"
  elseif trigger:match("^[%d%*/%s%-,]+$") and trigger:find("%s") then
    paramName = "schedule"
  else
    return {
      status = "error",
      message = "cannot classify trigger '"
        .. trigger
        .. "'. Expected cron expression, duration like '30m', one-shot like 'in 20m', or broadcast action.",
    }
  end

  local session = params.session or "ISOLATED"
  local description = params.description or ""

  local lines = {}
  table.insert(lines, "--- " .. (description ~= "" and description or params.name))
  table.insert(lines, "-- @automation " .. params.name)
  table.insert(lines, "-- @trigger " .. params.trigger)
  if description ~= "" then
    table.insert(lines, "-- @description " .. description)
  end
  table.insert(lines, "-- @session " .. session)
  table.insert(lines, "")
  -- If the body already defines `function run(...)` (some LLMs include the
  -- wrapper even when instructed not to), use it verbatim. Otherwise wrap the
  -- body statements in `function run(<paramName>) ... end` ourselves.
  if params.body:match("function%s+run%s*%(") then
    for bodyLine in params.body:gmatch("[^\n]+") do
      table.insert(lines, bodyLine)
    end
  else
    table.insert(lines, "function run(" .. paramName .. ")")
    for bodyLine in params.body:gmatch("[^\n]+") do
      table.insert(lines, "    " .. bodyLine)
    end
    table.insert(lines, "end")
  end

  local content = table.concat(lines, "\n") .. "\n"

  -- Validate Lua syntax before writing
  local _, syntaxErr = load(content)
  if syntaxErr then
    return { status = "error", error_type = "syntax", message = syntaxErr }
  end

  -- Validate tool references: scan the body for tools.call("name", ...) patterns
  -- and reject if any name isn't a registered tool. Catches LLM hallucinations
  -- (e.g. "get_tactical_picture" when the real tool is "get_picture") before the
  -- automation ever fires, rather than 30 seconds later when it crashes at runtime.
  -- Pattern uses a regular double-quoted string (NOT a [[long bracket]]): the
  -- char class [\"'] followed by [\"'] contains ]] which would prematurely
  -- terminate a [[...]] long bracket and truncate the pattern. Learned the hard
  -- way — keep the escaped form here.
  local TOOLS_CALL_PATTERN = "tools%.call%s*%(%s*[\"']([^\"']+)[\"']"
  console.log("[write_automation] validating body, length=" .. #params.body)
  local unknownTools = {}
  local seenTools = {}
  local matchCount = 0
  for toolName in params.body:gmatch(TOOLS_CALL_PATTERN) do
    matchCount = matchCount + 1
    console.log("[write_automation] gmatch hit #" .. matchCount .. ": " .. toolName)
    if not seenTools[toolName] then
      seenTools[toolName] = true
      local existsFn = tools and tools.exists
      if type(existsFn) ~= "function" then
        console.warn("[write_automation] tools.exists is not a function (type=" .. type(existsFn) .. ")")
      else
        local exists = existsFn(toolName)
        console.log("[write_automation] tools.exists(" .. toolName .. ")=" .. tostring(exists))
        if not exists then
          table.insert(unknownTools, toolName)
        end
      end
    end
  end
  console.log("[write_automation] match_count=" .. matchCount .. " unknown_count=" .. #unknownTools)
  if #unknownTools > 0 then
    return {
      status = "error",
      error_type = "unknown_tool",
      message = "Automation body references tool(s) that don't exist: "
        .. table.concat(unknownTools, ", ")
        .. ". Tool names are NOT the same as skill IDs (e.g. skill 'custos.tactical_picture' exposes the tool 'get_picture', not 'get_tactical_picture'). "
        .. 'Call discover_api(query="<topic>") or inspect the available skills before writing the automation.',
      unknown_tools = unknownTools,
    }
  end

  local dir = File(automationsDir)
  if not dir:exists() then
    dir:mkdirs()
  end

  local fileName = params.name .. ".lua"
  local file = File(dir, fileName)
  local writer = FileWriter(file)
  writer:write(content)
  writer:close()

  return {
    status = "created",
    name = params.name,
    trigger = params.trigger,
    ctx_param = paramName,
    file = automationsDir .. "/" .. fileName,
  }
end
