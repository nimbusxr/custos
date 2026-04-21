--- Create or update a skill's SKILL.md metadata file
-- @tool write_skill
-- @description Write a skill's SKILL.md file with YAML frontmatter and optional template body. Triggers hot-reload.
-- @tparam string skill_id Skill ID (e.g., 'custos.markers')
-- @tparam string description Skill description
-- @tparam string scripts Comma-separated list of script paths (e.g., 'custos.markers/place_marker.lua,custos.markers/find_items.lua')
-- @tparam string tags Comma-separated list of tags (e.g., 'markers,map,navigation')
-- @tparam string template Markdown template body (instructions for the LLM when this skill is selected)
-- @impact SIGNIFICANT
function write_skill(params)
  local File = import("java.io.File")
  local FileWriter = import("java.io.FileWriter")

  local skillsDir = "/sdcard/atak/custos/skills"

  -- Derive group and name from skill_id
  local group, name = params.skill_id:match("^([^%.]+)%.(.+)$")
  if not group or not name then
    return { status = "error", message = "Invalid skill_id format. Expected 'group.name' (e.g., 'custos.markers')" }
  end

  -- Parse scripts list
  local scripts = {}
  if params.scripts and params.scripts ~= "" then
    for script in params.scripts:gmatch("[^,]+") do
      table.insert(scripts, script:match("^%s*(.-)%s*$"))
    end
  end

  -- Parse tags list
  local tags = {}
  if params.tags and params.tags ~= "" then
    for tag in params.tags:gmatch("[^,]+") do
      table.insert(tags, tag:match("^%s*(.-)%s*$"))
    end
  end

  -- Build SKILL.md content
  local lines = {}
  table.insert(lines, "---")
  table.insert(lines, "group: " .. group)
  table.insert(lines, "name: " .. name)
  table.insert(lines, 'description: "' .. (params.description or "") .. '"')

  if #scripts > 0 then
    table.insert(lines, "scripts:")
    for _, s in ipairs(scripts) do
      table.insert(lines, "  - " .. s)
    end
  else
    table.insert(lines, "scripts: []")
  end

  if #tags > 0 then
    table.insert(lines, "tags: [" .. table.concat(tags, ", ") .. "]")
  else
    table.insert(lines, "tags: []")
  end

  table.insert(lines, "---")

  if params.template and params.template ~= "" then
    table.insert(lines, "")
    table.insert(lines, params.template)
  end

  local content = table.concat(lines, "\n") .. "\n"

  -- Ensure skill directory exists
  local skillDir = File(skillsDir, params.skill_id)
  if not skillDir:exists() then
    skillDir:mkdirs()
  end

  -- Write SKILL.md
  local file = File(skillDir, "SKILL.md")
  local writer = FileWriter(file)
  writer:write(content)
  writer:close()

  -- SkillFileWatcher auto-reloads on file change

  return {
    status = "written",
    skill_id = params.skill_id,
    group = group,
    name = name,
    scripts = scripts,
    tags = tags,
  }
end
