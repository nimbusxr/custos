-- read_skill_test.lua
-- Tests that read_skill() returns metadata for custos.map_nav

local result = read_skill({ skill_id = "custos.map_nav" })
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
assert(result.skill_id == "custos.map_nav", "Expected skill_id=custos.map_nav, got " .. tostring(result.skill_id))
console.log("[read_skill] skill_id=" .. tostring(result.skill_id) .. " group=" .. tostring(result.group) .. " name=" .. tostring(result.name))
return "PASS"
