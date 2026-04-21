--- Read a Lua script file from a skill directory
-- @tool read_skill_script
-- @description Read the content of a .lua script file from a skill directory
-- @tparam string skill_id Skill ID (e.g., 'custos.markers')
-- @tparam string script_name Script filename (e.g., 'place_marker.lua')
-- @impact PROCEDURAL
function read_skill_script(params)
  local File = import("java.io.File")
  local Scanner = import("java.util.Scanner")

  local skillsDir = "/sdcard/atak/custos/skills"

  if not params.script_name:match("%.lua$") then
    return { status = "error", message = "script_name must end with .lua" }
  end

  local file = File(File(skillsDir, params.skill_id), params.script_name)
  if not file:exists() then
    return { status = "error", message = "Script not found: " .. params.skill_id .. "/" .. params.script_name }
  end

  local sc = Scanner(file):useDelimiter("\\A")
  local content = sc:hasNext() and sc:next() or ""
  sc:close()

  return {
    status = "success",
    skill_id = params.skill_id,
    script_name = params.script_name,
    content = content,
  }
end
