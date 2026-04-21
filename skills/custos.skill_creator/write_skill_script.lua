--- Write a Lua script to a skill directory with validation and hot-reload
-- @tool write_skill_script
-- @description Write a .lua script file to a skill directory. Validates syntax, class resolution, and method calls. Auto-updates SKILL.md scripts list. Returns API surface for imported classes.
-- @tparam string skill_id Skill ID (e.g., 'custos.markers')
-- @tparam string script_name Script filename (e.g., 'place_marker.lua')
-- @tparam string content Full Lua script content
-- @impact SIGNIFICANT
function write_skill_script(params)
  local File = import("java.io.File")
  local FileWriter = import("java.io.FileWriter")
  local Scanner = import("java.util.Scanner")
  local Modifier = import("java.lang.reflect.Modifier")
  local Array = import("java.lang.reflect.Array")

  local skillsDir = "/sdcard/atak/custos/skills"

  -- Validate script_name
  if not params.script_name:match("%.lua$") then
    return { status = "error", message = "script_name must end with .lua" }
  end

  -- Syntax check BEFORE writing
  local fn, syntaxErr = load(params.content)
  if syntaxErr then
    return { status = "error", error_type = "syntax", message = syntaxErr }
  end

  -- Write the file
  local skillDir = File(skillsDir, params.skill_id)
  if not skillDir:exists() then
    return { status = "error", message = "Skill directory not found: " .. params.skill_id }
  end

  local file = File(skillDir, params.script_name)
  local writer = FileWriter(file)
  writer:write(params.content)
  writer:close()

  -- Auto-update SKILL.md scripts list
  local skillMdUpdated = false
  local scriptPath = params.skill_id .. "/" .. params.script_name
  local skillMdFile = File(skillDir, "SKILL.md")
  if skillMdFile:exists() then
    local sc = Scanner(skillMdFile):useDelimiter("\\A")
    local mdContent = sc:hasNext() and sc:next() or ""
    sc:close()

    if not mdContent:find(params.script_name, 1, true) and not mdContent:find(scriptPath, 1, true) then
      local lines = {}
      for line in mdContent:gmatch("[^\n]+") do
        table.insert(lines, line)
      end
      local newLines = {}
      local inserted = false
      for li = 1, #lines do
        local line = lines[li]
        table.insert(newLines, line)
        if not inserted and line:find("scripts:", 1, true) then
          if line:find("[]", 1, true) then
            newLines[#newLines] = "scripts:"
            table.insert(newLines, "  - " .. scriptPath)
          else
            local insertAt = li + 1
            while insertAt <= #lines and lines[insertAt]:find("^  %- ") do
              table.insert(newLines, lines[insertAt])
              insertAt = insertAt + 1
              li = li + 1
            end
            table.insert(newLines, "  - " .. scriptPath)
          end
          inserted = true
        end
      end
      if inserted then
        local mdWriter = FileWriter(skillMdFile)
        mdWriter:write(table.concat(newLines, "\n"))
        mdWriter:close()
        skillMdUpdated = true
      end
    end
  end

  -- SkillFileWatcher auto-reloads on file change — no manual reload needed

  -- Extract import("...") class names
  local classNames = {}
  for className in params.content:gmatch('import%s*%(%s*"([^"]+)"%s*%)') do
    table.insert(classNames, className)
  end

  -- Introspect each class — skip boring java.* classes
  local apiSurface = {}
  for _, className in ipairs(classNames) do
    if
      not className:find("^java%.io%.")
      and not className:find("^java%.util%.")
      and not className:find("^java%.lang%.")
      and not className:find("^java%.nio%.")
    then
      local ok, result = pcall(function()
        local clazz = classForName(className)
        local methods = clazz:getMethods()
        local sigs = {}
        local seen = {}
        for i = 0, Array:getLength(methods) - 1 do
          local m = Array:get(methods, i)
          local name = m:getName()
          if
            name:find("access%$", 1, true) == nil
            and name ~= "wait"
            and name ~= "notify"
            and name ~= "notifyAll"
            and name ~= "getClass"
            and name ~= "hashCode"
            and name ~= "equals"
            and name ~= "toString"
          then
            local paramTypes = m:getParameterTypes()
            local paramStr = ""
            for j = 0, Array:getLength(paramTypes) - 1 do
              if j > 0 then
                paramStr = paramStr .. ", "
              end
              paramStr = paramStr .. Array:get(paramTypes, j):getSimpleName()
            end
            local prefix = Modifier:isStatic(m:getModifiers()) and "static " or ""
            local sig = prefix .. name .. "(" .. paramStr .. "): " .. m:getReturnType():getSimpleName()
            if not seen[sig] then
              seen[sig] = true
              table.insert(sigs, sig)
            end
          end
        end
        table.sort(sigs)
        return sigs
      end)
      if ok then
        apiSurface[className] = result
      else
        apiSurface[className] = "Class not found: " .. tostring(result)
      end
    end
  end

  -- Fail fast if any classes couldn't be resolved
  local classErrors = {}
  for _, className in ipairs(classNames) do
    if type(apiSurface[className]) == "string" then
      table.insert(classErrors, className .. ": " .. apiSurface[className])
    end
  end
  if #classErrors > 0 then
    return {
      status = "error",
      error_type = "class_not_found",
      message = "Classes not found: " .. table.concat(classErrors, "; "),
      api_surface = apiSurface,
    }
  end

  -- Validate method calls against api_surface
  local warnings = {}
  for _, cn in ipairs(classNames) do
    if type(apiSurface[cn]) == "table" and #apiSurface[cn] > 0 then
      local varName = params.content:match('local%s+(%w+)%s*=%s*import%s*%(%s*"' .. cn:gsub("%.", "%%.") .. '"%s*%)')
      if varName then
        local methodNames = {}
        for _, sig in ipairs(apiSurface[cn]) do
          local mName = sig:gsub("^static ", ""):match("^([^(]+)")
          methodNames[mName] = true
        end
        for calledMethod in params.content:gmatch(varName .. "[:%.](%w+)%s*%(") do
          if not methodNames[calledMethod] then
            table.insert(warnings, cn .. " has no method '" .. calledMethod .. "'")
          end
        end
      end
    end
  end

  -- Fail fast if any method calls don't match
  if #warnings > 0 then
    return {
      status = "error",
      error_type = "invalid_methods",
      message = table.concat(warnings, "; "),
      api_surface = apiSurface,
    }
  end

  local result = {
    status = "written_and_reloaded",
    skill_id = params.skill_id,
    script_name = params.script_name,
  }
  if skillMdUpdated then
    result.skill_md_updated = true
  end
  local hasApiSurface = false
  for _ in pairs(apiSurface) do
    hasApiSurface = true
    break
  end
  if hasApiSurface then
    result.api_surface = apiSurface
  end
  return result
end
