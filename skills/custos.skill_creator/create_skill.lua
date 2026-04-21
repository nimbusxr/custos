--- Create a new skill directory with a SKILL.md file
-- @tool create_skill
-- @description Create a new skill directory with a SKILL.md file. Use this before writing scripts for a new skill.
-- @tparam string group Skill group (e.g., 'custos', 'custom')
-- @tparam string name Skill name (e.g., 'route_planner')
-- @tparam string description What the skill does
-- @impact SIGNIFICANT
function create_skill(params)
  local File = import("java.io.File")
  local FileWriter = import("java.io.FileWriter")
  local dirName = params.group .. "." .. params.name
  local dir = File("/sdcard/atak/custos/skills", dirName)
  if dir:exists() then
    return { status = "error", message = "Skill directory already exists: " .. dirName }
  end
  dir:mkdirs()

  local skillMd = File(dir, "SKILL.md")
  local content = "---\n"
    .. "group: "
    .. params.group
    .. "\n"
    .. "name: "
    .. params.name
    .. "\n"
    .. 'description: "'
    .. params.description
    .. '"\n'
    .. "scripts: []\n"
    .. "tags: []\n"
    .. "---\n\n"
    .. params.description
    .. "\n"
  local writer = FileWriter(skillMd)
  writer:write(content)
  writer:close()

  -- SkillFileWatcher auto-reloads on file change
  return { status = "created", skill_id = dirName }
end
