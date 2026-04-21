--- Read and parse a skill's SKILL.md metadata
-- @tool read_skill
-- @description Read a skill's SKILL.md file and return its parsed frontmatter (group, name, description, scripts, tags) and markdown template body
-- @tparam string skill_id Skill ID (e.g., 'custos.markers')
-- @impact PROCEDURAL
function read_skill(params)
  local File = import("java.io.File")
  local Scanner = import("java.util.Scanner")

  local skillsDir = "/sdcard/atak/custos/skills"
  local skillMdFile = File(File(skillsDir, params.skill_id), "SKILL.md")

  if not skillMdFile:exists() then
    return { status = "error", message = "SKILL.md not found for " .. params.skill_id }
  end

  local sc = Scanner(skillMdFile):useDelimiter("\\A")
  local content = sc:hasNext() and sc:next() or ""
  sc:close()

  -- Parse YAML frontmatter between --- delimiters
  local frontStart = content:find("---", 1, true)
  local frontEnd = content:find("---", frontStart + 3, true)

  if not frontStart or not frontEnd then
    return { status = "error", message = "Invalid SKILL.md: missing frontmatter delimiters" }
  end

  local yamlBlock = content:sub(frontStart + 4, frontEnd - 1)
  local template = content:sub(frontEnd + 4):match("^%s*(.-)%s*$") or ""

  -- Parse key fields from YAML
  local group = yamlBlock:match("group:%s*(.-)%s*\n") or ""
  local name = yamlBlock:match("name:%s*(.-)%s*\n") or ""
  local description = yamlBlock:match('description:%s*"?(.-)"?%s*\n') or ""

  -- Parse scripts list
  local scripts = {}
  local inScripts = false
  for line in yamlBlock:gmatch("[^\n]+") do
    if line:match("^scripts:") then
      inScripts = true
      -- Check for empty list: scripts: []
      if line:match("%[%]") then
        inScripts = false
      end
    elseif inScripts then
      local script = line:match("^%s*%-%s*(.+)")
      if script then
        table.insert(scripts, script)
      else
        inScripts = false
      end
    end
  end

  -- Parse tags list
  local tags = {}
  local tagsStr = yamlBlock:match("tags:%s*%[(.-)%]")
  if tagsStr then
    for tag in tagsStr:gmatch("[^,]+") do
      table.insert(tags, tag:match("^%s*(.-)%s*$"))
    end
  end

  return {
    status = "success",
    skill_id = params.skill_id,
    group = group,
    name = name,
    description = description,
    scripts = scripts,
    tags = tags,
    template = template,
  }
end
