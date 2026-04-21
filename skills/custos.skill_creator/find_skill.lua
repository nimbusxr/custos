--- Find a skill by fuzzy name using semantic search
-- @tool find_skill
-- @description Find the closest matching skill ID and its scripts using semantic search. Use this when you don't know the exact skill ID or script filename.
-- @tparam string query Skill name, description, or partial ID to search for (e.g., "building detection", "detect_buildings", "markers")
-- @tparam integer top_k Number of results to return (default: 3)
-- @impact READ_ONLY
function find_skill(params)
  if not params.query then
    return { status = "error", message = "query is required" }
  end

  local File = import("java.io.File")
  local Array = import("java.lang.reflect.Array")
  local top_k = params.top_k or 3

  -- Semantic search via RAG (skills are embedded in the "skills" namespace)
  local results = {}
  local ok, err = pcall(function()
    local hits = rag:retrieve(params.query, top_k, "skills")
    local iter = hits:iterator()
    while iter:hasNext() do
      local hit = iter:next()
      local entry = hit:getEntry()
      local meta = entry:getMetadata()
      local skillId = tostring(meta:get("skill_id") or "")
      if skillId ~= "" then
        -- List the actual script files in this skill's directory
        local scripts = {}
        local skillDir = File("/sdcard/atak/custos/skills", skillId)
        if skillDir:exists() then
          local files = skillDir:listFiles()
          if files then
            for i = 0, Array:getLength(files) - 1 do
              local f = Array:get(files, i)
              local fname = f:getName()
              if fname:match("%.lua$") then
                table.insert(scripts, fname)
              end
            end
          end
          table.sort(scripts)
        end

        table.insert(results, {
          skill_id = skillId,
          description = entry:getText(),
          score = hit:getScore(),
          scripts = scripts,
        })
      end
    end
  end)

  if not ok then
    return { status = "error", message = "RAG search failed: " .. tostring(err) }
  end

  if #results == 0 then
    return { status = "no_match", query = params.query, message = "No matching skills found" }
  end

  return {
    status = "ok",
    query = params.query,
    results = results,
  }
end
