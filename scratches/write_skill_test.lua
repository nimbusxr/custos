-- write_skill_test.lua
-- Existence check: write_skill must be a callable function

assert(type(write_skill) == "function", "Expected write_skill to be function, got " .. type(write_skill))
console.log("[write_skill] function exists")
return "PASS (existence only)"
