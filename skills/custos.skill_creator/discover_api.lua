--- Introspect a Java class, ATAK API, or discover broadcast intents
-- @tool discover_api
-- @description Introspect a Java class by FQCN, list classes in a package with query="list:<package_prefix>", list broadcast intents with query="intents" or "intents:<filter>", or list plugins with query="plugins". Set depth > 0 to recursively explore return types.
-- @tparam string query Fully qualified class name, "list:<package_prefix>" to browse classes in a package, "intents" or "intents:<filter>" for broadcast intents, or "plugins" for loaded plugins
-- @tparam number depth Recursion depth for exploring return types (0 = no recursion) (default: 0)
-- @impact PROCEDURAL
function discover_api(params)
  local query = params.query
  local depth = params.depth or 0

  local Modifier = import("java.lang.reflect.Modifier")
  local Array = import("java.lang.reflect.Array")

  -- List all loaded plugins
  if query == "plugins" then
    local pluginList = plugin.list()
    table.sort(pluginList)
    return { plugins = pluginList, count = #pluginList }
  end

  -- List classes in a package from the pre-generated ATAK class index
  if query:find("^list:") then
    local prefix = query:sub(6)
    local File = import("java.io.File")
    local indexPath = "/sdcard/atak/custos/skills/custos.skill_creator/atak-class-index.txt"
    local indexFile = File(indexPath)
    if not indexFile:exists() then
      return {
        error = "Class index not found at " .. indexPath .. ". Run scripts/generate-class-index.sh to create it.",
      }
    end

    local Scanner = import("java.util.Scanner")
    local scanner = Scanner(indexFile)
    local results = {}
    while scanner:hasNextLine() do
      local line = scanner:nextLine()
      if line:find(prefix, 1, true) == 1 then
        table.insert(results, line)
      end
    end
    scanner:close()

    return { package = prefix, classes = results, count = #results }
  end

  -- List all registered broadcast intents (or filter by keyword)
  if query == "intents" or query:find("^intents:") then
    local filter = query:find("^intents:") and query:sub(9) or nil
    local AtakBroadcast = import("com.atakmap.android.ipc.AtakBroadcast")
    local broadcast = AtakBroadcast:getInstance()
    local filters = broadcast:getLocalDocumentedFilters()
    local results = {}
    local iter = filters:iterator()
    while iter:hasNext() do
      local intentFilter = iter:next()
      local actionIter = intentFilter:actionsIterator()
      while actionIter:hasNext() do
        local action = actionIter:next()
        if not filter or action:find(filter, 1, true) then
          local doc = intentFilter:getDocumentation(action)
          local entry = { action = action }
          if doc then
            entry.description = doc.description or ""
            local extras = doc.extras
            if extras and Array:getLength(extras) > 0 then
              entry.extras = {}
              for i = 0, Array:getLength(extras) - 1 do
                local extra = Array:get(extras, i)
                table.insert(entry.extras, {
                  name = extra.name,
                  description = extra.description or "",
                  optional = extra.optional,
                  type = extra.type and extra.type:getSimpleName() or "unknown",
                })
              end
            end
          end
          table.insert(results, entry)
        end
      end
    end
    table.sort(results, function(a, b)
      return a.action < b.action
    end)
    return { intents = results, count = #results }
  end

  local function introspect(className)
    local ok, result = pcall(function()
      local clazz = classForName(className)
      local methods = clazz:getMethods()
      local sigs = {}
      for i = 0, Array:getLength(methods) - 1 do
        local m = Array:get(methods, i)
        if not m:getName():find("access%$", 1, true) then
          local paramTypes = m:getParameterTypes()
          local paramStr = ""
          for j = 0, Array:getLength(paramTypes) - 1 do
            if j > 0 then
              paramStr = paramStr .. ", "
            end
            paramStr = paramStr .. Array:get(paramTypes, j):getSimpleName()
          end
          local prefix = Modifier:isStatic(m:getModifiers()) and "static " or ""
          table.insert(sigs, prefix .. m:getName() .. "(" .. paramStr .. "): " .. m:getReturnType():getSimpleName())
        end
      end
      -- Deduplicate
      local seen = {}
      local unique = {}
      for _, sig in ipairs(sigs) do
        if not seen[sig] then
          seen[sig] = true
          table.insert(unique, sig)
        end
      end
      table.sort(unique)
      return { ["class"] = className, methods = unique }
    end)
    if ok then
      return result
    end
    return { ["class"] = className, error = tostring(result) }
  end

  local result = introspect(query)

  if depth > 0 and result.methods then
    local related = {}
    local seenTypes = {}
    local primitives = {
      ["void"] = true,
      ["int"] = true,
      ["long"] = true,
      ["float"] = true,
      ["double"] = true,
      ["boolean"] = true,
      ["byte"] = true,
      ["char"] = true,
      ["short"] = true,
      ["String"] = true,
      ["Object"] = true,
      ["List"] = true,
      ["Map"] = true,
      ["Set"] = true,
    }
    local commonPackages = {
      "com.atakmap.android.maps.",
      "com.atakmap.coremap.",
      "com.atakmap.coremap.maps.coords.",
      "com.atakmap.android.cot.",
      "com.atakmap.android.ipc.",
      "com.atakmap.android.dropdown.",
      "",
    }

    for _, sig in ipairs(result.methods) do
      local returnType = sig:match("^[^(]+"):match("[^ ]+$")
      if returnType and not primitives[returnType] and not seenTypes[returnType] then
        seenTypes[returnType] = true
        for _, prefix in ipairs(commonPackages) do
          local fqcn = prefix .. returnType
          local ok2, sub = pcall(function()
            classForName(fqcn)
            return introspect(fqcn)
          end)
          if ok2 and sub and sub.methods and #sub.methods > 0 then
            related[returnType] = sub
            break
          end
        end
      end
    end

    local hasRelated = false
    for _ in pairs(related) do
      hasRelated = true
      break
    end
    if hasRelated then
      result.related = related
    end
  end

  return result
end
