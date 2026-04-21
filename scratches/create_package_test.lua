-- create_package_test.lua
-- Existence check: create_package must be a callable function

assert(type(create_package) == "function", "Expected create_package to be function, got " .. type(create_package))
console.log("[create_package] function exists")
return "PASS (existence only)"
