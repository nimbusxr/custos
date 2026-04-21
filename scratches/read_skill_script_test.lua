-- read_skill_script_test.lua
-- Tests that read_skill_script() returns content for focus_map.lua

local result = read_skill_script({
  skill_id = "custos.map_nav",
  script_name = "focus_map.lua",
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
assert(type(result.content) == "string", "Expected content to be string, got " .. type(result.content))
assert(#result.content > 0, "Expected non-empty content")
console.log("[read_skill_script] script=" .. tostring(result.script_name) .. " length=" .. #result.content)
return "PASS"
