-- write_skill_script_test.lua
-- Existence check: write_skill_script must be a callable function

assert(type(write_skill_script) == "function", "Expected write_skill_script to be function, got " .. type(write_skill_script))
console.log("[write_skill_script] function exists")
return "PASS (existence only)"
