-- import_file_test.lua
-- Tests that import_file function exists (cannot test without a real file)

assert(type(import_file) == "function", "Expected import_file to be a function, got " .. type(import_file))
console.log("[import_file] function exists and is callable")
return "PASS"
