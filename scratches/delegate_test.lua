-- delegate_test.lua
-- Existence check: delegate must be a callable function

assert(type(delegate) == "function", "Expected delegate to be function, got " .. type(delegate))
console.log("[delegate] function exists")
return "PASS (existence only)"
