-- create_skill_test.lua
-- Existence check: create_skill must be a callable function

assert(type(create_skill) == "function", "Expected create_skill to be function, got " .. type(create_skill))
console.log("[create_skill] function exists")
return "PASS (existence only)"
